class TwitterSettings < Settingslogic
  namespace Rails.env
  source Rails.root.join('config', 'twitter.yml')
end