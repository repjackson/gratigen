@picked_sections = new ReactiveArray []
@picked_tags = new ReactiveArray []
@picked_ingredients = new ReactiveArray []

@current_markers = new ReactiveArray []


Template.app.helpers
    ct: -> 
        # console.log Meteor.user().current_template
        Meteor.user().current_template


Template.doc_history_button.helpers 
    doc_from_id:->
        # console.log @, @valueOf()
        Docs.findOne @valueOf()
        
# Template.app.events 
#     'click .goto_doc': ->
#         Meteor.users.update Meteor.userId(),
#             $set:
#                 current_doc_id:@_id
#             $addToSet:
#                 doc_history:@_id

Template.add_model_doc_button.events 
    'click .add_model_doc': ->
        new_id = 
            Docs.insert 
                model:@slug 
        gstate_set "/m/#{@slug}/#{new_id}/edit"


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


Template.layout.helpers 
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

# Template.nav.onCreated ->
#     @autorun => @subscribe 'order_count'
#     @autorun => @subscribe 'product_count'
#     @autorun => @subscribe 'ingredient_count'
#     @autorun => @subscribe 'subscription_count'
#     @autorun => @subscribe 'source_count'
#     @autorun => @subscribe 'giftcard_count'
#     @autorun => @subscribe 'user_count'
        
        
Template.not_found.events
    'click .browser_back': ->
          window.history.back();



$.cloudinary.config
    cloud_name:"facet"
Template.layout.events
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
