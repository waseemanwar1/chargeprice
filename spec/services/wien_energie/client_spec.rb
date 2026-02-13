require 'rails_helper'

RSpec.describe WienEnergie::Client do
  describe '#fetch_stations' do
    it 'posts to ajax endpoint and parses JSON response' do
      fake_response = {
        "data" => [
          {
            "operatorEvseId" => "VIE",
            "name" => "Test Station"
          }
        ]
      }

      stub_request(:post, "https://www.wienenergie.at/wp-admin/admin-ajax.php")
        .with(
          body: hash_including(
            "action" => "we_theme_tanke_fetch_poi"
          )
        )
        .to_return(
          status: 200,
          body: fake_response.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

      client = described_class.new
      result = client.fetch_stations

      expect(result['data']).to be_present
      expect(result['data'].first["operatorEvseId"]).to eq("VIE")
    end
  end
end
