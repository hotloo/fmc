Users = new Meteor.Collection("users")

if Meteor.isServer
  Users._ensureIndex 'id', {unique: 1, sparse: 1}
  
# User methods
Meteor.user = () ->
  userId = Session.get("currentUserId")
  return null unless userId
  user = Users.findOne(id: userId)

