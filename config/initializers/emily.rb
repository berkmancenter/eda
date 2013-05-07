Eda::Application.config.emily = YAML.load_file(Rails.root.join('config', 'emily.yml'))[Rails.env]
