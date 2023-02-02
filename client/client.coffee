@picked_sections = new ReactiveArray []
@picked_tags = new ReactiveArray []
@picked_ingredients = new ReactiveArray []

@current_markers = new ReactiveArray []

Router.route '/d/:model/:doc_id', (->
    @layout 'layout'
    @render 'doc_view'
    ), name:'doc_view'

Template.doc_view.onCreated ->
    @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'model_docs', 'menu_section'

Template.doc_view.onRendered ->
    Meteor.call 'log_view', Router.current().params.doc_id, ->

Template.doc_view.helpers
    doc_view_template: ->
        console.log @
        "#{@model}_view"

Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0

moment.locale('en', {
    relativeTime: {
        future: 'in %s',
        # past: '%s ago',
        past: '%s',
        s:  'seconds',
        ss: '%ss',
        m:  'a minute',
        mm: '%dm',
        h:  'an hour',
        hh: '%dh',
        d:  'a day',
        dd: '%dd',
        M:  'a month',
        MM: '%dM',
        y:  'a year',
        yy: '%dY'
    }
});


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
# Router.notFound =
    # action: 'not_found'

Template.layout.events
    'click .log_history': ->
        if Meteor.user()
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    history_ids: @_id
    'hover .tada': (e,t)-> $(e.currentTarget).closest('.tada').transition('tada', 500)
    'click .fly_right': (e,t)-> $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .zoom': (e,t)-> $(e.currentTarget).closest('.grid').transition('drop', 500)
    'click .fade_left': (e,t)-> 
        $(e.currentTarget).closest('.card').transition('fade left', 500)
        $(e.currentTarget).closest('.grid').transition('fade left', 500)
    'click .fade_down': (e,t)-> $(e.currentTarget).closest('.grid').transition('fade down', 500)
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


# Tracker.autorun ->
#     current = Router.current()
#     Tracker.afterFlush ->
#         $(window).scrollTop 0


# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
