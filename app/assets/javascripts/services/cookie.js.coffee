#= require ../vendor/jquery.cookie
#= require ../services/url

module = angular.module("plunker.cookie", [])

module.factory "cookie", [ () ->
  return {
    sessionId: $.cookie("plnk_session")
  }
]
  