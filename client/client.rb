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
    response = JSON.parse(RestClient.get ARTWORKS_URL.concat(params))
    ids = []
    for_sale = []
    sold_primary_count = 0
    artist_id = []
    response.each do |artwork|
      artwork.transform_keys!(&:to_sym)
      ids.push(artwork[:id])
      artwork[:isPrimary] = ['red', 'blue', 'yellow'].include?(artwork[:dominant_color])
      for_sale.push(artwork) if artwork[:availability] == 'for_sale'
      sold_primary_count += 1 if artwork[:availability] == 'sold' && artwork[:isPrimary]
      artist_id.push(artwork[:artist_id]) unless artist_id.include?(artwork[:artist_id])
    end
    artist_name = []
    artist_id.each do |id|
      artist = JSON.parse(RestClient.get "#{ARTIST_URL}?id=#{id}")[0]
      artist.transform_keys!(&:to_sym)
      artist_name.push(artist[:name])
    end
    p artist_name.sort!
  end

end

client = Client.new
client.retrieve({ page: 2, dominant_color: ["red", "brown"] })
