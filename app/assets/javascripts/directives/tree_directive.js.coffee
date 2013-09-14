array_insert = (array, item, newItems, pos) ->
  if array.length > 0
    idx = array.indexOf item
    unless idx == -1
      array.concat newItems, array.splice idx + (if pos == 'right' then 1 else 0)
    else
      array
  else
    newItems

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
              console.log item 
          scope.nodes = array_insert scope.nodes, node, newItems , 'right'
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
      


module = angular.module 'angularBootstrapNavTree',[]

module.directive 'abnTree',($timeout)-> 
  restrict:'E'
  template:"""
  <ul class="nav nav-list abn-tree">
    <li ng-show="header" class="nav-header">
        {{ header }}
    </li>
    <li ng-repeat="row in tree_rows | filter:{visible:true}" 
          ng-animate="'abn-tree-animate'" 
          ng-class="row.level_class   "
          class="abn-tree-row ">
      <a ng-click="user_clicks_branch(row.branch)">
        <i ng-class="row.tree_icon" ng-click="row.branch.expanded = !row.branch.expanded" class="indented tree-icon"> 
        </i>
        <span class="indented tree-label">
          {{ row.label }}
        </span>
      </a>
    </li>
  </ul>
  """
  scope:
    treeData:'='
    onSelect:'&'
    initialSelection:'='

  link:(scope,element,attrs)->

    # default values
    attrs.iconExpand   ?= 'icon-plus'    
    attrs.iconCollapse ?= 'icon-minus'
    attrs.iconLeaf     ?= 'icon-chevron-right'
    attrs.expandLevel  ?= '3'

    expand_level = parseInt attrs.expandLevel,10

    scope.header = attrs.header

    # check args
    if !scope.treeData
      alert 'no treeData defined for the tree!'
    if !scope.treeData.length?
      if treeData.label?
        scope.treeData = [ treeData ]
      else
        alert 'treeData should be an array of root branches'


    #
    # internal utilities...
    # 
    for_each_branch = (f)->      
      do_f = (branch,level)->
        f(branch,level)
        if branch.children?
          for child in branch.children
            do_f(child,level + 1)
      for root_branch in scope.treeData
        do_f(root_branch,1)



    #
    # expand to the proper level
    #
    for_each_branch (b,level)->
      b.level = level
      b.expanded = b.level < expand_level

    
    #
    # only one branch can be selected at a time
    # 
    selected_branch = null
    select_branch = (branch)->
      if branch isnt selected_branch
        if selected_branch?
          selected_branch.selected = false
        branch.selected = true
        selected_branch = branch
        #
        # check:
        # 1) branch.onSeelct
        # 2) tree.onSelect
        #
        if branch.onSelect?
          #
          # use $timeout
          # so that the branch becomes fully selected
          # ( and highlighted )
          # before calling the "onSelect" .
          #
          $timeout ->
            branch.onSelect(branch)
        else
          if scope.onSelect?
            $timeout ->
              scope.onSelect({branch:branch})


    scope.user_clicks_branch = (branch)->
      if branch isnt selected_branch
         select_branch(branch)


    #
    # To make the Angular rendering simpler,
    #  ( and to avoid recursive templates )
    #  we transform the TREE of data into a LIST of data.
    #  ( "tree_rows" )
    #
    # We do this whenever data in the tree changes.
    # The tree itself is bound to this list.
    # 
    # Children of un-expanded parents are included, 
    #  but are set to "visible:false" 
    #  ( and then they filtered out during rendering )
    #
    scope.tree_rows = []
    on_treeData_change = ->
      scope.tree_rows = []

      #
      # if "children" is just a list of strings...
      # ...change them into objects:
      # 
      for_each_branch (branch)->
        if branch.children
          if branch.children.length > 0
            branch.children = branch.children.map (e)->
              if typeof e == 'string'
                label:e
                children:[]
              else
                e
        else
          branch.children = []

      # give each Branch a UID ( to keep AngularJS happy )
      for_each_branch (b,level)->
        if not b.uid
          b.uid = ""+Math.random()


      #
      # add_branch_to_list: recursively add one branch
      # and all of it's children to the list
      #
      add_branch_to_list = (level,branch,visible)->

        if not branch.expanded?
          branch.expanded = false

        #
        # icons can be Bootstrap or Font-Awesome icons:
        # they will be rendered like:
        # <i class="icon-plus"></i>
        #
        if not branch.children or branch.children.length == 0 
          tree_icon = attrs.iconLeaf
        else
          if branch.expanded
            tree_icon = attrs.iconCollapse
          else
            tree_icon = attrs.iconExpand 




        #
        # append to the list of "Tree Row" objects:
        #
        scope.tree_rows.push
          level     : level
          level_class: 'level-' + level 
          branch    : branch
          label     : branch.label
          tree_icon : tree_icon
          visible   : visible

        #
        # recursively add all children of this branch...( at Level+1 )
        #
        if branch.children?
          for child in branch.children
            #
            # all branches are added to the list,
            #  but some are not visible
            # ( if parent is collapsed )
            # 
            child_visible = visible and branch.expanded
            add_branch_to_list level+1, child, child_visible

      #
      # start with root branches,
      # and recursively add all children to the list
      #
      for root_branch in scope.treeData        
        add_branch_to_list 1, root_branch, true


    #
    # initial-selection="Branch Label"
    # if specified, find and select the branch:
    #
    if attrs.initialSelection?
      for_each_branch (b)->
        if b.label == attrs.initialSelection
          select_branch b

    #
    # make sure to do a "deep watch" on the tree data
    # ( by passing "true" as the third arg )
    #
    #on_treeData_change()
    scope.$watch 'treeData',on_treeData_change,true
