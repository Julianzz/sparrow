###
 * The main TodoMVC app module
 *
 * @type {angular.Module}
###
 
@todomvc = angular.module 'todomvc', [ 
  "ngResource",
  "plunker.editor",
  '$angularTree.directives',
  "plunker.filelist"
] 

@todomvc.config(["$httpProvider", (provider) ->
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
])

todomvc.config( ['$routeProvider', ($routeProvider) ->
  $routeProvider.when('/todos', { controller: "TodoCtrl" })
]);


todomvc.config (['$locationProvider', ($locationProvider) ->
  $locationProvider.html5Mode true
])
