Template.modal.events
    'click #myBtn': ->
        # Get the modal
        modal = document.getElementById('myModal')
        # console.log 'hi'
        console.log modal
        modal.style.display = 'block'
        # Get the button that opens the modal
        # btn = document.getElementById('myBtn')
        # Get the <span> element that closes the modal
        # When the user clicks the button, open the modal 
        
        # When the user clicks on <span> (x), close the modal
    'click .close': ->
        modal = document.getElementById('myModal')
        # span = document.getElementsByClassName('close')[0]
        modal.style.display = 'none'


        # When the user clicks anywhere outside of the modal, close it
        
        # window.onclick = (event) ->
        #     modal = document.getElementById('myModal')
        #   if event.target == modal
        #     modal.style.display = 'none'
        #   return
