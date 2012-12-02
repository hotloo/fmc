
start_server = ->
  positions = get_user_positions()
  titles = []
  return null unless positions instanceof Array
  for position in positions
    # console.log position
    for pos in position
      titles.push pos.title
  titles_coll = {}
  titles_coll.top = []
  titles_coll.senior = []
  titles_coll.middle = []
  titles_coll.junior = []
  titles_coll.low = []
  i = 0
  while i < titles.length
    i += 5
    titles_coll.top.push titles[i]
    titles_coll.senior.push titles[i+1]
    titles_coll.middle.push titles[i+2]
    titles_coll.junior.push titles[i+3]
    titles_coll.low.push titles[i+4]
  console.log titles_coll
  Titles.remove({})
  Titles.insert(titles_coll)


get_user_data = ()->
  Users.find({}).fetch()

get_user_positions = ()->
  users = get_user_data()
  positions = []
  for user in users
    continue unless user.data 
    continue unless user.data.positions
    values = user.data.positions.values
    positions.push values if values instanceof Array
  return positions

get_title_data = (callback)->
  Titles.find {}, (titles) ->
    title = titles[0]
    callback title

