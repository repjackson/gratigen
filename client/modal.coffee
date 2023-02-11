Template.layout.events
    'click .launch_modal': (e,t)->
        console.log e
        # Get the modal
        modal = document.getElementById('global_modal')
        # console.log 'hi'
        # console.log modal
        modal.style.display = 'block'
        # Get the button that opens the modal
        # btn = document.getElementById('myBtn')
        # Get the <span> element that closes the modal
        # When the user clicks the button, open the modal 

        # When the user clicks on <span> (x), close the modal
Template.modal.events
    'click .close': ->
        modal = document.getElementById('global_modal')
        # span = document.getElementsByClassName('close')[0]
        modal.style.display = 'none'

        # When the user clicks anywhere outside of the modal, close it
        
Template.modal.onRendered ->
    window.onclick = (event) ->
        modal = document.getElementById('global_modal')
        if event.target == modal
            modal.style.display = 'none'
