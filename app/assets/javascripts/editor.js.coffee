
###
module = angular.module("plunker.editor", ["ui.directives", "plunker.scratch", "plunker.url", "plunker.userpanel", "plunker.layout", "plunker.ace", "plunker.statusbar", "plunker.multipanel", "plunker.toolbar"])
###
module = angular.module("plunker.editor", [
  "ui.directives", 
  "plunker.scratch", 
  "plunker.url", 
  "plunker.userpanel",
  "plunker.layout", 
  "plunker.ace", 
  "plunker.filelist",
  "plunker.downloader",
  "plunker.statusbar", 
  "plunker.buffers",
  "plunker.multipanel" ])

module.value "ui.config",
  select2:
    tags:["angularjs","angular-ui","jquery","bootstrap","jquery-ui","coffee", "YUI"]
    tokenSeparators: [",", " "]


module.directive "selectList", ->
  restrict: "A"
  require: "ngModel"
  priority: 99
  link: ($scope, element, args, ngModel) ->
    ngModel.$parsers.push (options = []) ->
      tags = []
      tags.push(option.text) for option in options
      tags
  

module.config ["$routeProvider", "$locationProvider", ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)
]

module.controller "editor", [ "$scope", "$location", "scratch", "url","fileList" , ($scope, $location, scratch, url,fileList) ->
  $scope.url = url
  
  repaintSidebar = ->
    # Hack to force a repaint after AngularJS does first rendering
    setTimeout ->
      el = $(".plnk-sidebar")[0]
      el.style.display = "none"
      el.offsetHeight
      el.style.display = "block"
    , 1
  
  # Watch for changes in the path and load the appropriate plunk into the scratch
  $scope.$watch (-> $location.path()), (path) ->
    if path is "/" then scratch.reset(_plunker.bootstrap)
    else
      source = path.slice(1)
      unless scratch.plunk.id is source then scratch.loadFrom(source).then(repaintSidebar)
    
    delete _plunker.bootstrap
  
  $scope.scratch = scratch
  
  $scope.isPaneEnabled = (pane) -> !pane.hidden
  
  $scope.person = { name: "Ari Lerner" }
  updateClock = ->
    $scope.clock = new Date()
  timer = setInterval ->
    $scope.$apply(updateClock)
  , 1000
  updateClock()
  
  $scope.logs = []
  $scope.treeOptions =
    expandedIconClass: 'icon-chevron-down'
    collapsedIconClass: 'icon-chevron-right'
    # expandedIconClass: 'icon-minus'
    # collapsedIconClass: 'icon-plus'
    
    getChildren: (node, callback) ->
      searchPath = if node and node.path  then node.path else "/"
      fileList.fetchFile searchPath, (err, files ) ->
        return if err 
        callback files
        
    onLabelClick: (node) ->
      $scope.logs = [
        { text: 'selected: ' + JSON.stringify(label:node.label, level:node.level) }
      ].concat $scope.logs
      
    onExpanderClick: (node) ->
      $scope.logs = [
        {text: (if node.expanded then 'expanded' else 'collapsed') + ': ' + JSON.stringify(label:node.label, level:node.level)}
      ].concat $scope.logs
  
]
###
  repaintSidebar()
  
  window.onbeforeunload = ->
      json = if scratch.savedState then scratch._getDeltaJSON(scratch.savedState) else scratch._getSaveJSON()
      
      count = 0
      count++ for filename, file of json.files
      
      if count or json.description or json.tags
        return "You have not saved your changes to this plunk."


]
###