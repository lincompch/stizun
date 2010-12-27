
# Thanks to Ryan Bates
# http://railscasts.com/episodes/85-yaml-configuration-file

APP_CONFIG = YAML.load_file("#{Rails.root}/config/stizun.yml")[Rails.env]
