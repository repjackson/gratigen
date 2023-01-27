if Meteor.isClient
    Template.user_credit.onCreated ->
        # @autorun -> Meteor.subscribe 'user_from_username', Template.parentData().username, ->
        # @autorun -> Meteor.subscribe 'user_read_docs', Template.parentData().username, ->
    
    Template.user_credit.events 
        'click .calc_points': ->
            Meteor.call 'calc_user_points', Meteor.userId(), ->
                
                
            
    Template.user_credit.helpers
        read_docs: ->
            # d = 
            # user = Meteor.users.findOne username:Meteor.user().username 
            Docs.find 
                read_by_user_ids: $in: [Meteor.userId()]
    
    Template.profile.onCreated ->
        # @autorun -> Meteor.subscribe 'user_from_username', Template.parentData().username, ->
        # @autorun -> Meteor.subscribe 'user_referenced_docs', Template.parentData().username, ->
if Meteor.isServer 
    Meteor.publish 'user_bookmark_docs', ->
        Docs.find 
            _id:$in:Meteor.user().bookmark_ids
    Meteor.publish 'user_read_docs', (username)->
        # user = Meteor.users.findOne username:username
        Docs.find 
            read_by_user_ids: $in: [Meteor.userId()]
        # Docs.find 
        #     read_by_user_ids: $in: [user._id]

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
                _author_username:Template.parentData().username
            },
                sort:
                    _updated_timestamp:-1
                
        
if Meteor.isClient
    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Template.parentData().group}"

    Template.profile.helpers
        # current_user: ->
        #     Meteor.users.findOne username:Template.parentData().username
        user: ->
            Meteor.users.findOne username:Template.parentData().username
        sponsored_by_users: ->
            user = Meteor.users.findOne username:Template.parentData().username
            Meteor.users.find 
                sponsored_by_ids:$in:[Meteor.userId()]
        sponsoring_users: ->
            user = Meteor.users.findOne username:Template.parentData().username
            Meteor.users.find 
                sponsoring_ids:$in:[Meteor.userId()]


    Template.profile.events
        'click .sponsor': ->
            current_user = Meteor.users.findOne username:Template.parentData().username
            Meteor.users Meteor.userId(), 
                $addToSet:
                    sponsoring_user_ids: current_user._id
            Meteor.users.update current_user._id, 
                $addToSet:
                    sponsored_by_ids: Meteor.userId()
            
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Meteor.call 'template', 'login', ->
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
    Template.user_credit.onCreated ->
        # @autorun => Meteor.subscribe 'user_by_username', Template.parentData().username
        # @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        # @autorun => Meteor.subscribe 'my_topups'
        # if Meteor.isDevelopment
        #     pub_key = Meteor.settings.public.stripe_test_publishable
        # else if Meteor.isProduction
        #     pub_key = Meteor.settings.public.stripe_live_publishable
        # Template.instance().checkout = StripeCheckout.configure(
        #     key: pub_key
        #     image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
        #     locale: 'auto'
        #     # zipCode: true
        #     token: (token) ->
        #         # product = Docs.findOne Meteor.user()._model
        #         user = Meteor.users.findOne username:Template.parentData().username
        #         deposit_amount = parseInt $('.deposit_amount').val()*100
        #         stripe_charge = deposit_amount*100*1.02+20
        #         # calculated_amount = deposit_amount*100
        #         # console.log calculated_amount
        #         charge =
        #             amount: deposit_amount*1.02+20
        #             currency: 'usd'
        #             source: token.id
        #             description: token.description
        #             # receipt_email: token.email
        #         Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
        #             if error then alert error.reason, 'danger'
        #             else
        #                 alert 'payment received', 'success'
        #                 Docs.insert
        #                     model:'deposit'
        #                     deposit_amount:deposit_amount/100
        #                     stripe_charge:stripe_charge
        #                     amount_with_bonus:deposit_amount*1.05/100
        #                     bonus:deposit_amount*.05/100
        #                 Meteor.users.update user._id,
        #                     $inc: credit: deposit_amount*1.05/100
    	# )


    Template.user_credit.events
        'click .add_credits': ->
            amount = parseInt $('.deposit_amount').val()
            amount_times_100 = parseInt amount*100
            calculated_amount = amount_times_100*1.02+20
            # Template.instance().checkout.open
            #     name: 'credit deposit'
            #     # email:Meteor.user().emails[0].address
            #     description: 'gold run'
            #     amount: calculated_amount
            Docs.insert
                model:'deposit'
                amount: amount
            Meteor.users.update Meteor.userId(),
                $inc: credit: amount_times_100


        'click .initial_withdrawal': ->
            withdrawal_amount = parseInt $('.withdrawal_amount').val()
            if confirm "initiate withdrawal for #{withdrawal_amount}?"
                Docs.insert
                    model:'withdrawal'
                    amount: withdrawal_amount
                    status: 'started'
                    complete: false
                Meteor.users.update Meteor.userId(),
                    $inc: credit: -withdrawal_amount

        'click .cancel_withdrawal': ->
            if confirm "cancel withdrawal for #{@amount}?"
                Docs.remove @_id
                Meteor.users.update Meteor.userId(),
                    $inc: credit: @amount

        'click .send_points': ->
            new_id = 
                Docs.insert 
                    model:'transfer'
                    amount:10
            gstate_set "/transfer/#{new_id}/edit"


    Template.user_credit.helpers
        payments: ->
            Docs.find {
                model:'payment'
                _author_username: Meteor.user().username
            }, sort:_timestamp:-1
        deposits: ->
            Docs.find {
                model:'deposit'
                _author_username: Meteor.user().username
            }, sort:_timestamp:-1
        topups: ->
            Docs.find {
                model:'topup'
                _author_username: Meteor.user().username
            }, sort:_timestamp:-1



    Template.user_credit.events
        'click .add_credit': ->
            user = Meteor.users.findOne(username:Template.parentData().username)
            Meteor.users.update Meteor.userId(),
                $inc:points:10
                # $set:points:1
        'click .remove_points': ->
            user = Meteor.users.findOne(username:Template.parentData().username)
            Meteor.users.update Meteor.userId(),
                $inc:points:-1
        'click .add_credits': ->
            deposit_amount = parseInt $('.deposit_amount').val()*100
            calculated_amount = deposit_amount*1.02+20
            
            # Template.instance().checkout.open
            #     name: 'credit deposit'
            #     # email:Meteor.user().emails[0].address
            #     description: 'gold run'
            #     amount: calculated_amount


            
            
        
if Meteor.isClient
    

    Template.user_badges.onCreated ->
        # @autorun => Meteor.subscribe 'user_badges', Template.parentData().username
        # @autorun => Meteor.subscribe 'model_docs', 'badge'

    Template.user_badges.events
        'keyup .new_badge': (e,t)->
            if e.which is 13
                val = $('.new_badge').val()
                console.log val
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'badge'
                    body: val
                    target_user_id: target_user._id
                val = $('.new_badge').val('')

        'click .submit_badge': (e,t)->
            val = $('.new_badge').val()
            console.log val
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.insert
                model:'badge'
                body: val
                target_user_id: target_user._id
            val = $('.new_badge').val('')



    Template.user_badges.helpers
        user_badges: ->
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.find
                model:'badge'
                # target_user_id: target_user._id

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Template.parentData().user_id


if Meteor.isServer
    Meteor.publish 'user_badges', (username)->
        Docs.find
            model:'badge'        
            
            
if Meteor.isClient

    Template.user_events.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'event', Template.parentData().username
        # @autorun => Meteor.subscribe 'user_events', Template.parentData().username
        @autorun => Meteor.subscribe 'model_docs', 'event'

    Template.user_events.events
        'keyup .new_event': (e,t)->
            if e.which is 13
                val = $('.new_event').val()
                console.log val
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'event'
                    body: val
                    target_user_id: target_user._id

        'click .toggle_maybe': -> Session.set('view_maybe',!Session.get('view_maybe'))

    Template.user_events.helpers
        sent_items: ->
            current_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.find {
                model:'event'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1

        user_maybe_events: ->
            current_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.find
                model:'event'
                maybe_user_ids: $in:[current_user._id]


if Meteor.isServer
    Meteor.publish 'user_events', (username)->
        Docs.find
            model:'event'            
            
            
            
            
if Meteor.isClient
    
    Template.user_messages.onCreated ->
        @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought'


    Template.user_messages.onCreated ->
        @autorun => Meteor.subscribe 'user_messages', Template.parentData().username
        @autorun => Meteor.subscribe 'model_docs', 'message'

    Template.user_messages.events
        'keyup .new_public_message': (e,t)->
            if e.which is 13
                val = $('.new_public_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:false
                    target_user_id: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Template.parentData().username)
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
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:true
                    target_user_id: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                target_user_id: target_user._id
            val = $('.new_private_message').val('')



    Template.user_messages.helpers
        user_public_messages: ->
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:false

        user_private_messages: ->
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:true
                _author_id:Meteor.userId()



if Meteor.isServer
    Meteor.publish 'user_public_messages', (username)->
        target_user = Meteor.users.findOne(username:Template.parentData().username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:false

    Meteor.publish 'user_private_messages', (username)->
        target_user = Meteor.users.findOne(username:Template.parentData().username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:true
            _author_id:Meteor.userId()


            
            
            
if Meteor.isClient

    Template.user_sent.onCreated ->
        # @autorun -> Meteor.subscribe 'user_model_docs', 'debit', Template.parentData().username
        @autorun => Meteor.subscribe 'user_sent', Template.parentData().username, ->

    Template.user_sent.events
        'keyup .new_debit': (e,t)->
            if e.which is 13
                val = $('.new_debit').val()
                console.log val
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'debit'
                    body: val
                    target_user_id: target_user._id



    Template.user_sent.helpers
        sent_items: ->
            current_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.find {
                model:'debit'
                _author_id: current_user._id
                # target_user_id: target_user._id
            },
                sort:_timestamp:-1

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Template.parentData().user_id


# if Meteor.isServer
    # Meteor.publish 'user_sent', (username)->
    #     user = Meteor.users.findOne username:username
    #     Docs.find {
    #         model:'debit'
    #         _author_id: user._id
    #     }, 
    #         limit:100            
            
            
            
# if Meteor.isClient

#     Template.user_sent.onCreated ->
#         # @autorun -> Meteor.subscribe 'user_model_docs', 'debit', Template.parentData().username
#         @autorun => Meteor.subscribe 'user_sent', Template.parentData().username

#     Template.user_sent.events
#         'keyup .new_debit': (e,t)->
#             if e.which is 13
#                 val = $('.new_debit').val()
#                 console.log val
#                 target_user = Meteor.users.findOne(username:Template.parentData().username)
#                 Docs.insert
#                     model:'debit'
#                     body: val
#                     target_user_id: target_user._id



#     Template.user_sent.helpers
#         sent_items: ->
#             current_user = Meteor.users.findOne(username:Template.parentData().username)
#             Docs.find {
#                 model:'debit'
#                 _author_id: current_user._id
#                 # target_user_id: target_user._id
#             },
#                 sort:_timestamp:-1

#         slots: ->
#             Docs.find
#                 model:'slot'
#                 _author_id: Template.parentData().user_id


if Meteor.isServer
    Meteor.publish 'user_sent', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'debit'
            _author_id: user._id
        }, 
            limit:100            
            
            
            
            
# if Meteor.isClient

    # Template.user_orders.onCreated ->
    #     @autorun -> Meteor.subscribe 'user_orders', Template.parentData().username
    #     # @autorun => Meteor.subscribe 'user_orders', Template.parentData().username
    #     # @autorun => Meteor.subscribe 'model_docs', 'order'

    # Template.user_orders.events
    #     'keyup .new_order': (e,t)->
    #         if e.which is 13
    #             val = $('.new_order').val()
    #             console.log val
    #             target_user = Meteor.users.findOne(username:Template.parentData().username)
    #             Docs.insert
    #                 model:'order'
    #                 body: val
    #                 target_user_id: target_user._id



    # Template.user_orders.helpers
    #     orders: ->
    #         current_user = Meteor.users.findOne(username:Template.parentData().username)
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

    Template.user_offers.onCreated ->
        @autorun -> Meteor.subscribe 'user_offers', Template.parentData().username
        # @autorun => Meteor.subscribe 'user_offers', Template.parentData().username
        # @autorun => Meteor.subscribe 'model_docs', 'offer'

    Template.user_offers.events
        'keyup .new_offer': (e,t)->
            if e.which is 13
                val = $('.new_offer').val()
                console.log val
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'offer'
                    body: val
                    target_user_id: target_user._id



    Template.user_offers.helpers
        offers: ->
            current_user = Meteor.users.findOne(username:Template.parentData().username)
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

    Template.user_requests.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'request', Template.parentData().username
        # @autorun => Meteor.subscribe 'user_requests', Template.parentData().username
        @autorun => Meteor.subscribe 'model_docs', 'request'

    Template.user_requests.events
        'keyup .new_request': (e,t)->
            if e.which is 13
                val = $('.new_request').val()
                console.log val
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'request'
                    body: val
                    target_user_id: target_user._id



    Template.user_requests.helpers
        requests: ->
            current_user = Meteor.users.findOne(username:Template.parentData().username)
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

#     Template.user_skills.onCreated ->
#         @autorun -> Meteor.subscribe 'user_model_docs', 'request', Template.parentData().username
#         # @autorun => Meteor.subscribe 'user_skills', Template.parentData().username
#         @autorun => Meteor.subscribe 'model_docs', 'request'

#     Template.user_skills.events
#         'keyup .new_request': (e,t)->
#             if e.which is 13
#                 val = $('.new_request').val()
#                 console.log val
#                 target_user = Meteor.users.findOne(username:Template.parentData().username)
#                 Docs.insert
#                     model:'request'
#                     body: val
#                     target_user_id: target_user._id



#     Template.user_skills.helpers
#         skills: ->
#             current_user = Meteor.users.findOne(username:Template.parentData().username)
#             Docs.find {
#                 model:'request'
#                 _author_id: current_user._id
#                 # target_user_id: target_user._id
#             },
#                 sort:_timestamp:-1



if Meteor.isClient
    Template.user_genekeys.onCreated ->
        @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought'
    Template.user_genekeys.onCreated ->
        @autorun => Meteor.subscribe 'user_genekeys', Template.parentData().username
        @autorun => Meteor.subscribe 'model_docs', 'message'
    Template.user_genekeys.events
        'keyup .new_public_message': (e,t)->
            if e.which is 13
                val = $('.new_public_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:false
                    target_user_id: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Template.parentData().username)
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
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:true
                    target_user_id: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                target_user_id: target_user._id
            val = $('.new_private_message').val('')
    Template.user_genekeys.helpers
        user_public_genekeys: ->
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:false

        user_private_genekeys: ->
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:true
                _author_id:Meteor.userId()
if Meteor.isServer
    Meteor.publish 'user_public_genekeys', (username)->
        target_user = Meteor.users.findOne(username:Template.parentData().username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:false

    Meteor.publish 'user_private_genekeys', (username)->
        target_user = Meteor.users.findOne(username:Template.parentData().username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:true
            _author_id:Meteor.userId()


                                    
                                    
if Meteor.isClient
    Template.user_delivery.onCreated ->
        @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought'
    Template.user_delivery.onCreated ->
        @autorun => Meteor.subscribe 'user_delivery', Template.parentData().username
        @autorun => Meteor.subscribe 'model_docs', 'message'
    Template.user_delivery.events
        'keyup .new_public_message': (e,t)->
            if e.which is 13
                val = $('.new_public_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:false
                    target_user_id: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Template.parentData().username)
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
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:true
                    target_user_id: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                target_user_id: target_user._id
            val = $('.new_private_message').val('')



    Template.user_delivery.helpers
        user_public_delivery: ->
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:false

        user_private_delivery: ->
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:true
                _author_id:Meteor.userId()



if Meteor.isServer
    Meteor.publish 'user_public_delivery', (username)->
        target_user = Meteor.users.findOne(username:Template.parentData().username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:false

    Meteor.publish 'user_private_delivery', (username)->
        target_user = Meteor.users.findOne(username:Template.parentData().username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:true
            _author_id:Meteor.userId()


if Meteor.isClient


    Template.user_credits.onCreated ->
        @autorun => Meteor.subscribe 'user_credits', Template.parentData().username
        # @autorun => Meteor.subscribe 'model_docs', 'debit'

    Template.user_credits.events
        # 'keyup .new_credit': (e,t)->
        #     if e.which is 13
        #         val = $('.new_credit').val()
        #         console.log val
        #         target_user = Meteor.users.findOne(username:Template.parentData().username)
        #         Docs.insert
        #             model:'credit'
        #             body: val
        #             recipient_id: target_user._id



    Template.user_credits_small.helpers
        user_credits: ->
            target_user = Meteor.users.findOne({username:Template.parentData().username})
            Docs.find {
                model:'debit'
                recipient_id: target_user._id
            },
                sort:_timestamp:-1

    Template.user_credits.helpers
        user_credits: ->
            target_user = Meteor.users.findOne({username:Template.parentData().username})
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
    
    Template.user_food.onCreated ->
        @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought'


    Template.user_food.onCreated ->
        # @autorun => Meteor.subscribe 'user_food', Template.parentData().username
        @autorun => Meteor.subscribe 'user_model_docs', 'food_order', Template.parentData().username

    Template.user_food.events
        'keyup .new_public_message': (e,t)->
            if e.which is 13
                val = $('.new_public_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:false
                    target_user_id: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Template.parentData().username)
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
                target_user = Meteor.users.findOne(username:Template.parentData().username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:true
                    target_user_id: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                target_user_id: target_user._id
            val = $('.new_private_message').val('')



    Template.user_food.helpers
        food_orders: ->
            user = Meteor.users.findOne(username:Template.parentData().username)
            Docs.find
                model:'food_order'
                # _author_id:user._id



if Meteor.isServer
    Meteor.publish 'user_public_food', (username)->
        target_user = Meteor.users.findOne(username:Template.parentData().username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:false

    Meteor.publish 'user_private_food', (username)->
        target_user = Meteor.users.findOne(username:Template.parentData().username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:true
            _author_id:Meteor.userId()


            
            
if Meteor.isClient
    Template.user_friends.onCreated ->
        @autorun => Meteor.subscribe 'users'



    Template.user_friends.helpers
        friends: ->
            current_user = Meteor.users.findOne Template.parentData().user_id
            Meteor.users.find
                _id:$in: current_user.friend_ids
        nonfriends: ->
            Meteor.users.find
                _id:$nin:Meteor.user().friend_ids


    Template.user_friend_button.helpers
        is_friend: ->
            Meteor.user() and Meteor.user().friend_ids and @_id in Meteor.user().friend_ids


    Template.user_friend_button.events
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
                current_user = Meteor.users.findOne Template.parentData().user_id
                Docs.insert
                    body:post
                    model:'earn'
                    assigned_user_id:current_user._id
                    assigned_username:current_user.username

                t.$('.assign_earn').val('')            