require 'rest-client'
require 'json'

class Client

  # /artworks endpoint
  ARTWORKS_URL = "http://localhost:4567/artworks"
  ARTIST_URL = "http://localhost:4567/artist"

  # Your retrieve function plus any additional functions go here ...
  def retrieve(option)
    puts option[:page] if option.has_key?(:page) && option[:page].is_a?(Integer)
    puts option[:dominant_color] if option.has_key?(:dominant_color) && option[:dominant_color].is_a?(Array)
  end

end

client = Client.new
client.retrieve({ page: 2, dominant_color: ["red", "brown"] })
