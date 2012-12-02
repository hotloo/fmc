Users = new Meteor.Collection("users")

if Meteor.isServer
  Users._ensureIndex 'id', {unique: 1, sparse: 1}
  
# User methods
Meteor.user = () ->
  userId = amplify.store("currentUserId")
  return null unless userId
  user = Users.findOne(id: userId)
  
insertUser = (user)->
  # Trim unnecessary data
  attrs = ["apiStandardProfileRequest", "educations", "imAccounts", "memberUrlResources", "phoneNumbers", "recommendationReceived", "skills", "siteStandardProfileRequest", "twitterAccounts"]
  for attr in attrs
    delete user.data[attr] if user.data[attr]
  Users.insert user

