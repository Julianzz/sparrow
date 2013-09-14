insertAfterItem = ( a,item, newItems )->
  result = if a.length > 0 then a else newItems
  index = a.indexOf item
  unless index == -1
    result = a.concat newItems, a.splice index+ 1
  return result

angular.module('$angularTree.config', []).value('$angularTree.config', {});
angular.module('$angularTree.filters', ['$angularTree.config']);
angular.module('$angularTree.directives', ['$angularTree.config']);
angular.module('$angularTree', ['$angularTree.filters', '$angularTree.directives', '$angularTree.config']);

angular.module('$angularTree.directives').directive 'angularTree', () ->
  restrict:'E'
  template: '''
    <ul class="nav nav-list ">
    <li ng-show="header" class="nav-header">
      {{ header }}
    </li>
    <div angular-tree-node ng-repeat="node in nodes"
      data-node="node" data-options="options">
    </div>
    '''
  replace: true
  scope:
    options: '=options'
    
  link: (scope, element, attrs) ->
    scope.nodes = []
    scope.header = "hello, this my tree view "
    scope.trees = {}    
    
    getChildren = (node) ->
      path = if node then node.path else "/"
      if scope.options.getChildren
        scope.options.getChildren node, (files) ->
          if not files.children
            return 
          newItems = [] 
          for key, item of files.children
            if item.path and item.path in scope.trees
              item = scope.tree[item.path]
            else 
              item.level = if node then node.level + 1 else 0
              item.parent = node
              item.label = key
              scope.trees[item.path] = item 
              
              newItems.push( item )

          scope.nodes = insertAfterItem scope.nodes,node, newItems 
          console.log scope.nodes
          if node 
            node.loaded = true
            node.expanded = true

    scope.onExpanderClick = (node) ->
      node.level = 0 unless node.level
      unless node.loaded
        getChildren node
      else
        node.expanded = not node.expanded
      true

    scope.onLabelClick = (node) ->
      if node.selected
        false
      else
        for item in scope.nodes
          item.selected = false
        node.selected = true

    getChildren()


angular.module('$angularTree.directives').directive 'angularTreeNode', () ->
  template: '''
  <li class="abn-tree-row" 
        ng-show="node.visible"
        ng-animate="'abn-tree-animate'" 
        ng-class="nodeClass">
          
    <i ng-style="{ marginLeft: node.level + 'em'}"></i>
    <i ng-class="node.tree_icon" 
        class="indented" 
        ng-click="onExpanderClick(node) && options.onExpanderClick(node)">
    </i>
    
    <span class="indented tree-label " ng-click="onLabelClick(node) && options.onLabelClick(node);">
      {{node.label}}
    </span>
  </li>'''
  
  replace: true
  link: (scope, element, attrs) ->
    # default values
    attrs.iconExpand   ?= 'icon-plus'    
    attrs.iconCollapse ?= 'icon-minus'
    attrs.iconLeaf     ?= 'icon-file'
    
    scope.$watch 'node.parent.expanded', (expanded) ->
      if scope.node.parent
        scope.node.visible = expanded
      else
        scope.node.visible = true
        
    scope.$watch 'node.parent.visible', (visible) ->
      if scope.node.parent
        scope.node.visible = visible
      else
        scope.node.visible = true
        
    scope.$watch 'node.expanded', (expanded) ->
      
      if scope.node.type == "file"
        scope.node.tree_icon = attrs.iconLeaf
      else
        scope.node.tree_icon = if not expanded then attrs.iconExpand  else  attrs.iconCollapse
          
    scope.$watch 'node.selected', (v) ->
      scope.nodeClass = if v then 'selected' else ''
      

