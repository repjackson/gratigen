if Meteor.isServer
    Meteor.publish 'product_from_message_id', (message_id)->
        message = Docs.findOne message_id
        Docs.find 
            _id:message.product_id
            
            
if Meteor.isClient
    Template.message_edit.helpers
        recipient: ->
            message = Docs.findOne Meteor.user()._model
            if message.recipient_id
                Meteor.users.findOne
                    _id: message.recipient_id
        members: ->
            message = Docs.findOne Meteor.user()._model
            Meteor.users.find 
                # levels: $in: ['member']
                _id: $ne: Meteor.userId()
        # subtotal: ->
        #     message = Docs.findOne Meteor.user()._model
        #     message.amount*message.recipient_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_submit: ->
            true
            message = Docs.findOne Meteor.user()._model
            message.description and message.recipient_id
    Template.message_edit.events
        'click .add_recipient': ->
            Docs.update Meteor.user()._model,
                $set:
                    recipient_id:@_id
        'click .remove_recipient': ->
            Docs.update Meteor.user()._model,
                $unset:
                    recipient_id:1
        'keyup .new_element': (e,t)->
            if e.which is 13
                element_val = t.$('.new_element').val().toLowerCase().trim()
                Docs.update Meteor.user()._model,
                    $addToSet:tags:element_val
                t.$('.new_element').val('')
    
        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            Docs.update Meteor.user()._model,
                $pull:tags:element
            t.$('.new_element').focus()
            t.$('.new_element').val(element)
    
    
        # 'click .result': (e,t)->
        #     Meteor.call 'log_term', @title, ->
        #     picked_tags.push @title
        #     $('#search').val('')
        #     Meteor.call 'call_wiki', @title, ->
        #     Meteor.call 'calc_term', @title, ->
        #     Meteor.call 'omega', @title, ->
        #     Session.set('current_query', '')
        #     Session.set('searching', false)
    
        #     Meteor.call 'search_reddit', picked_tags.array(), ->
        #     # Meteor.setTimeout ->
        #     #     Session.set('dummy', !Session.get('dummy'))
        #     # , 7000

    

if Meteor.isClient
    Template.message_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .submit': ->
            Swal.fire({
                title: "confirm send message?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'send_message', @_id, =>
                        Swal.fire(
                            title:"message sent"
                            icon:'success'
                            showClass:
                                popup: 'swal2-noanimation',
                                backdrop: 'swal2-noanimation'
                            hideClass:
                                popup: '',
                                backdrop: ''
                            showConfirmButton: false
                            timer: 1000
                        )
                        gstate_set "/message/#{@_id}/view"
            )

if Meteor.isServer
    Meteor.methods
        send_message: (message_id)->
            message = Docs.findOne message_id
            recipient = Meteor.users.findOne message.recipient_id
            sender = Meteor.users.findOne message._author_id

            console.log 'sending message', message
            Meteor.users.update sender._id,
                $inc:
                    unread_message_count:1
            Docs.update message_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update message_id,
                $set:
                    submitted:true            