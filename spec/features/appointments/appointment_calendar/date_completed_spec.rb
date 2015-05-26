require 'rails_helper'

feature 'Date completed', js: true do

  scenario 'User sees disabled datepicker when :date_completed is not set' do
    given_i_am_viewing_an_appointment
    when_i_add_a_procedure
    then_i_should_see_a_disabled_datepicker
  end

  scenario 'User marks Procedure as complete and sees :date_completed updated and enabled' do
    given_i_am_viewing_a_procedure
    after_appointment_has_started
    when_i_complete_the_procedure
    then_i_should_see_an_enabled_datepicker_with_the_current_date
  end

  scenario 'User marks Procedure as incomplete and sees :date_completed disabled' do
    given_i_am_viewing_a_completed_procedure
    when_i_incomplete_the_procedure
    then_i_should_see_a_disabled_datepicker
  end

  def given_i_am_viewing_a_complete_procedure
    given_i_am_viewing_a_procedure
    when_i_complete_the_procedure
  end

  def given_i_am_viewing_an_appointment
    protocol      = create(:protocol_imported_from_sparc)
    @participant  = protocol.participants.first

    visit participant_path(@participant)
  end

  def given_i_am_viewing_a_procedure
    given_i_am_viewing_an_appointment
    when_i_add_a_procedure
  end

  def given_i_am_viewing_a_completed_procedure
    given_i_am_viewing_a_procedure
    after_appointment_has_started
    when_i_complete_the_procedure
  end

  def after_appointment_has_started
    find('button.start_visit').click
  end

  def when_i_complete_the_procedure
    find('label.status.complete').click
  end

  def when_i_incomplete_the_procedure
    reason = Procedure::NOTABLE_REASONS.first

    find('label.status.incomplete').click
    select reason, from: 'procedure_notes_attributes_0_reason'
    fill_in 'procedure_notes_attributes_0_comment', with: 'Test comment'
    click_button 'Save'
  end

  def when_i_add_a_procedure
    visit_group = @participant.appointments.first.visit_group
    service     = Service.per_participant_visits.first
    bootstrap_select('#appointment_select', visit_group.name)
    wait_for_ajax
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: '1'
    page.find('button.add_service').click
  end

  def then_i_should_see_a_disabled_datepicker
    expect(page).to have_css(".completed-date input[disabled]")
  end

  def then_i_should_see_an_enabled_datepicker_with_the_current_date
    expect(page).to_not have_css(".completed_date_field input[disabled]")
    expect(page).to have_css("input[value='#{Time.current.strftime('%m/%d/%Y')}']")
  end
end