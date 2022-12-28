if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'
    
    
    Template.latest_activity.onCreated ->
        @autorun => @subscribe 'latest_home_docs', ->
    Template.latest_activity.helpers 
        latest_docs: ->
            Docs.find {_updated_timestamp:$exists:true},
                sort:
                    _updated_timestamp:-1
                
# if Meteor.isServer
#     Meteor.publish 'latest_docs', ->
#         Docs.find {_updated_timestamp:$exists:true},
#             sort:
#                 _updated_timestamp:-1
#             limit:10
        
if Meteor.isClient
    Template.online_users.onCreated ->
        @autorun => @subscribe 'online_users', ->
    Template.online_users.helpers 
        online_user_docs: ->
            Meteor.users.find {online:true}
                
if Meteor.isServer
    Meteor.publish 'online_users', ->
        Meteor.users.find {online:true}
        
    Meteor.publish 'latest_home_docs', (model)->
        match = {}
        if model 
            match.model = model
        else 
            match.model = model:$in:['product','service','project','resource', 'comment','event']
        Docs.find match,
            limit:20
            sort:_timestamp:-1
            
    
if Meteor.isClient
    Template.home.onCreated ->
        # @autorun => @subscribe 'post_docs',
        #     picked_tags.array()
        #     Session.get('post_title_filter')

        @autorun => @subscribe 'latest_home_docs', Session.get('current_model_filter'),->
        
        @autorun => @subscribe 'all_users', ->
        @autorun => @subscribe 'post_facets',
            picked_tags.array()
            Session.get('post_title_filter')

    Template.filter_model.helpers
        button_class:->
            if Session.equals('current_model_filter',@model) then 'blue large' else 'basic small'
    Template.filter_model.events
        'click .pick_model': ->
            Session.set('current_model_filter',@model)
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

