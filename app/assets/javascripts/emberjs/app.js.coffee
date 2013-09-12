exports = this
exports.App = Ember.Application.createWithMixins {}, 
  rootElement: '#main'
  hasFocus: true
  
  LOG_TRANSITIONS: true
  LOG_VIEW_LOOKUPS: true
  LOG_ACTIVE_GENERATION: true
   
  getURL: (url) ->
    return url if url.indexOf('http') == 0 

    u = (App.BaseUri == undefined ? "/" : Discourse.BaseUri) 
    u = u.substring(0, u.length-1)  if  u[u.length-1] == '/'
    return u + url
    
###
Ember.Application.initializer
  name: 'currentUser'
 
  initialize: (container) ->
    #store = container.lookup('store:main')
    #attributes = $('meta[name="current-user"]').attr('content')
    #console.log attributes
    console.log  Ember.TEMPLATES
    return 
###