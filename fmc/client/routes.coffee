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
#    currentUser = Meteor.user()
#    if currentUser
#      obj = recommend(currentUser.data.positions.values)
#      amplify.store("resume", obj)
#      Session.set("resume",obj)

    $('#rat').hide()
    $('#about-link').fadeIn()

    $('#container')
      .hide()
      .html(Meteor.render(Template.indexTemplate))
      .fadeIn()
    $('#footer').fadeIn()

  callback: (params) ->
    return unless params
    if params.code
#      console.log "getAccessToken", params.code

      $('#container')
        .hide()
        .html(Meteor.render(Template.callbackTemplate))
        .fadeIn()

      $('#about-link').hide()
      $('#rat').fadeIn()

      Meteor.call "createUser", params.code, (err, userId)=>
        console.log "client:err", err
        console.log "client:code", params.code
        console.log "client:userId", userId
        if userId
          amplify.store("currentUserId", userId)
          currentUser = Users.findOne(id:userId)
#          if currentUser
#            obj = recommend(currentUser.data.positions.values)
#            console.log "test"
#            amplify.store("resume", obj)
#            Session.set("resume",obj)
        @navigate 'resume', {trigger: true}



  resume: ->
    currentUser = Meteor.user()
    if currentUser
      obj = recommend(currentUser.data.positions.values)
      amplify.store("resume", obj)
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
