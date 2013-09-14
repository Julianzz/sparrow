module = angular.module("plunker.userpanel", ["plunker.session"])

module.directive "plnkrPress", ["$parse", ($parse) ->
  (scope, element, attrs) ->
    tapping = false
    fn = $parse(attrs["plnkrPress"])
    
    element.bind 'touchstart', (e) -> tapping = true
    element.bind 'touchmove', (e) -> tapping = false
    element.bind 'touchend', (e) -> if tapping then scope.$apply -> fn(scope, $event: e)
    element.bind 'click', (e) -> scope.$apply -> fn(scope, $event: e)
]
