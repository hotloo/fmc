Meteor.publish "users", () ->
  Users.find {}

Meteor.publish "titles", () ->
  Titles.find {}

getAccessToken = (code) ->
  console.log "code", code
  return null unless code
  result = Meteor.http.post config.singly.url + "oauth/access_token",
    params:
      client_id:      config.singly.clientId
      client_secret:  config.singly.clientSecret
      code:           code
  throw result.error if result.error
  data = result.data
  throw new Meteor.Error 500, "Couldn't find access token" unless data
  console.log "data", data
  data.access_token

getIdentity = (accessToken) ->
  return null unless accessToken
  result = Meteor.http.get config.singly.url + "services/linkedin/self", 
    params:
      access_token: accessToken  
  throw result.error if result.error
  return result.data[0]

createUser = (code)->
  accessToken = getAccessToken(code)
  console.log "accessToken", accessToken
  userData = getIdentity(accessToken)
  console.log "userData", userData
  return null unless userData
  userData.accessToken = accessToken
  user = Users.findOne id: userData.id
  if user and user.id
    userId = user.id
  else
    userId = insertUser userData
  populateConnections(accessToken)
  console.log "userId", userId
  return userId

populateConnections = (accessToken)->
  return null unless accessToken
  result = Meteor.http.get config.singly.url + "services/linkedin/connections", 
    params:
      limit: 1000
      access_token: accessToken
  throw result.error if result.error
  connections = result.data
  console.log "connections length", connections.length 
  for connection in connections
    existedConnection = Users.findOne id: connection.id
    unless existedConnection
      console.log connection.data.firstName
      insertUser connection

Meteor.methods
  getAccessToken: getAccessToken
  getIdentity: getIdentity
  createUser: createUser
  populateConnections: populateConnections
  
Meteor.startup ->
  start_server()
  
