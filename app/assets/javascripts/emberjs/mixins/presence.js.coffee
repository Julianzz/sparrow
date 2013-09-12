
App.Presence = Em.Mixin.create( 

  blank: (name)->
    return Ember.isEmpty(@[name] || @get(name))

  present: (name) ->
    return !@blank(name)
  
)


