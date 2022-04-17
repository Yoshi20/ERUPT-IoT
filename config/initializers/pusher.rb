require 'pusher/push_notifications'

Pusher::PushNotifications.configure do |config|
  config.instance_id = 'cce6bd24-139c-495e-809e-39580b8ba006'
  config.secret_key = '896F933B0167EB8B91A4A68BD2FFA65E0A69533C5C5231BC5F0A78C43579257C'
end
