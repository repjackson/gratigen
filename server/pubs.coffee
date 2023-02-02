Meteor.publish 'user_by_id',(user_id)->
    if user_id
        Meteor.users.find user_id
Meteor.publish 'latest_docs', ->
    Docs.find {_updated_timestamp:$exists:true},
        sort:
            _updated_timestamp:-1
        limit:10

Meteor.publish 'all_markers', ->
    Markers.find()