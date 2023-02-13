Meteor.publish 'user_by_id',(user_id)->
    if user_id
        Meteor.users.find {_id:user_id},{
            fields:
                username:1
                image_id:1
                first_name:1
                last_name:1
                tags:1
        }
Meteor.publish 'icons', ->
    Docs.find {
        model:'icon'
    },{
        limit:10
        sort:_timestamp:-1
    }
Meteor.publish 'latest_docs', ->
    Docs.find {_updated_timestamp:$exists:true},
        sort:
            _updated_timestamp:-1
        limit:10

Meteor.publish 'all_markers', ->
    Markers.find()