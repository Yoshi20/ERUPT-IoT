module ScanEventHelper

  def member_ids_no_card_id
    Member.where(card_id: [nil, ""]).map{ |m| m.id }
  end

  def member_names_no_card_id
    Member.where(card_id: [nil, ""]).map{ |m| "#{m.email}" }
  end

  def members_no_card_id_for_select
    member_names_no_card_id.zip(member_ids_no_card_id).sort
  end

end
