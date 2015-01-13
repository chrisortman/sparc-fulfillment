# Easily accessed variables
# Prevents having to do <%= %> every time
arm_id = <%= @arm.id %>
page = <%= @page %>
visit_count = <%= @arm.visit_count %>

# Set new pages
$("#arrow-left-#{arm_id}").attr('page', page - 1)
$("#arrow-right-#{arm_id}").attr('page', page + 1)
# Disable arrows if needed
disable_left = page == 1
$("#arrow-left-#{arm_id}").attr('disabled', disable_left)
disable_right = visit_count - page * <%= Visit.per_page %> < 0
$("#arrow-right-#{arm_id}").attr('disabled', disable_right)

# Overwrite the visit_groups
$(".visit_groups_for_#{arm_id}").html("<%= escape_javascript(render partial: '/service_calendar/visit_groups', locals: {arm: @arm, page: @page, visit_groups: @visit_groups}) %>")
# Overwrite the check columns
$(".check_columns_for_arm_#{arm_id}").html("<%= escape_javascript(render partial: '/service_calendar/check_visit_columns', locals: {visit_groups: @visit_groups}) %>")

# Overwrite the visits
<% @arm.line_items.each do |line_item| %>
$(".visits_for_line_item_<%= line_item.id %>").html("<%= escape_javascript(render partial: '/service_calendar/visits', locals: {line_item: line_item, page: @page, tab: @tab}) %>")
<% end %>

# Set the dropdown to the selected page
$("#visits_select_for_#{arm_id}").val(page)
# Set the current page for early out in javascript
$("#visits_select_for_#{arm_id}").attr('page', page)