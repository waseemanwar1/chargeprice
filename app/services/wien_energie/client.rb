require 'net/http'
require 'json'
require 'uri'

module WienEnergie
  class Client
    API_URL = 'https://www.wienenergie.at/wp-admin/admin-ajax.php'

    def fetch_stations
      uri = URI(API_URL)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request['Accept'] = 'application/json'

      request.set_form_data(payload)

      response = http.request(request)
      JSON.parse(response.body)
    end

    private

    def payload
      {
        northLat: 48.3909122900258,
        eastLng: 17.00311060791015,
        southLat: 48.02483352261578,
        westLng: 15.744489392089838,
        action: 'we_theme_tanke_fetch_poi',
        _ajax_nonce: 'e266481bda'
      }
    end
  end
end
