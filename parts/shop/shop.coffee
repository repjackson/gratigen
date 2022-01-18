if Meteor.isClient
    Router.route '/shop', (->
        @layout 'layout'
        @render 'shop'
        ), name:'shop'


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
        shop_section=null
        limit=20
        sort_key='_timestamp'
        sort_direction=1
        )->
        # console.log picked_ingredients
        self = @
        match = {model:'product', app:'nf'}
        if shop_section 
            match.shop_section = shop_section
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
        shop_section=null
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
        if shop_section 
            match.shop_section = shop_section
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
