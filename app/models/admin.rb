class Admin < Settingslogic
  namespace Rails.env
  source Rails.root.join('config', 'admin.yml')
end