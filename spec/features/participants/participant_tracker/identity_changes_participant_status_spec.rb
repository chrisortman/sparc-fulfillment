require 'rails_helper'

feature 'Identity changes the status of a participant on the participant tracker', js: true do

  scenario 'and sees the updated status on the page' do
    given_a_protocol_with_participants
    when_i_update_the_participant_status
    then_i_should_see_the_updated_status
  end

  def given_a_protocol_with_participants
    @protocol    = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first
    visit protocol_path @protocol.id
    click_link 'Participant Tracker'
  end

  def when_i_update_the_participant_status
    bootstrap_select = page.find("select.participant_#{@participant.id} + .bootstrap-select")
    bootstrap_select.click
    first(".participant_#{@participant.id}.bootstrap-select a", text: "Screening").click
    wait_for_ajax
  end

  def then_i_should_see_the_updated_status
    expect(bootstrap_selected?("participant_status_#{@participant.id}", "Screening")).to be
  end
end