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
    if params and params.code
      console.log params
      console.log "getAccessToken", params.code
      Meteor.call "getAccessToken", params.code

      Template.callbackTemplate.code = params.code

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
