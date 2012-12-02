Template.indexTemplate.events "click #login": ->
  authUrl = "https://api.singly.com/oauth/authenticate"
  clientId = "2c546e7315c4fbf5fe439fe04821925e"
  redirectUri = "http://localhost:3000/callback"

  window.location = authUrl + "?client_id=" + clientId + "&redirect_uri=" + redirectUri + "&service=linkedin"


