class ScanEventsChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'ScanEventsChannel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
