if Meteor.isClient
    Router.route '/messages/', (->
        @layout 'layout'
        @render 'messages'
        ), name:'messages'
    

    Router.route '/message/:doc_id/view', (->
        @layout 'layout'
        @render 'message_view'
        ), name:'message_view'

    Template.message_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_message_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        
    Template.message_view.onRendered ->



if Meteor.isServer
    Meteor.publish 'product_from_message_id', (message_id)->
        message = Docs.findOne message_id
        Docs.find 
            _id:message.product_id