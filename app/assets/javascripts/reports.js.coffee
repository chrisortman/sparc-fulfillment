# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $(document).on 'click', '#billing_report_button', ->
    $.ajax
      type: 'GET'
      url: '/reports/new_billing_report'

  $(document).on 'click', '#auditing_report_button', ->
    $.ajax
      type: 'GET'
      url: '/reports/new_auditing_report'