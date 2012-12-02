clientSecret = ""
clientId = "2c546e7315c4fbf5fe439fe04821925e"

Meteor.methods
  # Method for fetching the users linkedin profile
  getAccessToken: (code) ->

    url = "https://api.singly.com/oauth/access_token"
#    data =
#      "client_id": clientId
#      "client_secret": clientSecret
#      "code": code

    #this.unblock()

    s = "client_id=#{clientId}&client_secret=#{clientSecret}&code=#{code}"

#    console.log "Meteor.http.post('#{url}',{data: #{JSON.stringify(data)}, function() { alert('yeah')})"

    console.log "Meteor.http.post"

    result = Meteor.http.post url, {params: s}

#
#    if result.statusCode == 200
#      return true
#    return false
