$("#modal_area").html("<%= escape_javascript(render(:partial =>'protocols/study_schedule/line_item_form', locals: {header_text: 'Add a Service', button_text: 'Add Service', services: @services, protocol: @protocol, selected_service: @selected_service, page_hash: @page_hash, calendar_tab: @calendar_tab})) %>");
$("#modal_place").modal 'show'
$(".selectpicker").selectpicker()