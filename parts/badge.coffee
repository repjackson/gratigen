if Meteor.isClient
    Router.route '/badges', (->
        @layout 'layout'
        @render 'badges'
        ), name:'badges'
    Router.route '/badge/:doc_id/edit', (->
        @layout 'layout'
        @render 'badge_edit'
        ), name:'badge_edit'
    Router.route '/badge/:doc_id', (->
        @layout 'layout'
        @render 'badge_view'
        ), name:'badge_view'
    Router.route '/badge/:doc_id/view', (->
        @layout 'layout'
        @render 'badge_view'
        ), name:'badge_view_long'
    
    
    Template.badges.onCreated ->
        @autorun => @subscribe 'badge_docs',
            picked_tags.array()
            Session.get('badge_title_filter')

        @autorun => @subscribe 'badge_facets',
            picked_tags.array()
            Session.get('badge_title_filter')

    
    
    Template.badges.events
        'click .add_badge': ->
            new_id = 
                Docs.insert 
                    model:'badge'
            Router.go "/badge/#{new_id}/edit"
            
            
            
    Template.badges.helpers
        picked_tags: -> picked_tags.array()
    
        badge_docs: ->
            Docs.find {
                model:'badge'
            }, sort:_timestamp:-1    
        tag_results: ->
            Results.find {
                model:'tag'
            }, sort:_timestamp:-1

    Template.user_badges.onCreated ->
        @autorun => Meteor.subscribe 'user_badges', Router.current().params.username, ->
    Template.user_badges.helpers
        badge_docs: ->
            Docs.find {
                model:'badge'
            }, sort:_timestamp:-1    
    
    Template.badge_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.badge_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.badge_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


    Template.badge_card.events
        'click .view_badge': ->
            Router.go "/badge/#{@_id}"
    Template.badge_item.events
        'click .view_badge': ->
            Router.go "/badge/#{@_id}"

    Template.badge_view.events
        'click .add_badge_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    badge_ids:[@_id]
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
    
    
    Template.badge_edit.events
        'click .delete_badge': ->
            Swal.fire({
                title: "delete badge?"
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
                        title: 'badge removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/badges"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish badge?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_badge', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'badge published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish badge?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_badge', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'badge unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            
if Meteor.isServer
    Meteor.publish 'user_badges', (username)->
        user = Meteor.users.findOne username:username
        
        Docs.find 
            model:'badge'
            _author_id:user._id
    
    Meteor.publish 'badge_count', (
        picked_tags
        picked_sections
        badge_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_tags
        self = @
        match = {model:'badge'}
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
        if badge_query and badge_query.length > 1
            console.log 'searching badge_query', badge_query
            match.title = {$regex:"#{badge_query}", $options: 'i'}
        Counts.publish this, 'badge_counter', Docs.find(match)
        return undefined


if Meteor.isClient
    Template.badge_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.badge_card.events
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

    Template.badge_card.helpers
        badge_card_class: ->
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
    Meteor.publish 'badge_facets', (
        picked_tags=[]
        title_filter
        picked_authors=[]
        picked_tasks=[]
        picked_locations=[]
        picked_timestamp_tags=[]
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        # console.log 'picked staff', picked_authors
    
        self = @
        match = {}
        # match = {app:'pes'}
        match.model = 'badge'
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
                model:'tag'
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
        
    Meteor.publish 'badge_docs', (
        picked_tags
        # title_filter
        # picked_authors=[]
        # picked_tasks=[]
        # picked_locations=[]
        # picked_timestamp_tags=[]
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
        match.model = 'badge'
        # match.group_id = Meteor.user().current_group_id
        # if title_filter and title_filter.length > 1
        #     match.title = {$regex:title_filter, $options:'i'}
        
        # if view_vegan
        #     match.vegan = true
        # if view_gf
        #     match.gluten_free = true
        # if view_local
        #     match.local = true
        # if picked_authors.length > 0 then match._author_username = $in:picked_authors
        # if picked_tags.length > 0 then match.tags = $all:picked_tags 
        # if picked_locations.length > 0 then match.location_title = $in:picked_locations 
        # if picked_timestamp_tags.length > 0 then match._timestamp_tags = $in:picked_timestamp_tags 
        console.log match
        Docs.find match, 
            limit:20
            sort:
                _timestamp:-1