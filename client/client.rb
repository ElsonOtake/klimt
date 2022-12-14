require 'rest-client'
require 'json'

class Client

  # /artworks endpoint
  ARTWORKS_URL = "http://localhost:4567/artworks"
  ARTIST_URL = "http://localhost:4567/artist"

  # Your retrieve function plus any additional functions go here ...
  def retrieve(option)
    puts option
  end

end

client = Client.new
client.retrieve({ page: 2, dominant_color: ["red", "brown"] })
