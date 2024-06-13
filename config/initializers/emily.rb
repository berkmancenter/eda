Rails.application.config.to_prepare do
  Eda::Application.config.emily = YAML.load_file(Rails.root.join('config', 'emily.yml'))[Rails.env]
  if ActiveRecord::Base.connection.table_exists? 'editions'
    Eda::Application.config.emily['default_edition'] = Edition.where(short_name: Eda::Application.config.emily['default_edition']).first
  end
end
