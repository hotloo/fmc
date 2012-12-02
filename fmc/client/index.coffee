Template.bodyTemplate.events
  "click #logo": (event) ->
    event.preventDefault()
    window.router.navigate "", {trigger: true}
  "click #about-link": (event) ->
    event.preventDefault()
    target = $(event.currentTarget).attr("href")

    $("html, body").stop().animate
      scrollTop: $(target).offset().top
      
Template.bodyTemplate.currentUser = ->
  Meteor.user()

  "click #go-up": (event) ->
    $("html, body").stop().animate
      scrollTop: 0

Template.indexTemplate.events
  "click #login": ->
    authUrl = "https://api.singly.com/oauth/authenticate"
    clientId = "2c546e7315c4fbf5fe439fe04821925e"
    redirectUri = "http://localhost:3000/callback"

    window.location = authUrl + "?client_id=" + clientId + "&redirect_uri=" + redirectUri + "&service=linkedin"
    console.log authUrl + "?client_id=" + clientId + "&redirect_uri=" + redirectUri + "&service=linkedin"

Meteor.startup ->
  $window = $ window
  $screen = $ "#screen"

  windowResized = ->
    height = $window.height()
    $screen.height(height)
    $footer = $('#footer')
    $footer.height(height) if $footer

  $window.resize windowResized

  windowResized()

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

