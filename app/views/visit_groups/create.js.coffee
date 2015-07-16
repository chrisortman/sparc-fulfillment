$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>")
<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('application/flash')) %>")
$("#modal_place").modal 'hide'

# update dropdown to page visit groups
$("#select_for_arm_<%= @arm.id %>").html("<%= escape_javascript(render partial: '/study_schedule/visit_group_page_select', locals: {arm: @arm, page: @current_page.to_i}) %>")

# re-render Manage Visits dropdown
$("#manage_visit_groups").html("<%= escape_javascript(render partial: '/study_schedule/study_schedule_management/visit_groups_selectpicker', locals: {protocol: @arm.protocol}) %>")
# and create associated selectpicker
$(".selectpicker").selectpicker()

<% if on_current_page?(@current_page, @visit_group) %>
# Overwrite the visit_groups
$(".visit_groups_for_<%= @arm.id %>").html("<%= escape_javascript(render partial: '/study_schedule/visit_groups', locals: { arm: @arm, visit_groups: @visit_groups, tab: @schedule_tab }) %>")
# Overwrite the check columns
$(".check_columns_for_arm_<%= @arm.id %>").html("<%= escape_javascript(render partial: '/study_schedule/check_visit_columns', locals: { visit_groups: @visit_groups, tab: @schedule_tab }) %>")
# Overwrite the visits
<% @arm.line_items.each do |line_item| %>
$(".visits_for_line_item_<%= line_item.id %>").html("<%= escape_javascript(render partial: '/study_schedule/visits', locals: {line_item: line_item, page: @current_page, tab: @schedule_tab}) %>")
<% end %>
<% end %>
<% end %>

$("div#manage_visit_groups [data-toggle='tooltip']").tooltip()
