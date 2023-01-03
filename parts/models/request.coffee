if Meteor.isClient
    Template.registerHelper 'claimer', () ->
        Meteor.users.findOne @claimed_user_id
    Template.registerHelper 'completer', () ->
        Meteor.users.findOne @completed_by_user_id
    
    
    Template.request_view.events
        'click .claim': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    claimed_user_id: Meteor.userId()
                    status:'claimed'
            
                            
        'click .unclaim': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    claimed_user_id: 1
                $set:
                    status:'unclaimed'
            
                            
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete: true
                    completed_by_user_id:@claimed_user_id
                    status:'complete'
                    completed_timestamp:Date.now()
            Meteor.users.update @claimed_user_id,
                $inc:points:@point_bounty
                            
        'click .mark_incomplete': ->
            Docs.update Router.current().params.doc_id,
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
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


if Meteor.isClient
    Router.route '/request/:doc_id/edit', (->
        @layout 'layout'
        @render 'request_edit'
        ), name:'request_edit'



    Template.request_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
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
                    Router.go "/m/request"
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