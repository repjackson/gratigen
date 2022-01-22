if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'
    
    
    Template.home.onCreated ->
        @autorun => @subscribe 'post_docs',
            picked_tags.array()
            Session.get('post_title_filter')

        @autorun => @subscribe 'model_docs', 'post', ->
        @autorun => @subscribe 'model_docs', 'request', ->
        @autorun => @subscribe 'model_docs', 'offer', ->
        @autorun => @subscribe 'model_docs', 'rental', ->
        @autorun => @subscribe 'model_docs', 'product', ->
        @autorun => @subscribe 'model_docs', 'task', ->
        @autorun => @subscribe 'model_docs', 'project', ->
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
            Docs.find {},
                sort:_timestamp:-1
        user_docs: ->
            Meteor.users.find {}
