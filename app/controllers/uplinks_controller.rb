class UplinksController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # POST /lora_uplink
  # POST /lora_uplink.json
  def lora_uplink
    dev_eui = params['uplink']['end_device_ids']['dev_eui']
    device = Device.find_by(dev_eui: dev_eui)
    return head :not_found if device.nil?
    payload_raw = params['uplink']['uplink_message']['frm_payload']
    payload = Base64.decode64(payload_raw).bytes.map{|b| sprintf("%02X", b)}.join
    event = nil
    lora_message_id = payload[0...2]
    ActiveRecord::Base.transaction do
      case lora_message_id
      # when "00"  # heartbeat
      # when "20"  # any button clicked
      # when "21"  # any button clicked with image ID
      # when "22"  # specific button clicked
      when "30"  # Oxobutton event (https://oxobutton.ch/products/oxobutton-lorawan/documentation#uplink))
        button_number = payload[2..3].to_i(16) unless payload[2..3].nil?
        is_heartbeat = payload[4..5].to_i(16) != 0 unless payload[4..5].nil?
        image_code = payload[8..11]
        battery = payload[12..13].to_i(16) unless payload[12..13].nil?
        temperature = payload[14..15].to_i(16) unless payload[14..15].nil?
        device.update(battery: battery, last_time_seen: Time.now)
        unless is_heartbeat
          event = Order.create!(
            title: device.name,
            text: "btnNr=#{button_number}; imgCode=#{image_code}; bat=#{battery}; temp=#{temperature}",
            data: params.to_json.to_s,
            device_id: device.id,
          )
          ActionCable.server.broadcast('OrdersChannel', event)
          open_order_ctr = Order.open.count
          WifiDisplay.all.each do |disp|
            ActionCable.server.broadcast(
              disp.name,
              {
                open_order_ctr: open_order_ctr,
                beep: 1,
              }
            )
          end
        end
      else
        raise "lora_message_id: \"#{lora_message_id}\" is invalid"
      end
      render json: event, status: :created
    rescue => errors
      render json: errors, status: :unprocessable_entity
    end
  end

end
