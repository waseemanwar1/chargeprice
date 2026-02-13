namespace :wien_energie do
  desc "Fetch Wien Energie stations and generate CSV"
  task fetch: :environment do
    client = WienEnergie::Client.new
    raw_data = client.fetch_stations

    mapper = WienEnergie::StationMapper.new(raw_data)
    rows = mapper.map

    file_path = Rails.root.join("wien_energie_stations.csv")

    WienEnergie::CsvExporter.export(rows, file_path)

    puts "CSV generated at #{file_path}"
  end
end
