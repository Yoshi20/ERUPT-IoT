class Member < ApplicationRecord
  has_many :abo_types_members
  has_many :abo_types, through: :abo_types_members
  has_many :scan_events, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :card_id, uniqueness: true, allow_blank: true

  def new?
    (!self.active || !self.card_id.present?) && self.created_at.today?
  end

  def self.sync_with_ggleap_users
    jwt = Request::ggleap_auth
    ggleap_users = Request::ggleap_users(jwt)
    # all_member_emails = Member.select(:email).all.map{ |m| m.email }.uniq.compact
    # ggleap_emails = ggleap_users.map{ |u| u["Email"] }.uniq.compact
    # missing_emails = ggleap_emails - all_member_emails
    ggleap_users.each do |u|
      # create or update
      member = Member.find_or_create_by(email: u["Email"])
      puts "-> Updating \"#{member.email}\""
      member.update(
        first_name: u["FirstName"] || '',
        last_name: u["LastName"] || '',
        mobile_number: u["Phone"],
        magma_coins: u["Balance"],
        ggleap_uuid: u["Uuid"],
        wants_newsletter_emails: true,
        wants_event_emails: true,
        locked: u["Locked"],
      )
    end
    return ggleap_users.any?
  end

end
