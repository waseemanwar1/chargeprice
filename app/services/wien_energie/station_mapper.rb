module WienEnergie
  class StationMapper
    ALLOWED_OPERATORS = %w[VIE VNA].freeze
    CONNECTOR_MAPPING = {
      "IEC_62196_T2"       => "type2",
      "IEC_62196_T2_COMBO" => "ccs",
      "CHADEMO"            => "chademo"
    }.freeze
    DEFAULT_CONNECTOR = "other".freeze

    def initialize(raw_data)
      @raw_data = raw_data
    end

    def map
      stations.flat_map do |station|
        next unless valid_operator?(station)

        connectors_for_station(station).map do |connector_data|
          build_connector_hash(station, connector_data)
        end
      end.compact
    end

    private

    def stations
      @raw_data.fetch("data", [])
    end

    def valid_operator?(station)
      ALLOWED_OPERATORS.include?(station["operatorEvseId"])
    end

    def connectors_for_station(station)
      connector_types = station.dig("connectorTypes") || []
      connector_types.each_with_index.map do |connector_type, index|
        {
          standard: connector_type["standard"],
          index: index,
          power: extract_connector_power(station, index)
        }
      end
    end

    def extract_connector_power(station, index)
      per_connector_powers = station["chargersChargingPowerInKw"] || []
      per_connector_powers[index] || station["maxChargingPowerInKw"]
    end

    def build_connector_hash(station, connector_data)
      {
        name: station["name"].to_s,
        address: formatted_address(station),
        longitude: longitude(station),
        latitude: latitude(station),
        operator_id: station["operatorEvseId"],
        connector: normalize_connector(connector_data[:standard]),
        power: connector_data[:power].to_i
      }
    end

    def formatted_address(station)
      parts = [
        station["address"],
        station["postcode"],
        station["city"]
      ].reject { |part| part.to_s.empty? }
      parts.join(", ")
    end

    def longitude(station)
      (station.dig("coordinates", "lng") || station["lng"]).to_f
    end

    def latitude(station)
      (station.dig("coordinates", "lat") || station["lat"]).to_f
    end

    def normalize_connector(standard)
      CONNECTOR_MAPPING.fetch(standard, DEFAULT_CONNECTOR)
    end
  end
end
