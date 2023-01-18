@picked_sections = new ReactiveArray []
@picked_tags = new ReactiveArray []
@picked_ingredients = new ReactiveArray []

@current_markers = new ReactiveArray []


Template.app.helpers
    ct: -> 
        # console.log Meteor.user()._template
        Meteor.user()._template


Template.doc_history_button.helpers 
    doc_from_id:->
        # console.log @, @valueOf()
        Docs.findOne @valueOf()
        
Template.app.events 
    'click .goto_doc': ->
        Meteor.users.update Meteor.userId(),
            $set:
                _doc_id:@_id
            $addToSet:
                doc_history:@_id

Template.add_model_doc_button.events 
    'click .add_model_doc': ->
        new_id = 
            Docs.insert 
                model:@slug 
        Meteor.call 'change_state',{ _template:'model_doc_edit', _model:@slug, _doc_id:new_id }, ->


Meteor.users.find(_id:Meteor.userId()).observe({
    changed: (new_doc, old_doc)->
        difference = new_doc.points-old_doc.points
        if difference > 0
            $('body').toast({
                title: "#{new_doc.points-old_doc.points}p earned"
                # message: 'Please see desk staff for key.'
                class : 'success'
                showIcon:'hashtag'
                # showProgress:'bottom'
                position:'bottom right'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })

})


Template.app.helpers 
    invert_class: ->
        if Meteor.user().invert_mode 
            'invert'

Template.footer.helpers
    doc_docs: ->
        Docs.find {}

    user_docs: ->
        Meteor.users.find()
# Template.home.onCreated ->
#     @autorun => @subscribe 'model_docs', 'stats', ->
# Template.home.onRendered ->
    #     Meteor.call 'log_homepage_view', ->
    #         console.log '?'
# Template.home.helpers
#     stats: ->
#         Docs.findOne
#             model:'stats'

$.cloudinary.config
    cloud_name:"facet"
Template.app.events
    'click .fly_out': -> 
        Meteor.users.update({_id:Meteor.userId()}, {$set:flyout_doc_id:@_id})
        $('.ui.flyout').flyout('toggle')
    'click .show_modal': ->
        console.log @
        Meteor.users.update({_id:Meteor.userId()}, {$set:modal_doc_id:@_id})
        $('.ui.modal').modal({
            inverted:true
            # blurring:true
            }).modal('show')


    'click .fly_right': (e,t)-> $(e.currentTarget).closest('.card').transition('fly right', 500)
    'click .zoom': (e,t)-> $(e.currentTarget).closest('.card').transition('drop', 500)
    'click .fly_left': (e,t)-> 
        $(e.currentTarget).closest('.segment').transition('fly left', 500)
        $(e.currentTarget).closest('.card').transition('fly left', 500)
    'click .fly_down': (e,t)-> $(e.currentTarget).closest('.card').transition('fly down', 500)
    # 'click .button': ->
    #     $(e.currentTarget).closest('.button').transition('bounce', 1000)

    # 'click a(not:': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)

    'click .log_view': ->
        # console.log Template.currentData()
        # console.log @
        Docs.update @_id,
            $inc: views: 1

# Template.healthclub.events
    # 'click .button': ->
    #     $('.global_container')
    #     .transition('fade out', 5000)
    #     .transition('fade in', 5000)

# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
