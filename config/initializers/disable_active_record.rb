# Disable ActiveRecord since this application does not use a database
Rails.application.config.to_prepare do
  # Prevent Rails from trying to connect to a database
  if defined?(ActiveRecord)
    ActiveRecord::Railtie.instance_variable_set(:@load_active_record, false)
  end
end
