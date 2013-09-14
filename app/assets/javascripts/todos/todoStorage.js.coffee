###
todomvc.factory 'todoStorage', ($resource) ->
	STORAGE_ID = 'todos-angularjs'

	todos = $resource  "/api/v1/todos/:todo_id", 
		todo_id: "@id"
		
	return {
		get: ->
			return todos.query()
			#return JSON.parse(localStorage.getItem(STORAGE_ID) || '[]')

		put: (todos) ->
			localStorage.setItem(STORAGE_ID, JSON.stringify(todos))
		
		all: ->
	}
###

todomvc.factory 'todoStorage', ['railsResourceFactory', (railsResourceFactory) ->
	todos = railsResourceFactory {url: '/api/v1/todos', name: 'book'} 
	todos.findByTitle = (title) ->
		return resource.query {title: title} 
	return  {
		get: ->
			todos.query()
		put:( todo ) ->
			#todos.update(todo)
	}
]
