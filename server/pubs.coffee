Meteor.publish 'delta', (match)->
    console.log match

Meteor.publish 'latest_docs', ->
    Docs.find {_updated_timestamp:$exists:true},
        sort:
            _updated_timestamp:-1
        limit:10

Meteor.publish 'current_doc', ->
    if Meteor.user()
        d = Docs.findOne Meteor.user().delta_id 
        Docs.find 
            _id:d._doc_id
Meteor.publish 'current_user', ->
    if Meteor.user()
        d = Docs.findOne Meteor.user().delta_id 
        Meteor.users.find 
            _id:d._user_id
Meteor.publish 'current_model', ->
    if Meteor.user()
        d = Docs.findOne Meteor.user().delta_id 
        Docs.find 
            model:'model'
            slug:d._model

Meteor.publish 'all_markers', ->
    Markers.find()
    
Meteor.publish 'coordination_models', ->
    list = ['post', 'offer', 'request', 'org', 'event', 'role', 'task', 'skill', 'resource', 'product', 'service', 'trip']
    Docs.find 
        model:'model'
        slug: $in:list