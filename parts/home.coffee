if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'
    
    
    Template.latest_activity.onCreated ->
        @autorun => @subscribe 'latest_docs', ->
    Template.latest_activity.helpers 
        latest_docs: ->
            Docs.find {_updated_timestamp:$exists:true},
                sort:
                    _updated_timestamp:-1
                
if Meteor.isServer
    Meteor.publish 'latest_docs', ->
        Docs.find {_updated_timestamp:$exists:true},
            sort:
                _updated_timestamp:-1
            limit:10
        
if Meteor.isClient
    Template.online_users.onCreated ->
        @autorun => @subscribe 'online_users', ->
    Template.online_users.helpers 
        online_user_docs: ->
            Meteor.users.find {online:true}
                
if Meteor.isServer
    Meteor.publish 'online_users', ->
        Meteor.users.find {online:true}
        
    
    
if Meteor.isClient
    Template.home.onCreated ->
        # @autorun => @subscribe 'post_docs',
        #     picked_tags.array()
        #     Session.get('post_title_filter')

        # @autorun => @subscribe 'model_docs', 'post', ->
        # @autorun => @subscribe 'model_docs', 'request', ->
        # @autorun => @subscribe 'model_docs', 'offer', ->
        # @autorun => @subscribe 'model_docs', 'rental', ->
        # @autorun => @subscribe 'model_docs', 'product', ->
        # @autorun => @subscribe 'model_docs', 'task', ->
        # @autorun => @subscribe 'model_docs', 'project', ->
        @autorun => @subscribe 'latest_docs', ->
        
        @autorun => @subscribe 'all_users', ->
        @autorun => @subscribe 'post_facets',
            picked_tags.array()
            Session.get('post_title_filter')

    
    Template.home.events 
        'click .check_notifications': ->
            Notification.requestPermission (result) ->
                console.log result

        'click .send_notification': ->
            if Notification.permission is "granted"
                notification = new Notification("Hi there!")


    Template.home.helpers 
        doc_results: ->
            # Docs.find {model:$ne:'comment'},
            Docs.find {},
                sort:_timestamp:-1
    Template.closest_allies.helpers 
        user_docs: ->
            Meteor.users.find {}



if Meteor.isServer 
    Meteor.publish 'latest_docs', ->
        Docs.find {},
            sort:_timestamp:-1
            limit:20