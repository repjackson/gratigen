@picked_products = new ReactiveArray []
@picked_weeks = new ReactiveArray []
@picked_months = new ReactiveArray []


if Meteor.isClient
    Template.cart.onCreated ->
        @autorun => Meteor.subscribe 'doc', Meteor.user()._model, ->
        @autorun => Meteor.subscribe 'cart_items', Meteor.user()._model, ->
    Template.cart.helpers 
        cart_items: ->
            Docs.find
                model:'cart_item'
        item_count_total: ->
            res = 0
            for cart_item in Docs.find(model:'cart_item').fetch()
                res += cart_item.amount
            res
        
        
    Template.cart_item.events
        'click .remove_item': (e,t)->
            if confirm 'remove item?'
                $(e.currentTarget).closest('.grid').transition('fly left', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000
    Template.cart.events
        'click .complete_order': ->
            Docs.update @_id,
                $set:
                    status:'complete'
        'click .increase_amount': (e,t)->
            $(e.currentTarget).closest('.item').transition('bounce', 1000)
            Meteor.setTimeout ->
                Docs.update @_id, 
                    $inc:amount:1
            , 1000
        'click .decrease_amount': (e,t)->
            $(e.currentTarget).closest('.item').transition('bounce', 1000)
            Meteor.setTimeout ->
                Docs.update @_id, 
                    $inc:amount:-1
            , 1000
        
        
if Meteor.isServer 
    Meteor.publish 'cart_items', (cart_id)->
        Docs.find 
            model:'cart_item'
            cart_id:cart_id


if Meteor.isServer 
    Meteor.methods
        cart_meta: (doc_id)->
            cart = Docs.findOne doc_id
            split = cart.Ean_Code.split('/')
            # console.log split[4]
            
            
            converted = moment(cart.Txn_Timestamp, ["DD/MM/YYYY HH:mm:ss"]).toDate()
            Docs.update doc_id, 
                $set:
                    _product:split[4]
                    _converted_date: converted 
                    _month: moment(converted).format('MMMM')
                    _weekdaynum: moment(converted).isoWeekday()
                    _week_number: moment(converted).week()
                    _weekday: moment(converted).format('dddd')

        parse_cart: (parsed_results)->
            # console.log parsed_results
            # console.log parsed_results.data.length
            for item in parsed_results.data
                # console.log item
                found_item = 
                    Docs.findOne    
                        model:'cart'
                        Charge_ID:item.Charge_ID
                        Ean_Code:item.Ean_Code
                if found_item 
                    console.log 'skipping existing item', item.Charge_ID
                    Meteor.call 'cart_meta', found_item._id, ->
                else 
                    item.model = 'cart'
                    new_id = Docs.insert item
                    Meteor.call 'cart_meta', new_id, ->
                # console.log item.Txn_Timestamp, converted

    Meteor.publish 'cart_total', (
        product_search=''
        picked_products=[]
        picked_month=null
        picked_weeknum=null
        picked_weekday=null
        )->
        # @unblock()
        self = @
        match = {model:'cart', app:'nf'}

        # match.tags = $all: picked_tags
        # if model then match.model = model
        # if parent_id then match.parent_id = parent_id

        # if view_private is true
        #     match.author_id = Meteor.userId()

        # if view_private is false
        #     match.published = $in: [0,1]

        if picked_products.length > 0 then match._product = $in:picked_products
        if picked_weeknum then match._week_number = picked_weeknum
        if picked_weekday then match._weekday = picked_weekday
        if picked_month then match._month = picked_month
        if product_search.length > 1 then match._product = {$regex:"#{product_search}", $options: 'i'}
        Counts.publish this, 'cart_total', Docs.find(match)
        return undefined


    Meteor.publish 'product_by_cart', (cart)->
        # console.log cart
        Docs.find({
            model:'product'
            slug:cart._product
        }, limit:1)
    Meteor.publish 'cart_facets', (
        product_search=''
        picked_products=[]
        picked_month=null
        picked_weeknum=null
        picked_weekday=null
        )->
            self = @
            match = {model:'cart'}
    
            # match.tags = $all: picked_tags
            # if model then match.model = model
            # if parent_id then match.parent_id = parent_id
    
            # if view_private is true
            #     match.author_id = Meteor.userId()
    
            # if view_private is false
            #     match.published = $in: [0,1]
    
            if picked_products.length > 0 then match._product = $in:picked_products
            if picked_weeknum then match._week_number = picked_weeknum
            if picked_weekday then match._weekday = picked_weekday
            if picked_month then match._month = picked_month
            if product_search.length > 1 then match._product = {$regex:"#{product_search}", $options: 'i'}
            #     username: {$regex:"#{username}", $options: 'i'}

            # if picked_author_ids.length > 0
            #     match.author_id = $in: picked_author_ids
            #     match.published = 1
            # if picked_location_tags.length > 0 then match.location_tags = $all: picked_location_tags
            # if picked_building_tags.length > 0 then match.building_tags = $all: picked_building_tags
            # if picked_timestamp_tags.length > 0 then match.timestamp_tags = $all: picked_timestamp_tags
    
            # if tag_limit then limit=tag_limit else limit=50
            # if author_id then match.author_id = author_id
    
            # if view_private is true then match.author_id = @userId
            # if view_resonates?
            #     if view_resonates is true then match.favoriters = $in: [@userId]
            #     else if view_resonates is false then match.favoriters = $nin: [@userId]
            # if view_read?
            #     if view_read is true then match.read_by = $in: [@userId]
            #     else if view_read is false then match.read_by = $nin: [@userId]
            # if view_published is true
            #     match.published = $in: [1,0]
            # else if view_published is false
            #     match.published = -1
            #     match.author_id = Meteor.userId()
    
            # if view_bookmarked?
            #     if view_bookmarked is true then match.bookmarked_ids = $in: [@userId]
            #     else if view_bookmarked is false then match.bookmarked_ids = $nin: [@userId]
            # if view_complete? then match.complete = view_complete
            # console.log view_complete
    
    
    
            # match.site = Meteor.settings.public.site
    
            # console.log 'match:', match
            # if view_images? then match.components?.image = view_images
    
            # lightbank models
            # if view_lightbank_type? then match.lightbank_type = view_lightbank_type
            # match.lightbank_type = $ne:'journal_prompt'
    
            # ancestor_ids_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: ancestor_array: 1 }
            #     { $unwind: "$ancestor_array" }
            #     { $group: _id: '$ancestor_array', count: $sum: 1 }
            #     { $match: _id: $nin: picked_ancestor_ids }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: limit }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]
            # # console.log 'theme ancestor_ids_cloud, ', ancestor_ids_cloud
            # ancestor_ids_cloud.forEach (ancestor_id, i) ->
            #     self.added 'ancestor_ids', Random.id(),
            #         name: ancestor_id.name
            #         count: ancestor_id.count
            #         index: i
    
            product_cloud = Docs.aggregate [
                { $match: match }
                { $project: 
                    _product: 1
                    Qty: 1
                    # sale_total: 
                    #     $sum: '$Qty' 
                }
                # { $unwind: "$tags" }
                # { $group: 
                #     _id: '$_product', 
                # }
                { $group: 
                    _id: '$_product'
                    total: 
                        $sum: "$Qty"
                    count: 
                        $sum: 1
                }
                # { $match: _id: $nin: picked_products }
                # { $sort: count: -1, _id: 1 }
                { $sort: total: -1, _id: 1 }
                { $limit: 100 }
                { $project: _id:0, name:'$_id', count:1, total:1}
                ]
            # console.log 'theme theme_tag_cloud, ', theme_tag_cloud
            product_cloud.forEach (product, i) ->
                self.added 'results', Random.id(),
                    name: product.name
                    model:'_product'
                    count: product.count
                    total: product.total
                    # index: i
                    
            weeknum_cloud = Docs.aggregate [
                { $match: match }
                { $project: _week_number: 1 }
                # { $unwind: "$tags" }
                { $group: _id: '$_week_number', count: $sum: 1 }
                # { $match: _id: $ne: picked_week }
                { $sort: count: -1, _id: 1 }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'theme theme_tag_cloud, ', theme_tag_cloud
            weeknum_cloud.forEach (weeknum, i) ->
                self.added 'results', Random.id(),
                    name: weeknum.name
                    model:'weeknum'
                    count: weeknum.count
                    # index: i
    
            month_cloud = Docs.aggregate [
                { $match: match }
                { $project: _month: 1 }
                # { $unwind: "$tags" }
                { $group: _id: '$_month', count: $sum: 1 }
                # { $match: _id: $nin: picked_months }
                { $sort: count: -1, _id: 1 }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'theme theme_tag_cloud, ', theme_tag_cloud
            month_cloud.forEach (month, i) ->
                self.added 'results', Random.id(),
                    name: month.name
                    model:'month'
                    count: month.count
                    # index: i
    
            weekday_cloud = Docs.aggregate [
                { $match: match }
                { $project: _weekday: 1 }
                # { $unwind: "$tags" }
                { $group: _id: '$_weekday', count: $sum: 1 }
                # { $match: _id: $nin: picked_days }
                { $sort: count: -1, _id: 1 }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'theme theme_tag_cloud, ', theme_tag_cloud
            weekday_cloud.forEach (weekday, i) ->
                self.added 'results', Random.id(),
                    name: weekday.name
                    model:'weekday'
                    count: weekday.count
                    # index: i
    
            # timestamp_tags_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: timestamp_tags: 1 }
            #     { $unwind: "$_timestamp_tags" }
            #     { $group: _id: '$_timestamp_tags', count: $sum: 1 }
            #     { $match: _id: $nin: picked_timestamp_tags }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: 10 }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]
            # # console.log 'building timestamp_tags_cloud, ', timestamp_tags_cloud
            # timestamp_tags_cloud.forEach (timestamp_tag, i) ->
            #     self.added 'timestamp_tags', Random.id(),
            #         name: timestamp_tag.name
            #         count: timestamp_tag.count
            #         index: i
            #
            #
            # building_tag_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: building_tags: 1 }
            #     { $unwind: "$building_tags" }
            #     { $group: _id: '$building_tags', count: $sum: 1 }
            #     { $match: _id: $nin: picked_building_tags }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: limit }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]
            # # console.log 'building building_tag_cloud, ', building_tag_cloud
            # building_tag_cloud.forEach (building_tag, i) ->
            #     self.added 'building_tags', Random.id(),
            #         name: building_tag.name
            #         count: building_tag.count
            #         index: i
            #
            #
            # location_tag_cloud = Docs.aggregate [
            #     { $match: match }
            #     { $project: location_tags: 1 }
            #     { $unwind: "$location_tags" }
            #     { $group: _id: '$location_tags', count: $sum: 1 }
            #     { $match: _id: $nin: picked_location_tags }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: limit }
            #     { $project: _id: 0, name: '$_id', count: 1 }
            #     ]
            # # console.log 'location location_tag_cloud, ', location_tag_cloud
            # location_tag_cloud.forEach (location_tag, i) ->
            #     self.added 'location_tags', Random.id(),
            #         name: location_tag.name
            #         count: location_tag.count
            #         index: i
            #
            #
            # author_match = match
            # author_match.published = 1
            #
            # author_tag_cloud = Docs.aggregate [
            #     { $match: author_match }
            #     { $project: _author_id: 1 }
            #     { $group: _id: '$_author_id', count: $sum: 1 }
            #     { $match: _id: $nin: picked_author_ids }
            #     { $sort: count: -1, _id: 1 }
            #     { $limit: limit }
            #     { $project: _id: 0, text: '$_id', count: 1 }
            #     ]
            #
            #
            # # console.log author_tag_cloud
            #
            # # author_objects = []
            # # Meteor.users.find _id: $in: author_tag_cloud.
            #
            # author_tag_cloud.forEach (author_id) ->
            #     self.added 'author_ids', Random.id(),
            #         text: author_id.text
            #         count: author_id.count
            # int_doc_limit = parseInt doc_limit
            # console.log 'doc match', match
            subHandle = Docs.find(match, {limit:20, sort: timestamp:-1}).observeChanges(
                added: (id, fields) ->
                    # console.log 'added doc', id, fields
                    # doc_results.push id
                    self.added 'docs', id, fields
                changed: (id, fields) ->
                    # console.log 'changed doc', id, fields
                    self.changed 'docs', id, fields
                removed: (id) ->
                    # console.log 'removed doc', id, fields
                    # doc_results.pull id
                    self.removed 'docs', id
            )
    
            # for doc_result in doc_results
    
            # user_results = Meteor.users.find(_id:$in:doc_results).observeChanges(
            #     added: (id, fields) ->
            #         # console.log 'added doc', id, fields
            #         self.added 'docs', id, fields
            #     changed: (id, fields) ->
            #         # console.log 'changed doc', id, fields
            #         self.changed 'docs', id, fields
            #     removed: (id) ->
            #         # console.log 'removed doc', id, fields
            #         self.removed 'docs', id
            # )
    
    
    
            # console.log 'doc handle count', subHandle
    
            self.ready()
    
            self.onStop ()-> subHandle.stop()
