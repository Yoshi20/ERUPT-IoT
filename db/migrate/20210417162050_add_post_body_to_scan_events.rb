class AddPostBodyToScanEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :scan_events, :post_body, :string

  end
end
