require 'rest-client'
require 'json'

class Client

  # /artworks endpoint
  ARTWORKS_URL = "http://localhost:4567/artworks"
  ARTIST_URL = "http://localhost:4567/artist"

  # Your retrieve function plus any additional functions go here ...
  LIMIT = 10
  def retrieve(option)
    params = "?limit=#{LIMIT}"
    params.concat("&offset=#{(option[:page] - 1) * 10}") if option.has_key?(:page) && option[:page].is_a?(Integer)
    colors = option[:dominant_color] if option.has_key?(:dominant_color) && option[:dominant_color].is_a?(Array)
    params.concat(colors.join('&dominant_color[]=').prepend('&dominant_color[]=')) if colors.all? { |clr| clr.is_a?(String) }
    response = RestClient.get ARTWORKS_URL.concat(params)
    puts response
  end

end

client = Client.new
client.retrieve({ page: 2, dominant_color: ["red", "brown"] })
