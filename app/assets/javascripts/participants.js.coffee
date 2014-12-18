$ ->
  if $('#participant_list').length > 0
    protocol_id = $("#protocol_id").val()
    faye = new Faye.Client('http://localhost:9292/faye')
    faye.disable('websocket')
    faye.subscribe "/participants/#{protocol_id}/list", (data) ->
      $('#participants-table').bootstrapTable('refresh', {silent: "true"})

  window.operateEvents =
    "click #removeParticipant": (e, value, row, index) ->
      del = confirm "Are you sure you want to delete "+capitalize(row.first_name)+" "+capitalize(row.last_name)+" from the Participant List?"
      if del
        $.ajax
          type: 'DELETE'
          url: "/protocols/#{row.protocol_id}/participants/#{row.id}"

    "click #editParticipant": (e, value, row, index) ->
      $.ajax
        type: 'GET'
        url: "/protocols/#{row.protocol_id}/participants/#{row.id}/edit"

    "click #changeParticipantArm": (e, value, row, index) ->
      if row.arm_id == null
        urlVar = "/protocols/#{row.protocol_id}/participants/#{row.id}/change_arm"
      else
        urlVar = "/protocols/#{row.protocol_id}/participants/#{row.id}/change_arm/#{row.arm_id}/edit"
      $.ajax
        type: 'GET'
        url: urlVar

    "click .calendar": (e, value, row, index) ->
      alert JSON.stringify row

    "click .stats": (e, value, row, index) ->
      alert JSON.stringify row

  capitalize = (string) ->
    string.charAt(0).toUpperCase() + string.slice(1).toLowerCase()

(exports ? this).deleteFormatter = (value, row, index) ->
  [
    "<a class='remove' href='javascript:void(0)' title='Remove' id='removeParticipant'>",
    "<i class='glyphicon glyphicon-remove' style='z-index: 100'></i>",
    "</a>"
  ].join ""

(exports ? this).editFormatter = (value, row, index) ->
  [
    "<a class='edit ml10' href='javascript:void(0)' title='Edit' id='editParticipant'>",
    "<i class='glyphicon glyphicon-edit'></i>",
    "</a>"
  ].join ""

(exports ? this).changeArmFormatter = (value, row, index) ->
  [
    "<a class='edit ml10' href='javascript:void(0)' title='Edit' id='changeParticipantArm'>",
    "<i class='glyphicon glyphicon-random'></i>",
    "</a>"
  ].join ""

(exports ? this).nameFormatter = (value, row, index) ->
  value.charAt(0).toUpperCase() + value.slice(1).toLowerCase()

(exports ? this).calendarFormatter = (value, row, index) ->
  [
    "<a class='calendar' href='javascript:void(0)' title='Calendar'>",
    "<i class='glyphicon glyphicon-calendar' style='z-index: 100'></i>",
    "</a>"
  ].join ""

(exports ? this).statsFormatter = (value, row, index) ->
  [
    "<a class='stats' href='javascript:void(0)' title='Stats'>",
    "<i class='glyphicon glyphicon-stats' style='z-index: 100'></i>",
    "</a>"
  ].join ""

(exports ? this).refreshParticipantTables = (protocol_id) ->
  $("#participants-list-table").bootstrapTable 'refresh', {url: "/protocols/#{protocol_id}/participants.json"}
  $("#participants-tracker-table").bootstrapTable 'refresh', {url: "/protocols/#{protocol_id}/participants.json"}
