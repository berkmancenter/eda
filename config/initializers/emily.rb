Eda::Application.config.emily = YAML.load_file(Rails.root.join('config', 'emily.yml'))[Rails.env]
Eda::Application.config.emily['default_edition'] = Edition.find_by_short_name(Eda::Application.config.emily['default_edition'])
