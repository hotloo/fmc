Template.bodyTemplate.events
  "click #about-link": (event) ->
    event.preventDefault()
    console.log event.currentTarget
    target = $(event.currentTarget).attr("href")
    console.log $(target)

    $("html, body").stop().animate
      scrollTop: $(target).offset().top

Template.indexTemplate.events
  "click #login": ->
    authUrl = "https://api.singly.com/oauth/authenticate"
    clientId = "2c546e7315c4fbf5fe439fe04821925e"
    redirectUri = "http://localhost:3000/callback"

    window.location = authUrl + "?client_id=" + clientId + "&redirect_uri=" + redirectUri + "&service=linkedin"

Meteor.startup ->
  $window = $ window
  $screen = $ "#screen"

  windowResized = ->
    $screen.height($window.height())

  $window.resize windowResized

  windowResized()



