# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
//= require jquery
//= require jquery_ujs

$(document).ready ->
  $('#billing_fields').hide()

  $('#subscription_payment_method_credit_card').click ->
    $('#billing_fields').show()
    true
  $('#subscription_payment_method_paypal').click ->
    $('#billing_fields').hide()
    true