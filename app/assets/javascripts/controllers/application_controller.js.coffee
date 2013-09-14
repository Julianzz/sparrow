todomvc.controller "ApplicationController", ($scope, fileList ) ->
  $scope.person = { name: "Ari Lerner" }
  updateClock = ->
    $scope.clock = new Date()
  timer = setInterval ->
    $scope.$apply(updateClock)
  , 1000
  updateClock()
  

  