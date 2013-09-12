
App.TodosRoute = Ember.Route.extend 
	model: ->
		return App.Todo.find() 

App.TodosIndexRoute = Ember.Route.extend 
	setupController: ->
		todos = App.Todo.find();
		@controllerFor('todos').set('filteredTodos', todos);


App.TodosActiveRoute = Ember.Route.extend 
	setupController: ->
		todos = App.Todo.filter (todo) ->
			 return true if not todo.get( 'isCompleted') 
		@controllerFor('todos').set('filteredTodos', todos)


App.TodosCompletedRoute = Ember.Route.extend 
	setupController:  ->
		todos = App.Todo.filter (todo) ->
			if todo.get('isCompleted') 
				return true
		@controllerFor('todos').set('filteredTodos', todos)
