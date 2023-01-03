if Meteor.isClient
    @picked_tags = new ReactiveArray []
    
    Template.task_view.events
        'click .record_work': ->
            new_id = Docs.insert 
                model:'work'
                task_id: Router.current().params.doc_id
            Router.go "/work/#{new_id}/edit"    
    
                
           
    Template.task_view.helpers
        possible_locations: ->
            task = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'location'
                _id:$in:task.location_ids
                
        task_work: ->
            Docs.find 
                model:'work'
                task_id:Router.current().params.doc_id
                
    Template.task_edit.helpers
        task_locations: ->
            Docs.find
                model:'location'
                
        location_class: ->
            task = Docs.findOne Router.current().params.doc_id
            if task.location_ids and @_id in task.location_ids then 'blue' else 'basic'
            
                
    Template.task_edit.events
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id, 
                $set:
                    complete:true
                    complete_timestamp: Date.now()
                    
        'click .select_location': ->
            task = Docs.findOne Router.current().params.doc_id
            if task.location_ids and @_id in task.location_ids
                Docs.update Router.current().params.doc_id, 
                    $pull:location_ids:@_id
            else
                Docs.update Router.current().params.doc_id, 
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
                    task = Docs.findOne Router.current().params.doc_id
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
                    Router.go "/task/#{@_id}/"
                    )
            )

        'click .delete_task':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/tasks"
            
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
            Router.go "/work/#{new_id}/edit"    
      
        'click .add_task': ->
            new_id = Docs.insert 
                model:'task'
            Router.go "/task/#{new_id}/edit"    
    
                
    Template.work_edit.events
        'click .pick_staff': ->
            Docs.update Router.current().params.doc_id, 
                $set:
                    staff_id:@_id
                    staff_name: "#{@first_name} #{@last_name}"
                    staff_image_id: @image_id
        
        'click .pick_location': ->
            Docs.update Router.current().params.doc_id, 
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
        #     work = Docs.findOne Router.current().params.doc_id
        #     if work.staff_id is @_id then 'blue big' else 'basic large'
            
        location_picker_class: ->
            work = Docs.findOne Router.current().params.doc_id
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
    Router.route '/work/:doc_id/edit', (->
        @layout 'layout'
        @render 'work_edit'
        ), name:'work_edit'



    Template.work_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'work_task', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
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
        #             work = Docs.findOne Router.current().params.doc_id
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
        #             Router.go "/work/#{@_id}/"
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
                Router.go "/work"
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
                Router.go "/work"
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
    Router.route '/role/:doc_id/edit', (->
        @layout 'layout'
        @render 'role_edit'
        ), name:'role_edit'
    Router.route '/role/:doc_id', (->
        @layout 'layout'
        @render 'role_view'
        ), name:'role_view'
    Router.route '/role/:doc_id/view', (->
        @layout 'layout'
        @render 'role_view'
        ), name:'role_view_long'
    
    
    Template.role_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.role_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.role_item.events
        'click .view_role': ->
            Router.go "/role/#{@_id}"

    Template.role_view.events
        'click .add_role_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    role_ids:[@_id]
            Router.go "/recipe/#{new_id}/edit"

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
                    Router.go "/roles"
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
            Router.go("/food/#{@_id}")
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
                    
if Meteor.isClient
    Template.project_edit.helpers
        child_tasks: ->
            Docs.find
                model:'task'
                
                
    Template.project_view.helpers
        child_tasks: ->
            Docs.find
                model:'task'
                project_id: Router.current().params.doc_id
                
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
                    Router.go "/projects"
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
            Router.go("/food/#{@_id}")
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
            