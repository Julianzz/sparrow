module = angular.module "plunker.socket", ["plunker.url"] 

module.factory "socket", [ "url", ( url ) ->
  new class Comm
    constructor: ->
      #@io = io.connect url.socket
      #@io.emit 'ready' 
      #@io.on 'talk', (data)->
      #    alert data.message 
    on: (messge,callback) ->
      @io.on message,(data)->
        callback(data)
]
