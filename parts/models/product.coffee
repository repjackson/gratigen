if Meteor.isClient
    Router.route '/product/:doc_id', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'
    # Router.route '/product/:doc_id/orders', (->
    #     @layout 'product_layout'
    #     @render 'product_orders'
    #     ), name:'product_orders'
    # Router.route '/product/:doc_id/subscriptions', (->
    #     @layout 'product_layout'
    #     @render 'product_subscriptions'
    #     ), name:'product_subscriptions'
    # Router.route '/product/:doc_id/comments', (->
    #     @layout 'product_layout'
    #     @render 'product_comments'
    #     ), name:'product_comments'
    # Router.route '/product/:doc_id/reviews', (->
    #     @layout 'product_layout'
    #     @render 'product_reviews'
    #     ), name:'product_reviews'
    # Router.route '/product/:doc_id/inventory', (->
    #     @layout 'product_layout'
    #     @render 'product_inventory'
    #     ), name:'product_inventory'


    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'product_source', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'ingredients_from_product_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'orders_from_product_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'subs_from_product_id', Router.current().params.doc_id, ->
    Template.product_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'ingredients_from_product_id', Router.current().params.doc_id
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
            Meteor.call 'calc_product_data', Router.current().params.doc_id, ->
        'click .goto_source': (e,t)->
            $(e.currentTarget).closest('.pushable').transition('fade right', 240)
            product = Docs.findOne Router.current().params.doc_id
            Meteor.setTimeout =>
                Router.go "/source/#{product.source_id}"
            , 240
        
        'click .goto_ingredient': (e,t)->
            # $(e.currentTarget).closest('.pushable').transition('fade right', 240)
            product = Docs.findOne Router.current().params.doc_id
            console.log @
            found_ingredient = 
                Docs.findOne 
                    model:'ingredient'
                    title:@valueOf()
            if found_ingredient
                Router.go "/ingredient/#{found_ingredient._id}"
            else 
                new_id = 
                    Docs.insert 
                        model:'ingredient'
                        title:@valueOf()
                Router.go "/ingredient/#{new_id}/edit"
                
            # found_ingredient = 
            #     Docs.findOne 
            #         model:'ingredient'
            #         title:@valueOf()
            # Meteor.setTimeout =>
            #     Router.go "/source/#{product.source_id}"
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
                Docs.update Router.current().params.doc_id,
                    $addToSet: 
                        subscribed_ids: Meteor.userId()
                new_sub_id = 
                    Docs.insert 
                        model:'product_subscription'
                        product_id:Router.current().params.doc_id
                Router.go "/subscription/#{new_sub_id}/edit"
                    
        'click .unsubscribe': ->
            if confirm 'unsubscribe?'
                Docs.update Router.current().params.doc_id,
                    $pull: 
                        subscribed_ids: Meteor.userId()
                                    
    
        'click .mark_ready': ->
            if confirm 'mark product ready?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        ready:true
                        ready_timestamp:Date.now()

        'click .unmark_ready': ->
            if confirm 'unmark product ready?'
                Docs.update Router.current().params.doc_id,
                    $set:
                        ready:false
                        ready_timestamp:null

    Template.product_inventory.onCreated ->
        @autorun => Meteor.subscribe 'inventory_from_product_id', Router.current().params.doc_id
            
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
                product_id:Router.current().params.doc_id

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
            product = Docs.findOne Router.current().params.doc_id
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
        #                 product_id: Router.current().params.doc_id
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
            #     product_id: Router.current().params.doc_id
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
                    Router.go "/order/#{res}/edit"
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
    Router.route '/product/:doc_id/edit', (->
        @layout 'layout'
        @render 'product_edit'
        ), name:'product_edit'


    Template.product_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
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
            product = Docs.findOne Router.current().params.doc_id
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
                Docs.update Router.current().params.doc_id,
                    $set:source_id:null
        'click .pick_source': (e,t)->
            Docs.update Router.current().params.doc_id,
                $set:source_id:@_id
        'keyup .source_search': (e,t)->
            # if e.which is '13'
            val = t.$('.source_search').val()
            console.log val
            Session.set('source_search', val)
                
            
        'click .save_product': ->
            product_id = Router.current().params.doc_id
            Meteor.call 'calc_product_data', product_id, ->
            Router.go "/product/#{product_id}"


        'click .save_availability': ->
            doc_id = Router.current().params.doc_id
            availability = $('.ui.calendar').calendar('get date')[0]
            console.log availability
            formatted = moment(availability).format("YYYY-MM-DD[T]HH:mm")
            console.log formatted
            # console.log moment(@end_datetime).diff(moment(@start_datetime),'minutes',true)
            # console.log moment(@end_datetime).diff(moment(@start_datetime),'hours',true)
            Docs.update doc_id,
                $set:datetime_available:formatted





        # 'click .select_product': ->
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             product_id: @_id
        #
        #
        # 'click .clear_product': ->
        #     if confirm 'clear product?'
        #         Docs.update Router.current().params.doc_id,
        #             $set:
        #                 product_id: null



        'click .delete_product': ->
            if confirm 'refund orders and cancel product?'
                Docs.remove Router.current().params.doc_id
                Router.go "/"

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
            product = Docs.findOne Router.current().params.doc_id
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
                Docs.update Router.current().params.doc_id,
                    $pull:
                        ingredient_ids:@_id
                        ingredient_titles:@title
        'click .pick_ingredient': (e,t)->
            Docs.update Router.current().params.doc_id,
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
            Router.go "/ingredient/#{new_id}/edit"


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
    Router.route '/products', (->
        @layout 'layout'
        @render 'products'
        ), name:'products'


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
            Router.go("/food/#{@_id}")
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
        