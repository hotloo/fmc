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
    console.log params
    if params?.code
      console.log "getAccessToken", params.code
      userId = Meteor.call "createUser", params.code
      Session.set "currentUserId", userId
      $('#container')
        .hide()
        .html(Meteor.render(Template.callbackTemplate))
        .fadeIn()

      $('#rat').css('visibility','visible')
      goToResume = =>
        @navigate 'resume', {trigger: true}
      setTimeout(goToResume, 2000)

  resume: ->
    console.log "in resume"
    $('#rat').css('visibility','hidden')
    $('#container')
      .hide()
      .html(Meteor.render(Template.resumeTemplate))
      .fadeIn()

Meteor.startup ->
  router = new Router()

  Backbone.history.start
    pushState: true
