Meteor.autosubscribe ->
  Meteor.subscribe("users")

class Router extends Backbone.Router
  routes:
    "": "index"
    "callback": "callback"
    "resume": "resume"

  index: ->
    console.log "index"
    $('#container')
      .hide()
      .html(Meteor.render(Template.indexTemplate))
      .fadeIn()

  callback: (params) ->
    if params?.code
      console.log "getAccessToken", params.code
      Meteor.call "getAccessToken", params.code, (err, accessToken)->
        console.log "accessToken", accessToken
        Meteor.call "getIdentity", accessToken, (err, profile)->
      
          console.log "profile", profile
          Users.insert profile

          $('#container')
            .hide()
            .html(Meteor.render(Template.callbackTemplate))
            .fadeIn()

  resume: ->
    $('#container')
      .hide()
      .html(Meteor.render(Template.resumeTemplate))
      .fadeIn()

Meteor.startup ->
  router = new Router()

  Backbone.history.start
    pushState: true
