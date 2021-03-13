json.extract! member, :id, :first_name, :last_name, :email, :birthdate, :mobile_number, :gender, :canton, :comment, :wants_newsletter_emails, :wants_event_emails, :card_id, :magma_coins, :expiration_date, :number_of_scans, :created_at, :updated_at
json.url member_url(member, format: :json)
