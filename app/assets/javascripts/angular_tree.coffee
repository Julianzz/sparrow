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
	template: '''<div>
		<div angular-tree-node ng-repeat="node in nodes"
			data-node="node" data-options="options"></div></div>'''
	replace: true
	scope:
		options: '=options'
	link: (scope, element, attrs) ->
		scope.nodes = []

		getChildren = (node) ->
			if scope.options.getChildren
				scope.options.getChildren node, (data) ->
					for item in data
						item.level = if node then node.level + 1 else 0
						item.parent = node
					scope.nodes = array_insert scope.nodes, node, data, 'right'
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
  <div class="angular-tree-node" ng-show="node.visible" ng-class="nodeClass">
		<i ng-style="{marginLeft: node.level + 'em'}"></i>
		<i ng-class="expanderClass" class="angular-tree-icon-collapsed angular-tree-node-expander" 
      ng-click="onExpanderClick(node) && options.onExpanderClick(node)"></i>
		<span class="angular-tree-node-label" ng-click="onLabelClick(node) && options.onLabelClick(node);">
      {{node.label}}
    </span>
	</div>'''
	replace: true
	link: (scope, element, attrs) ->
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
		scope.$watch 'node.expanded', (v) ->
			scope.expanderClass = if v
				scope.options.expandedIconClass || 'angular-tree-icon-expanded'
			else
				scope.options.collapsedIconClass || 'angular-tree-icon-collapsed'
		scope.$watch 'node.selected', (v) ->
			scope.nodeClass = if v then 'selected' else ''