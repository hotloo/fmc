# fs = require 'fs'

if Meteor.isServer
  Meteor.startup ->
    
import_data = (callback)->
  fs.readFile("../../stats/sample.json", "utf8", (err, content)->
    return null unless content
    for user in content
      Users.insert(user)
    callback()
  )

get_user_data = ()->
  Users.find({}, (users)-> 
    positions = []
    for user in users
      positions.push user.data.positions.value
    return positions
  )


