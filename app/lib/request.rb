module Request

  require 'httparty'
  require 'json'

  def self.ggleap_auth
    Rails.cache.fetch("ggleap_auth", expires_in: 5.minutes) do
      jwt = nil
      url = "https://api.ggleap.com/production/authorization/public-api/auth"
      params = {
        "AuthToken": ENV['GGLEAP_API_TOKEN']
      }
      puts "Requesting: POST #{url}"
      begin
        resp = HTTParty.post(url,
          body: params.to_json,
          headers: {
            'Content-Type': 'application/json'
          }
        )
        if resp.success?
          jwt = resp.parsed_response["Jwt"]
        end
      rescue HTTParty::Error => ex
        puts ex
      end
      jwt
    end
  end

  def self.ggleap_users(jwt)
    users = []
    url = "https://api.ggleap.com/production/users/summaries"
    puts "Requesting: GET #{url}"
    begin
      resp = HTTParty.get(url,
        headers: {
          'Authorization': "Bearer #{jwt}"
        }
      )
      if resp.success?
        users = resp.parsed_response["Users"]
      end
    rescue HTTParty::Error => ex
      puts ex
    end
  end

  def self.ggleap_user(jwt, uuid)
    user = nil
    url = "https://api.ggleap.com/production/users/user-details?Uuid=#{uuid}"
    puts "Requesting: GET #{url}"
    begin
      resp = HTTParty.get(url,
        headers: {
          'Authorization': "Bearer #{jwt}"
        }
      )
      if resp.success?
        user = resp.parsed_response["User"]
      end
    rescue HTTParty::Error => ex
      puts ex
    end
  end

  def self.ggleap_apps(jwt)
    Rails.cache.fetch("ggleap_apps", expires_in: 1.day) do
      apps = []
      url = "https://api.ggleap.com/production/apps/get-enabled-apps-summary"
      puts "Requesting: GET #{url}"
      begin
        resp = HTTParty.get(url,
          headers: {
            'Authorization': "Bearer #{jwt}"
          }
        )
        if resp.success?
          apps = resp.parsed_response["Apps"]
        end
      rescue HTTParty::Error => ex
        puts ex
      end
      apps
    end
  end

  def self.ggleap_products(jwt)
    Rails.cache.fetch("ggleap_products", expires_in: 1.day) do
      products = []
      url = "https://api.ggleap.com/production/pos/products/get-all"
      puts "Requesting: GET #{url}"
      begin
        resp = HTTParty.get(url,
          headers: {
            'Authorization': "Bearer #{jwt}"
          }
        )
        if resp.success?
          products = resp.parsed_response["Products"]
        end
      rescue HTTParty::Error => ex
        puts ex
      end
      products
    end
  end

  def self.ggleap_sell_product(jwt, product_uuid, product_price, user_uuid)
    resp_body = nil
    url = "https://api.ggleap.com/beta/pos/sales/create"
    # url = "https://api.ggleap.com/production/pos/sales/create"
    params = {
      "Cart": {
        product_uuid.to_sym => 1
      },
      "UserUuid": user_uuid,
      "FromUserBalance": nil,
      "Cash": product_price,
      "Card": nil,
      "AddChangeToUserAccount": false,
      "QuickDiscountPercent": 0,
      "CouponCode": nil
    }
    puts "Requesting: POST #{url}"
    begin
      resp = HTTParty.post(url,
        body: params.to_json,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer #{jwt}"
        }
      )
      if resp.success?
        resp_body = resp.parsed_response
      end
    rescue HTTParty::Error => ex
      puts ex
    end
    resp_body
  end

end

# Example:
# jwt = Request::ggleap_auth
# users = Request::ggleap_users(jwt)
# users.each do |u|
#   puts u["Email"]
# end
