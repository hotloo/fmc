Users = new Meteor.Collection("users")

if Meteor.isServer
  Users._ensureIndex 'id', {unique: 1, sparse: 1}
