if Meteor.isClient
    Router.route '/rentals', (->
        @layout 'layout'
        @render 'rentals'
        ), name:'rentals'


    Template.rentals.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'rental_sort_key', 'datetime_available'
        Session.setDefault 'rental_sort_label', 'available'
        Session.setDefault 'rental_limit', 42
        Session.setDefault 'view_open', true

    Template.rentals.onCreated ->
        @autorun => @subscribe 'rental_facets',
            picked_tags.array()
            Session.get('current_lat')
            Session.get('current_long')
            Session.get('rental_limit')
            Session.get('rental_sort_key')
            Session.get('rental_sort_direction')

        @autorun => @subscribe 'rental_results',
            picked_tags.array()
            Session.get('lat')
            Session.get('long')
            Session.get('rental_limit')
            Session.get('rental_sort_key')
            Session.get('rental_sort_direction')
    
    Template.rentals.events
        'click .add_rental': ->
            new_id = 
                Docs.insert 
                    model:'rental'
            Router.go "/rental/#{new_id}/edit"
        'click .fly_right': (e,t)->
            console.log 'hi'
            $(e.currentTarget).closest('.grid').transition('fly right', 500)
    
        'click .request_rental': ->
            title = prompt "different title than #{Session.get('query')}"
            new_id = 
                Docs.insert 
                    model:'request'
                    title:Session.get('query')


        'click .tag_result': -> picked_tags.push @title
        'click .unselect_tag': ->
            picked_tags.remove @valueOf()

        'click .clear_picked_tags': ->
            Session.set('query',null)
            picked_tags.clear()

        'keyup .query': _.throttle((e,t)->
            query = $('.query').val()
            Session.set('query', query)
            # console.log Session.get('query')
            if e.which is 13
                search = $('.query').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('.query').val('')
                    Session.set('query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_rental_count': ->
            Meteor.call 'calc_rental_count', ->

        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = picked_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             picked_tags.pop()
        #             Meteor.call 'search_reddit', picked_tags.array(), ->
        # , 1000)

    Template.rentals.helpers
        query_requests: ->
            Docs.find
                model:'request'
                title:Session.get('query')
            
        counter: -> Counts.get('rental_counter')
        tags: -> Results.find({model:'tag'})
        location_tags: -> Results.find({model:'location_tag',title:$nin:picked_location_tags.array()})
        authors: -> Results.find({model:'author'})

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        picked_tags: -> picked_tags.array()
        picked_tags_plural: -> picked_tags.array().length > 1
        searching: -> Session.get('searching')

        one_rental: ->
            Docs.find(model:'rental').count() is 1
        rental_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model: 'rental'
                # downvoter_ids:$nin:[Meteor.userId()]
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:Session.get('limit')

        subs_ready: ->
            Template.instance().subscriptionsReady()






if Meteor.isServer
    Meteor.publish 'rental_results', (
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
        match = {model:'rental'}
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
        

        # console.log 'rental match', match
        # console.log 'sort key', sort_key
        # console.log 'sort direction', sort_direction
        Docs.find match,
            sort:"#{sort_key}":sort_direction
            # sort:_timestamp:-1
            limit: limit

    Meteor.publish 'rental_facets', (
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
        match.model = 'rental'
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
    Router.route '/rental/:doc_id/', (->
        @layout 'layout'
        @render 'rental_view'
        ), name:'rental_view'
    Router.route '/rental/:doc_id/edit', (->
        @layout 'layout'
        @render 'rental_edit'
        ), name:'rental_edit'


    
    Template.rental_big_card.onCreated ->
        @autorun => @subscribe 'rental_orders',@data._id, ->
    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => @subscribe 'rental_orders',Router.current().params.doc_id, ->
    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => @subscribe 'rental_orders',Router.current().params.doc_id, ->
    Template.rental_view.onRendered ->
        Docs.update Router.current().params.doc_id, 
            $inc:views:1
    
    Template.rental_view.helpers
        future_order_docs: ->
            Docs.find 
                model:'order'
                rental_id:Router.current().params.doc_id
                
                
                
    Template.rental_card.events
        'click .flat_pick_tag': -> picked_tags.push @valueOf()
        
    Template.rental_view.events
        'click .new_order': (e,t)->
            rental = Docs.findOne Router.current().params.doc_id
            new_order_id = Docs.insert
                model:'order'
                rental_id: @_id
                rental_id:rental._id
                rental_title:rental.title
                rental_image_id:rental.image_id
                rental_image_link:rental.image_link
                rental_daily_rate:rental.daily_rate
            Router.go "/order/#{new_order_id}/edit"
            
        'click .goto_tag': ->
            picked_tags.push @valueOf()
            Router.go '/'
            
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
                    rental = Docs.findOne context._id
                    new_order_id = Docs.insert
                        model:'order'
                        rental_id: rental._id
                        order_date: tech_form
                        _seller_username:rental._author_username
                        rental_id:rental._id
                        rental_title:rental.title
                        rental_image_id:rental.image_id
                        rental_image_link:rental.image_link
                        rental_daily_rate:rental.daily_rate
                    Swal.fire(
                        "reserved for #{human_form}",
                        ''
                        'success'
                    )
            )

            

if Meteor.isServer
    Meteor.publish 'user_rentals', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'rental'
            _author_id: user._id
            
    Meteor.publish 'rental_orders', (doc_id)->
        rental = Docs.findOne doc_id
        Docs.find
            model:'order'
            rental_id:rental._id
            
            
            
            
if Meteor.isClient
    Template.rental_stats.events
        'click .refresh_rental_stats': ->
            Meteor.call 'refresh_rental_stats', @_id




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
    Meteor.publish 'rental_orders_by_id', (rental_id)->
        Docs.find
            model:'order'
            rental_id: rental_id


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
        rentals_return = []
        for day in [0..6]
            day_number++
            # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
            date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
            console.log date_string
            rentals.return.push date_string
        rentals_return

        # data.long_form
        # Docs.find
        #     model:'order_slot'


    Meteor.methods
        refresh_rental_stats: (rental_id)->
            rental = Docs.findOne rental_id
            # console.log rental
            orders = Docs.find({model:'order', rental_id:rental_id})
            order_count = orders.count()
            total_earnings = 0
            total_rental_hours = 0
            average_rental_duration = 0

            # shortest_order =
            # longest_order =

            for res in orders.fetch()
                total_earnings += parseFloat(res.cost)
                total_rental_hours += parseFloat(res.hour_duration)

            average_rental_cost = total_earnings/order_count
            average_rental_duration = total_rental_hours/order_count

            Docs.update rental_id,
                $set:
                    order_count: order_count
                    total_earnings: total_earnings.toFixed(0)
                    total_rental_hours: total_rental_hours.toFixed(0)
                    average_rental_cost: average_rental_cost.toFixed(0)
                    average_rental_duration: average_rental_duration.toFixed(0)