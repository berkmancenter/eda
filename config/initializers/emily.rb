Eda::Application.config.emily = YAML.load_file(Rails.root.join('config', 'emily.yml'))[Rails.env]
#Eda::Application.config.emily['placeholder_image'] = Image.find_by_credits('PLACEHOLDER')
