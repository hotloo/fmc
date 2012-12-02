Meteor.autosubscribe ->
  Meteor.subscribe("users")
  Meteor.subscribe("titles")

class Router extends Backbone.Router
  routes:
    "": "index"
    "callback": "callback"
    "resume": "resume"
    ":other": "index"

  index: ->
    $('#about-link').fadeIn()
    $('#container')
      .hide()
      .html(Meteor.render(Template.indexTemplate))
      .fadeIn()
    $('#footer').fadeIn()

  callback: (params) ->
    if params?.code
      console.log "getAccessToken", params.code

      $('#container')
      .hide()
      .html(Meteor.render(Template.callbackTemplate))
      .fadeIn()

      $('#about-link').hide()
      $('#rat').fadeIn()

      Meteor.call "createUser", params.code, (error, userId)=>
        console.log "--userId", userId
        Session.set("currentUserId", userId)

        goToResume = =>
          @navigate 'resume', {trigger: true}
        setTimeout(goToResume, 3000)

  resume: ->
    $('#rat').hide()
    $('#about-link').hide()

    $('#container')
      .hide()
      .html(Meteor.render(Template.resumeTemplate))
      .fadeIn()
    $('#footer').hide()

Meteor.startup ->
  window.router = new Router()

  Backbone.history.start
    pushState: true
