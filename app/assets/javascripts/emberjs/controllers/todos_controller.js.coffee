
App.TodoController = Ember.ObjectController.extend 
	isEditing: false

	editTodo: () ->
		@set 'isEditing', true

	removeTodo: () ->
		todo = @get 'model' 
		todo.deleteRecord()
		todo.get('store').commit()


App.TodosController = Ember.ArrayController.extend 
	createTodo: ->

		title = this.get('newTitle');
		if not title.trim()
			return
      
		App.Todo.createRecord 
			title: title
			isCompleted: false
      
		@set('newTitle', '')

		#Save the new model
		@get('store').commit()


	clearCompleted: ->
		completed = @filterProperty 'isCompleted', true
		completed.invoke 'deleteRecord'
		@get('store').commit()

	remaining: ( ->
		return @filterProperty('isCompleted', false).get('length') 
	).property('@each.isCompleted')

	remainingFormatted: ( ->
		remaining = @get('remaining') 
		plural = remaining == 1 ? 'item' : 'items'
		return '<strong>%@</strong> %@ left'.fmt(remaining, plural)
	).property('remaining')

	completed:( ->
		return @filterProperty('isCompleted', true).get('length')
	).property('@each.isCompleted')

	hasCompleted: ( ->
		return this.get('completed') > 0
	).property('completed')

	allAreDone:  ( (key, value) ->
		if not value == undefined 
			@setEach('isCompleted', value)
			return value
		else
			return @get('length') && @everyProperty('isCompleted', true) 
	).property('@each.isCompleted')