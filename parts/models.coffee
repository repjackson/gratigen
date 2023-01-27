if Meteor.isServer 
    Meteor.publish 'my_events_publication', ->
        user = Meteor.user()
        # authored
        Docs.find 
            model:'event'
            _author_id:Meteor.userId()



if Meteor.isClient
    Template.registerHelper 'facilitator', () ->    
        Meteor.users.findOne @facilitator_id
    Template.registerHelper 'fac', () ->    
        Meteor.users.findOne @facilitator_id
   
    Template.registerHelper 'my_ticket', () ->    
        event = Docs.findOne @_id
        Docs.findOne
            model:'order'
            order_type:'ticket_purchase'
            event_id:@_id
            _author_id:Meteor.userId()
   
    Template.registerHelper 'event_room', () ->
        event = Docs.findOne @_id
        Docs.findOne 
            _id:event.room_id

    Template.registerHelper 'going', () ->
        event = Docs.findOne @_id
        event_tickets = 
            Docs.find(
                model:'order'
                order_type:'ticket_purchase'
                event_id: @_id
                ).fetch()
        going_user_ids = []
        for ticket in event_tickets
            going_user_ids.push ticket._author_id
        Meteor.users.find 
            _id:$in:going_user_ids
            
    Template.registerHelper 'maybe_going', () ->
        event = Docs.findOne @_id
        Meteor.users.find 
            _id:$in:event.maybe_user_ids
    Template.registerHelper 'not_going', () ->
        event = Docs.findOne @_id
        Meteor.users.find 
            _id:$in:event.not_user_ids

    Template.registerHelper 'event_tickets', () ->
        Docs.find 
            model:'order'
            order_type:'ticket_purchase'
            event_id: Meteor.user()._model


    Template.event_view.onCreated ->
        # @autorun => @subscribe 'model_docs', 'order'
    Template.event_view.events
        'click .buy_ticket': ->
            Docs.insert 
                model:'order'
                ticket:true
                event_id:@_id
                ticket_price: @point_price
        
    Template.event_view.helpers
        event_ticket_docs: ->
            Docs.find
                model:'order'
                ticket:true
                event_id:@_id
                ticket_price: @point_price
        
    
        can_add_event: ->
            facilitator_badge = 
                Docs.findOne    
                    model:'badge'
                    slug:'facilitator'
            if facilitator_badge
                Meteor.userId() in facilitator_badge.badger_ids
            
    
    

if Meteor.isServer
    Meteor.publish 'future_events', ()->
        console.log moment().subtract(1,'days').format("YYYY-MM-DD")
        Docs.find {
            model:'event'
            published:true
            date:$gt:moment().subtract(1,'days').format("YYYY-MM-DD")
        }, 
            sort:date:1
    
    Meteor.publish 'events', (
        viewing_room_id
        viewing_past
        viewing_published
        )->
            
        match = {model:'event'}
        if viewing_room_id
            match.room_id = viewing_room_id
        if viewing_past
            match.date = $gt:moment().subtract(1,'days').format("YYYY-MM-DD")
            
        match.published = viewing_published    
            
        console.log moment().subtract(1,'days').format("YYYY-MM-DD")
        Docs.find match, 
            sort:date:1
    

    # Meteor.publish 'doc_by_slug', (slug)->
    #     Docs.find
    #         slug:slug
            
    # Meteor.publish 'author_by_doc_id', (doc_id)->
    #     doc_by_id =
    #         Docs.findOne doc_id
    #     doc_by_slug =
    #         Docs.findOne slug:doc_id
    #     if doc_by_id
    #         Meteor.users.findOne 
    #             _id:doc_by_id._author_id
    #     else
    #         Meteor.users.findOne 
    #             _id:doc_by_slug._author_id
            
            
    # Meteor.publish 'author_by_doc_slug', (slug)->
    #     doc = 
    #         Docs.findOne
    #             slug:slug
    #     Meteor.users.findOne 
    #         _id:doc._author_id


#     Meteor.methods
        # send_event: (event_id)->
        #     event = Docs.findOne event_id
        #     target = Meteor.users.findOne event.recipient_id
        #     gifter = Meteor.users.findOne event._author_id
        #
        #     console.log 'sending event', event
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: event.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -event.amount
        #     Docs.update event_id,
        #         $set:
        #             submitted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Meteor.user()._model,
        #         $set:
        #             submitted:true


 if Meteor.isClient
    Template.registerHelper 'ticket_event', () ->
        Docs.findOne @event_id



    Template.ticket_view.onCreated ->
        @autorun => Meteor.subscribe 'event_from_ticket_id', Meteor.user()._model
        @autorun => Meteor.subscribe 'author_from_doc_id', Meteor.user()._model
        @autorun => Meteor.subscribe 'doc', Meteor.user()._model
        @autorun => Meteor.subscribe 'all_users'
        
    Template.ticket_view.onRendered ->

    Template.ticket_view.events
        'click .cancel_reservation': ->
            event = @
            # Swal.fire({
            #     title: "cancel reservation?"
            #     # text: "cannot be undone"
            #     icon: 'question'
            #     confirmButtonText: 'confirm cancelation'
            #     confirmButtonColor: 'red'
            #     showCancelButton: true
            #     cancelButtonText: 'return'
            #     reverseButtons: true
            # }).then((result)=>
            #     if result.value
            #         console.log @
            #             Meteor.call 'remove_reservation', @_id, =>
            #                 Swal.fire(
            #                     position: 'top-end',
            #                     icon: 'success',
            #                     title: 'reservation removed',
            #                     showConfirmButton: false,
            #                     timer: 1500
            #                 )
            #                 gstate_set "/event/#{event}/view"
            #         )
            # )_



if Meteor.isServer
    Meteor.publish 'event_from_ticket_id', (ticket_id)->
        ticket = Docs.findOne ticket_id
        Docs.find 
            _id:ticket.event_id
            
            
    Meteor.methods
        remove_reservation: (doc_id)->
            Docs.remove doc_id
            
            
            
if Meteor.isClient
    Template.eft_view_item.helpers 
        in_list: ()->
            if @efts
                @label in @efts
            # cd = Docs.findOne Meteor.user()._model 
            # @label in cd.efts
    Template.eft_view_item_small.onRendered ->
        Meteor.setTimeout ->
            $('.icon')
                .popup()
        , 2000
    Template.eft_view_item_small.helpers 
        in_list: ()->
            # cd = Docs.findOne Meteor.user()._model 
            if Template.parentData() and Template.parentData().efts
                @label in Template.parentData().efts
            # @label in cd.efts
    Template.eft_picker.events 
        'click .toggle_eft': ->
            d = Docs.findOne Meteor.user().delta_id
            current_doc = Docs.findOne d._doc_id 
            if current_doc.efts
                if @label in current_doc.efts 
                    Docs.update current_doc._id,
                        $pull:
                            efts:@label
                else 
                    Docs.update current_doc._id,
                        $addToSet:
                            efts:@label
            else 
                Docs.update current_doc._id,
                    $addToSet:
                        efts:@label
    Template.eft_picker.helpers 
        toggled: -> 
            current_doc = Docs.findOne Meteor.user()._model 
            if current_doc.efts
                @label in current_doc.efts
            else 
                false
        eft_picker_class: ->
            current_doc = Docs.findOne Meteor.user()._model 
            if current_doc.efts
                if @label in current_doc.efts
                    'basic'
                else
                    'tertiary'
            else 
                'tertiary'


    Template.event_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Meteor.user()._model, ->
        @autorun => Meteor.subscribe 'model_docs', 'room_reservation', ->
        @autorun => Meteor.subscribe 'model_docs', 'room', ->
    Template.event_edit.onRendered ->
    Template.event_edit.helpers
        rooms: ->
            Docs.find   
                model:'room'


    Template.event_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .select_room': ->
            reservation_exists = 
                Docs.findOne
                    model:'room_reservation'
                    room_id:event.room_id 
                    date:event.date
            console.log reservation_exists
            unless reservation_exists            
                Docs.update Meteor.user()._model,
                    $set:
                        room_id:@_id
                        room_title:@title

        'click .submit': ->
            Docs.update Meteor.user()._model,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'send_event', @_id, =>
                    gstate_set "/event/#{@_id}"


    Template.event_edit.helpers
        reservation_exists: ->
            event = Docs.findOne Meteor.user()._model
            Docs.findOne
                model:'room_reservation'
                # room_id:event.room_id 
                date:event.date
        room_button_class: ->
            event = Docs.findOne Meteor.user()._model
            room = Docs.findOne _id:event.room_id
            reservation_exists = 
                Docs.findOne
                    model:'room_reservation'
                    # room_id:event.room_id 
                    date:event.date
            res = ''
            if event.room_id is @_id
                res += 'blue'
            else 
                res += 'basic'
            if reservation_exists
                # console.log 'res exists'
                res += ' disabled'
            else
                console.log 'no res'
            res
    
        room_reservations: ->
            event = Docs.findOne Meteor.user()._model
            room = Docs.findOne _id:event.room_id
            Docs.find 
                model:'room_reservation'
                room_id:event.room_id 
                date:event.date
                
    Template.reserve_button.helpers
        event_room: ->
            event = Docs.findOne Meteor.user()._model
            room = Docs.findOne _id:event.room_id
        slot_res: ->
            event = Docs.findOne Meteor.user()._model
            room = Docs.findOne _id:event.room_id
            Docs.findOne
                model:'room_reservation'
                room_id:event.room_id
                date:event.date
                slot:@slot
    
    
    Template.reserve_button.events
        'click .cancel_res': ->
            Swal.fire({
                title: "confirm delete reservation?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
            )
        'click .reserve_slot': ->
            event = Docs.findOne Meteor.user()._model
            room = Docs.findOne _id:event.room_id
            Docs.insert 
                model:'room_reservation'
                room_id:event.room_id
                date:event.date
                slot:@slot
                payment:'points'

if Meteor.isServer
    Meteor.methods
        send_event: (event_id)->
            event = Docs.findOne event_id
            target = Meteor.users.findOne event.recipient_id
            gifter = Meteor.users.findOne event._author_id

            console.log 'sending event', event
            Meteor.users.update target._id,
                $inc:
                    points: event.amount
            Meteor.users.update gifter._id,
                $inc:
                    points: -event.amount
            Docs.update event_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()



            Docs.update Meteor.user()._model,
                $set:
                    submitted:true



if Meteor.isClient
    Template.event_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Meteor.user()._model
        @autorun => Meteor.subscribe 'doc_by_slug', Template.parentData().doc_slug
        @autorun => Meteor.subscribe 'author_by_doc_id', Meteor.user()._model
        # @autorun => Meteor.subscribe 'author_by_doc_slug', Template.parentData().doc_slug

        @autorun => Meteor.subscribe 'event_tickets', Meteor.user()._model, ->
        @autorun => Meteor.subscribe 'event_orders', Meteor.user()._model, ->
        # @autorun => Meteor.subscribe 'model_docs', 'room'
        
        if Meteor.isDevelopment
            pub_key = Meteor.settings.public.stripe_test_publishable
        else if Meteor.isProduction
            pub_key = Meteor.settings.public.stripe_live_publishable
        Template.instance().checkout = StripeCheckout.configure(
            key: pub_key
            image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/one_logo.png'
            locale: 'auto'
            zipCode: true
            token: (token) =>
                # amount = parseInt(Session.get('topup_amount'))
                event = Docs.findOne Meteor.user()._model
                charge =
                    amount: event.price_usd*100
                    event_id:event._id
                    currency: 'usd'
                    source: token.id
                    input:'number'
                    # description: token.description
                    description: "gratigen event ticket purchase"
                    event_title:event.title
                    # receipt_email: token.email
                Meteor.call 'buy_ticket', charge, (err,res)=>
                    if err then alert err.reason, 'danger'
                    else
                        console.log 'res', res
                        Swal.fire(
                            'ticket purchased',
                            ''
                            'success'
                        # Meteor.users.update Meteor.userId(),
                        #     $inc: points:500
                        )
        )
    
    Template.event_view.onRendered ->
        Docs.update Meteor.user()._model, 
            $inc: views: 1

    Template.event_view.helpers 
        can_buy: ->
            now = Date.now()
            

    Template.event_view.events
        'click .buy_for_points': (e,t)->
            val = parseInt $('.point_input').val()
            Session.set('point_paying',val)
            # $('.ui.modal').modal('show')
            Swal.fire({
                title: "buy ticket for #{Session.get('point_paying')}pts?"
                text: "#{@title}"
                icon: 'question'
                # input:'number'
                confirmButtonText: 'purchase'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.insert 
                        model:'order'
                        order_type:'ticket_purchase'
                        payment_type:'points'
                        is_points:true
                        point_amount:Session.get('point_paying')
                        event_id:@_id
                    Meteor.users.update Meteor.userId(),
                        $inc:points:-Session.get('point_paying')
                    Meteor.users.update @_author_id, 
                        $inc:points:Session.get('point_paying')
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'ticket purchased',
                        showConfirmButton: false,
                        timer: 1500
                    )
            )
        
        'click .return': (e,t)->
            # val = parseInt $('.point_input').val()
            # Session.set('point_paying',val)
            # $('.ui.modal').modal('show')
            Swal.fire({
                title: "return ticket?"
                # text: "#{Template.parentData().title}"
                icon: 'question'
                # input:'number'
                confirmButtonText: 'return'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'ticket returned',
                        showConfirmButton: false,
                        timer: 1500
                    )
            )
    
        'click .buy_for_usd': (e,t)->
            console.log Template.instance()
            val = parseInt t.$('.usd_input').val()
            Session.set('usd_paying',val)

            instance = Template.instance()
            event = 
                Docs.findOne Meteor.user()._model
            console.log event
            if event.price_usd
                Swal.fire({
                    # title: "buy ticket for $#{@usd_price} or more!"
                    title: "buy ticket for $#{event.price_usd}?"
                    text: "for #{@title}"
                    icon: 'question'
                    showCancelButton: true,
                    confirmButtonText: 'purchase'
                    # input:'number'
                    confirmButtonColor: 'green'
                    showCancelButton: true
                    cancelButtonText: 'cancel'
                    reverseButtons: true
                }).then((result)=>
                    if result.value
                        # Session.set('topup_amount',5)
                        # Template.instance().checkout.open
                        instance.checkout.open
                            name: 'gratigen'
                            # email:Meteor.user().emails[0].address
                            description: "#{@title} ticket purchase"
                            amount: event.price_usd*100
                
                        Meteor.users.update @_author_id,
                            $inc:credit:@order_price
                        Swal.fire(
                            'topup initiated',
                            ''
                            'success'
                        )
                )




    
    Template.attendance.events
        'click .mark_maybe': ->
            event = Docs.findOne Meteor.user()._model
            Meteor.call 'mark_maybe', Meteor.user()._model, ->
    
        'click .mark_not': ->
            event = Docs.findOne Meteor.user()._model
            Meteor.call 'mark_not', Meteor.user()._model, ->

    Template.event_card.events
        'click .mark_maybe': ->
            Meteor.call 'mark_maybe', @_id, ->
    
        'click .mark_not': ->
            Meteor.call 'mark_not', @_id, ->
    Template.event_view.helpers
        tickets_left: ->
            ticket_count = 
                Docs.find({ 
                    model:'order'
                    # order_type:'ticket_purchase'
                    event_id: Meteor.user()._model
                }).count()
            @max_attendees-ticket_count
        event_orders: ->
            Docs.find 
                model:'order'
                


# if Meteor.isServer
#     Meteor.publish 'event_tickets', (event_id)->
#         Docs.find
#             model:'order'
#             order_type:'ticket_purchase'
#             event_id:event_id


Meteor.methods
    'mark_not': (event_id)->
        event = Docs.findOne event_id
        if Meteor.userId() in event.not_user_ids
            Docs.update event_id,
                $pull:
                    not_user_ids: Meteor.userId()
        else
            Docs.update event_id,
                $addToSet:
                    not_user_ids: Meteor.userId()
                $pull:
                    going_user_ids: Meteor.userId()
                    maybe_user_ids: Meteor.userId()

        
    'mark_maybe': (event_id)->
        event = Docs.findOne event_id
        if Meteor.userId() in event.maybe_user_ids
            Docs.update event_id,
                $pull:
                    maybe_user_ids: Meteor.userId()
        else
            Docs.update event_id,
                $addToSet:
                    maybe_user_ids: Meteor.userId()
                $pull:
                    going_user_ids: Meteor.userId()
                    not_user_ids: Meteor.userId()
                    
                    
if Meteor.isServer
    Meteor.publish 'event_tickets', (event_id)->
        event = Docs.findOne event_id 
        if event 
            Docs.find 
                model:'order'
                event_id:event_id
                
    Meteor.publish 'event_orders', (event_id)->
        event = Docs.findOne event_id 
        if event 
            Docs.find 
                model:'order'
                
                
                
                


if Meteor.isClient
    Template.registerHelper 'claimer', () ->
        Meteor.users.findOne @claimed_user_id
    Template.registerHelper 'completer', () ->
        Meteor.users.findOne @completed_by_user_id
    
    
    Template.request_view.events
        'click .claim': ->
            Docs.update Meteor.user()._model,
                $set:
                    claimed_user_id: Meteor.userId()
                    status:'claimed'
            
                            
        'click .unclaim': ->
            Docs.update Meteor.user()._model,
                $unset:
                    claimed_user_id: 1
                $set:
                    status:'unclaimed'
            
                            
        'click .mark_complete': ->
            Docs.update Meteor.user()._model,
                $set:
                    complete: true
                    completed_by_user_id:@claimed_user_id
                    status:'complete'
                    completed_timestamp:Date.now()
            Meteor.users.update @claimed_user_id,
                $inc:points:@point_bounty
                            
        'click .mark_incomplete': ->
            Docs.update Meteor.user()._model,
                $set:
                    complete: false
                    completed_by_user_id: null
                    status:'claimed'
                    completed_timestamp:null
            Meteor.users.update @claimed_user_id,
                $inc:points:-@point_bounty
                            

    Template.request_view.helpers
        can_claim: ->
            if @claimed_user_id
                false
            else 
                if @_author_id is Meteor.userId()
                    false
                else
                    true



# if Meteor.isServer
#     Meteor.methods
        # send_request: (request_id)->
        #     request = Docs.findOne request_id
        #     target = Meteor.users.findOne request.recipient_id
        #     gifter = Meteor.users.findOne request._author_id
        #
        #     console.log 'sending request', request
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: request.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -request.amount
        #     Docs.update request_id,
        #         $set:
        #             publishted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Meteor.user()._model,
        #         $set:
        #             submitted:true


if Meteor.isClient
    Template.request_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Meteor.user()._model
        # @autorun => Meteor.subscribe 'doc', Meteor.user()._model
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'
    
    Template.request_edit.onRendered ->


    Template.request_edit.events
        'click .delete_request': ->
            Swal.fire({
                title: "delete request?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'request removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    gstate_set "/m/request"
            )


    Template.request_edit.helpers
    Template.request_edit.events

if Meteor.isServer
    Meteor.methods
        publish_request: (request_id)->
            request = Docs.findOne request_id
            # target = Meteor.users.findOne request.recipient_id
            author = Meteor.users.findOne request._author_id

            console.log 'publishing request', request
            Meteor.users.update author._id,
                $inc:
                    points: -request.point_bounty
            Docs.update request_id,
                $set:
                    published:true
                    published_timestamp:Date.now()
                    
                    
        unpublish_request: (request_id)->
            request = Docs.findOne request_id
            # target = Meteor.users.findOne request.recipient_id
            author = Meteor.users.findOne request._author_id

            console.log 'unpublishing request', request
            Meteor.users.update author._id,
                $inc:
                    points: request.point_bounty
            Docs.update request_id,
                $set:
                    published:false
                    published_timestamp:null
                    
                    
                    
if Meteor.isServer 
    Meteor.publish 'request_facets', (
        picked_tags=[]
        title_filter
        picked_authors=[]
        picked_requests=[]
        picked_locations=[]
        picked_timestamp_tags=[]
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        # console.log 'picked staff', picked_authors
    
        self = @
        match = {}
        # match = {app:'pes'}
        # match.group_id = Meteor.user().current_group_id
        
        match.model = 'request'
        if title_filter and title_filter.length > 1
            match.title = {$regex:title_filter, $options:'i'}
        
        # if view_vegan
        #     match.vegan = true
        # if view_gf
        #     match.gluten_free = true
        # if view_local
        #     match.local = true
        if picked_authors.length > 0 then match._author_username = $in:picked_authors
        if picked_tags.length > 0 then match.tags = $all:picked_tags 
        if picked_locations.length > 0 then match.location_title = $in:picked_locations 
        if picked_timestamp_tags.length > 0 then match._timestamp_tags = $in:picked_timestamp_tags 
        # match.$regex:"#{product_query}", $options: 'i'}
        # if product_query and product_query.length > 1
        author_cloud = Docs.aggregate [
            { $match: match }
            { $project: "_author_username": 1 }
            { $group: _id: "$_author_username", count: $sum: 1 }
            { $match: _id: $nin: picked_authors }
            # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
        
        author_cloud.forEach (author, i) =>
            # console.log 'queried author ', author
            # console.log 'key', key
            self.added 'results', Random.id(),
                title: author.title
                count: author.count
                model:'author'
                # category:key
                # index: i
    
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
        
        tag_cloud.forEach (tag, i) =>
            # console.log 'queried tag ', tag
            # console.log 'key', key
            self.added 'results', Random.id(),
                title: tag.title
                count: tag.count
                model:'request_tag'
                # category:key
                # index: i
    
    
        location_cloud = Docs.aggregate [
            { $match: match }
            { $project: "location_title": 1 }
            # { $unwind: "$locations" }
            { $match: _id: $nin: picked_locations }
            { $group: _id: "$location_title", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
    
        location_cloud.forEach (location, i) =>
            # console.log 'location result ', location
            self.added 'results', Random.id(),
                title: location.title
                count: location.count
                model:'location'
                # category:key
                # index: i
    
        timestamp_tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "_timestamp_tags": 1 }
            { $unwind: "$_timestamp_tags" }
            { $match: _id: $nin: picked_timestamp_tags }
            { $group: _id: "$_timestamp_tags", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
    
        timestamp_tag_cloud.forEach (timestamp_tag, i) =>
            # console.log 'timestamp_tag result ', timestamp_tag
            self.added 'results', Random.id(),
                title: timestamp_tag.title
                count: timestamp_tag.count
                model:'timestamp_tag'
                # category:key
                # index: i
    
    
    
    
        self.ready()
        
    Meteor.publish 'request_docs', (
        picked_tags
        title_filter
        picked_authors=[]
        picked_requests=[]
        picked_locations=[]
        picked_timestamp_tags=[]
        # product_query
        # view_vegan
        # view_gf
        # doc_limit
        # doc_sort_key
        # doc_sort_direction
        )->
    
        self = @
        match = {}
        # match = {app:'pes'}
        match.model = 'request'
        # match.group_id = Meteor.user().current_group_id
        
        if title_filter and title_filter.length > 1
            match.title = {$regex:title_filter, $options:'i'}
        
        # if view_vegan
        #     match.vegan = true
        # if view_gf
        #     match.gluten_free = true
        # if view_local
        #     match.local = true
        if picked_authors.length > 0 then match._author_username = $in:picked_authors
        if picked_tags.length > 0 then match.tags = $all:picked_tags 
        if picked_locations.length > 0 then match.location_title = $in:picked_locations 
        if picked_timestamp_tags.length > 0 then match._timestamp_tags = $in:picked_timestamp_tags 
        console.log match
        Docs.find match, 
            limit:20
            sort:
                _timestamp:-1


if Meteor.isClient
    Template.user_posts.onCreated ->
        @autorun => Meteor.subscribe 'user_posts', Template.parentData().username, ->
    Template.user_posts.helpers
        post_docs: ->
            Docs.find {
                model:'post'
            }, sort:_timestamp:-1    
    

if Meteor.isServer 
    Meteor.methods 
        mark_doc_read: (doc_id)->
            Docs.update doc_id, 
                $addToSet:read_by_user_ids:Meteor.userId()
            console.log 'marked doc read'
            

if Meteor.isClient
    # Template.favorite_icon_toggle.helpers
    #     icon_class: ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             'red'
    #         else
    #             'outline'
    # Template.favorite_icon_toggle.events
    #     'click .toggle_fav': ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             Docs.update @_id, 
    #                 $pull:favorite_ids:Meteor.userId()
    #         else
    #             $('body').toast(
    #                 showIcon: 'heart'
    #                 message: "marked favorite"
    #                 showProgress: 'bottom'
    #                 class: 'success'
    #                 # displayTime: 'auto',
    #                 position: "bottom right"
    #             )

    #             Docs.update @_id, 
    #                 $addToSet:favorite_ids:Meteor.userId()
    
    
    Template.post_edit.events
        'click .delete_post': ->
            Swal.fire({
                title: "delete post?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'post removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    gstate_set "/posts"
            )

            
if Meteor.isServer
    Meteor.publish 'user_posts', (username)->
        user = Meteor.users.findOne username:username
        
        Docs.find 
            model:'post'
            _author_id:user._id
    
    Meteor.publish 'post_count', (
        picked_tags
        picked_sections
        post_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_tags
        self = @
        match = {model:'post'}
        if picked_tags.length > 0
            match.ingredients = $all: picked_tags
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if post_query and post_query.length > 1
            console.log 'searching post_query', post_query
            match.title = {$regex:"#{post_query}", $options: 'i'}
        Counts.publish this, 'post_counter', Docs.find(match)
        return undefined


if Meteor.isClient
    Template.post_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.post_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            gstate_set("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.post_card.helpers
        post_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
            


if Meteor.isClient
    @picked_tags = new ReactiveArray []
    
    Template.task_view.events
        'click .record_work': ->
            new_id = Docs.insert 
                model:'work'
                task_id: Meteor.user()._model
            gstate_set "/work/#{new_id}/edit"    
    
                
           
    Template.task_view.helpers
        possible_locations: ->
            task = Docs.findOne Meteor.user()._model
            Docs.find
                model:'location'
                _id:$in:task.location_ids
                
        task_work: ->
            Docs.find 
                model:'work'
                task_id:Meteor.user()._model
                
    Template.task_edit.helpers
        task_locations: ->
            Docs.find
                model:'location'
                
        location_class: ->
            task = Docs.findOne Meteor.user()._model
            if task.location_ids and @_id in task.location_ids then 'blue' else 'basic'
            
                
    Template.task_edit.events
        'click .mark_complete': ->
            Docs.update Meteor.user()._model, 
                $set:
                    complete:true
                    complete_timestamp: Date.now()
                    
        'click .select_location': ->
            task = Docs.findOne Meteor.user()._model
            if task.location_ids and @_id in task.location_ids
                Docs.update Meteor.user()._model, 
                    $pull:location_ids:@_id
            else
                Docs.update Meteor.user()._model, 
                    $addToSet:location_ids:@_id
            
if Meteor.isServer
    Meteor.publish 'task_work', (task_id)->
        Docs.find   
            model:'work'
            task_id:task_id
    # Meteor.publish 'work_task', (work_id)->
    #     work = Docs.findOne work_id
    #     Docs.find   
    #         model:'task'
    #         _id: work.task_id
            
            
    Meteor.publish 'user_sent_task', (username)->
        Docs.find   
            model:'task'
            _author_username:username
    Meteor.publish 'product_task', (product_id)->
        Docs.find   
            model:'task'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Template.task_edit.events
        'click .send_task': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    task = Docs.findOne Meteor.user()._model
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update task._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'task sent',
                        ''
                        'success'
                    gstate_set "/task/#{@_id}/"
                    )
            )

        'click .delete_task':->
            if confirm 'delete?'
                Docs.remove @_id
                gstate_set "/tasks"
            
    Template.task_edit.helpers
        all_shop: ->
            Docs.find
                model:'task'


        current_subgroups: ->
            Docs.find 
                model:'group'
                parent_group_id:Meteor.user().current_group_id
                
                
                
if Meteor.isClient
    @picked_authors = new ReactiveArray []
    @picked_locations = new ReactiveArray []
    @picked_tasks = new ReactiveArray []
    @picked_timestamp_tags = new ReactiveArray []
    

    Template.work.helpers
        task_results: ->
            Results.find {
                model:'task'
            }, sort:_timestamp:-1
        timestamp_tag_results: ->
            Results.find {
                model:'timestamp_tag'
            }, sort:_timestamp:-1
        author_results: ->
            Results.find {
                model:'author'
            }, sort:_timestamp:-1
        location_results: ->
            Results.find {
                model:'location'
            }, sort:_timestamp:-1
        work_list: ->
            Docs.find {
                model:'work'
            }, sort:_timestamp:-1
        eric_total: ->
            Docs.find({
                model:'work'
                _author_username: 'dev'
            }).count()
        ryan_total: ->
            Docs.find({
                model:'work'
                _author_username: 'ryan'
            }).count()
        picked_tasks: -> picked_tasks.array()
        picked_locations: -> picked_locations.array()
        picked_authors: -> picked_authors.array()
        picked_timestamp_tags: -> picked_timestamp_tags.array()
    Template.work.events
        'click .pick_timestamp_tag': -> picked_timestamp_tags.push @title
        'click .unpick_timestamp_tag': -> picked_timestamp_tags.remove @valueOf()
        'click .pick_task': -> picked_tasks.push @title
        'click .unpick_task': -> picked_tasks.remove @valueOf()
        'click .pick_location': -> picked_locations.push @title
        'click .unpick_location': -> picked_locations.remove @valueOf()
        'click .pick_author': -> picked_authors.push @title
        'click .unpick_author': -> picked_authors.remove @valueOf()
        'click .add_work': ->
            new_id = Docs.insert 
                model:'work'
            gstate_set "/work/#{new_id}/edit"    
      
        'click .add_task': ->
            new_id = Docs.insert 
                model:'task'
            gstate_set "/task/#{new_id}/edit"    
    
                
    Template.work_edit.events
        'click .pick_staff': ->
            Docs.update Meteor.user()._model, 
                $set:
                    staff_id:@_id
                    staff_name: "#{@first_name} #{@last_name}"
                    staff_image_id: @image_id
        
        'click .pick_location': ->
            Docs.update Meteor.user()._model, 
                $set:
                    location_id:@_id
                    location_title: @title
                    location_image_id: @image_id
        
        
        
    Template.work_edit.helpers
        task_locations: ->
            work_doc = Docs.findOne(model:'task')
            Docs.find 
                model:'location'
                _id: $in: work_doc.location_ids
                
        porter_staff: ->
            Docs.find 
                model:'staff'
                
        # staff_picker_class: ->
        #     work = Docs.findOne Meteor.user()._model
        #     if work.staff_id is @_id then 'blue big' else 'basic large'
            
        location_picker_class: ->
            work = Docs.findOne Meteor.user()._model
            if work.location_id is @_id then 'blue massive' else 'basic big'
            
        
if Meteor.isServer
    Meteor.publish 'user_received_work', (username)->
        Docs.find   
            model:'work'
            recipient_username:username
            
            
    Meteor.publish 'user_sent_work', (username)->
        Docs.find   
            model:'work'
            _author_username:username
    Meteor.publish 'product_work', (product_id)->
        Docs.find   
            model:'work'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Template.work_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Meteor.user()._model
        @autorun => Meteor.subscribe 'work_task', Meteor.user()._model
        # @autorun => Meteor.subscribe 'doc', Meteor.user()._model
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.work_edit.events
        # 'click .send_work': ->
        #     Swal.fire({
        #         title: 'confirm send card'
        #         text: "#{@amount} credits"
        #         icon: 'question'
        #         showCancelButton: true,
        #         confirmButtonText: 'confirm'
        #         cancelButtonText: 'cancel'
        #     }).then((result) =>
        #         if result.value
        #             work = Docs.findOne Meteor.user()._model
        #             Meteor.users.update Meteor.userId(),
        #                 $inc:credit:-@amount
        #             Docs.update work._id,
        #                 $set:
        #                     sent:true
        #                     sent_timestamp:Date.now()
        #             Swal.fire(
        #                 'work sent',
        #                 ''
        #                 'success'
        #             gstate_set "/work/#{@_id}/"
        #             )
        #     )

        'click .delete_work':(e,t)->
            # Swal.fire({
            #     title: "delete work entry?"
            #     text: "for #{@task_title}"
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            # }).then((result) =>
            #     if result.value
            $(e.currentTarget).closest('.grid').transition('fly right', 750)
            Meteor.setTimeout =>
                Docs.remove @_id
                gstate_set "/work"
            , 750    
                
            $('body').toast(
                showIcon: 'remove'
                message: "#{@task_title} work entry"
                showProgress: 'bottom'
                class: 'error'
                # displayTime: 'auto',
                position: "bottom right"
            )
        'click .submit_work':(e,t)->
            $(e.currentTarget).closest('.grid').transition('fly left', 750)
            Meteor.setTimeout =>
                gstate_set "/work"
            , 750
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@task_title} work entry"
                showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )
            
    Template.work_edit.helpers
        all_shop: ->
            Docs.find
                model:'work'

if Meteor.isServer
    # Meteor.publish 'user_received_task', (username)->
    #     Docs.find   
    #         model:'task'
    #         recipient_username:username
            
    Meteor.publish 'work_task', (work_id)->
        work = Docs.findOne work_id
        Docs.find   
            model:'task'
            _id: work.task_id                
            
            
            
if Meteor.isClient
    Template.role_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Meteor.user()._model, ->
    Template.role_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Meteor.user()._model, ->
    Template.role_item.events
        'click .view_role': ->
            gstate_set "/role/#{@_id}"

    Template.role_view.events
        'click .add_role_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    role_ids:[@_id]
            gstate_set "/recipe/#{new_id}/edit"

    # Template.favorite_icon_toggle.helpers
    #     icon_class: ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             'red'
    #         else
    #             'outline'
    # Template.favorite_icon_toggle.events
    #     'click .toggle_fav': ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             Docs.update @_id, 
    #                 $pull:favorite_ids:Meteor.userId()
    #         else
    #             $('body').toast(
    #                 showIcon: 'heart'
    #                 message: "marked favorite"
    #                 showProgress: 'bottom'
    #                 class: 'success'
    #                 # displayTime: 'auto',
    #                 position: "bottom right"
    #             )

    #             Docs.update @_id, 
    #                 $addToSet:favorite_ids:Meteor.userId()
    
    
    Template.role_edit.events
        'click .delete_role': ->
            Swal.fire({
                title: "delete role?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'role removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    gstate_set "/roles"
            )

            
if Meteor.isServer
    Meteor.publish 'user_roles', (username)->
        user = Meteor.users.findOne username:username
        
        Docs.find 
            model:'role'
            _author_id:user._id
    
    Meteor.publish 'role_count', (
        picked_tags
        picked_sections
        role_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_tags
        self = @
        match = {model:'role'}
        if picked_tags.length > 0
            match.ingredients = $all: picked_tags
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if role_query and role_query.length > 1
            console.log 'searching role_query', role_query
            match.title = {$regex:"#{role_query}", $options: 'i'}
        Counts.publish this, 'role_counter', Docs.find(match)
        return undefined


if Meteor.isClient
    Template.role_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.role_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            gstate_set("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.role_card.helpers
        role_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
            
            
if Meteor.isServer
    Meteor.publish 'resource_results', (
        picked_tags
        lat=50
        long=100
        limit=42
        doc_sort_key
        doc_sort_direction
        )->
        # console.log picked_tags
        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'resource'}
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            # sort = 'price_per_serving'
        else
            # match.tags = $nin: ['wikipedia']
            sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        # if Meteor.userId()
        #     match._author_id = $ne:Meteor.userId()

        # match.tags = $all: picked_tags
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array
        # match.location = 
        #    { $near : [ -73.9667, 40.78 ], $maxDistance: 110 }
            
        #   { $near :
        #       {
        #         $geometry: { type: "Point",  coordinates: [ long, lat ] },
        #         $minDistance: 1000,
        #         $maxDistance: 5000
        #       }
        #   }
        

        # console.log 'resource match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit

    Meteor.publish 'resource_facets', (
        picked_tags=[]
        lat
        long
        picked_timestamp_tags
        query
        doc_limit
        doc_sort_key
        doc_sort_direction
        )->
        # console.log 'lat', lat
        # console.log 'long', long
        # console.log 'selected tags', picked_tags

        self = @
        match = {}
        match.model = 'resource'
        if Meteor.userId()
            match._author_id = $ne:Meteor.userId()
        if picked_tags.length > 0 then match.tags = $all: picked_tags
            # match.$regex:"#{current_query}", $options: 'i'}
        # if lat
        #     match.location = 
        #        { $near :
        #           {
        #             $geometry: { type: "Point",  coordinates: [ lat, long ] },
        #             $minDistance: 1000,
        #             $maxDistance: 5000
        #           }
        #        }
        agg_doc_count = Docs.find(match).count()
        # console.log match
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $match: count: $lt: agg_doc_count }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        tag_cloud.forEach (tag, i) =>
            # console.log 'tag result ', tag
            self.added 'results', Random.id(),
                title: tag.title
                count: tag.count
                model:'tag'
                # category:key
                # index: i
        self.ready()




if Meteor.isClient
    Template.resource_big_card.onCreated ->
        @autorun => @subscribe 'resource_orders',@data._id, ->
    
    Template.resource_view.helpers
        future_order_docs: ->
            Docs.find 
                model:'order'
                resource_id:Meteor.user()._model
                
                
                
    Template.resource_card.events
        'click .flat_pick_tag': -> picked_tags.push @valueOf()
        
    Template.resource_view.events
        'click .new_order': (e,t)->
            resource = Docs.findOne Meteor.user()._model
            new_order_id = Docs.insert
                model:'order'
                resource_id: @_id
                resource_id:resource._id
                resource_title:resource.title
                resource_image_id:resource.image_id
                resource_image_link:resource.image_link
                resource_daily_rate:resource.daily_rate
            gstate_set "/order/#{new_order_id}/edit"
            
        'click .goto_tag': ->
            picked_tags.push @valueOf()
            gstate_set '/'
            
        'click .cancel_order': ->
            console.log 'hi'
            Swal.fire({
                title: "cancel?"
                # text: "this will charge you $5"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                )

    Template.quickbuy.helpers
        button_class: ->
            tech_form = moment().add(@day_diff, 'days').format('YYYY-MM-DD')
            found_order = 
                Docs.findOne
                    model:'order'
                    order_date:tech_form
            if found_order
                'disabled'
            else 
                'large'
                    
                    
                    
        human_form: ->
            moment().add(@day_diff, 'days').format('ddd, MMM Do')
        from_form: ->
            moment().add(@day_diff, 'days').fromNow()
            
    Template.quickbuy.events
        'click .buy': ->
            console.log @
            context = Template.parentData()
            human_form = moment().add(@day_diff, 'days').format('dddd, MMM Do')
            tech_form = moment().add(@day_diff, 'days').format('YYYY-MM-DD')
            Swal.fire({
                title: "quickbuy #{human_form}?"
                # text: "this will charge you $5"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result)=>
                if result.value
                    resource = Docs.findOne context._id
                    new_order_id = Docs.insert
                        model:'order'
                        resource_id: resource._id
                        order_date: tech_form
                        _seller_username:resource._author_username
                        resource_id:resource._id
                        resource_title:resource.title
                        resource_image_id:resource.image_id
                        resource_image_link:resource.image_link
                        resource_daily_rate:resource.daily_rate
                    Swal.fire(
                        "reserved for #{human_form}",
                        ''
                        'success'
                    )
            )

            

if Meteor.isServer
    Meteor.publish 'user_resources', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'resource'
            _author_id: user._id
            
    Meteor.publish 'resource_orders', (doc_id)->
        resource = Docs.findOne doc_id
        Docs.find
            model:'order'
            resource_id:resource._id
            
            
            
            
if Meteor.isClient
    Template.resource_stats.events
        'click .refresh_resource_stats': ->
            Meteor.call 'refresh_resource_stats', @_id




    Template.order_segment.events
        'click .calc_res_numbers': ->
            start_date = moment(@start_timestamp).date()
            start_month = moment(@start_timestamp).month()
            start_minute = moment(@start_timestamp).minute()
            start_hour = moment(@start_timestamp).hour()
            Docs.update @_id,
                $set:
                    start_date:start_date
                    start_month:start_month
                    start_hour:start_hour
                    start_minute:start_minute



if Meteor.isServer
    Meteor.publish 'resource_orders_by_id', (resource_id)->
        Docs.find
            model:'order'
            resource_id: resource_id


    Meteor.publish 'order_by_day', (product_id, month_day)->
        # console.log month_day
        # console.log product_id
        orders = Docs.find(model:'order',product_id:product_id).fetch()
        # for order in orders
            # console.log 'id', order._id
            # console.log order.paid_amount
        Docs.find
            model:'order'
            product_id:product_id

    Meteor.publish 'order_slot', (moment_ob)->
        resources_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            resources.return.push date_string
        resources_return

        # data.long_form
        # Docs.find
        #     model:'order_slot'


    Meteor.methods
        refresh_resource_stats: (resource_id)->
            resource = Docs.findOne resource_id
            # console.log resource
            orders = Docs.find({model:'order', resource_id:resource_id})
            order_count = orders.count()
            total_earnings = 0
            total_resource_hours = 0
            average_resource_duration = 0

            # shortest_order =
            # longest_order =

            for res in orders.fetch()
                total_earnings += parseFloat(res.cost)
                total_resource_hours += parseFloat(res.hour_duration)

            average_resource_cost = total_earnings/order_count
            average_resource_duration = total_resource_hours/order_count

            Docs.update resource_id,
                $set:
                    order_count: order_count
                    total_earnings: total_earnings.toFixed(0)
                    total_resource_hours: total_resource_hours.toFixed(0)
                    average_resource_cost: average_resource_cost.toFixed(0)
                    average_resource_duration: average_resource_duration.toFixed(0)
                    
if Meteor.isClient
    Template.project_edit.helpers
        child_tasks: ->
            Docs.find
                model:'task'
                
                
    Template.project_view.helpers
        child_tasks: ->
            Docs.find
                model:'task'
                project_id: Meteor.user()._model
                
    # Template.favorite_icon_toggle.helpers
    #     icon_class: ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             'red'
    #         else
    #             'outline'
    # Template.favorite_icon_toggle.events
    #     'click .toggle_fav': ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             Docs.update @_id, 
    #                 $pull:favorite_ids:Meteor.userId()
    #         else
    #             $('body').toast(
    #                 showIcon: 'heart'
    #                 message: "marked favorite"
    #                 showProgress: 'bottom'
    #                 class: 'success'
    #                 # displayTime: 'auto',
    #                 position: "bottom right"
    #             )

    #             Docs.update @_id, 
    #                 $addToSet:favorite_ids:Meteor.userId()
    
    
    Template.project_edit.events
        'click .delete_project': ->
            Swal.fire({
                title: "delete project?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'project removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    gstate_set "/projects"
            )

            
if Meteor.isServer
    Meteor.publish 'user_projects', (username)->
        user = Meteor.users.findOne username:username
        
        Docs.find 
            model:'project'
            _author_id:user._id
    
    Meteor.publish 'project_count', (
        picked_tags
        picked_sections
        project_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_tags
        self = @
        match = {model:'project'}
        if picked_tags.length > 0
            match.ingredients = $all: picked_tags
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if project_query and project_query.length > 1
            console.log 'searching project_query', project_query
            match.title = {$regex:"#{project_query}", $options: 'i'}
        Counts.publish this, 'project_counter', Docs.find(match)
        return undefined


if Meteor.isClient
    Template.project_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.project_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            gstate_set("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.project_card.helpers
        project_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
            
if Meteor.isClient
    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'product_source', Meteor.user()._model, ->
        @autorun => Meteor.subscribe 'doc', Meteor.user()._model, ->
        @autorun => Meteor.subscribe 'ingredients_from_product_id', Meteor.user()._model, ->
        @autorun => Meteor.subscribe 'orders_from_product_id', Meteor.user()._model, ->
        @autorun => Meteor.subscribe 'subs_from_product_id', Meteor.user()._model, ->
    Template.product_view.events
        # 'click .generate_qrcode': (e,t)->
        #     qrcode = new QRCode(document.getElementById("qrcode"), {
        #         text: @title,
        #         width: 250,
        #         height: 250,
        #         colorDark : "#000000",
        #         colorLight : "#ffffff",
        #         correctLevel : QRCode.CorrectLevel.H
        #     })

        'click .calc_stats': (e,t)->
            Meteor.call 'calc_product_data', Meteor.user()._model, ->
        'click .goto_source': (e,t)->
            $(e.currentTarget).closest('.pushable').transition('fade right', 240)
            product = Docs.findOne Meteor.user()._model
            Meteor.setTimeout =>
                gstate_set "/source/#{product.source_id}"
            , 240
        
        'click .goto_ingredient': (e,t)->
            # $(e.currentTarget).closest('.pushable').transition('fade right', 240)
            product = Docs.findOne Meteor.user()._model
            console.log @
            found_ingredient = 
                Docs.findOne 
                    model:'ingredient'
                    title:@valueOf()
            if found_ingredient
                gstate_set "/ingredient/#{found_ingredient._id}"
            else 
                new_id = 
                    Docs.insert 
                        model:'ingredient'
                        title:@valueOf()
                gstate_set "/ingredient/#{new_id}/edit"
                
            # found_ingredient = 
            #     Docs.findOne 
            #         model:'ingredient'
            #         title:@valueOf()
            # Meteor.setTimeout =>
            #     gstate_set "/source/#{product.source_id}"
            # , 240
        
        'click .add_to_cart': ->
            Meteor.call 'add_to_cart', @_id, =>
                $('body').toast(
                    showIcon: 'cart plus'
                    message: "#{@title} added"
                    # showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )


    Template.product_subscriptions.events
        'click .subscribe': ->
            if confirm 'subscribe?'
                Docs.update Meteor.user()._model,
                    $addToSet: 
                        subscribed_ids: Meteor.userId()
                new_sub_id = 
                    Docs.insert 
                        model:'product_subscription'
                        product_id:Meteor.user()._model
                gstate_set "/subscription/#{new_sub_id}/edit"
                    
        'click .unsubscribe': ->
            if confirm 'unsubscribe?'
                Docs.update Meteor.user()._model,
                    $pull: 
                        subscribed_ids: Meteor.userId()
                                    
    
        'click .mark_ready': ->
            if confirm 'mark product ready?'
                Docs.update Meteor.user()._model,
                    $set:
                        ready:true
                        ready_timestamp:Date.now()

        'click .unmark_ready': ->
            if confirm 'unmark product ready?'
                Docs.update Meteor.user()._model,
                    $set:
                        ready:false
                        ready_timestamp:null

    Template.product_inventory.onCreated ->
        @autorun => Meteor.subscribe 'inventory_from_product_id', Meteor.user()._model
            
    Template.product_inventory.events
        'click .add_inventory': ->
            count = Docs.find(model:'inventory_item').count()
            new_id = Docs.insert 
                model:'inventory_item'
                product_id:@_id
                id:count++
            Session.set('editing_inventory_id', @_id)
        'click .edit_inventory_item': -> 
            Session.set('editing_inventory_id', @_id)
        'click .save_inventory_item': -> 
            Session.set('editing_inventory_id', null)
        
    Template.product_inventory.helpers
        editing_this: -> Session.equals('editing_inventory_id', @_id)
        inventory_items: ->
            Docs.find({
                model:'inventory_item'
                product_id:@_id
            }, sort:'_timestamp':-1)


    Template.product_subscriptions.helpers
        product_subs: ->
            Docs.find
                model:'product_subscription'
                product_id:Meteor.user()._model

    Template.product_view.helpers
        product_order_total: ->
            orders = 
                Docs.find({
                    model:'order'
                    product_id:@_id
                }).fetch()
            res = 0
            for order in orders
                res += order.order_price
            res
                

        can_cancel: ->
            product = Docs.findOne Meteor.user()._model
            if Meteor.userId() is product._author_id
                if product.ready
                    false
                else
                    true
            else if Meteor.userId() is @_author_id
                if product.ready
                    false
                else
                    true


        can_order: ->
            if Meteor.user().roles and 'admin' in Meteor.user().roles
                true
            else
                @cook_user_id isnt Meteor.userId()

        product_order_class: ->
            if @status is 'ready'
                'green'
            else if @status is 'pending'
                'yellow'
                
                
    Template.order_button.onCreated ->

    Template.order_button.helpers

    Template.order_button.events
        # 'click .join_waitlist': ->
        #     Swal.fire({
        #         title: 'confirm wait list join',
        #         text: 'this will charge your account if orders cancel'
        #         icon: 'question'
        #         showCancelButton: true,
        #         confirmButtonText: 'confirm'
        #         cancelButtonText: 'cancel'
        #     }).then((result) =>
        #         if result.value
        #             Docs.insert
        #                 model:'order'
        #                 waitlist:true
        #                 product_id: Meteor.user()._model
        #             Swal.fire(
        #                 'wait list joined',
        #                 "you'll be alerted if accepted"
        #                 'success'
        #             )
        #     )

        'click .order_product': ->
            # if Meteor.user().credit >= @price_per_serving
            # Docs.insert
            #     model:'order'
            #     status:'pending'
            #     complete:false
            #     product_id: Meteor.user()._model
            #     if @serving_unit
            #         serving_text = @serving_unit
            #     else
            #         serving_text = 'serving'
            # Swal.fire({
            #     # title: "confirm buy #{serving_text}"
            #     title: "confirm order?"
            #     text: "this will charge you #{@price_usd}"
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            # }).then((result) =>
            #     if result.value
            Meteor.call 'order_product', @_id, (err, res)->
                if err
                    Swal.fire(
                        'err'
                        'error'
                    )
                    console.log err
                else
                    gstate_set "/order/#{res}/edit"
                    # Swal.fire(
                    #     'order and payment processed'
                    #     ''
                    #     'success'
                    # )
        # )

if Meteor.isServer
    Meteor.publish 'ingredients_from_product_id', (product_id)->
        product = Docs.findOne product_id
        Docs.find 
            model:'ingredient'  
            _id:$in:product.ingredient_ids
    Meteor.publish 'product_source', (product_id)->
        product = Docs.findOne product_id
        # console.log 'need source from this product', product
        Docs.find
            model:'source'
            _id:product.source_id
    Meteor.publish 'orders_from_product_id', (product_id)->
        # product = Docs.findOne product_id
        Docs.find
            model:'order'
            product_id:product_id
            
    Meteor.publish 'subs_from_product_id', (product_id)->
        # product = Docs.findOne product_id
        Docs.find
            model:'product_subscription'
            product_id:product_id
    Meteor.publish 'inventory_from_product_id', (product_id)->
        # product = Docs.findOne product_id
        Docs.find
            model:'inventory_item'
            product_id:product_id





if Meteor.isClient
    Template.product_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Meteor.user()._model
        # @autorun => Meteor.subscribe 'doc', Meteor.user()._model
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.product_edit.onRendered ->
        Meteor.setTimeout ->
            today = new Date()
            $('#availability')
                .calendar({
                    inline:true
                    # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
                    # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
                })
        , 2000

    Template.product_edit.helpers
        # all_shop: ->
        #     Docs.find
        #         model:'product'
        can_delete: ->
            product = Docs.findOne Meteor.user()._model
            if product.reservation_ids
                if product.reservation_ids.length > 1
                    false
                else
                    true
            else
                true

    Template.product_edit.onCreated ->
        @autorun => @subscribe 'source_search_results', Session.get('source_search'), ->
    Template.product_edit.helpers
        search_results: ->
            Docs.find 
                model:'source'
                

    Template.product_edit.events
        'click .remove_source': (e,t)->
            if confirm 'remove source?'
                Docs.update Meteor.user()._model,
                    $set:source_id:null
        'click .pick_source': (e,t)->
            Docs.update Meteor.user()._model,
                $set:source_id:@_id
        'keyup .source_search': (e,t)->
            # if e.which is '13'
            val = t.$('.source_search').val()
            console.log val
            Session.set('source_search', val)
                
            
        'click .save_product': ->
            product_id = Meteor.user()._model
            Meteor.call 'calc_product_data', product_id, ->
            gstate_set "/product/#{product_id}"


        'click .save_availability': ->
            doc_id = Meteor.user()._model
            availability = $('.ui.calendar').calendar('get date')[0]
            console.log availability
            formatted = moment(availability).format("YYYY-MM-DD[T]HH:mm")
            console.log formatted
            # console.log moment(@end_datetime).diff(moment(@start_datetime),'minutes',true)
            # console.log moment(@end_datetime).diff(moment(@start_datetime),'hours',true)
            Docs.update doc_id,
                $set:datetime_available:formatted





        # 'click .select_product': ->
        #     Docs.update Meteor.user()._model,
        #         $set:
        #             product_id: @_id
        #
        #
        # 'click .clear_product': ->
        #     if confirm 'clear product?'
        #         Docs.update Meteor.user()._model,
        #             $set:
        #                 product_id: null



        'click .delete_product': ->
            if confirm 'refund orders and cancel product?'
                Docs.remove Meteor.user()._model
                gstate_set "/"

if Meteor.isServer 
    Meteor.publish 'source_search_results', (source_title_queary)->
        Docs.find 
            model:'source'
            title: {$regex:"#{source_title_queary}",$options:'i'}


if Meteor.isClient
    Template.ingredient_picker.onCreated ->
        @autorun => @subscribe 'ingredient_search_results', Session.get('ingredient_search'), ->
        @autorun => @subscribe 'model_docs', 'ingredient', ->
    Template.ingredient_picker.helpers
        ingredient_results: ->
            Docs.find 
                model:'ingredient'
                title: {$regex:"#{Session.get('ingredient_search')}",$options:'i'}
                
        product_ingredients: ->
            product = Docs.findOne Meteor.user()._model
            Docs.find 
                # model:'ingredient'
                _id:$in:product.ingredient_ids
        ingredient_search_value: ->
            Session.get('ingredient_search')
        
    Template.ingredient_picker.events
        'click .clear_search': (e,t)->
            Session.set('ingredient_search', null)
            t.$('.ingredient_search').val('')

            
        'click .remove_ingredient': (e,t)->
            if confirm "remove #{@title} ingredient?"
                Docs.update Meteor.user()._model,
                    $pull:
                        ingredient_ids:@_id
                        ingredient_titles:@title
        'click .pick_ingredient': (e,t)->
            Docs.update Meteor.user()._model,
                $addToSet:
                    ingredient_ids:@_id
                    ingredient_titles:@title
            Session.set('ingredient_search',null)
            t.$('.ingredient_search').val('')
                    
        'keyup .ingredient_search': (e,t)->
            # if e.which is '13'
            val = t.$('.ingredient_search').val()
            console.log val
            Session.set('ingredient_search', val)

        'click .create_ingredient': ->
            new_id = 
                Docs.insert 
                    model:'ingredient'
                    title:Session.get('ingredient_search')
            gstate_set "/ingredient/#{new_id}/edit"


if Meteor.isServer 
    Meteor.publish 'ingredient_search_results', (ingredient_title_query)->
        Docs.find 
            model:'ingredient'
            title: {$regex:"#{ingredient_title_query}",$options:'i'}
    Meteor.publish 'product_orders', (product_id)->
        product = Docs.findOne product_id
        # console.log 'finding mishi for', product
        if product.slug 
            Docs.find 
                model:'order'
                _product:product.slug
        # else console.log 'no product slug', product
        
        
if Meteor.isClient
    Template.product_card.events
        'click .add_to_cart': (e,t)->
            $(e.currentTarget).closest('.card').transition('bounce',500)
            Meteor.call 'add_to_cart', @_id, =>
                $('body').toast(
                    showIcon: 'cart plus'
                    message: "#{@title} added"
                    # showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom center"
                )


    # Template.set_sort_key.events
    #     'click .set_sort': ->
    #         console.log @
    #         Session.set('sort_key', @key)
    #         Session.set('product_sort_label', @label)
    #         Session.set('product_sort_icon', @icon)



if Meteor.isServer
    Meteor.methods
        add_to_cart: (product_id)->
            # existing_cart_item_with_product = 
            #     Docs.findOne 
            #         model:'cart_item'
            #         product_id:product_id
            # if existing_cart_item_with_product
            #     Docs.update existing_cart_item_with_product._id,
            #         $inc:amount:1
            # else 
            product = Docs.findOne product_id
            current_order = 
                Docs.findOne 
                    model:'order'
                    _author_id:Meteor.userId()
                    status:'cart'
            if current_order
                order_id = current_order._id
            else
                order_id = 
                    Docs.insert 
                        model:'order'
                        status:'cart'
            new_cart_doc_id = 
                Docs.insert 
                    model:'cart_item'
                    status:'cart'
                    product_id: product_id
                    product_price_usd:product.price_usd
                    product_price_points:product.price_points
                    product_title:product.title
                    product_image_id:product.image_id
                    order_id:order_id
            console.log new_cart_doc_id
            
                    
    Meteor.publish 'product_results', (
        picked_ingredients=[]
        picked_sections=[]
        product_query=''
        view_vegan
        view_gf
        products_section=null
        limit=20
        sort_key='_timestamp'
        sort_direction=1
        )->
        # console.log picked_ingredients
        self = @
        match = {model:'product', app:'nf'}
        if products_section 
            match.products_section = products_section
        if picked_ingredients.length > 0
            match.ingredients = $all: picked_ingredients
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if product_query and product_query.length > 1
            console.log 'searching product_query', product_query
            match.title = {$regex:"#{product_query}", $options: 'i'}
            # match.tags_string = {$regex:"#{query}", $options: 'i'}

        # match.tags = $all: picked_ingredients
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        # console.log 'product match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit
            fields:
                title:1
                image_id:1
                ingredients:1
                model:1
                price_usd:1
                vegan:1
                local:1
                gluten_free:1
            
    Meteor.publish 'product_search_count', (
        picked_ingredients=[]
        picked_sections=[]
        product_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_ingredients
        self = @
        match = {model:'product', app:'nf'}
        if picked_ingredients.length > 0
            match.ingredients = $all: picked_ingredients
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if product_query and product_query.length > 1
            console.log 'searching product_query', product_query
            match.title = {$regex:"#{product_query}", $options: 'i'}
        Counts.publish this, 'product_counter', Docs.find(match)
        return undefined

    Meteor.publish 'product_facets', (
        picked_ingredients=[]
        picked_sections=[]
        product_query=null
        view_vegan=false
        view_gf=false
        products_section=null
        doc_limit=20
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        # console.log 'picked ingredients', picked_ingredients

        self = @
        match = {app:'nf'}
        match.model = 'product'
        if products_section 
            match.products_section = products_section
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        # if view_local
        #     match.local = true
        if picked_ingredients.length > 0 then match.ingredients = $all: picked_ingredients
        if picked_sections.length > 0 then match.menu_section = $all: picked_sections
            # match.$regex:"#{product_query}", $options: 'i'}
        if product_query and product_query.length > 1
            console.log 'searching product_query', product_query
            match.title = {$regex:"#{product_query}", $options: 'i'}
            # match.tags_string = {$regex:"#{query}", $options: 'i'}
        #
        #     Terms.find {
        #         title: {$regex:"#{query}", $options: 'i'}
        #     },
        #         sort:
        #             count: -1
        #         limit: 42
            # tag_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: "tags": 1 }
            #     { $unwind: "$tags" }
            #     { $group: _id: "$tags", count: $sum: 1 }
            #     { $match: _id: $nin: picked_ingredients }
            #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: 42 }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]

        # else
        # unless query and query.length > 2
        # if picked_ingredients.length > 0 then match.tags = $all: picked_ingredients
        # # match.tags = $all: picked_ingredients
        # # console.log 'match for tags', match
        section_cloud = Docs.aggregate [
            { $match: match }
            { $project: "menu_section": 1 }
            { $group: _id: "$menu_section", count: $sum: 1 }
            { $match: _id: $nin: picked_sections }
            # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }
        
        section_cloud.forEach (section, i) =>
            # console.log 'queried section ', section
            # console.log 'key', key
            self.added 'results', Random.id(),
                title: section.name
                count: section.count
                model:'section'
                # category:key
                # index: i


        ingredient_cloud = Docs.aggregate [
            { $match: match }
            { $project: "ingredients": 1 }
            { $unwind: "$ingredients" }
            { $match: _id: $nin: picked_ingredients }
            { $group: _id: "$ingredients", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        ingredient_cloud.forEach (ingredient, i) =>
            # console.log 'ingredient result ', ingredient
            self.added 'results', Random.id(),
                title: ingredient.title
                count: ingredient.count
                model:'ingredient'
                # category:key
                # index: i


        self.ready()





if Meteor.isClient
    Template.product_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.product_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            gstate_set("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.product_card.helpers
        product_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
        
        
        
