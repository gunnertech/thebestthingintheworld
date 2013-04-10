$(->
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