# Wien Energie Stations

A Rails application that fetches charging station data from Wien Energie API and exports it to CSV format.

## Project Overview

This project fetches EV charging station information from Wien Energie's public API, processes the data, filters stations by operator (VIE and VNA only), and exports the results to a CSV file. The application uses a service-oriented architecture with no database dependency.

## Architecture

The project follows a service-oriented architecture with three main service classes:

### 1. **WienEnergie::Client** 
Handles API communication with Wien Energie's endpoint:
- Makes POST requests to `https://www.wienenergie.at/wp-admin/admin-ajax.php`
- Sends required parameters including geographic bounds and action identifiers
- Returns parsed JSON response containing station data

### 2. **WienEnergie::StationMapper**
Processes raw API data:
- Filters stations by allowed operators (VIE, VNA)
- Normalizes connector types to standardized format
- Creates one row per connector (stations can have multiple connectors)
- Formats address data and extracts geographic coordinates
- Extracts power specifications per connector

### 3. **WienEnergie::CsvExporter**
Exports processed data to CSV:
- Creates properly formatted CSV files
- Includes headers: name, address, longitude, latitude, operator_id, connector, power
- Handles file creation and writing

## Setup Instructions

### Requirements
- Ruby 3.2.2
- Rails 7.1.5+
- Bundler

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd wien_energie_stations
```

2. Install dependencies:
```bash
bundle install
```

3. Note: This application does not use a database, so no database setup is required.

## Running the Application

### Fetch Data and Generate CSV

To fetch station data from Wien Energie and generate the CSV file:

```bash
bundle exec rake wien_energie:fetch
```

This command will:
1. Fetch charging station data from the Wien Energie API
2. Filter stations by operator (VIE and VNA only)
3. Process each connector separately
4. Generate `wien_energie_stations.csv` in the project root directory

**Output File Location:** `wien_energie_stations.csv`

### CSV File Format

The generated CSV contains the following columns:

| Column | Description |
|--------|-------------|
| name | Station name |
| address | Full formatted address (street, postcode, city) |
| longitude | Geographic longitude (float) |
| latitude | Geographic latitude (float) |
| operator_id | Operator identifier (VIE or VNA) |
| connector | Connector type (type2, chademo, ccs, etc.) |
| power | Charging power in kW for this connector |

**Example CSV Output:**
```
name,address,longitude,latitude,operator_id,connector,power
Wipark Garage Lehargasse,"Lehargasse 2, 1060 Wien",16.363769999999999,48.20037099999999,VIE,type2,11
Wipark Garage Lehargasse,"Lehargasse 2, 1060 Wien",16.363769999999999,48.20037099999999,VIE,chademo,50
```

## Running Tests

The project uses RSpec for testing. All service classes have comprehensive test coverage.

### Run All Specs

```bash
bundle exec rspec
```

### Run Specific Test File

```bash
bundle exec rspec spec/services/wien_energie/client_spec.rb
bundle exec rspec spec/services/wien_energie/station_mapper_spec.rb
```

### Test Coverage

#### Client Tests (`spec/services/wien_energie/client_spec.rb`)
- Verifies API endpoint communication
- Mocks HTTP requests using webmock
- Tests JSON response parsing
- Validates correct request parameters

#### StationMapper Tests (`spec/services/wien_energie/station_mapper_spec.rb`)
- Filters stations by operator (VIE/VNA only)
- Creates one row per connector
- Formats addresses correctly
- Normalizes connector types (IEC_62196_T2 → type2, CHADEMO → chademo, etc.)
- Extracts correct power values per connector
- Converts coordinates to float values

## Configuration

The application is configured as a Rails API without a database:

- **Database:** Not used (configured with in-memory SQLite3 for Rails compatibility)
- **Environment Variables:** None required for basic operation
- **API Endpoint:** Wien Energie's `/wp-admin/admin-ajax.php` endpoint
- **API Parameters:** Geographic bounds covering Vienna area

## Key Implementation Details

### Approach

1. **API Fetching:** Uses `Net::HTTP` to make authenticated requests to Wien Energie's API
2. **Data Processing:** Maps raw API responses to structured data with normalized connector types
3. **Filtering:** Only includes stations operated by VIE (Wien Energie) and VNA (Vienna National Chargers)
4. **Normalization:** Converts connector type standards (IEC_62196_T2, CHADEMO, etc.) to user-friendly formats
5. **CSV Export:** Exports structured data with proper formatting

### Service Dependencies

- **webmock** (test environment): Mocks HTTP requests in tests
- **rspec-rails**: Testing framework
- **Standard Rails libraries**: JSON parsing, HTTP communication

## Development

### Code Structure

```
app/
  services/
    wien_energie/
      client.rb              # API communication
      station_mapper.rb      # Data processing
      csv_exporter.rb        # CSV generation

spec/
  services/
    wien_energie/
      client_spec.rb         # API tests
      station_mapper_spec.rb # Data processing tests
```

## Notes

- The application does not use ActiveRecord or any database persistence
- API responses are processed in-memory and exported to CSV
- The API requires specific geographic bounds for Vienna (already configured)
- Connector types are normalized to lowercase, hyphenated format
- Each charging connector is exported as a separate row in the CSV


## I tried to follow Ruby standards and here is the list:

- **Single Responsibility:** The class has one clear job—transforming raw station data—making it easy to understand and maintain.
- **Readable & Decomposed:** Complex logic is broken into small, well‑named private methods; the public `#map` reads like a high‑level description.
- **Defensive & Resilient:** Fallbacks, safe navigation, and handling of missing fields prevent crashes and produce clean output.
- **Configuration via Constants:** Allowed operators and connector mappings are centralised, making updates easy and keeping code DRY.
- **Consistent Normalization:** Connector types are mapped to a fixed set of strings with a sensible default, ensuring predictable downstream use.
- **Testability:** Small, focused methods allow easy unit testing of each piece of logic in isolation.
- **Efficient & Idiomatic:** Uses `flat_map` + `compact` for collections, `case` for mapping, and Ruby best practices throughout.
- **Pragmatic Error Handling:** Instead of raising on missing data, it gracefully falls back to empty strings or zeros—ideal for data pipelines.
- **Easy to Extend:** Adding new operators or connector types requires changes in only one place (open/closed principle).
- **Ruby‑Native Style:** The code feels natural to Ruby developers, enhancing readability and collaboration.

That's why I think it's best approach.

Regard's
Waseem Anwar
