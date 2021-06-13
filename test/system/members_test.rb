require "application_system_test_case"

class MembersTest < ApplicationSystemTestCase
  setup do
    @member = members(:one)
  end

  test "visiting the index" do
    visit members_url
    assert_selector "h1", text: "Members"
  end

  test "creating a Member" do
    visit members_url
    click_on "New Member"

    fill_in "Birthdate", with: @member.birthdate
    fill_in "Canton", with: @member.canton
    fill_in "Card", with: @member.card_id
    fill_in "Comment", with: @member.comment
    fill_in "Email", with: @member.email
    fill_in "First name", with: @member.first_name
    fill_in "Gender", with: @member.gender
    fill_in "Last name", with: @member.last_name
    fill_in "Magma coins", with: @member.magma_coins
    fill_in "Mobile number", with: @member.mobile_number
    check "Wants event emails" if @member.wants_event_emails
    check "Wants newsletter emails" if @member.wants_newsletter_emails
    click_on "Create Member"

    assert_text "Member was successfully created"
    click_on "Back"
  end

  test "updating a Member" do
    visit members_url
    click_on "Edit", match: :first

    fill_in "Birthdate", with: @member.birthdate
    fill_in "Canton", with: @member.canton
    fill_in "Card", with: @member.card_id
    fill_in "Comment", with: @member.comment
    fill_in "Email", with: @member.email
    fill_in "First name", with: @member.first_name
    fill_in "Gender", with: @member.gender
    fill_in "Last name", with: @member.last_name
    fill_in "Magma coins", with: @member.magma_coins
    fill_in "Mobile number", with: @member.mobile_number
    check "Wants event emails" if @member.wants_event_emails
    check "Wants newsletter emails" if @member.wants_newsletter_emails
    click_on "Update Member"

    assert_text "Member was successfully updated"
    click_on "Back"
  end

  test "destroying a Member" do
    visit members_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Member was successfully destroyed"
  end
end
