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
    if option != ''
      colors = option[:dominant_color] if option.has_key?(:dominant_color) && option[:dominant_color].is_a?(Array)
      if colors
        params.concat(colors.join('&dominant_color[]=').prepend('&dominant_color[]=')) if colors.all? { |clr| clr.is_a?(String) }
      end
      page = option.has_key?(:page) && option[:page].is_a?(Integer) ? option[:page] : 1
      next_params = "#{params}&offset=#{page * LIMIT}"
      params.concat("&offset=#{(option[:page] - 1) * LIMIT}") unless page == 1
    else
      page = 1
      next_params = "#{params}&offset=#{LIMIT}"
    end
    response = JSON.parse(RestClient.get "#{ARTWORKS_URL}#{params}")
    next_response = JSON.parse(RestClient.get "#{ARTWORKS_URL}#{next_params}")
    ids = []
    for_sale = []
    sold_primary_count = 0
    artist_name = []
    if response
      artist_id = []
      response.each do |artwork|
        artwork.transform_keys!(&:to_sym)
        ids.push(artwork[:id])
        artwork[:isPrimary] = ['red', 'blue', 'yellow'].include?(artwork[:dominant_color]) if ['red', 'blue', 'yellow'].include?(artwork[:dominant_color])
        for_sale.push(artwork) if artwork[:availability] == 'for_sale'
        sold_primary_count += 1 if artwork[:availability] == 'sold' && artwork[:isPrimary]
        artist_id.push(artwork[:artist_id]) unless artist_id.include?(artwork[:artist_id])
      end
      artist_id.each do |id|
        artist = JSON.parse(RestClient.get "#{ARTIST_URL}?id=#{id}")[0].transform_keys!(&:to_sym)
        artist_name.push(artist[:name])
      end
    end
    output = {}
    output[:ids] = ids
    output[:for_sale] = for_sale
    output[:soldPrimaryCount] = sold_primary_count
    output[:artistNames] = artist_name.sort
    output[:previousPage] = page == 1 ? nil : page - 1
    output[:nextPage] = next_response.nil? || next_response.size == 0 ? nil : page + 1
    output
  end

end

client = Client.new
# p client.retrieve
# p client.retrieve({ page: 50 })
# p client.retrieve({ page: 2, dominant_color: ["red", "brown"] })
p client.retrieve({ page: 10, dominant_color: ["brown"] })
