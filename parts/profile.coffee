if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'user_layout'
        @render 'user_dashboard'
        ), name:'profile'
    Router.route '/user/:username/cart', (->
        @layout 'user_layout'
        @render 'cart'
        ), name:'user_cart'
    Router.route '/user/:username/credit', (->
        @layout 'user_layout'
        @render 'user_credit'
        ), name:'user_credit'
    Router.route '/user/:username/orders', (->
        @layout 'user_layout'
        @render 'user_orders'
        ), name:'user_orders'
    Router.route '/user/:username/friends', (->
        @layout 'user_layout'
        @render 'user_friends'
        ), name:'user_friends'
    Router.route '/user/:username/subscriptions', (->
        @layout 'user_layout'
        @render 'user_subs'
        ), name:'user_subscriptions'
    Router.route '/user/:username/posts', (->
        @layout 'user_layout'
        @render 'user_posts'
        ), name:'user_posts'
    Router.route '/user/:username/products', (->
        @layout 'user_layout'
        @render 'user_products'
        ), name:'user_products'
    Router.route '/user/:username/comments', (->
        @layout 'user_layout'
        @render 'user_comments'
        ), name:'user_comments'



    Template.user_layout.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username, ->
if Meteor.isServer 
    Meteor.publish 'user_bookmark_docs', ->
        Docs.find 
            _id:$in:Meteor.user().bookmark_ids


if Meteor.isClient 
    Template.user_layout.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

    Template.user_layout.helpers
        current_user: ->
            Meteor.users.findOne username:Router.current().params.username

        user: ->
            Meteor.users.findOne username:Router.current().params.username

    Template.user_layout.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()
            
            
            
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
        @autorun => Meteor.subscribe 'user_by_username', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        @autorun => Meteor.subscribe 'my_topups'
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
        #         # product = Docs.findOne Router.current().params.doc_id
        #         user = Meteor.users.findOne username:Router.current().params.username
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
            Router.go "/transfer/#{new_id}/edit"


    Template.user_credit.helpers
        payments: ->
            Docs.find {
                model:'payment'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        deposits: ->
            Docs.find {
                model:'deposit'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        topups: ->
            Docs.find {
                model:'topup'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1




    Template.user_credit.events
        'click .add_credit': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            Meteor.users.update Meteor.userId(),
                $inc:points:10
                # $set:points:1
        'click .remove_points': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
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



            
            
if Meteor.isServer
    Meteor.publish 'my_topups', ->
        Docs.find 
            model:'topup'
            _author_id:Meteor.userId()  
            amount:$exists:true
            
            
            
if Meteor.isClient
    Router.route '/user/:username/genekeys', (->
        @layout 'profile_layout'
        @render 'user_genekeys'
        ), name:'user_genekeys'
    
    Template.user_genekeys.onCreated ->
        @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought'


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
                    recipient: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                is_private:false
                body: val
                recipient: target_user._id
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
                    recipient: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                recipient: target_user._id
            val = $('.new_private_message').val('')



    Template.user_genekeys.helpers
        user_public_genekeys: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                recipient: target_user._id
                is_private:false

        user_private_genekeys: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                recipient: target_user._id
                is_private:true
                _author_id:Meteor.userId()



if Meteor.isServer
    Meteor.publish 'user_public_genekeys', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            recipient: target_user._id
            is_private:false

    Meteor.publish 'user_private_genekeys', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            recipient: target_user._id
            is_private:true
            _author_id:Meteor.userId()




if Meteor.isClient
    Router.route '/user/:username/credits', (->
        @layout 'profile_layout'
        @render 'user_received'
        ), name:'user_received'


    Template.user_received.onCreated ->
        @autorun => Meteor.subscribe 'user_received', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'debit'

    Template.user_received.events
        # 'keyup .new_credit': (e,t)->
        #     if e.which is 13
        #         val = $('.new_credit').val()
        #         console.log val
        #         target_user = Meteor.users.findOne(username:Router.current().params.username)
        #         Docs.insert
        #             model:'credit'
        #             body: val
        #             recipient_id: target_user._id



    Template.user_received_small.helpers
        user_received: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'debit'
                recipient_id: target_user._id
            },
                sort:_timestamp:-1

    Template.user_received.helpers
        user_received_docs: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'debit'
                recipient_id: target_user._id
            },
                sort:_timestamp:-1




if Meteor.isServer
    Meteor.publish 'user_received', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'debit'
            recipient_id:user._id
            
            
            
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
                    recipient: target_user._id
                val = $('.new_badge').val('')

        'click .submit_badge': (e,t)->
            val = $('.new_badge').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'badge'
                body: val
                recipient: target_user._id
            val = $('.new_badge').val('')



    Template.user_badges.helpers
        user_badges: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'badge'
                # recipient: target_user._id

        slots: ->
            Docs.find
                model:'slot'
                _author_id: Router.current().params.user_id


if Meteor.isServer
    Meteor.publish 'user_badges', (username)->
        Docs.find
            model:'badge'
            
            
            
if Meteor.isClient
    Router.route '/user/:username/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
        
        
    Template.user_dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'user_credits', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_debits', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_requests', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_completed_requests', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_event_tickets', Router.current().params.username
        @autorun -> Meteor.subscribe 'model_docs', 'event'
        
    Template.user_dashboard.events
        'click .user_credit_segment': ->
            Router.go "/debit/#{@_id}/view"
            
        'click .user_debit_segment': ->
            Router.go "/debit/#{@_id}/view"
            
            
            
    Template.user_dashboard.helpers
        user_debits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                _author_id: current_user._id
            }, 
                limit: 10
                sort: _timestamp:-1
        user_credits: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'debit'
                recipient_id: current_user._id
            }, 
                sort: _timestamp:-1
                limit: 10

        user_requests: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'request'
                _author_id: current_user._id
            }, 
                sort: _timestamp:-1
                limit: 10

        user_completed_requests: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'request'
                completed_by_user_id: current_user._id
            }, 
                sort: _timestamp:-1
                limit: 10

        user_event_tickets: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transaction'
                transaction_type:'ticket_purchase'
            }, 
                sort: _timestamp:-1
                limit: 10


if Meteor.isServer
    Meteor.publish 'user_debits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'debit'
            _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
        
        
    # Meteor.publish 'user_requests', (username)->
    #     user = Meteor.users.findOne username:username
    #     Docs.find({
    #         model:'request'
    #         completed_by_user_id:user._id
    #     },{
    #         limit:20
    #         sort: _timestamp:-1
    #     })
        
    Meteor.publish 'user_event_tickets', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'transaction'
            transaction_type:'ticket_purchase'
            _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
        
        
        
        
        
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
                    recipient: target_user._id



    Template.user_requests.helpers
        requests: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'request'
                _author_id: current_user._id
                # recipient: target_user._id
            },
                sort:_timestamp:-1



if Meteor.isServer
    Meteor.publish 'user_requests', (username)->
        Docs.find
            model:'request'
            
            
            
if Meteor.isClient
    Router.route '/user/:username/tribes', (->
        @layout 'profile_layout'
        @render 'user_tribes'
        ), name:'user_tribes'

    Template.user_tribes.onCreated ->
        @autorun -> Meteor.subscribe 'user_member_tribes', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_leader_tribes', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_tribes', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'order'

    Template.user_tribes.events
        'keyup .new_order': (e,t)->
            if e.which is 13
                val = $('.new_order').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'order'
                    body: val
                    recipient: target_user._id

    Template.enter_tribe.events
        'click .enter': ->
            Meteor.call 'enter_tribe', @_id, ->

    Template.user_tribes.helpers
        tribes: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'order'
                _author_id: current_user._id
                # recipient: target_user._id
            },
                sort:_timestamp:-1

        user_member_tribes: ->
            user = Meteor.users.findOne username:@username
            Docs.find
                model:'tribe'
                tribe_member_ids:$in:[user._id]
            
        user_leader_tribes: ->
            user = Meteor.users.findOne username:@username
            Docs.find
                model:'tribe'
                tribe_leader_ids:$in:[user._id]




if Meteor.isServer
    Meteor.methods 
        enter_tribe: (tribe_id)->
            Meteor.users.update Meteor.userId(),
                $set:
                    current_tribe_id:tribe_id
    
    Meteor.publish 'user_member_tribes', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'tribe'
            tribe_member_ids:$in:[user._id]
            
    Meteor.publish 'user_leader_tribes', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'tribe'
            tribe_leader_ids:$in:[user._id]
            
            
            
            
if Meteor.isClient
    Router.route '/user/:username/messages', (->
        @layout 'profile_layout'
        @render 'user_messages'
        ), name:'user_messages'
    
    Template.user_messages.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'thought'


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
                    recipient: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                is_private:false
                body: val
                recipient: target_user._id
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
                    recipient: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                recipient: target_user._id
            val = $('.new_private_message').val('')



    Template.user_messages.helpers
        user_public_messages: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                recipient: target_user._id
                is_private:false

        user_private_messages: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                recipient: target_user._id
                is_private:true
                _author_id:Meteor.userId()



if Meteor.isServer
    Meteor.publish 'user_public_messages', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            recipient: target_user._id
            is_private:false

    Meteor.publish 'user_private_messages', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            recipient: target_user._id
            is_private:true
            _author_id:Meteor.userId()


