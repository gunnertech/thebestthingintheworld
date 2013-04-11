$(->
  
  scroll_page = 1
  $('.assigned_things .pagination').waypoint
    handler: ->
      scroll_page += 1
      $.ajax(
        location.href
        data: "page=#{scroll_page}"
        dataType: 'html'
      ).done( (html,status,event) ->
        
        $('#assigned-things-rows').append(
          $("<div>#{html}</div>").find('#assigned-things-rows').html()
        )
        
        $('.pagination').html(
          $("<div>#{html}</div>").find('.pagination').html()
        )
      )
    offset: '90%'
  
  $(".sortable" ).sortable(axis: "y", 
    helper: (e, ui) ->
      ui.children().each( ->
        $(this).width($(this).width());
      )
      return ui
    update: (e,ui) ->      
      position = ui.item.index()+1
      
      $.ajax(
        $(ui.item).data("object-url"),
        data: "position=#{position}&_method=PUT"
        type: 'POST'
        dataType: 'json'
      ).done( ->
        $(ui.item).parents(".sortable").find("tr").each( (i,element) ->
          $(element).find("td:first").html(i+1)
        )
      )
      
      return ui
  ).disableSelection()
  
  
  $('time.convert').each( ->
    try 
      $(this).text(Date.parse($(this).text()).addHours(-(new Date().getTimezoneOffset()/60)).toString("MM/dd/yyyy hh:mm tt")) 
    catch e
      console.log(e)
  )

  $('time.convert_time').each( ->
    $(this).text(Date.parse($(this).text()).addHours(-(new Date().getTimezoneOffset()/60)).toString("hh:mm tt"))
  )
)