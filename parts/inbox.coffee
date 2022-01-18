if Meteor.isClient
    Router.route '/inbox', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'inbox'

    Template.inbox.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'message', Router.current().params.username
        @autorun => Meteor.subscribe 'my_received_messages'
        @autorun => Meteor.subscribe 'my_sent_messages'
        # @autorun => Meteor.subscribe 'inbox', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'stat'

    Template.inbox.events
        'click .add_message': ->
            new_message_id =
                Docs.insert
                    model:'message'
            Router.go "/m/message/#{new_message_id}/edit"



    Template.inbox.helpers
        my_sent_messages: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'message'
                _author_id: Meteor.userId()
                # recipient: target_user._id
            },
                sort:_timestamp:-1

        my_received_messages: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'message'
                recipient_id: Meteor.userId()
                # recipient: target_user._id
            },
                sort:_timestamp:-1

    Template.toggle_view_icon.helpers
        is_read: ->
            @read_ids and Meteor.userId() in @read_ids
    Template.toggle_view_icon.events
        'click .mark_read': ->
            Meteor.call 'mark_read', @_id, ->
        'click .mark_unread': ->
            Meteor.call 'mark_unread', @_id, ->
            
if Meteor.isServer
    Meteor.publish 'inbox', (username)->
        Docs.find
            model:'offer'
