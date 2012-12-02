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
  user = Users.findOne id: userData.id
  if user and user.id
    userId = user.id
  else
    userId = Users.insert userData
    populateConnections(accessToken)
  console.log "userId", userId
  return userId

populateConnections = (accessToken)->
  return null unless accessToken
  result = Meteor.http.get config.singly.url + "services/linkedin/connections", 
    params:
      access_token: accessToken
  throw result.error if result.error
  connections = result.data
  for connection in connections
    Users.insert connection

Meteor.methods
  getAccessToken: getAccessToken
  getIdentity: getIdentity
  createUser: createUser
  
