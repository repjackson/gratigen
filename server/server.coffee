Meteor.users.allow
    update: (userId, doc, fields, modifier) ->
        true
        # if userId and doc._id == userId
        #     true
    remove: (userId, doc) -> 
        # true
        doc._author_id is userId or 'admin' in Meteor.user().roles


Docs.allow
    insert: (userId, doc) -> 
        userId    
        # doc._author_id is userId
    update: (userId, doc) ->
        userId
        # if doc.model in ['calculator_doc','simulated_rental_item','healthclub_session']
        #     true
        # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
        #     true
        # else
        #     doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> 
        userId
        # doc._author_id is userId or 'admin' in Meteor.user().roles
Letters.allow
    insert: (userId, doc) -> 
        true    
        # doc._author_id is userId
    update: (userId, doc) ->
        true
        # if doc.model in ['calculator_doc','simulated_rental_item','healthclub_session']
        #     true
        # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
        #     true
        # else
        #     doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> 
        true
        # doc._author_id is userId or 'admin' in Meteor.user().roles
Markers.allow
    insert: (userId, doc) -> 
        true    
        # doc._author_id is userId
    update: (userId, doc) ->
        true
        # if doc.model in ['calculator_doc','simulated_rental_item','healthclub_session']
        #     true
        # else if Meteor.user() and Meteor.user().roles and 'admin' in Meteor.user().roles
        #     true
        # else
        #     doc._author_id is userId
    # update: (userId, doc) -> doc._author_id is userId or 'admin' in Meteor.user().roles
    remove: (userId, doc) -> 
        true
        # doc._author_id is userId or 'admin' in Meteor.user().roles

Meteor.publish 'docs', (picked_tags, filter)->
    # user = Meteor.users.findOne @userId
    # console.log picked_tags
    # console.log filter
    self = @
    match = {}
    # if Meteor.user()
    #     unless Meteor.user().roles and 'dev' in Meteor.user().roles
    #         match.view_roles = $in:Meteor.user().roles
    # else
    #     match.view_roles = $in:['public']

    # if filter is 'shop'
    #     match.active = true
    if picked_tags.length > 0 then match.tags = $all: picked_tags
    if filter then match.model = filter

    Docs.find match, sort:_timestamp:-1


# Meteor.users.allow
#     update: (userId, doc, fields, modifier) ->
#         true
#         # if userId and doc._id == userId
#         #     true

Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.private.cloudinary_key
    api_secret: Meteor.settings.private.cloudinary_secret



# SyncedCron.add
#     name: 'Update incident escalations'
#     schedule: (parser) ->
#         # parser is a later.parse object
#         parser.text 'every 1 hour'
#     job: ->
#         Meteor.call 'update_escalation_statuses', (err,res)->
#             # else


# SyncedCron.add({
#         name: 'check out members'
#         schedule: (parser) ->
#             parser.text 'every 2 hours'
#         job: ->
#             Meteor.call 'checkout_members', (err, res)->
#     },{
#         name: 'check leases'
#         schedule: (parser) ->
#             # parser is a later.parse object
#             parser.text 'every 24 hours'
#         job: ->
#             Meteor.call 'check_lease_status', (err, res)->
#     }
# )


# if Meteor.isProduction
#     SyncedCron.start()



Meteor.publish 'model_from_child_id', (child_id)->
    child = Docs.findOne child_id
    Docs.find
        model:'model'
        slug:child.type


Meteor.publish 'model_fields_from_child_id', (child_id)->
    child = Docs.findOne child_id
    model = Docs.findOne
        model:'model'
        slug:child.type
    Docs.find
        model:'field'
        parent_id:model._id

Meteor.publish 'all_users', ()->
    Meteor.users.find {}
    # limit:20
    
    
Meteor.publish 'model_docs', (model,limit)->
    if limit
        Docs.find {
            model: model
            # app:'nf'
        }, 
            limit:limit
    else
        Docs.find {
            # app:'nf'
            model: model
        }, sort:_timestamp:-1
Meteor.publish 'me', ->
    Meteor.users.find({_id:@userId},{
        # fields:
        #     username:1
        #     image_id:1
        #     tags:1
        #     points:1
    })

Meteor.publish 'document_by_slug', (slug)->
    Docs.find
        model: 'document'
        slug:slug

Meteor.publish 'child_docs', (id)->
    # id=unknown 
    if id
        found_parent = Docs.findOne id
        if found_parent
            Docs.find
                parent_id:id


Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array


Meteor.publish 'inline_doc', (slug)->
    Docs.find
        model:'inline_doc'
        slug:slug



Meteor.publish 'user_from_username', (username)->
    Meteor.users.find username:username

Meteor.publish 'user_from_id', (user_id)->
    Meteor.users.find user_id

Meteor.publish 'doc_by_id', (doc_id)->
    Docs.find doc_id
Meteor.publish 'doc', (doc_id)->
    Docs.find doc_id

Meteor.publish 'author_from_doc_id', (doc_id)->
    doc = Docs.findOne doc_id
    Meteor.users.find doc._author_id

# Meteor.publish 'page', (slug)->
#     Docs.find
#         model:'page'
#         slug:slug


Meteor.publish 'doc_tags', (picked_tags)->

    user = Meteor.users.findOne @userId
    # current_herd = user.profile.current_herd

    self = @
    match = {}

    # picked_tags.push current_herd
    match.tags = $all: picked_tags

    cloud = Docs.aggregate [
        { $match: match }
        { $project: tags: 1 }
        { $unwind: "$tags" }
        { $group: _id: '$tags', count: $sum: 1 }
        { $match: _id: $nin: picked_tags }
        { $sort: count: -1, _id: 1 }
        { $limit: 20 }
        { $project: _id: 0, name: '$_id', count: 1 }
        ]
    cloud.forEach (tag, i) ->

        self.added 'tags', Random.id(),
            name: tag.name
            count: tag.count
            index: i

    self.ready()



Meteor.publish 'order_count', (
    )->
    @unblock()
    self = @
    match = {model:'order', app:'nf'}
    Counts.publish this, 'order_count', Docs.find(match)
    return undefined
Meteor.publish 'ingredient_count', (
    )->
    @unblock()
    self = @
    match = {model:'ingredient', app:'nf'}
    Counts.publish this, 'ingredient_count', Docs.find(match)
    return undefined
Meteor.publish 'product_count', (
    )->
    @unblock()
    self = @
    match = {model:'product', app:'nf'}
    Counts.publish this, 'product_count', Docs.find(match)
    return undefined
Meteor.publish 'source_count', (
    )->
    @unblock()
    self = @
    match = {model:'source', app:'nf'}
    Counts.publish this, 'source_count', Docs.find(match)
    return undefined
Meteor.publish 'subscription_count', (
    )->
    @unblock()
    self = @
    match = {model:'product_subscription', app:'nf'}
    Counts.publish this, 'subscription_count', Docs.find(match)
    return undefined
    
    
Meteor.publish 'giftcard_count', (
    )->
    @unblock()
    self = @
    match = {model:'giftcard', app:'nf'}
    Counts.publish this, 'giftcard_count', Docs.find(match)
    return undefined




if Meteor.isServer
    Meteor.startup () ->
        # Meteor.users.dropIndexes()
        Meteor.users._ensureIndex({ "location": '2dsphere'});
    
    
    Meteor.methods
        clear_markers: ->
            Markers.remove({})

        geolocate: (doc_id, search)->
            # Doc
            console.log Meteor.settings.private.maps
            # HTTP.get "https://api.mapbox.com/geocoding/v5/mapbox.places/#{search}.json&access_token=#{"pk.eyJ1IjoiZ29sZHJ1biIsImEiOiJjbGM5cXNsZmQwbW14M3BsaHFjMnY4dW90In0.SQ5FWLZYeq-xO6_g7wekRQ"}",(err,res)=>
            # HTTP.get "https://api.mapbox.com/geocoding/v5/mapbox.places/arapahoe%2C%20boulder%2C%20co.json?proximity=ip&types=place%2Cpostcode%2Caddress&access_token=#{Meteor.settings.private.maps}",(err,res)=>
            HTTP.get "https://api.opencagedata.com/geocode/v1/json?q=#{search}&key=3da4768aa84b45f693b00be20f1aff32",(err,res)=>
                # console.log res.results.geometry.lat
                # console.log res.results.geometry.lng
                console.log res.data.results[0].geometry
                
                Docs.update doc_id, 
                    $set:
                        location_info:res
                        lat:res.data.results[0].geometry.lat
                        lng: res.data.results[0].geometry.lng
        
        
        
        tag_coordinates: (doc_id, lat,long)->
            # HTTP.get "https://api.opencagedata.com/geocode/v1/json?q=#{lat}%2C#{long}&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1",(err,response)=>
            HTTP.get "https://api.opencagedata.com/geocode/v1/json?q=#{lat}+#{long}&key=3da4768aa84b45f693b00be20f1aff32&language=en&pretty=1&no_annotations=1",(err,response)=>
                console.log response.data
                if err then console.log err
                else
                    doc = Docs.findOne doc_id
                    user = Meteor.users.findOne doc_id
                    if doc
                        Docs.update doc_id,
                            $set:geocoded:response.data.results
                    if user
                        Meteor.users.update doc_id,
                            $set:geocoded:response.data.results
                    console.log 'working', response
    
            # https://api.opencagedata.com/geocode/v1/json?q=24.77701%2C%20121.02189&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1
            # https://api.opencagedata.com/geocode/v1/json?q=Dhumbarahi%2C%20Kathmandu&key=f234c66b8ec44a448f8cb6a883335718&language=en&pretty=1&no_annotations=1
    
    
    # Meteor.publish 'nearby_people', (lat,long)->
    Meteor.publish 'nearby_people', (username)->
        user = Meteor.users.findOne username:username
        
        if user
            console.log 'searching for users lat long', user.current_lat, user.current_long
            Meteor.users.find
                light_mode:true
                location:
                    $near:
                        $geometry:
                            type: "Point"
                            coordinates: [user.current_long, user.current_lat]
                            $maxDistance: 2000



Meteor.publish 'agg_emotions', (
    # group
    picked_tags
    dummy
    # picked_time_tags
    # selected_location_tags
    # selected_people_tags
    # picked_max_emotion
    # picked_timestamp_tags
    )->
    # @unblock()
    self = @
    match = {
        model:'post'
        # group:group
        joy_percent:$exists:true
    }
        
    doc_count = Docs.find(match).count()
    if picked_tags.length > 0 then match.tags = $all:picked_tags
    # if picked_max_emotion.length > 0 then match.max_emotion_name = $all:picked_max_emotion
    # if picked_time_tags.length > 0 then match.time_tags = $all:picked_time_tags
    # if selected_location_tags.length > 0 then match.location_tags = $all:selected_location_tags
    # if selected_people_tags.length > 0 then match.people_tags = $all:selected_people_tags
    # if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all:picked_timestamp_tags
    
    emotion_avgs = Docs.aggregate [
        { $match: match }
        #     # avgAmount: { $avg: { $multiply: [ "$price", "$quantity" ] } },
        { $group: 
            _id:null
            avg_sent_score: { $avg: "$doc_sentiment_score" }
            avg_joy_score: { $avg: "$joy_percent" }
            avg_anger_score: { $avg: "$anger_percent" }
            avg_sadness_score: { $avg: "$sadness_percent" }
            avg_disgust_score: { $avg: "$disgust_percent" }
            avg_fear_score: { $avg: "$fear_percent" }
        }
    ]
    emotion_avgs.forEach (res, i) ->
        self.added 'results', Random.id(),
            model:'emotion_avg'
            avg_sent_score: res.avg_sent_score
            avg_joy_score: res.avg_joy_score
            avg_anger_score: res.avg_anger_score
            avg_sadness_score: res.avg_sadness_score
            avg_disgust_score: res.avg_disgust_score
            avg_fear_score: res.avg_fear_score
    self.ready()    
        
