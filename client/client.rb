require 'rest-client'
require 'json'

class Client

  # /artworks endpoint
  ARTWORKS_URL = "http://localhost:4567/artworks"
  ARTIST_URL = "http://localhost:4567/artist"

  # Your retrieve function plus any additional functions go here ...
  LIMIT = 10
  def retrieve(option = '')
    params = "?limit=#{LIMIT}"
    page = 1
    if !option
      page = option.has_key?(:page) && option[:page].is_a?(Integer) ? option[:page] : 1
      params.concat("&offset=#{(option[:page] - 1) * 10}") unless page == 1
      colors = option[:dominant_color] if option.has_key?(:dominant_color) && option[:dominant_color].is_a?(Array)
      params.concat(colors.join('&dominant_color[]=').prepend('&dominant_color[]=')) if colors.all? { |clr| clr.is_a?(String) }
    end
    response = JSON.parse(RestClient.get "#{ARTWORKS_URL}#{params}")
    return "No data found" if !response

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
      artist = JSON.parse(RestClient.get "#{ARTIST_URL}?id=#{id}")[0].transform_keys!(&:to_sym)
      artist_name.push(artist[:name])
    end
    output = {}
    output[:id] = ids
    output[:for_sale] = for_sale
    output[:soldPrimaryCount] = sold_primary_count
    output[:artistNames] = artist_name.sort
    output[:previousPage] = page == 1 ? nil : page - 1
    output[:nextPage] = page + 1
    output
  end

end

client = Client.new
p client.retrieve
# p client.retrieve({ page: 2, dominant_color: ["red", "brown"] })
