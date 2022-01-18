if Meteor.isClient
    Router.route '/message/:doc_id/edit', (->
        @layout 'layout'
        @render 'message_edit'
        ), name:'message_edit'
        
        
    Template.message_edit.onCreated ->
        @autorun => Meteor.subscribe 'recipient_from_message_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id


    Template.message_edit.helpers
        recipient: ->
            message = Docs.findOne Router.current().params.doc_id
            if message.recipient_id
                Meteor.users.findOne
                    _id: message.recipient_id
        members: ->
            message = Docs.findOne Router.current().params.doc_id
            Meteor.users.find 
                # levels: $in: ['member']
                _id: $ne: Meteor.userId()
        # subtotal: ->
        #     message = Docs.findOne Router.current().params.doc_id
        #     message.amount*message.recipient_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_submit: ->
            true
            message = Docs.findOne Router.current().params.doc_id
            message.description and message.recipient_id
    Template.message_edit.events
        'click .add_recipient': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    recipient_id:@_id
        'click .remove_recipient': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    recipient_id:1
        'keyup .new_element': (e,t)->
            if e.which is 13
                element_val = t.$('.new_element').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                t.$('.new_element').val('')
    
        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            Docs.update Router.current().params.doc_id,
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

    
        'blur .edit_description': (e,t)->
            textarea_val = t.$('.edit_textarea').val()
            Docs.update Router.current().params.doc_id,
                $set:description:textarea_val
    
    
        'blur .edit_text': (e,t)->
            val = t.$('.edit_text').val()
            Docs.update Router.current().params.doc_id,
                $set:"#{@key}":val
    
    


if Meteor.isClient
    Template.message_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'recipient_from_message_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
    Template.message_edit.onRendered ->


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
                        Router.go "/message/#{@_id}/view"
            )


    Template.message_edit.helpers
    Template.message_edit.events

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
