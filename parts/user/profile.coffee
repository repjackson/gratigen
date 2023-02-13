if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile'
        ), name:'profile'

    # Template.profile_section.onRendered ->
    #     Meteor.setTimeout ->
    #         $('.accordion').accordion()
    #     , 1000

    Template.model_item_small.helpers 
        model_item_small_subtemplate: ->
            "#{@model}_item_small"
    Template.profile_section.helpers 
        user_template:->
            "user_#{@key}"

    Template.profile_section.onCreated ->
        # reactivevars are like Session.get() but template specific 
        @expanded = new ReactiveVar false
        @loading = new ReactiveVar false
    Template.profile_section.helpers 
        is_expanded: -> Template.instance().expanded.get()
        loading: -> Template.instance().loading.get()
        user_template:->
            # like user_tasks
            "user_#{@key}"
    Template.profile_section.events
        'click .toggle_expanded': (e,t)->
            t.expanded.set !t.expanded.get()
            $(e.currentTarget).closest('.segment').transition('pulse',500)

    Template.quickgive_button.helpers 
        give_button_class: ->
            if @amount > Meteor.user().points then 'disabled'
    Template.quickgive_button.events
        'click .quickgive': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if current_user
                Meteor.users.update current_user._id, 
                    $inc: points:@amount

    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username, ->

    Template.user_roles.onCreated ->
        @autorun -> Meteor.subscribe 'user_authored_docs', Router.current().params.username,'role', ->
        @autorun -> Meteor.subscribe 'user_taken_roles', Router.current().params.username, ->
    Template.user_resources.onCreated ->
        @autorun -> Meteor.subscribe 'user_authored_docs', Router.current().params.username,'resource', ->
        # @autorun -> Meteor.subscribe 'user_taken_roles', Router.current().params.username, ->
if Meteor.isServer 
    Meteor.publish 'user_taken_roles',(username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            model:'role'
            taken_by_user_id:user._id
if Meteor.isServer 
    Meteor.publish 'bookmarked_docs', ->
        Docs.find {_id:$in:Meteor.user().bookmarked_ids},{
            fields: 
                title:1
                model:1
                image_id:1
                read_by_user_ids:1
        }
    Meteor.publish 'user_read_docs', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {read_by_user_ids: $in: [user._id]},{
            fields: 
                title:1
                model:1
                image_id:1
                read_by_user_ids:1
        }
if Meteor.isClient 
    Template.profile.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
        
        
    Template.latest_user_activity.onCreated ->
        @autorun => @subscribe 'latest_docs', ->
    Template.latest_user_activity.helpers 
        latest_user_docs: ->
            Docs.find {
                _updated_timestamp:$exists:true
                _author_username:Router.current().params.username
            },
                sort:
                    _updated_timestamp:-1
                fields:
                    title:1
                    image_id:1
                    tags:1
                    model:1
                
        
if Meteor.isClient
    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

    Template.profile.helpers
        current_user: ->
            Meteor.users.findOne username:Router.current().params.username
        user: ->
            Meteor.users.findOne username:Router.current().params.username
        sponsored_by_users: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find 
                sponsored_by_ids:$in:[Meteor.userId()]
        sponsoring_users: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.find 
                sponsoring_ids:$in:[Meteor.userId()]


    Template.profile.events
        'click .boop': (e)->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.update current_user._id, 
                $inc:
                    boops: 1
                $addToSet:
                    booper_ids:Meteor.userId()
            $(e.currentTarget).closest('.boop').transition('bounce',500)
            $('body').toast(
                showIcon: 'hand point up outline'
                message: "boop!"
                showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom left"
            )

        'click .sponsor': ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users Meteor.userId(), 
                $addToSet:
                    sponsoring_user_ids: current_user._id
            Meteor.users.update current_user._id, 
                $addToSet:
                    sponsored_by_ids: Meteor.userId()
            
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()
            
    Template.locate_me.events
        'click .locate_me': ->
            navigator.geolocation.getCurrentPosition (position) =>
                console.log 'navigator position', position
                Session.set('current_lat', position.coords.latitude)
                Session.set('current_long', position.coords.longitude)
                Meteor.users.update Meteor.userId(),
                    $set:
                        current_lat: position.coords.latitude
                        current_lon: position.coords.longitude
                        
                console.log 'saving long', position.coords.longitude
                console.log 'saving lat', position.coords.latitude
            
                pos = Geolocation.currentLocation()

            
    Template.topup_button.events
        'click .topup': ->
            $('body').toast(
                showIcon: 'food'
                message: "100 points added"
                showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )
            Docs.insert 
                model:'topup'
                amount:100
            Meteor.call 'calc_user_credit', Meteor.userId(), ->
            # Meteor.users.update Meteor.userId(),
            #     $inc:
            #         points:@amount
            
            
if Meteor.isServer
    Meteor.methods
        'calc_user_credit': (user_id)->
            total_points = 0
            topups = 
                Docs.find 
                    model:'topup'
                    _author_id:Meteor.userId()
                    amount:$exists:true
            for topup in topups.fetch()
                total_points += topup.amount
            console.log total_points
            
            Meteor.users.update Meteor.userId(),
                $set:points:total_points
            
            
    Meteor.publish 'username_model_docs', (model, username)->
        if username 
            Docs.find   
                model:model
                _author_username:username
        else 
            Docs.find   
                model:model
                _author_username:Meteor.user().username            
                
                
                
if Meteor.isClient
    Router.route '/user/:username/badges', (->
        @layout 'profile_layout'
        @render 'user_badges'
        ), name:'user_badges'
    

    Template.user_badges.onCreated ->
        @autorun => Meteor.subscribe 'user_badges', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'badge'

    Template.user_badges.events
        'keyup .new_badge': (e,t)->
            if e.which is 13
                val = $('.new_badge').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'badge'
                    body: val
                    target_user_id: target_user._id
                val = $('.new_badge').val('')

        'click .submit_badge': (e,t)->
            val = $('.new_badge').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'badge'
                body: val
                target_user_id: target_user._id
            val = $('.new_badge').val('')



    Template.user_badges.helpers
        user_badges: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'badge'
                # target_user_id: target_user._id

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_badges', (username)->
        Docs.find
            model:'badge'        
            
            
if Meteor.isClient
    Router.route '/user/:username/events', (->
        @layout 'profile_layout'
        @render 'user_events'
        ), name:'user_events'

    Template.user_events.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'event', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_events', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'event'

    Template.user_events.events
        'keyup .new_event': (e,t)->
            if e.which is 13
                val = $('.new_event').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'event'
                    body: val
                    target_user_id: target_user._id

        'click .toggle_maybe': -> Session.set('view_maybe',!Session.get('view_maybe'))

    Template.user_events.helpers
        sent_items: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'event'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1

        user_maybe_events: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'event'
                maybe_user_ids: $in:[current_user._id]


if Meteor.isServer
    Meteor.publish 'user_events', (username)->
        Docs.find
            model:'event'            
            
            
            
            
if Meteor.isClient
    Router.route '/user/:username/messages', (->
        @layout 'profile_layout'
        @render 'user_messages'
        ), name:'user_messages'
    
    Template.user_messages.onCreated ->
        @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought'


    Template.user_messages.onCreated ->
        @autorun => Meteor.subscribe 'user_messages', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'message'

    Template.user_messages.events
        'keyup .new_public_message': (e,t)->
            if e.which is 13
                val = $('.new_public_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:false
                    target_user_id: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                is_private:false
                body: val
                target_user_id: target_user._id
            val = $('.new_public_message').val('')


        'keyup .new_private_message': (e,t)->
            if e.which is 13
                val = $('.new_private_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:true
                    target_user_id: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                target_user_id: target_user._id
            val = $('.new_private_message').val('')



    Template.user_messages.helpers
        user_public_messages: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:false

        user_private_messages: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:true
                _author_id:Meteor.userId()



if Meteor.isServer
    Meteor.publish 'user_public_messages', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:false

    Meteor.publish 'user_private_messages', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:true
            _author_id:Meteor.userId()


            
            
            
if Meteor.isClient
    Router.route '/user/:username/sent', (->
        @layout 'profile_layout'
        @render 'user_sent'
        ), name:'user_sent'
    Router.route '/user/:username/debits', (->
        @layout 'profile_layout'
        @render 'user_sent'
        ), name:'user_debits'

    Template.user_sent.onCreated ->
        # @autorun -> Meteor.subscribe 'user_model_docs', 'debit', Router.current().params.username
        @autorun => Meteor.subscribe 'user_sent', Router.current().params.username, ->

    Template.user_sent.events
        'keyup .new_debit': (e,t)->
            if e.which is 13
                val = $('.new_debit').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'debit'
                    body: val
                    target_user_id: target_user._id



    Template.user_sent.helpers
        sent_items: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


# if Meteor.isServer
    # Meteor.publish 'user_sent', (username)->
    #     user = Meteor.users.findOne username:username
    #     Docs.find {
    #         model:'debit'
    #         _author_id: user._id
    #     }, 
    #         limit:100            
            
            
            
# if Meteor.isClient
#     Router.route '/user/:username/sent', (->
#         @layout 'profile_layout'
#         @render 'user_sent'
#         ), name:'user_sent'
#     Router.route '/user/:username/debits', (->
#         @layout 'profile_layout'
#         @render 'user_sent'
#         ), name:'user_debits'

#     Template.user_sent.onCreated ->
#         # @autorun -> Meteor.subscribe 'user_model_docs', 'debit', Router.current().params.username
#         @autorun => Meteor.subscribe 'user_sent', Router.current().params.username

#     Template.user_sent.events
#         'keyup .new_debit': (e,t)->
#             if e.which is 13
#                 val = $('.new_debit').val()
#                 console.log val
#                 target_user = Meteor.users.findOne(username:Router.current().params.username)
#                 Docs.insert
#                     model:'debit'
#                     body: val
#                     target_user_id: target_user._id



#     Template.user_sent.helpers
#         sent_items: ->
#             current_user = Meteor.users.findOne(username:Router.current().params.username)
#             Docs.find {
#                 model:'debit'
#                 _author_id: current_user._id
#                 # target_user_id: target_user._id
#             },
#                 sort:_timestamp:-1

#         slots: ->
#             Docs.find
#                 model:'slot'
#                 _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_sent', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'debit'
            _author_id: user._id
        }, 
            limit:100            
            
            
            
            
# if Meteor.isClient
    # Router.route '/user/:username/orders', (->
    #     @layout 'profile_layout'
    #     @render 'user_orders'
    #     ), name:'user_orders'

    # Template.user_orders.onCreated ->
    #     @autorun -> Meteor.subscribe 'user_orders', Router.current().params.username
    #     # @autorun => Meteor.subscribe 'user_orders', Router.current().params.username
    #     # @autorun => Meteor.subscribe 'model_docs', 'order'

    # Template.user_orders.events
    #     'keyup .new_order': (e,t)->
    #         if e.which is 13
    #             val = $('.new_order').val()
    #             console.log val
    #             target_user = Meteor.users.findOne(username:Router.current().params.username)
    #             Docs.insert
    #                 model:'order'
    #                 body: val
    #                 target_user_id: target_user._id



    # Template.user_orders.helpers
    #     orders: ->
    #         current_user = Meteor.users.findOne(username:Router.current().params.username)
    #         Docs.find {
    #             model:'order'
    #             _author_id: current_user._id
    #             # target_user_id: target_user._id
    #         },
    #             sort:_timestamp:-1



# if Meteor.isServer
#     Meteor.publish 'user_orders', (username)->
#         user = Meteor.users.findOne username:username
#         Docs.find
#             model:'order'
#             _author_id:user._id
            
            
            
if Meteor.isClient
    Router.route '/user/:username/offers', (->
        @layout 'profile_layout'
        @render 'user_offers'
        ), name:'user_offers'

    Template.user_offers.onCreated ->
        @autorun -> Meteor.subscribe 'user_offers', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_offers', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'offer'

    Template.user_offers.events
        'keyup .new_offer': (e,t)->
            if e.which is 13
                val = $('.new_offer').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'offer'
                    body: val
                    target_user_id: target_user._id



    Template.user_offers.helpers
        offers: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'offer'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_offers', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'offer'
            _author_id:user._id
                                    
                                    
                                    
                                    
if Meteor.isClient
    Router.route '/user/:username/requests', (->
        @layout 'profile_layout'
        @render 'user_requests'
        ), name:'user_requests'

    Template.user_requests.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'request', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_requests', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'request'

    Template.user_requests.events
        'keyup .new_request': (e,t)->
            if e.which is 13
                val = $('.new_request').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'request'
                    body: val
                    target_user_id: target_user._id



    Template.user_requests.helpers
        requests: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'request'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_requests', (username)->
        Docs.find
            model:'request'
                                    
                             
                             
# if Meteor.isClient
#     Router.route '/user/:username/skills', (->
#         @layout 'profile_layout'
#         @render 'user_skills'
#         ), name:'user_skills'

#     Template.user_skills.onCreated ->
#         @autorun -> Meteor.subscribe 'user_model_docs', 'request', Router.current().params.username
#         # @autorun => Meteor.subscribe 'user_skills', Router.current().params.username
#         @autorun => Meteor.subscribe 'model_docs', 'request'

#     Template.user_skills.events
#         'keyup .new_request': (e,t)->
#             if e.which is 13
#                 val = $('.new_request').val()
#                 console.log val
#                 target_user = Meteor.users.findOne(username:Router.current().params.username)
#                 Docs.insert
#                     model:'request'
#                     body: val
#                     target_user_id: target_user._id



#     Template.user_skills.helpers
#         skills: ->
#             current_user = Meteor.users.findOne(username:Router.current().params.username)
#             Docs.find {
#                 model:'request'
#                 _author_id: current_user._id
#                 # target_user_id: target_user._id
#             },
#                 sort:_timestamp:-1


                                    
                                    
if Meteor.isClient
    Router.route '/user/:username/genekeys', (->
        @layout 'profile_layout'
        @render 'user_genekeys'
        ), name:'user_genekeys'
    
    Template.user_genekeys.onCreated ->
        # @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought', ->


    Template.user_genekeys.onCreated ->
        @autorun => Meteor.subscribe 'user_genekeys', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'message'

    Template.user_genekeys.events
        'keyup .new_public_message': (e,t)->
            if e.which is 13
                val = $('.new_public_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:false
                    target_user_id: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                is_private:false
                body: val
                target_user_id: target_user._id
            val = $('.new_public_message').val('')


        'keyup .new_private_message': (e,t)->
            if e.which is 13
                val = $('.new_private_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:true
                    target_user_id: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                target_user_id: target_user._id
            val = $('.new_private_message').val('')



    Template.user_genekeys.helpers
        user_public_genekeys: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:false

        user_private_genekeys: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:true
                _author_id:Meteor.userId()



if Meteor.isServer
    Meteor.publish 'user_public_genekeys', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:false

    Meteor.publish 'user_private_genekeys', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:true
            _author_id:Meteor.userId()


                                    
                                    
if Meteor.isClient
    Router.route '/user/:username/delivery', (->
        @layout 'profile_layout'
        @render 'user_delivery'
        ), name:'user_delivery'
    
    Template.user_delivery.onCreated ->
        @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought'


    Template.user_delivery.onCreated ->
        @autorun => Meteor.subscribe 'user_delivery', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'message'

    Template.user_delivery.events
        'keyup .new_public_message': (e,t)->
            if e.which is 13
                val = $('.new_public_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:false
                    target_user_id: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                is_private:false
                body: val
                target_user_id: target_user._id
            val = $('.new_public_message').val('')


        'keyup .new_private_message': (e,t)->
            if e.which is 13
                val = $('.new_private_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:true
                    target_user_id: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                target_user_id: target_user._id
            val = $('.new_private_message').val('')



    Template.user_delivery.helpers
        user_public_delivery: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:false

        user_private_delivery: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:true
                _author_id:Meteor.userId()



if Meteor.isServer
    Meteor.publish 'user_public_delivery', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:false

    Meteor.publish 'user_private_delivery', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:true
            _author_id:Meteor.userId()


if Meteor.isClient
    Router.route '/user/:username/credits', (->
        @layout 'layout'
        @render 'user_credits'
        ), name:'user_credits'
    Router.route '/user/:username/credit', (->
        @layout 'layout'
        @render 'user_credit'
        ), name:'user_credit'


    Template.user_credits.onCreated ->
        @autorun => Meteor.subscribe 'user_credits', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'debit'

    Template.user_credits.events
        # 'keyup .new_credit': (e,t)->
        #     if e.which is 13
        #         val = $('.new_credit').val()
        #         console.log val
        #         target_user = Meteor.users.findOne(username:Router.current().params.username)
        #         Docs.insert
        #             model:'credit'
        #             body: val
        #             recipient_id: target_user._id



    Template.user_credits_small.helpers
        user_credits: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'debit'
                recipient_id: target_user._id
            },
                sort:_timestamp:-1

    Template.user_credits.helpers
        user_credits: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'debit'
                recipient_id: target_user._id
            },
                sort:_timestamp:-1




if Meteor.isServer
    Meteor.publish 'user_credits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'debit'
            recipient_id:user._id
            
            
if Meteor.isClient
    Router.route '/user/:username/food', (->
        @layout 'profile_layout'
        @render 'user_food'
        ), name:'user_food'
    
    Template.user_food.onCreated ->
        @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought'


    Template.user_food.onCreated ->
        # @autorun => Meteor.subscribe 'user_food', Router.current().params.username
        @autorun => Meteor.subscribe 'user_model_docs', 'food_order', Router.current().params.username

    Template.user_food.events
        'keyup .new_public_message': (e,t)->
            if e.which is 13
                val = $('.new_public_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:false
                    target_user_id: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                is_private:false
                body: val
                target_user_id: target_user._id
            val = $('.new_public_message').val('')


        'keyup .new_private_message': (e,t)->
            if e.which is 13
                val = $('.new_private_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:true
                    target_user_id: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                target_user_id: target_user._id
            val = $('.new_private_message').val('')



    Template.user_food.helpers
        food_orders: ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'food_order'
                # _author_id:user._id



if Meteor.isServer
    Meteor.publish 'user_public_food', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:false

    Meteor.publish 'user_private_food', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:true
            _author_id:Meteor.userId()


            
            
if Meteor.isClient
    Router.route '/user/:username/friends', (->
        @layout 'profile_layout'
        @render 'user_friends'
        ), name:'user_friends'
    
    Template.user_friends.onCreated ->
        @autorun => Meteor.subscribe 'users'



    Template.user_friends.helpers
        friends: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if current_user.friend_ids
                Meteor.users.find
                    _id:$in: current_user.friend_ids
        nonfriends: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            if current_user.friend_ids
                Meteor.users.find
                    _id:$nin:Meteor.user().friend_ids


    Template.friend_button.helpers
        is_friend: ->
            Meteor.user() and Meteor.user().friend_ids and @_id in Meteor.user().friend_ids


    Template.friend_button.events
        'click .friend':->
            Meteor.users.update Meteor.userId(),
                $addToSet: friend_ids:@_id
        'click .unfriend':->
            Meteor.users.update Meteor.userId(),
                $pull: friend_ids:@_id

        'keyup .assign_earn': (e,t)->
            if e.which is 13
                post = t.$('.assign_earn').val().trim()
                # console.log post
                current_user = Meteor.users.findOne Router.current().params.user_id
                Docs.insert
                    body:post
                    model:'earn'
                    assigned_user_id:current_user._id
                    assigned_username:current_user.username

                t.$('.assign_earn').val('')            