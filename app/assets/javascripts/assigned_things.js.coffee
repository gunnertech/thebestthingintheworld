$(->
  
  $modal = $('#email-modal')
  
  $modal.on('shown', ->
    unless $modal.data('binded')
      $modal.data('binded',true)
      $modal.find('.modal-footer .btn-danger').on('click', (event) ->
        event.preventDefault()
        $modal.modal('hide')
      )
    
      $modal.find('.modal-footer .btn-primary').on('click', (event) ->
        event.preventDefault()
        unless $modal.find('form').attr('action').match(/json/)
          $modal.find('form').attr('action',"#{$modal.find('form').attr('action')}.json")
        $modal.find('form').trigger('submit')
        $modal.modal('hide')
      )
  )
  
  $('.btn-email-share').on('click', (event) ->
    event.preventDefault()
    
    $modal.modal('show')
    #$modal.find('.modal-body').html("Hell Nah")
    #$modal.find('h3').html($(this).text())
  )
  
  
  $('.btn-share').click( (event) -> 
    event.preventDefault()
    $('.share-url').show()
  )
  
  
  $('.btn-facebook-share').click (event) ->
    FB.ui(
      method: 'feed'
      name: $(this).data('name')
      caption: "Which one is better?"
      description: "In the battle for 'Best Thing In The World,' every matchup counts! Weigh in with your opinion now!"
      link: $(this).data('link')
      picture: $(this).data('picture')
      (response) ->
        if (response && response.post_id)
          #alert('Post was published.')
        else
          #alert('Post was not published.')
    )
)