Router.route '/notecards', (->
    @layout 'layout'
    @render 'notecards'
    ), name:'notecards'
    
Router.route '/notecard/edit/:doc_id', (->
    @layout 'layout'
    @render 'edit_notecard'
    ), name:'edit_notecard'


if Meteor.isClient
    Template.edit_notecard.onCreated ->
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
    
    Template.edit_notecard.helpers
        notecard: -> Docs.findOne Router.current().params.doc_id

    Template.edit_notecard.events
        'blur #front': ->
            front = $('#front').val()
            Docs.update Router.current().params.doc_id,
                $set: front: front
                
        'blur #back': ->
            back = $('#back').val()
            Docs.update Router.current().params.doc_id,
                $set: back: back
                

    Template.notecard_card.onRendered ->
        $('.shape').shape()

    Template.notecard_card.events
        'click .side': (e,t)->
            t.$('.shape').shape('flip over')