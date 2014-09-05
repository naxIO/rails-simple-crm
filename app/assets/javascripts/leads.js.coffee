# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org
jQuery ->
  if(0 < $("#lead_tag_list_form").size())
    $("#lead_tag_list_form").select2
      width: "400px"
      tags: gon.tag_list
  $("#lead_tag_list_search").select2
    width: "400px"

  $('#index_all_checkbox').on 'change', ->
    $('input[name=leads]').prop('checked', this.checked)

  $('#leads_address_label').click ->
    sData = $('input.leads_index_checkbox').serialize()
    if sData == "" 
      alert("チェックがありません")
      return false
    w = window.open()
    w.location.href = "/leads/address.csv?" + sData
    return false 
