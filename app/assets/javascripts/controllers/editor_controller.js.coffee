module = angular.module("plunker.controller.editor", [ 
  "plunker.scratch",
  "plunker.url",
  "plunker.filelist"
])

module.controller "EditorController", [ "$scope", "$location", "scratch", "url","fileList" , ($scope, $location, scratch, url, fileList) ->
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