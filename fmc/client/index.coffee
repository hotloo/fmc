Meteor.loginWithSingly = (options, callback)->
  # support both (options, callback) and (callback).
  if not callback and typeof options is "function"
    callback = options
    options = {}

  service = options.service
  clientId = options.clientId
  redirectUri = options.redirectUri

  loginUrl = config.singly.url + "oauth/authenticate?client_id=#{clientId}&redirect_uri=#{redirectUri}&service=#{service}"
  window.location = loginUrl
  
Template.indexTemplate.events "click #login": ->
  options =
    service: "linkedin"
    clientId: "2c546e7315c4fbf5fe439fe04821925e"
    redirectUri: Meteor.absoluteUrl('callback')
  Meteor.loginWithSingly options

