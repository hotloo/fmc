# fs = require 'fs'

if Meteor.isServer
  Meteor.startup ->
    positions = get_user_positions()
    titles = []
    for position in positions
      titles.push position.title
    titles_coll = {}
    i = 0
    while i < titles.length
      i += 5
      return if i + 5 > titles_coll.length
      titles_coll.top = titles[i]
      titles_coll.senior = titles[i+1]
      titles_coll.middle = titles[i+2]
      titles_coll.junior = titles[i+3]
      titles_coll.low = titles[i+4]
    Titles.remove({})
    Titles.insert(titles_coll)
      
import_data = (callback)->
  fs.readFile("../../stats/sample.json", "utf8", (err, content)->
    return null unless content
    for user in content
      Users.insert(user)
    callback()
  )

get_user_data = ()->
  Users.find({}).fetch()

get_user_positions = ()->
  users = get_user_data()
  positions = []
  for i,user in users
    console.log user
    return [i,user] unless user.data
    positions.concat user.data.positions.values
  return positions

get_title_data = (callback)->
  Titles.find {}, (titles) ->
    title = titles[0]
    callback title

