
module = angular.module("plunker.buffers", [])

###
Class representing an active file in the editor
###

class Buffer
    
  constructor: (attributes = {}) ->
    angular.copy(attributes, @)
    
    @content ||= ""
    @filename ||= @nextID()
    @path ||= ""
    
    @old_filename = @filename if @filename
    
  nextID: do ->
    counter = 1
    -> "Untitled#{counter++}"
      
  getDelta: (file) ->
    delta = {}
    delta.filename = @filename unless file.filename is @filename
    delta.content = @content unless file.content is @content
    
    return delta if delta.filename? or delta.content?

module.factory "buffers", [ () ->

  class Buffers
    constructor: ->
      @queue = []
    
    at: (idx = 0) -> @queue[idx]
    active: -> @at(0)
    
    activate: (active) ->
      # Take it out and put it in the front
      @remove(active)
      @queue.unshift(active)
      @
    
    findBy: (key, value) ->
      return object for object in @queue when object[key] == value
    
    add: (add) ->
      @queue.push(new Buffer(add))
      @
    
    remove: (remove) ->
      if (idx = @queue.indexOf(remove)) >= 0
        @queue.splice(idx, 1)
      @
      
    reset: (queue = []) ->
      @queue.length = 0
      @add(item) for item in queue
      @
  
  return {
    "buffers": new Buffers
    "Buffers": Buffers
  }
]