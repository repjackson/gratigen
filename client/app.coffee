@picked_sections = new ReactiveArray []
@picked_tags = new ReactiveArray []
@picked_ingredients = new ReactiveArray []

@current_markers = new ReactiveArray []


Template.app.helpers
    ct: -> 
        # console.log Meteor.user()._template
        delta = Docs.findOne Meteor.user().delta_id
        # console.log delta
        if delta
            delta._template

Template.delta_nav.helpers
    delta_item_class: ->
        if @_id is Meteor.user().delta_id
            'active blue large invert'
        else 
            'small'
    editing_delta: ->
        Session.equals('editing_id', @_id)
    delta_users: ->
        Meteor.users.find
            delta_id:@_id
Template.delta_nav.events 
    'dblclick .pick_delta': ->
        Session.set('editing_id', @_id)
    'blur .pick_delta':(e)->
        if Session.get('editing_id')
            Session.set('editing_id', null)
            $('body').toast({
                title: "#{name} saved"
                # message: 'Please see desk staff for key.'
                class : 'success invert'
                showIcon:'checkmark'
                # showProgress:'bottom'
                position:'bottom right'
                })

    'click .add_session': ->
        name = prompt 'name session'
        if name
            new_id = 
                Docs.insert 
                    model:'delta'
                    name:name
            Meteor.users.update Meteor.userId(),
                $set:
                    delta_id:new_id
            $('body').toast({
                title: "#{name} session made"
                # message: 'Please see desk staff for key.'
                class : 'success'
                showIcon:'yin yang'
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

    'click .pick_delta': (e)->
        if Meteor.user().delta_id and @_id is Meteor.user().delta_id
            Meteor.users.update({_id:Meteor.userId()},{$unset:delta_id:1})
            $(e.currentTarget).closest('.item').transition('shake', 500)
        else 
            Meteor.users.update({_id:Meteor.userId()},{$set:delta_id:@_id})
            $(e.currentTarget).closest('.item').transition('bounce', 500)

        # console.log @_id
        # console.log Meteor.user().delta_id


Template.doc_history_button.events 
    'click .delete_history_item': ->
        console.log @
        Docs.update Meteor.user().delta_id, 
            $pull:
                _doc_history:@_id
Template.doc_history_button.helpers 
    doc_from_id:->
        # console.log @, @valueOf()
        Docs.findOne @valueOf()
        
Template.nav.events 
    'click .goto_profile': ->
        console.log 'profile'
        # delta = Docs.findOne Meteor.user().delta_id
        if Meteor.user().delta_id
            Docs.update Meteor.user().delta_id,
                $set:
                    _template:'profile'
                    _username:Meteor.user().username
                $addToSet:
                    _doc_history:'profile'
Template.app.events 
    'click .goto_doc': ->
        console.log 'going to', @title
        # delta = Docs.findOne Meteor.user().delta_id
        if @model is 'model'
            Docs.update Meteor.user().delta_id,
                $set:
                    _template:'delta'
                    _doc_id:@_id
                    _model:@slug
                $addToSet:
                    _doc_history:@_id
        else 
            Docs.update Meteor.user().delta_id,
                $set:
                    _template:'model_doc_view'
                    _doc_id:@_id
                $addToSet:
                    _doc_history:@_id
    'click .goto_template': ->
        console.log @
        # delta = Docs.findOne Meteor.user().delta_id
        # Docs.update Meteor.user().delta_id,
        #     $set:
        #         _doc_id:@_id
        #     $addToSet:
        #         _doc_history:@_id

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

Template.footer.events 
    'click .print_me': -> console.log @
Template.footer.helpers
    doc_docs: -> Docs.find {}
    result_docs: -> Results.find {}

    user_docs: -> Meteor.users.find()

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
