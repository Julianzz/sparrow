module = angular.module("plunker.controller.status", [ 
  "plunker.scratch"
])

module.controller "EditorController", [ "$scope", "$location", "scratch",
  ($scope, $location, scratch ) ->
    $scope.scratch = scratch
    
  ]
