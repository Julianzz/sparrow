###
Service representing the transient state of the editor
###

#module = angular.module("plunker.scratch", ["plunker.plunks", "plunker.importer", "plunker.notifier"])
module = angular.module("plunker.scratch", ["plunker.plunks", "plunker.notifier", "plunker.socket","plunker.buffers"])

#module.factory "scratch", ["$location", "$q", "Plunk", "importer", "session", "notifier", ($location, $q, Plunk, importer, session, notifier) ->
module.factory "scratch", ["$location", "$q", "Plunk", "session", "notifier","socket","buffers", ($location, $q, Plunk, session, notifier,socket,buffers ) ->
  
  new class Scratch
    @defaultIndex: """"""
    @emptyPlunk:
      description: ""
      files: { 
        "index.html": { 
          filename: "index.html", 
          content: @defaultIndex
        } 
      }
      
      'private': true
      
    constructor: ->
      @description = ""
      @tags = []
      console.log buffers
      
      @buffers = new buffers.Buffers
      @plunk = new Plunk()
      
      @reset()
      
      @loading = false
      @locked = false
    
    reset: (json = Scratch.emptyPlunk, options = {}) ->
      # We introduce a locking concept for the scratch to prevent unwanted operations
      # from destroying a stream.
      if @locked and options.ignoreLock isnt true
        notifier.warning "The active session was not reset: '#{@locked}'"
        return
      
      # This is an ugly hack because $location changes triggered by resetting the path to "/"
      # will only trigger on the next tick. As a result a @loadJson would otherwise fail to
      # load the desired json.
      if @skipNext
        @skipNext = false
        return
      
      json.private = (!!json.private and json.private != "false") # This may arrive as "true" instead of true
      
      @plunk.reset(angular.copy(json))

      # Save a copy of the loaded json if the plunk belongs to this session
      # There is no need for a saved state if the active user is not the owner
      saved = @isSaved()
      owned = @isOwned()

      if saved and owned
        @savedState ||= {}
        angular.copy(json, @savedState)
      else delete @savedState
      
      @buffers.reset(file for filename, file of json.files)
      @buffers.activate(index) if index = @buffers.findBy("filename", "index.html")
      
      @skipNext = !!options.skipNext
      
      @
    
    lock: (reason) -> @locked = reason or "Unknown"
    unlock: -> @locked = false
      
    _doAsync: (fn) =>
      self = @
      self.loading = true

      deferred = $q.defer()
      deferred.promise.then ->
        self.loading = false
      , ->
        self.loading = false
        
      fn.call(@, deferred)
      deferred.promise
    
    _getDeltaJSON: (savedState) ->
      json =
        description: @plunk.description or ""
        files: {}
      
      delete json.description if angular.equals(@plunk.description, savedState.description)
      
      # Just in case the old schema was still used
      @savedState.tags ||= []
      
      json.tags = {}
      
      # Add *new* tags
      for tagname in @plunk.tags
        json.tags[tagname] = true unless savedState.tags.indexOf(tagname) >= 0
      
      # Remove *old* tags no longer present
      for tagname in savedState.tags
        json.tags[tagname] = null unless @plunk.tags.indexOf(tagname) >= 0
      
      # Look for files that no longer exist and mark them for deletion
      for filename, file of savedState.files
        json.files[filename] = null unless @buffers.findBy("filename", filename)
    
      # Look at existing files and add deltas
      for buffer in @buffers.queue
        key = buffer.old_filename or buffer.filename
        
        if old = savedState.files[key]
          # Existing file; check delta
          json.files[key] = delta if delta = buffer.getDelta(old)
        else
          # New file
          json.files[key] = content: buffer.content
          
      tags = false
      for tagname, add of json.tags
        tags = true
        break
      
      delete json.tags unless tags
      
      files = false
      for filename, file of json.files
        files = true
        break
      
      delete json.files unless files
      
      json
        

    _getSaveJSON: ->
      json =
        description: @plunk.description
        files: {}
      for buffer in @buffers.queue
        json.files[buffer.filename] =
          filename: buffer.filename
          content: buffer.content
      
      json.tags = @plunk.tags
      json.private = !!@plunk.private
      
      json

    toJSON: -> @_getSaveJSON()
    
    save: -> @_doAsync (deferred) ->
      self = @
      
      @plunk.description ||= "Untitled"
      
      json = if @savedState then @_getDeltaJSON(@savedState) else @_getSaveJSON()
      
      count = 0
      count++ for filename, file of json.files
      
      if count or json.description or json.tags
        old_id = @plunk.id
        
        @plunk.save json, (plunk) ->
          angular.copy(plunk, self.savedState ||= {})
          buffer.old_filename = buffer.filename for buffer in self.buffers.queue
          
          $location.path("/#{plunk.id}")
          $location.replace() unless old_id and old_id != plunk.id
          
          deferred.resolve(arguments...)
          
          notifier.success "Save succeeded"
        , ->
          deferred.reject(arguments...)
          
          notifier.error
            title: "Save failed"
            text: "error"#arguments.join(", ")
      else
        console.warn "Save cancelled: No changes to save"
        deferred.reject("Save cancelled: No changes to save")
          
        notifier.warning
          title: "Save cancelled"
          text: "No changes made to the plunk."

    fork: (options = {}) -> @_doAsync (deferred) ->
      self = @
      
      @plunk.description ||= "Untitled"
      
      json = @_getSaveJSON()
      json.private = options.private if options.private?
      
      count = 0
      count++ for filename, file of json.files
      
      if count or json.description or json.tags
        old_id = @plunk.id
        
        @plunk.fork json, (plunk) ->
          angular.copy(plunk, self.savedState ||= {})
          buffer.old_filename = buffer.filename for buffer in self.buffers.queue
          
          $location.path("/#{plunk.id}")
          $location.replace() unless old_id and old_id != plunk.id
          
          deferred.resolve(arguments...)
          
          notifier.success "Fork succeeded"
        , ->
          deferred.reject(arguments...)
          
          notifier.error
            title: "Fork failed"
            text: arguments.join(", ")
      else
        deferred.reject("Fork cancelled: No changes to save")
          
        notifier.warning
          title: "Fork cancelled"
          text: "No changes made to the plunk."

    loadFrom: (source) -> @_doAsync (deferred) ->
      self = @
				       
    destroy: -> @_doAsync (deferred) ->
      if @isSaved() and @isOwned()
        @plunk.destroy ->
          @savedState = null
          
          deferred.resolve(arguments...)
          $location.path("/")
          
          notifier.success "Plunk deleted"
        , ->
          deferred.reject(arguments...)
          
          notifier.error
            title: "Delete failed"
            text: "Unable to delete the plunk."
    
    loadJson: (json = {}, options = {}) ->
      $location.path("/")
      @reset(json, options)
      @

    addFile: (filename, content = "") ->
      if @buffers.findBy("filename", filename)
        notifier.warning("File already exists: #{filename}")
        return @
      
      @buffers.add
        filename: filename
        content: content
      
      @

    removeFile: (filename) ->
      unless buffer = @buffers.findBy("filename", filename)
        notifier.warning("Attempt to remove a non-existing file: '#{filename}'")
        return @
      
      @buffers.remove(buffer)
      
      @
    
    renameFile: (filename, new_filename) ->
      unless buffer = @buffers.findBy("filename", filename)
        notifier.warning("Attempt to rename a non-existing file: '#{filename}'")
        return @
      
      buffer.filename = new_filename
      
      @

    getFile: (filename) -> @buffers.findBy("filename", filename)

    isOwned: -> not @isSaved() or !!@plunk.token
    isSaved: -> !!@plunk.id
    isImported: -> !!@plunk.source
    
    promptDestroy: ->
      @destroy() if confirm("Are you sure that you would like to destroy this plunk?")
    
    promptFileAdd: (new_filename) ->
      if new_filename ||= prompt("Please enter the name for the new file:")
        if @getFile(new_filename) then alert("A file already exists called: '#{new_filename}'")
        else @addFile(new_filename)
    
    promptFileRemove: (filename) ->
      if @getFile(filename) and confirm("Are you sure that you would like to remove the file '#{filename}'?")
        @removeFile(filename)
        @addFile("index.html") unless @buffers.queue.length > 0
    
    promptFileRename: (filename, new_filename) ->
      if @getFile(filename) and (new_filename ||= prompt("Please enter the name for new name for the file:"))
        if @getFile(new_filename) then alert("A file already exists called '#{new_filename}'")
        else @renameFile(filename, new_filename)

]