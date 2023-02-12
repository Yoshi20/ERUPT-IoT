Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://iframetester.com:443'
    resource '/games_for_iframe', headers: :any, methods: [:get]
    # resource '/feedbacks/extern', headers: :any, methods: [:get]
    # resource '/members/extern', headers: :any, methods: [:get]
  end

  allow do
    origins 'https://www.erupt.ch:443'
    resource '/games_for_iframe', headers: :any, methods: [:get]
    # resource '/feedbacks/extern', headers: :any, methods: [:get]
    # resource '/members/extern', headers: :any, methods: [:get]
  end

end
