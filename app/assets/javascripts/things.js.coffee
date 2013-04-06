$(->
  $('.sample-images a').click( (event) -> 
    event.preventDefault()
    console.log($(this).attr('href'))
    $('.sample-images a').removeClass('active').filter($(this)).addClass('active')
    $('#thing_image_url').val($(this).attr('href'))
  )
)