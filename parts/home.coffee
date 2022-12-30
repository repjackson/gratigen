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
    Template.dash_user_info.events 
        'click .print_me': ->
            console.log Meteor.user()
            alert Meteor.user()
            Meteor.call 'print_me', ->
            Meteor.users.update Meteor.userId(),
                $unset:updated:true
            
if Meteor.isServer
    Meteor.methods 
        print_me: ->
            console.log Meteor.user()
            
    
if Meteor.isClient
    Template.online_users.onCreated ->
        @autorun => @subscribe 'online_users', ->
    Template.online_users.helpers 
        online_user_docs: ->
            Meteor.users.find {online:true}
                
if Meteor.isServer
    Meteor.publish 'online_users', ->
        Meteor.users.find {online:true}
        
    Meteor.publish 'latest_home_docs', (model_filters=[])->
        match = {}
        # user = Meteor.user()
        # console.log Meteor.user().current_model_filters
        # if model 
        #     match.model = model
        # else 
        #     match.model = model:$in:['product','service','project','resource', 'comment','event']
        Docs.find {model:$in: model_filters},
            limit:20
            sort:_timestamp:-1
            
    
if Meteor.isClient
    @model_filters = new ReactiveArray []
    
    Template.home_card.events 
        'click .map_me': ->
            # navigator.geolocation.getCurrentPosition (position) =>
            #     console.log 'navigator position', position
            #     Session.set('current_lat', position.coords.latitude)
            #     Session.set('current_long', position.coords.longitude)
                
            #     console.log 'saving long', position.coords.longitude
            #     console.log 'saving lat', position.coords.latitude
            
            #     pos = Geolocation.currentLocation()
            #     map.setView([Session.get('current_lat'), Session.get('current_long')], 13);
                Markers.insert 
                    lat: "#{@lat}"
                    lng:"#{@lng}"
                
            
    Template.home.onCreated ->
        # @autorun => @subscribe 'post_docs',
        #     picked_tags.array()
        #     Session.get('post_title_filter')
        
        @autorun => @subscribe 'all_markers',->
        @autorun => @subscribe 'latest_home_docs',model_filters.array(),->
        
        @autorun => @subscribe 'all_users', ->
        @autorun => @subscribe 'post_facets',
            picked_tags.array()
            Session.get('post_title_filter')

    
    
    Template.filter_model.helpers
        button_class:->
            if @model in model_filters.array()
                'blue'
            else 
                'small secondary'
            # if Session.equals('current_model_filter',@model) then 'blue large' else 'small'
            # if  @model in Meteor.user().current_model_filters then 'blue big' else 'small basic'
    Template.filter_model.events
        'click .pick_model': ->
            # Session.set('current_model_filter',@model)
            if @model in model_filters.array()
                model_filters.remove @model 
            else 
                model_filters.push @model 
                
            # # if @model in Meteor.user().current_model_filters 
            # if @model in Meteor.user().current_model_filters 
            #     Meteor.users.update Meteor.userId(),
            #         $pull:
            #             current_model_filters:@model
            # else 
            #     Meteor.users.update Meteor.userId(),
            #         $addToSet:
            #             current_model_filters:@model
                
    
    
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

