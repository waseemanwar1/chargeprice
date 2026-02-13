require 'rails_helper'

RSpec.describe WienEnergie::StationMapper do
  describe '#map' do
    let(:raw_data) do
      {
        "data" => [
          {
            "name" => "Wipark Garage Lehargasse",
            "address" => "Lehargasse 2",
            "postcode" => "1060",
            "city" => "Wien",
            "coordinates" => { "lat" => "48.20037099999999", "lng" => "16.363769999999999" },
            "operatorEvseId" => "VIE",
            "connectorTypes" => [
              { "standard" => "IEC_62196_T2" },
              { "standard" => "CHADEMO" }
            ],
            "chargersChargingPowerInKw" => [11, 50],
            "maxChargingPowerInKw" => 50
          },
          {
            # This station should be filtered out (wrong operator)
            "name" => "Other Operator Station",
            "address" => "Test Street 1",
            "postcode" => "1010",
            "city" => "Wien",
            "coordinates" => { "lat" => "48.1", "lng" => "16.1" },
            "operatorEvseId" => "SMA",
            "connectorTypes" => [
              { "standard" => "IEC_62196_T2" }
            ],
            "chargersChargingPowerInKw" => [22]
          }
        ]
      }
    end

    it 'returns only VIE and VNA stations' do
      mapper = described_class.new(raw_data)
      result = mapper.map

      expect(result.all? { |row| %w[VIE VNA].include?(row[:operator_id]) }).to be true
    end

    it 'creates one row per connector' do
      mapper = described_class.new(raw_data)
      result = mapper.map

      expect(result.size).to eq(2) # only VIE station, 2 connectors
    end

    it 'formats address correctly' do
      mapper = described_class.new(raw_data)
      result = mapper.map

      expect(result.first[:address]).to eq("Lehargasse 2, 1060 Wien")
    end

    it 'maps connector types correctly' do
      mapper = described_class.new(raw_data)
      result = mapper.map

      expect(result.map { |r| r[:connector] }).to contain_exactly("type2", "chademo")
    end

    it 'extracts correct power per connector' do
      mapper = described_class.new(raw_data)
      result = mapper.map

      expect(result.map { |r| r[:power] }).to contain_exactly(11, 50)
    end

    it 'converts coordinates to float' do
      mapper = described_class.new(raw_data)
      result = mapper.map

      expect(result.first[:longitude]).to be_a(Float)
      expect(result.first[:latitude]).to be_a(Float)
    end
  end
end
