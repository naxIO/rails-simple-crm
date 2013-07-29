# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
        $( ".datepicker" ).datepicker({dateFormat: 'yy-mm-dd'})
        $('#label').click( ->
          sData = $('input', oTable.fnGetNodes()).serialize()
          console.log(sData)
          if sData == "" 
            alert("チェックがありません")
            return false
          w = window.open()
          w.location.href = "/companies_pdf.pdf?" + sData
          return false 
        )
        
        $('#up_postsend').click( ->
          sData = $('input', oTable.fnGetNodes()).serialize()
          console.log(sData)
          if sData == "" 
            alert("チェックがありません")
            return false
          $.ajax '/up_postsend',
            type: 'GET'
            dataType: 'json'
            timeout: 1000
            data : sData
            error:(jqXHR, textStatus, errorThrown) ->
              alert(errorThrown)
            success: (data, textStatus, jqXHR) ->
              noty(
                text: data["text"]
                type: data["type"]
              )
          return false 
        )
        
        oTable = $('#company').dataTable
          sPaginationType: "full_numbers"
          bJQueryUI: true
          bProcessing: true
          bServerSide: true
          bStateSave:  false
          bSort: true
          bDeferRender: true
          bAutoWidth: false
          sAjaxSource: $('#company').data('source')
          oLanguage: 
            "sLengthMenu": "表示行数 _MENU_ 件"
            "oPaginate": 
              "sNext": "次",
              "sPrevious": "前"
            "sInfo": "TOTAL_TOTAL_ _START_/_END_"
            "sSearch": "検索："
          aoColumnDefs:[
            {sWidth: "200px", aTargets:["client_name"]},
            {sWidth: "70px", aTargets:["rank"]},
            {sWidth: "50%", bSortable: false ,aTargets:["contact"]},
            {sWidth: "20px", bSortable: false, aTargets:["check"]}
           ]

         