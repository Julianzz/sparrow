
Fly.Ajax = Em.Mixin.create

  ajax: ->
    url = null
    args = {}

    if arguments.length == 1
      if typeof arguments[0] == "string" 
        url = arguments[0];
        args = {};
      else
        args = arguments[0];
        url = args.url;
        delete args.url;
    else if arguments.length == 2
      url = arguments[0];
      args = arguments[1];

    
    console.warning("DEPRECATION: Discourse.ajax should use promises, received 'success' callback") if args.success 
    console.warning("DEPRECATION: Discourse.ajax should use promises, received 'error' callback") if args.error

    # If we have URL_FIXTURES, load from there instead (testing)
    fixture = Fly.URL_FIXTURES && Discourse.URL_FIXTURES[url]
    return Ember.RSVP.resolve(fixture) if fixture

    performAjax = (promise) ->
      oldSuccess = args.success;
      args.success = (xhr) ->
        Ember.run(promise, promise.resolve, xhr);
        oldSuccess(xhr) if (oldSuccess)


      oldError = args.error;
      args.error = (xhr) ->
        # If it's a parseerror, don't reject
        return args.success(xhr) if (xhr.status == 200)

        promise.reject(xhr)
        oldError(xhr) if (oldError)

      # We default to JSON on GET. If we don't, sometimes if the server doesn't return the proper header
      # it will not be parsed as an object.
      args.type = 'GET' if !args.type
      args.dataType = 'json' if (!args.dataType) && (args.type == 'GET') 

      $.ajax(Fly.getURL(url), args)

    # For cached pages we strip out CSRF tokens, need to round trip to server prior to sending the
    #  request (bypass for GET, not needed)
    
    csrfToken = $('meta[name=csrf-token]').attr('content')
    
    if args.type && args.type != 'GET' && !csrfToken 
      return Ember.Deferred.promise (promise) ->
        $.ajax(Discourse.getURL('/session/csrf'))
           .success (result)->
              $('head').append('<meta name="csrf-token" content="' + result.csrf + '">')
              performAjax(promise)
    else
      return Ember.Deferred.promise(performAjax)






