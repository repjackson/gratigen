Meteor.publish 'latest_docs', ->
    Docs.find {_updated_timestamp:$exists:true},
        sort:
            _updated_timestamp:-1
        limit:10

Meteor.publish 'current_doc', ->
    d = Docs.findOne Meteor.user().delta_id 
    Docs.find 
        _id:d._doc_id
Meteor.publish 'current_model', ->
    d = Docs.findOne Meteor.user().delta_id 
    Docs.find 
        model:'model'
        slug:d._model

Meteor.publish 'all_markers', ->
    Markers.find()