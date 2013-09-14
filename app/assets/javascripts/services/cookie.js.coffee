#= require ../vendor/jquery.cookie
#= require ../services/url

module = angular.module("plunker.cookie", [])

module.factory "cookie", [ () ->
  return {
    sessionId: $.cookie("plnk_session")
    addSessionID: (id ,attrs )->
      attrs ||= {
        expires: 14 # 14 days from now
        path: "/"
      }
      $.cookie "plnk_session", id , attrs
  }
]
  