require 'csv'

module WienEnergie
  class CsvExporter
    HEADERS = %w[
      Name Address Longitude Latitude OperatorID Connector Power
    ]

    def self.export(rows, file_path)
      CSV.open(file_path, "w", write_headers: true, headers: HEADERS) do |csv|
        rows.each do |row|
          csv << [
            row[:name],
            row[:address],
            row[:longitude],
            row[:latitude],
            row[:operator_id],
            row[:connector],
            row[:power]
          ]
        end
      end
    end
  end
end
