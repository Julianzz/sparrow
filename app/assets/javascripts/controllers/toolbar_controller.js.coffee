todomvc.controller 'ToolbarController',($scope, $location, scratch, downloader )->
  $scope.scratch = scratch

  # Watch the ownership of the active plunk and change the save text accordingly
  $scope.$watch "scratch.isSaved()", (isSaved) ->
    if isSaved
      $scope.saveText = "Save"
      $scope.saveTitle = "Save your work as a new Plunk"
      $scope.saveIcon = "icon-save"
    else
      $scope.saveText = "Fork"
      $scope.saveTitle = "Save your work as a fork of the original Plunk"
      $scope.saveIcon = "icon-save"

  $scope.promptImportGist = (source) ->
    
    if source ||= prompt("Please enter a gist id to import")
      $location.path("gist:#{source}")
  
  $shareBtn = $("#share-buttons")
  
  lazyLoadedShareButtons = false
  
  $scope.triggerDownload = ->
    json = scratch.toJSON()
    
    filename = if scratch.plunk.id then "plunk-#{scratch.plunk.id}.zip" else "plunk.zip"
    
    downloader.download(json, filename)
  
  $scope.lazyLoadShareButtons = ->
    unless lazyLoadedShareButtons
      initSocialButtons()
      lazyLoadedShareButtons = true