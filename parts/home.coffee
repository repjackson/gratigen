if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'
    Router.route '/add', (->
        @layout 'layout'
        @render 'add'
        ), name:'add'
    
    
    Template.home.onCreated ->
        # @autorun => @subscribe 'my_current_thing', ->
        @autorun => @subscribe 'my_current_thing', Session.get('current_thing_id'),->
if Meteor.isServer
    Meteor.publish 'my_current_thing', (current_thing_id)->
        # user = Meteor.user()
        Docs.find current_thing_id
if Meteor.isClient
    Template.home.helpers
        view_template: -> "#{@model}_view"
        edit_template: -> "#{@model}_edit"
        current_viewing_thing: ->
            Docs.findOne Session.get('current_thing_id')
    Template.add_tab.events 
        # 'click .toggle_addmode': ->
        #     Session.set('addmode', !Session.get('addmode'))
    Template.home.events 
        'click .toggle_editmode':->
            Session.set('editmode', !Session.get('editmode'))
            console.log Session.get('editmode')
        'click .show_modal': (e,t)->
            Session.set('current_thing_id', @_id)
            console.log @
            # $(e.currentTarget).closest('.ui.modal').modal({
            $('.ui.modal').modal({
                inverted:true
                # blurring:true
                }).modal('show')
    Template.thing_maker.events 
        'click .show_modal': ->
            $('.ui.modal').modal({
                inverted:true
                }).modal('show')
            unless Session.get('current_thing_id')
                # unless Meteor.user().current_thing_id
                new_id = 
                    Docs.insert 
                        thing:true
                # Session.set('editing_thing_id')
                Session.set('current_thing_id', new_id)
                # Meteor.users.update Meteor.userId(),
                #     $set:
                #         current_thing_id: new_id
                
        'click .delete_thing':->
            if confirm 'delete?'
                Docs.remove @_id
                Session.set('current_thing_id', null)
                Meteor.users.update Meteor.userId(),
                    $unset:current_thing_id:1
        'click .add_thing':->
            new_id = 
                Docs.insert 
                    thing:true
            Meteor.users.update Meteor.userId(),
                $set:
                    current_thing_id: new_id
    Template.thing_maker.helpers 
        current_thing:->
            # user = Meteor.user()
            # Docs.findOne user.current_thing_id
            Docs.findOne Session.get('current_thing_id')
    Template.thing_picker.helpers
        model_picker_class:->
            
            current_doc = Docs.findOne Meteor.user()._doc_id
            if current_doc and @model is current_doc.model
                'big'
            else 
                'basic'
            # if @model is Template.parentData().model
            # parent = Template.parentData()
            # if parent and parent.model
    Template.add.onCreated ->
        @autorun => Meteor.subscribe 'user_current_doc', ->
if Meteor.isServer 
    Meteor.publish 'user_current_doc', ->
        Docs.find 
            _id: Meteor.user()._doc_id
if Meteor.isClient
    Template.add.helpers 
        current_doc: ->
            Docs.findOne Meteor.user()._doc_id, 
        model_edit_template: ->
            "#{@model}_edit"
        
    Template.thing_picker.events
        'click .pick_thing':->
            if Meteor.user()._doc_id
                edit_post = Docs.findOne Meteor.user()._doc_id
                Docs.update edit_post._id, 
                    $set:
                        model:@model
            else 
                new_id = 
                    Docs.insert 
                        model:@model 
                Meteor.users.update Meteor.userId(), 
                    $set:
                        _doc_id:new_id
            
            Session.set('current_thing_id', new_id)      
            Session.set('editmode',true)
            # $('.ui.modal').modal({
            #     inverted:true
            #     }).modal('show')

            # Docs.update Template.parentData()._id,
            #     $set:
            #         model:@model
    
    Template.side_menu_item.events
        'click .toggle_item': ->
            console.log @label 
            console.log Meteor.user().active_side_menu_items
            if Meteor.user().active_side_menu_items
                if @label in Meteor.user().active_side_menu_items
                    Meteor.users.update Meteor.userId(),
                        $pull:active_side_menu_items:@label
                else 
                    Meteor.users.update Meteor.userId(),
                        $addToSet:active_side_menu_items:@label
            else 
                Meteor.users.update Meteor.userId(),
                    $addToSet:active_side_menu_items:@label
    Template.side_menu_item.helpers
        is_toggled: ->
            @label in Meteor.user().active_side_menu_items
        side_item_class: ->
            if Meteor.user().active_side_menu_items and @label in Meteor.user().active_side_menu_items
                'inverted active zoomed'
            else 
                'small'
                
        
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
    
    Template.home_card.onDestroyed ->
        # console.log 'destroy', @data
        found = Markers.findOne
            lat:@data.lat
        if found
            Markers.remove found._id
    Template.calendar_view.onRendered ->
        $('#inline_calendar')
          .calendar()
        ;

    Template.home_card.onRendered ->
        # console.log @data
        if @data.lat and @data.lng
            Markers.insert 
                title:@data.title
                lat:@data.lat
                lng:@data.lng
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
                    title:@title
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
        left_column_class: ->
            if Session.get('expand_leftbar')
                'four wide center aligned column'
            else 
                'two wide center aligned column'
                
                
        main_column_class: ->
            if Session.get('show_map') or Session.get('show_calendar')
                'eight wide column'
            else 
                'twelve wide column'
        right_column_class: ->
            if Session.get('show_map') or Session.get('show_calendar')
                'four wide column'
            else 
                'no_show'
                
        doc_results: ->
            # Docs.find {model:$ne:'comment'},
            Docs.find {},
                sort:_timestamp:-1
                
    Template.home.onRendered ->
        categoryContent = [
            { category:'eft', title:'food', color:"FF73EA", icon:'food' }
            { category:'eft', title:'housing', color:"B785E1", icon:'home' }
            { category:'eft', title:'clothing', color:"7229AF", icon:'tshirt' }
            { category:'eft', title:'transportation', color:"1255B8", icon:'car' }
            { category:'eft', title:'energy', color:"83DFF4", icon:'lightning' }
            { category:'eft', title:'zero waste', color:"42E8C4", icon:'leaf' }
            { category:'eft', title:'wellness', color:"40C057", icon:'smile' }
            { category:'eft', title:'education', color:"FAB005", icon:'university' }
            { category:'eft', title:'art', color:"FD7E14", icon:'paint brush' }
            { category:'eft', title:'community core', color:"FF0000", icon:'users' }
            { category:'model', title:'org' }
            { category:'model', title:'project' }
            { category:'model', title:'event' }
            { category:'model', title:'role' }
            { category:'model', title:'tasks' }
            { category:'model', title:'resource' }
            { category:'model', title:'post' }
            { category:'model', title:'offer' }
            { category:'model', title:'request' }
            { category:'model', title:'skills' }
        ]
        
        $('.ui.search')
          .search({
            type: 'category',
            source: categoryContent
            selectFirstResult:true	            
          })
        $('.tabular.menu .item').tab();
    Template.nav.onRendered ->
        $('.popup').popup();
        $('.tabular.menu .item').tab();


    # Template.closest_allies.helpers 
    #     user_docs: ->
    #         Meteor.users.find {}

