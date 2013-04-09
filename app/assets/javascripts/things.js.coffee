$(->
  $('.sample-images a').click( (event) -> 
    event.preventDefault()
    $('.sample-images a').removeClass('active').filter($(this)).addClass('active')
    $('#thing_image_url').val($(this).attr('href'))
  )
)