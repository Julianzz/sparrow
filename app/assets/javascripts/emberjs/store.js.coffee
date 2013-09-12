#App.Store = DS.Store.extend
#  revision: 4
#  adapter: DS.RESTAdapter.create()


DS.RESTAdapter.reopen
  namespace: "api/v1"
  
App.Store = DS.Store.extend
  revision: 12
  adapter: DS.RESTAdapter.create()