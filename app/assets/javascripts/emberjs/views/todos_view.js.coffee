App.EditTodoView = Ember.TextField.extend 
	classNames: ['edit']

	valueBinding: 'todo.title'

	change: ->
		value = this.get('value');
		if Ember.isEmpty(value) 
		  @get('controller').removeTodo()

	focusOut: ->
		@set('controller.isEditing', false)

	insertNewline: ->
		@set('controller.isEditing', false)

	didInsertElement: ->
		@$().focus() 

 
App.TodosView = Ember.View.extend
  templateName: 'todos'

  
