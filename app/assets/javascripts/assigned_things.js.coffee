$(->
  $('.btn-share').click( (event) -> 
    event.preventDefault()
    $('.share-url').show()
  )
)