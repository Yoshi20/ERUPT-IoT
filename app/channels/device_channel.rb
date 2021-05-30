class DeviceChannel < ApplicationCable::Channel
  def subscribed
    stream_from params['name']  # device name from the WifiDisplay
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
