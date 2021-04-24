class AddCardIdToScanEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :scan_events, :card_id, :string

    ScanEvent.all.each do |se|
      if se.card_id == nil
        i = se.post_body.index('UID') + 7
        se.update(card_id: se.post_body[i... se.post_body.index(',', i)-1])
      end
    end

  end
end
