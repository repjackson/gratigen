if Meteor.isClient
    Template.registerHelper 'transfer_products', () -> 
        Docs.find
            model:'product'
            transfer_id:@_id
    Template.registerHelper 'product_transfer', () -> 
        found = 
            Docs.findOne
                model:'transfer'
                _id:@transfer_id
        # console.log found
        found
    
    Template.user_credit.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'deposits', Router.current().params.username, ->
    
    Template.user_credit.events 
        'click .calc_points': ->
            Meteor.call 'calc_user_points', Meteor.userId(), ->
                
                
            
    Template.user_credit.helpers
        # read_docs: ->
        #     user = Meteor.users.findOne username:Router.current().params.username 
        #     Docs.find 
        #         read_by_user_ids: $in: [user._id]
    
    Template.user_credit.onCreated ->
        @autorun => Meteor.subscribe 'user_by_username', Router.current().params.username, ->
        @autorun => Meteor.subscribe 'model_docs', 'deposit', ->
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        # @autorun => Meteor.subscribe 'my_topups'
        pub_key = Meteor.settings.public.stripe_test_publishable
        # if Meteor.isDevelopment
        #     pub_key = Meteor.settings.public.stripe_test_publishable
        # else if Meteor.isProduction
        #     pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
            locale: 'auto'
            # zipCode: true
            token: (token) ->
                # product = Docs.findOne Router.current().params.doc_id
                user = Meteor.users.findOne username:Router.current().params.username
                deposit_amount = parseInt $('.deposit_amount').val()*100
                stripe_charge = deposit_amount*100*1.02+20
                # calculated_amount = deposit_amount*100
                # console.log calculated_amount
                charge =
                    amount: deposit_amount*1.02+20
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
                    if error then alert error.reason, 'danger'
                    else
                        alert 'payment received', 'success'
                        Docs.insert
                            model:'deposit'
                            deposit_amount:deposit_amount/100
                            stripe_charge:stripe_charge
                            amount_with_bonus:deposit_amount*1.05/100
                            bonus:deposit_amount*.05/100
                        Meteor.users.update user._id,
                            $inc: credit: deposit_amount*1.05/100
    	)


    Template.user_credit.events
        'click .add_credits': ->
            note = prompt 'note'
            note = if note then note else ''
            amount = parseInt $('.deposit_amount').val()
            amount_times_100 = parseInt amount*100
            calculated_amount = amount_times_100*1.02+20
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: "gratigen fiat deposit #{note}"
                amount: calculated_amount
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
        user_deposits: ->
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
        # 'click .add_credits': ->
        #     deposit_amount = parseInt $('.deposit_amount').val()*100
        #     calculated_amount = deposit_amount*1.02+20
            
        #     Template.instance().checkout.open
        #         name: 'credit deposit'
        #         # email:Meteor.user().emails[0].address
        #         description: 'gold run'
        #         amount: calculated_amount


            
            
        
    
    
    
    Template.transfers.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'transfer', 20, ->
        @autorun => Meteor.subscribe 'all_users', ->
            
            
    Template.transfers.events
        'click .add_transfer': ->
            new_id = 
                Docs.insert 
                    model:'transfer'
            
            Router.go "/transfer/#{new_id}"
            Meteor.users.update Meteor.userId(),
                editing:true
            
        
# if Meteor.isServer
#     Meteor.publish 'transfer_products', (transfer_id)->
#         Docs.find   
#             model:'product'
#             transfer_id:transfer_id
            
            
# if Meteor.isClient
#     Template.transfer_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
#         # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'username_search', Session.get('username_query'), ->


#     Template.user_picker.helpers
#         unpicked_users: ->
#             current_transfer = Docs.findOne Router.current().params.doc_id
#             Meteor.users.find 
#                 _id:$ne:current_transfer.recipient
#         picked_user: ->
#             current_transfer = Docs.findOne Router.current().params.doc_id
#             Meteor.users.findOne 
#                 _id:current_transfer.recipient
                
#     Template.user_picker.events
#         'click .pick_user': ->
#             Docs.update Router.current().params.doc_id,
#                 $set:recipient:@_id
#         'keyup .search_user': ->
#             val = $('.search_user').val()
#             Session.set('username_query',val)
        
#     Template.transfer_view.events
#         'click .delete_transfer':->
#             if confirm 'delete?'
#                 Docs.remove @_id
#                 Router.go "/transfers"

            
#     Template.transfer_view.helpers
#         all_shop: ->
#             Docs.find
#                 model:'transfer'
                
# if Meteor.isServer
#     Meteor.publish 'username_search', (query)->
#         console.log 'search', query
#         Meteor.users.find 
#             username:{$regex:query,$options:'i'}


if Meteor.isClient
    Template.transfer_view.onCreated ->
        # @autorun => Meteor.su    Template.user_credit.onCreated ->
        @autorun => Meteor.subscribe 'user_by_username', Router.current().params.username, ->
        # @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        # @autorun => Meteor.subscribe 'my_topups'
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
            locale: 'auto'
            # zipCode: true
            token: (token) ->
                # product = Docs.findOne Router.current().params.doc_id
                user = Meteor.users.findOne username:Router.current().params.username
                deposit_amount = parseInt $('.deposit_amount').val()*100
                stripe_charge = deposit_amount*100*1.02+20
                # calculated_amount = deposit_amount*100
                # console.log calculated_amount
                charge =
                    amount: deposit_amount*1.02+20
                    currency: 'usd'
                    source: token.id
                    description: token.description
                    # receipt_email: token.email
                Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
                    if error then alert error.reason, 'danger'
                    else
                        alert 'payment received', 'success'
                        Docs.insert
                            model:'deposit'
                            deposit_amount:deposit_amount/100
                            stripe_charge:stripe_charge
                            amount_with_bonus:deposit_amount*1.05/100
                            bonus:deposit_amount*.05/100
                        Meteor.users.update user._id,
                            $inc: credit: deposit_amount*1.05/100
    	)


    Template.user_credit.events
        'click .add_credits': ->
            amount = parseInt $('.deposit_amount').val()
            amount_times_100 = parseInt amount*100
            calculated_amount = amount_times_100*1.02+20
            Template.instance().checkout.open
                name: 'credit deposit'
                # email:Meteor.user().emails[0].address
                description: 'gold run'
                amount: calculated_amount
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
        # 'click .add_credits': ->
        #     deposit_amount = parseInt $('.deposit_amount').val()*100
        #     calculated_amount = deposit_amount*1.02+20
            
        #     Template.instance().checkout.open
        #         name: 'credit deposit'
        #         # email:Meteor.user().emails[0].address
        #         description: 'gold run'
        #         amount: calculated_amount


    Template.transfer_view.onRendered ->
        @autorun => Meteor.subscribe 'recipient_from_transfer_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
        @autorun => @subscribe 'tag_results',
            # Router.current().params.doc_id
            picked_tags.array()
            Session.get('searching')
            Session.get('current_query')
            Session.get('dummy')

    Template.transfer_view.helpers
        terms: ->
            Terms.find()
        suggestions: ->
            Tags.find()
        recipient: ->
            transfer = Docs.findOne Router.current().params.doc_id
            if transfer.recipient_id
                Meteor.users.findOne
                    _id: transfer.recipient_id
        members: ->
            transfer = Docs.findOne Router.current().params.doc_id
            Meteor.users.find({
                # levels: $in: ['member','domain']
                _id: $ne: Meteor.userId()
            }, {
                sort:points:1
                limit:10
                })
        # subtotal: ->
        #     transfer = Docs.findOne Router.current().params.doc_id
        #     transfer.amount*transfer.recipient_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_submit: ->
            transfer = Docs.findOne Router.current().params.doc_id
            transfer.amount and transfer.recipient_id
    Template.transfer_view.events
        'click .add_recipient': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    recipient_id:@_id
        'click .remove_recipient': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    recipient_id:1
        'keyup .new_tag': _.throttle((e,t)->
            query = $('.new_tag').val()
            if query.length > 0
                Session.set('searching', true)
            else
                Session.set('searching', false)
            Session.set('current_query', query)
            
            if e.which is 13
                element_val = t.$('.new_tag').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                picked_tags.push element_val
                Meteor.call 'log_term', element_val, ->
                Session.set('searching', false)
                Session.set('current_query', '')
                Session.set('dummy', !Session.get('dummy'))
                t.$('.new_tag').val('')
        , 1000)

        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            picked_tags.remove element
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_tag').focus()
            t.$('.new_tag').val(element)
            Session.set('dummy', !Session.get('dummy'))
    
    
        'click .select_term': (e,t)->
            # picked_tags.push @title
            Docs.update Router.current().params.doc_id,
                $addToSet:tags:@title
            picked_tags.push @title
            $('.new_tag').val('')
            Session.set('current_query', '')
            Session.set('searching', false)
            Session.set('dummy', !Session.get('dummy'))


        'click .cancel_transfer': ->
            Swal.fire({
                title: "confirm cancel?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonColor: 'red'
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Router.go '/'
            )
            
        'click .submit': ->
            Swal.fire({
                title: "confirm send #{@amount}pts?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonColor: 'green'
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'send_transfer', @_id, =>
                        Swal.fire(
                            title:"#{@amount} sent"
                            icon:'success'
                            showConfirmButton: false
                            position: 'top-end',
                            timer: 1000
                        )
                        Router.go "/transfer/#{@_id}"
            )



if Meteor.isServer
    Meteor.publish 'deposits', ->
        Docs.find 
            model:'deposit'
    Meteor.methods
        send_transfer: (transfer_id)->
            transfer = Docs.findOne transfer_id
            recipient = Meteor.users.findOne transfer.recipient_id
            transferer = Meteor.users.findOne transfer._author_id

            console.log 'sending transfer', transfer
            Meteor.call 'recalc_one_stats', recipient._id, ->
            Meteor.call 'recalc_one_stats', transfer._author_id, ->
    
            Docs.update transfer_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()
            return
            
            
            
if Meteor.isClient
    Router.route '/transfers/', (->
        @layout 'layout'
        @render 'transfers'
        ), name:'transfers'
    Router.route '/my_accounts/', (->
        @layout 'layout'
        @render 'transfers'
        ), name:'my_accounts'
    

    Template.transfer_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_transfer_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->



if Meteor.isServer
    Meteor.publish 'product_from_transfer_id', (transfer_id)->
        transfer = Docs.findOne transfer_id
        Docs.find 
            _id:transfer.product_id            