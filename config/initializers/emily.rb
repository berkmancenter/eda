Eda::Application.config.emily = YAML.load_file(Rails.root.join('config', 'emily.yml'))[Rails.env]
if ActiveRecord::Base.connection.table_exists? 'editions'
    Eda::Application.config.emily['default_edition'] = Edition.find_by_short_name(Eda::Application.config.emily['default_edition'])
end
