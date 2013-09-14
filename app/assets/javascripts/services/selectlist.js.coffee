module = angular.module("plunker.selectlist", [])
module.directive "selectList", ->
  restrict: "A"
  require: "ngModel"
  priority: 99
  link: ($scope, element, args, ngModel) ->
    ngModel.$parsers.push (options = []) ->
      tags = []
      tags.push(option.text) for option in options
      tags
