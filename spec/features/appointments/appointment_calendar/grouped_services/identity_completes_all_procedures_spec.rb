require 'rails_helper'

feature 'Identity completes all Services', js: true do

  before :each do
    @protocol    = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first
    @appointment = @participant.appointments.first
    @services    = @protocol.organization.inclusive_child_services(:per_participant)
  end

  context 'in a Core with a ungrouped procedure and grouped procedures' do
    before :each do
      given_i_am_viewing_a_started_visit
      when_i_add_a_grouped_procedure_and_ungrouped_procedure
    end

    scenario 'and sees that all selected Procedures are completed' do
      and_i_select_the_procedure_in_the_core_dropdown
      and_i_click_complete_all
      then_i_should_see_a_complete_all_modal
      with_a_default_completed_date_of_current_date
      when_i_save_the_modal
      then_i_should_see_all_selected_procedures_completed
    end

    scenario 'and sees that all selected Procedures are completed' do
      and_i_select_all_in_the_core_dropdown
      and_i_click_complete_all
      then_i_should_see_a_complete_all_modal
      when_i_save_the_modal
      then_i_should_see_all_procedures_completed
    end 
  end

  def when_i_add_a_grouped_procedure_and_ungrouped_procedure
    add_a_procedure @services.first, 1
    add_a_procedure @services.last, 2
  end

  def and_i_select_the_procedure_in_the_core_dropdown
    bootstrap_multiselect '#core_multiselect', [@services.last.name]
    wait_for_ajax
  end

  def and_i_click_complete_all
    find('button.complete_all').click
    wait_for_ajax
  end

  def then_i_should_see_all_selected_procedures_completed
    expect(page).to have_css('label.status.complete.active', count: 2)
    expect(Procedure.where(service_id: @services.last.id).first.status).to eq("complete")
    expect(Procedure.where(service_id: @services.last.id).last.status).to eq("complete")
  end

  def then_i_should_see_a_complete_all_modal
    expect(page).to have_text("Complete Multiple Services")
  end

  def with_a_default_completed_date_of_current_date
    expected_date = page.evaluate_script %Q{ $('.date_field').first().val(); }
    expect(expected_date).to eq(DateTime.current.strftime('%m/%d/%Y'))
  end

  def when_i_save_the_modal
    find('button.save').click
  end

  def and_i_select_all_in_the_core_dropdown
    bootstrap_multiselect '#core_multiselect'
  end

  def then_i_should_see_all_procedures_completed
    expect(page).to have_css('label.status.complete.active', count: 3)
    expect(Procedure.where(service_id: @services.last.id).first.status).to eq("complete")
    expect(Procedure.where(service_id: @services.last.id).last.status).to eq("complete")
    expect(Procedure.where(service_id: @services.first.id).last.status).to eq("complete")
  end
end
