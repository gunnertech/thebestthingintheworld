$(->
 
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