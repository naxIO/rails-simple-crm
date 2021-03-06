# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  change_client_search = ->
    if $("#public_estimate_client_type").val() == "company"
      $("#lead_search_area").hide()
      $("#company_search_area").show()
    else if $("#public_estimate_client_type").val() == "lead"
      $("#lead_search_area").show()
      $("#company_search_area").hide()

  change_client_search()
  $("#company_search").change ->
    if $("#public_estimate_client_type").val() == "company"
      $("#public_estimate_client_id").val($(this).val())
  $("#lead_search").change ->
    if $("#public_estimate_client_type").val() == "lead"
      $("#public_estimate_client_id").val($(this).val())
  $("#public_estimate_client_type").change ->
    change_client_search()

  $(document).on 'change', '.public_estimate_lines_trigger', ->
    unit_price = $(this).parent().parent().find('.public_estimate_line_unit_price').val()
    quantity = $(this).parent().parent().find('.public_estimate_line_quantity').val()
    tax_rate = $(this).parent().parent().find('.public_estimate_line_tax_rate').val()
    total_price = unit_price * quantity
    tax_price = total_price * tax_rate / 100
    tax_include_price = total_price + tax_price

    $(this).parent().parent().find('.public_estimate_line_tax_price').html(tax_price + "円")
    $(this).parent().parent().find('.public_estimate_line_total_price').html( "<span class='public_estimate_line_calc'>" + tax_include_price + "</span>円")
    calcTotalPrice()


calcTotalPrice = ->
  total_price = 0
  tax_rate = parseInt($("#public_estimate_tax_rate").text())
  $("span.public_estimate_line_calc").each ->
    total_price += parseInt( $(this).text() )

  $("#td_public_estimate_total_price").text( total_price + "円")
  tax_price = total_price * tax_rate * 0.01
  $("#td_public_estimate_tax_price").text( tax_price + "円")
  $("#td_public_estimate_tax_include_price").text( (tax_price + total_price) + "円" )
