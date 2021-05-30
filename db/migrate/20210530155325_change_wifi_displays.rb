class ChangeWifiDisplays < ActiveRecord::Migration[6.1]
  def up
    add_column :wifi_displays, :name, :string
    WifiDisplay.all.each do |d|
      name = d.dns.gsub('.local', '')
      d.update(name: name)
    end
    remove_column :wifi_displays, :dns
    remove_column :wifi_displays, :path
    remove_column :wifi_displays, :ip
  end

  def down
    add_column :wifi_displays, :ip, :string
    add_column :wifi_displays, :path, :string
    add_column :wifi_displays, :dns, :string
    WifiDisplay.all.each do |d|
      dns = d.name + '.local'
      d.update(dns: dns)
    end
    remove_column :wifi_displays, :name
  end
end
