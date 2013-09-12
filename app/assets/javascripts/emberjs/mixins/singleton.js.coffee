###
  This mixin allows a class to return a singleton, as well as a method to quickly
  read/write attributes on the singleton.

    // Define your class and apply the Mixin
    User = Ember.Object.extend({});
    User.reopenClass(Discourse.Singleton);

    // Retrieve the current instance:
    var instance = User.current();
###

App.Singleton = Em.Mixin.create( 

  #Returns the current singleton instance of the class.
  current: ->
    @_current = @createCurrent() if (!@_current)
    return @_current

  createCurrent: ->
    return @create({}) 

  currentProp: (property, value) ->
    instance = @current()
    return if !instance 

    if typeof(value) != "undefined" 
      instance.set(property, value)
      return value
    else
      return instance.get(property)
)


