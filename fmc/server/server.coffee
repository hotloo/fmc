Meteor.publish "users", () ->
  Users.find {}, 
    fields:
      profile: 1
      username: 1
      email: 1
      services: 1

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
  console.log "data", data, data.access_token
  data.access_token

getIdentity = (accessToken) ->
  return null unless accessToken
  result = Meteor.http.get config.singly.url + "profiles/linkedin", 
    params:
      access_token: accessToken  
  throw result.error if result.error
  return result.data

Meteor.methods
  getAccessToken: getAccessToken
  getIdentity: getIdentity
  