# Static tables:
DeviceType.create([
  { name: 'LoRa-Panel',     number_of_buttons: 6 },
  { name: 'LoRa-EPD-4Btns', number_of_buttons: 4 },
  { name: 'LoRa-EPD-2Btns', number_of_buttons: 2 },
  { name: 'LoRa-Wristband', number_of_buttons: 1 }
])

# Admins:
yomi = User.find_by_email('jascha_haldemann@hotmail.com')
if yomi.present?
  yomi.update(is_admin: true)
end
