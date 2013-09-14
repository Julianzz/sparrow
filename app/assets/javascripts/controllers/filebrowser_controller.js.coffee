module = angular.module("plunker.filebrowser", [ "plunker.filelist" ])

module.controller 'FileBrowserController',($scope,fileList ) ->
  
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


  
  
  $scope.person = { name: "Ari Lerner" }
  updateClock = ->
    $scope.clock = new Date()
    
  timer = setInterval ->
    console.log "time"
    updateClock()
  , 1000
  
  updateClock()
  
