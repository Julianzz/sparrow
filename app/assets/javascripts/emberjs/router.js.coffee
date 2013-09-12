App.Router.map (match)->
  # match('/').to('index')
  @resource "todos" , { path: '/' }, -> 
    @route('active')
    @route('completed')