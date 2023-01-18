if Meteor.isClient
    Template.orgs_small.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'org', ->
    Template.orgs_small.helpers
        org_docs: ->
            Docs.find   
                model:'org'
                
                
    Template.org_view.helpers
        is_member: ->
            Meteor.userId() and Meteor.userId() in @member_ids
        # current_org: ->
        #     Docs.findOne
        #         model:'org'
        #         slug: Meteor.user()._model

    Template.org_view.events
        'click .refresh_org_stats': ->
            Meteor.call 'calc_org_stats', Meteor.user()._model, ->
        'click .join': ->
            if Meteor.userId()
                Docs.update @_id, 
                    $addToSet:
                        member_ids: Meteor.userId()
                Meteor.users.update Meteor.userId(),
                    $addToSet:
                        org_ids:@_id
            else 
                gstate_set '/login'
                
        'click .org_leave': ->
            Docs.update @_id, 
                $pull:
                    member_ids: Meteor.userId()
            Meteor.users.update Meteor.userId(),
                $pull:
                    org_ids:@_id


if Meteor.isClient
    Template.org_edit.events
        'click .add_option': ->
            Docs.insert
                model:'org_option'
                ballot_id: Meteor.user()._model
    Template.org_edit.helpers
        options: ->
            Docs.find
                model:'org_option'

# if Meteor.isServer
    # Meteor.publish 'org_results', (
    #     picked_tags
    #     doc_limit
    #     doc_sort_key
    #     doc_sort_direction
    #     view_delivery
    #     view_pickup
    #     view_open
    #     )->
    #     # console.log picked_tags
    #     if doc_limit
    #         limit = doc_limit
    #     else
    #         limit = 42
    #     if doc_sort_key
    #         sort_key = doc_sort_key
    #     if doc_sort_direction
    #         sort_direction = parseInt(doc_sort_direction)
    #     self = @
    #     match = {model:'org'}
    #     # if view_open
    #     #     match.open = $ne:false
    #     # if view_delivery
    #     #     match.delivery = $ne:false
    #     # if view_pickup
    #     #     match.pickup = $ne:false
    #     if picked_tags.length > 0
    #         match.tags = $all: picked_tags
    #         sort = 'member_count'
    #     else
    #         # match.tags = $nin: ['wikipedia']
    #         sort = '_timestamp'
    #         # match.source = $ne:'wikipedia'
    #     # if view_images
    #     #     match.is_image = $ne:false
    #     # if view_videos
    #     #     match.is_video = $ne:false

    #     # match.tags = $all: picked_tags
    #     # if filter then match.model = filter
    #     # keys = _.keys(prematch)
    #     # for key in keys
    #     #     key_array = prematch["#{key}"]
    #     #     if key_array and key_array.length > 0
    #     #         match["#{key}"] = $all: key_array
    #         # console.log 'current facet filter array', current_facet_filter_array

    #     console.log 'org match', match
    #     console.log 'sort key', sort_key
    #     console.log 'sort direction', sort_direction
    #     Docs.find match,
    #         # sort:"#{sort_key}":sort_direction
    #         sort:_timestamp:-1
    #         limit: limit

    # Meteor.publish 'org_facets', (
    #     picked_tags
    #     picked_timestamp_tags
    #     query
    #     doc_limit
    #     doc_sort_key
    #     doc_sort_direction
    #     view_delivery
    #     view_pickup
    #     view_open
    #     )->
    #     # console.log 'dummy', dummy
    #     # console.log 'query', query
    #     console.log 'selected tags', picked_tags

    #     self = @
    #     match = {}
    #     match.model = 'org'
    #     if view_open
    #         match.open = $ne:false

    #     if view_delivery
    #         match.delivery = $ne:false
    #     if view_pickup
    #         match.pickup = $ne:false
    #     if picked_tags.length > 0 then match.tags = $all: picked_tags
    #         # match.$regex:"#{current_query}", $options: 'i'}
    #     # if query and query.length > 1
    #     # #     console.log 'searching query', query
    #     # #     # match.tags = {$regex:"#{query}", $options: 'i'}
    #     # #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    #     # #
    #     #     Terms.find {
    #     #         title: {$regex:"#{query}", $options: 'i'}
    #     #     },
    #     #         sort:
    #     #             count: -1
    #     #         limit: 20
    #         # tag_cloud = Docs.aggregate [
    #         #     { $match: match }
    #         #     { $project: "tags": 1 }
    #         #     { $unwind: "$tags" }
    #         #     { $org: _id: "$tags", count: $sum: 1 }
    #         #     { $match: _id: $nin: picked_tags }
    #         #     { $match: _id: {$regex:"#{query}", $options: 'i'} }
    #         #     { $sort: count: -1, _id: 1 }
    #         #     { $limit: 42 }
    #         #     { $project: _id: 0, name: '$_id', count: 1 }
    #         #     ]

    #     # else
    #     # unless query and query.length > 2
    #     # if picked_tags.length > 0 then match.tags = $all: picked_tags
    #     # # match.tags = $all: picked_tags
    #     # # console.log 'match for tags', match
    #     # tag_cloud = Docs.aggregate [
    #     #     { $match: match }
    #     #     { $project: "tags": 1 }
    #     #     { $unwind: "$tags" }
    #     #     { $org: _id: "$tags", count: $sum: 1 }
    #     #     { $match: _id: $nin: picked_tags }
    #     #     # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
    #     #     { $sort: count: -1, _id: 1 }
    #     #     { $limit: 20 }
    #     #     { $project: _id: 0, name: '$_id', count: 1 }
    #     # ], {
    #     #     allowDiskUse: true
    #     # }
    #     #
    #     # tag_cloud.forEach (tag, i) =>
    #     #     # console.log 'queried tag ', tag
    #     #     # console.log 'key', key
    #     #     self.added 'tags', Random.id(),
    #     #         title: tag.name
    #     #         count: tag.count
    #     #         # category:key
    #     #         # index: i


    #     tag_cloud = Docs.aggregate [
    #         { $match: match }
    #         { $project: "tags": 1 }
    #         { $unwind: "$tags" }
    #         { $org: _id: "$tags", count: $sum: 1 }
    #         { $sort: count: -1, _id: 1 }
    #         { $limit: 20 }
    #         { $project: _id: 0, title: '$_id', count: 1 }
    #     ], {
    #         allowDiskUse: true
    #     }

    #     tag_cloud.forEach (tag, i) =>
    #         # console.log 'tag result ', tag
    #         self.added 'tags', Random.id(),
    #             title: tag.title
    #             count: tag.count
    #             # category:key
    #             # index: i


    #     self.ready()


if Meteor.isClient
    Template.org_history.onCreated ->
        @autorun => Meteor.subscribe 'children', 'log_event', Meteor.user()._model
    Template.org_history.helpers
        org_events: ->
            Docs.find
                model:'log_event'
                parent_id:Meteor.user()._model


    Template.org_subscription.onCreated ->
        # @autorun => Meteor.subscribe 'children', 'log_event', Meteor.user()._model
    Template.org_subscription.events
        'click .subscribe': ->
            Docs.insert
                model:'log_event'
                log_type:'subscribe'
                parent_id:Meteor.user()._model
                text: "#{Meteor.user().username} subscribed to org order."


    Template.org_reservations.onCreated ->
        @autorun => Meteor.subscribe 'org_reservations', Meteor.user()._model
    Template.org_reservations.helpers
        reservations: ->
            Docs.find
                model:'reservation'
                org_id: Meteor.user()._model
    Template.org_reservations.events
        'click .new_reservation': ->
            Docs.insert
                model:'reservation'
                org_id: Meteor.user()._model


if Meteor.isServer
    Meteor.publish 'org_reservations', (org_id)->
        Docs.find
            model:'reservation'
            org_id: org_id



    Meteor.methods
        calc_org_stats: ->
            org_stat_doc = Docs.findOne(model:'org_stats')
            unless org_stat_doc
                new_id = Docs.insert
                    model:'org_stats'
                org_stat_doc = Docs.findOne(model:'org_stats')
            console.log org_stat_doc
            total_count = Docs.find(model:'org').count()
            complete_count = Docs.find(model:'org', complete:true).count()
            incomplete_count = Docs.find(model:'org', complete:$ne:true).count()
            Docs.update org_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count


if Meteor.isClient
    Template.user_orgs.onCreated ->
        @autorun => Meteor.subscribe 'user_orgs', Template.parentData().username
    Template.user_orgs.events
        'click .add_org': ->
            new_id =
                Docs.insert
                    model:'org'
            gstate_set "/org/#{new_id}/edit"

    Template.user_orgs.helpers
        orgs: ->
            current_user = Meteor.users.findOne username:Template.parentData().username
            Docs.find {
                model:'org'
                _author_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer
    Meteor.publish 'user_orgs', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'org'
            _author_id: user._id


if Meteor.isServer
    Meteor.publish 'members', (tribe_id)->
        Meteor.users.find
            _id:$in:@member_ids

    Meteor.publish 'tribe_by_slug', (tribe_slug)->
        Docs.find
            model:'tribe'
            slug:tribe_slug
    Meteor.methods
        calc_tribe_stats: (tribe_slug)->
            tribe = Docs.findOne
                model:'tribe'
                slug: tribe_slug

            member_count =
                tribe.member_ids.length

            tribe_members =
                Meteor.users.find
                    _id: $in: tribe.member_ids

            dish_count = 0
            dish_ids = []
            for member in tribe_members.fetch()
                member_dishes =
                    Docs.find(
                        model:'dish'
                        _author_id:member._id
                    ).fetch()
                for dish in member_dishes
                    console.log 'dish', dish.title
                    dish_ids.push dish._id
                    dish_count++
            # dish_count =
            #     Docs.find(
            #         model:'dish'
            #         tribe_id:tribe._id
            #     ).count()
            tribe_count =
                Docs.find(
                    model:'tribe'
                    tribe_id:tribe._id
                ).count()

            order_cursor =
                Docs.find(
                    model:'order'
                    tribe_id:tribe._id
                )
            order_count = order_cursor.count()
            total_credit_exchanged = 0
            for order in order_cursor.fetch()
                if order.order_price
                    total_credit_exchanged += order.order_price
            tribe_tribes =
                Docs.find(
                    model:'tribe'
                    tribe_id:tribe._id
                ).fetch()

            console.log 'total_credit_exchanged', total_credit_exchanged


            Docs.update tribe._id,
                $set:
                    member_count:member_count
                    tribe_count:tribe_count
                    dish_count:dish_count
                    total_credit_exchanged:total_credit_exchanged
                    dish_ids:dish_ids