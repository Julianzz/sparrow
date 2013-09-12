
###
  preload some data 
###

PreloadStore =
  data: {}
  
  #Store an object in the store
  store: (key, value)->
    @data[key] = value

  ###
    To retrieve a key, you provide the key you want, plus a finder to load
    it if the key cannot be found. Once the key is used once, it is removed
    from the store.
    So, for example, you can't load a preloaded topic more than once.
  ###
  
  getAndRemove: (key, finder)->
    
    if @data[key] 
      promise = Ember.RSVP.resolve(@data[key])
      delete @data[key]
      return promise
      

    if finder 
      return Ember.Deferred.promise( 
        (promise) ->
          result = finder()

          # If the finder returns a promise, we support that too
          if result.then 
            result.then(
              (result) ->
                return promise.resolve(result)
              (result) ->
                return promise.reject(result)
            )
          else 
            promise.resolve(result)
        )

    return Ember.RSVP.resolve(null)

  #return stored data
  get: (key) ->
    return @data[key]
    
  #remove store value
  remove: (key) ->
    delete @data[key] if @data[key] 

