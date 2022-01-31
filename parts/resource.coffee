if Meteor.isClient
    Router.route '/resources', (->
        @layout 'layout'
        @render 'resources'
        ), name:'resources'


    Template.resources.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'resource_sort_key', 'datetime_available'
        Session.setDefault 'resource_sort_label', 'available'
        Session.setDefault 'resource_limit', 42
        Session.setDefault 'view_open', true

    Template.resources.onCreated ->
        @autorun => @subscribe 'resource_facets',
            picked_tags.array()
            Session.get('current_lat')
            Session.get('current_long')
            Session.get('resource_limit')
            Session.get('resource_sort_key')
            Session.get('resource_sort_direction')

        @autorun => @subscribe 'resource_results',
            picked_tags.array()
            Session.get('lat')
            Session.get('long')
            Session.get('resource_limit')
            Session.get('resource_sort_key')
            Session.get('resource_sort_direction')
    
    Template.resources.events
        'click .add_resource': ->
            new_id = 
                Docs.insert 
                    model:'resource'
            Router.go "/resource/#{new_id}/edit"
        'click .fly_right': (e,t)->
            console.log 'hi'
            $(e.currentTarget).closest('.grid').transition('fly right', 500)
    
        'click .request_resource': ->
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

        'click .calc_resource_count': ->
            Meteor.call 'calc_resource_count', ->

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

    Template.resources.helpers
        query_requests: ->
            Docs.find
                model:'request'
                title:Session.get('query')
            
        counter: -> Counts.get('resource_counter')
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

        one_resource: ->
            Docs.find(model:'resource').count() is 1
        resource_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model: 'resource'
                # downvoter_ids:$nin:[Meteor.userId()]
            },
                sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
                limit:Session.get('limit')

        subs_ready: ->
            Template.instance().subscriptionsReady()






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
    Router.route '/resource/:doc_id/', (->
        @layout 'layout'
        @render 'resource_view'
        ), name:'resource_view'
    Router.route '/resource/:doc_id/edit', (->
        @layout 'layout'
        @render 'resource_edit'
        ), name:'resource_edit'


    
    Template.resource_big_card.onCreated ->
        @autorun => @subscribe 'resource_orders',@data._id, ->
    Template.resource_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => @subscribe 'resource_orders',Router.current().params.doc_id, ->
    Template.resource_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => @subscribe 'resource_orders',Router.current().params.doc_id, ->
    Template.resource_view.onRendered ->
        Docs.update Router.current().params.doc_id, 
            $inc:views:1
    
    Template.resource_view.helpers
        future_order_docs: ->
            Docs.find 
                model:'order'
                resource_id:Router.current().params.doc_id
                
                
                
    Template.resource_card.events
        'click .flat_pick_tag': -> picked_tags.push @valueOf()
        
    Template.resource_view.events
        'click .new_order': (e,t)->
            resource = Docs.findOne Router.current().params.doc_id
            new_order_id = Docs.insert
                model:'order'
                resource_id: @_id
                resource_id:resource._id
                resource_title:resource.title
                resource_image_id:resource.image_id
                resource_image_link:resource.image_link
                resource_daily_rate:resource.daily_rate
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