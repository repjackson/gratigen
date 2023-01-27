if Meteor.isClient
    # Template.home.onRendered ->
    #     Meteor.setTimeout ->
    #         $( "#draggable" ).draggable();
    #     ,1000
    Template.home.onCreated ->
        # @autorun => @subscribe 'post_docs',
        #     picked_tags.array()
        #     Session.get('post_title_filter')
        
        # @autorun => @subscribe 'all_markers',->
        
        # @autorun => @subscribe 'latest_home_docs',model_filters.array(),->
        
        # @autorun => @subscribe 'all_users', ->
        # @autorun => @subscribe 'post_facets',
        #     picked_tags.array()
        #     Session.get('post_title_filter')
        
        # @autorun => @subscribe 'my_current_thing', ->
        # @autorun => @subscribe 'model_docs','model',->
        # @autorun => @subscribe 'my_current_thing', Session.get('current_thing_id'),->
        # @autorun => @subscribe 'homepage_models',->
        # @autorun => @subscribe 'model_docs', 'eft',->
        @autorun => @subscribe 'model_docs', 'view_mode',->
        @autorun => @subscribe 'model_docs', 'sort_key',->
if Meteor.isServer
    Meteor.publish 'my_current_thing', (current_thing_id)->
        # user = Meteor.user()
        Docs.find current_thing_id
    # Meteor.publish 'homepage_models', ()->
    #     # user = Meteor.user()
    #     Docs.find 
    #         model:'model'
    #         show_on_homepage:true
if Meteor.isClient
    Template.home.helpers
        homepage_models: ->
            Docs.find 
                model:'model'
                show_on_homepage:true
        model_facet_results: ->
            Results
                model:'model'
                # show_on_homepage:true
        view_template: -> "#{@model}_view"
        edit_template: -> "#{@model}_edit"
        current_viewing_thing: ->
            Docs.findOne Session.get('current_thing_id')
    Template.home.events 
        'click .toggle_editmode':->
            Session.set('editmode', !Session.get('editmode'))
            console.log Session.get('editmode')
        'click .toggle_addmode': ->
            Session.set('addmode', !Session.get('addmode'))
        'click .show_modal': (e,t)->
            Session.set('current_thing_id', @_id)
            console.log @
            # $(e.currentTarget).closest('.ui.modal').modal({
            $('.ui.modal').modal({
                inverted:true
                # blurring:true
                }).modal('show')
    
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
            if @label in Meteor.user().active_side_menu_items
                'inverted active zoomed'
            else 
                'small'
                
        
    # Template.latest_activity.onCreated ->
    #     @autorun => @subscribe 'latest_home_docs', ->
    # Template.latest_activity.helpers 
    #     latest_docs: ->
    #         Docs.find {_updated_timestamp:$exists:true},
    #             sort:
    #                 _updated_timestamp:-1
                
# if Meteor.isServer
#     Meteor.publish 'latest_docs', ->
#         Docs.find {_updated_timestamp:$exists:true},
#             sort:
#                 _updated_timestamp:-1
#             limit:10
        
            
if Meteor.isServer
    Meteor.methods 
        print_me: ->
            console.log Meteor.user()
            
        
if Meteor.isServer
    Meteor.publish 'latest_home_docs', (model_filters=[])->
        match = {}
        # user = Meteor.user()
        # console.log Meteor.user()._model_filters
        # if model 
        #     match.model = model
        # else 
        #     match.model = model:$in:['product','service','project','resource', 'comment','event']
        if Meteor.user()
            if model_filters.length > 0
                Docs.find {model:$in: model_filters},
                    limit:Meteor.user().limit
                    sort:
                        "#{Meteor.user().sort_key}":Meteor.user().sort_direction
                    fields:
                        title:1
                        model:1
                        icon:1
                        icon_color:1
                        image_id:1
            else 
                Docs.find {},{
                    limit:Meteor.user().limit
                    sort:
                        "#{Meteor.user().sort_key}":Meteor.user().sort_direction
                    fields:
                        title:1
                        model:1
                        icon:1
                        icon_color:1
                        image_id:1
                    # fields:
                    #     title:1
                    #     image_id:1
                    #     _author_id:1
                    #     _timestamp:1
                    #     model:1
                    #     _author_username:1
                    #     icon:1
                    #     icon_color:1
                }
            
    
if Meteor.isClient
    @model_filters = new ReactiveArray []
    
    Template.home_card.onDestroyed ->
        # console.log 'destroy', @data
        if @data and @data.lat
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
        if @data
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
    Template.home_card.helpers 
        model_card_template: -> "#{@model}_card"
        card_template_exists: ->
            # _model = Router.current().params.model_slug
            if @model
                if Template["#{@model}_card"]
                    return true
                else
                    return false

            
    @picked_efts = new ReactiveArray []
    
    
    Template.eft_home_picker.helpers
        eft_button_class:->
            if @title in picked_efts.array()
                'basic'
            else 
                'small seconary'
            # if Session.equals('_model_filter',@model) then 'blue large' else 'small'
            # if  @model in Meteor.user()._model_filters then 'blue big' else 'small basic'
    Template.eft_home_picker.events
        'click .toggle_eft': ->
            # Session.set('_model_filter',@model)
            if @title in picked_efts.array()
                picked_efts.remove @title 
            else 
                picked_efts.push @title 
            console.log picked_efts.array()
    
    
    
    
    Template.filter_model.helpers
        button_class:->
            if @slug in model_filters.array()
                "#{@color_name}"
                # "blue"
            else 
                'small secondary'
            # if Session.equals('_model_filter',@model) then 'blue large' else 'small'
            # if  @model in Meteor.user()._model_filters then 'blue big' else 'small basic'
    Template.filter_model.events
        'click .pick_model': ->
            # Session.set('_model_filter',@model)
            if @slug in model_filters.array()
                model_filters.remove @slug 
            else 
                model_filters.push @slug 
                
            # # if @model in Meteor.user()._model_filters 
            # if @model in Meteor.user()._model_filters 
            #     Meteor.users.update Meteor.userId(),
            #         $pull:
            #             _model_filters:@model
            # else 
            #     Meteor.users.update Meteor.userId(),
            #         $addToSet:
            #             _model_filters:@model
                
    
    
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
            white_list = ['post', 'offer', 'request', 'org', 'event', 'role', 'task', 'skill', 'resource', 'product', 'service', 'trip']
            match = {}
            # picked_models = picked_models.array()
            # d = Docs.findOne Meteor.user().delta_id
            if picked_models.array().length then match.models = $all:picked_models.array() 
            if picked_essentials.array().length > 0 then match.efts = $all: picked_essentials.array()
            if picked_tags.array().length > 0 then match.tags = $all: picked_tags.array()

            # if d 
            #     if d.picked_models and d.picked_models.length
            #         match.model = $in: picked_models.array()
            #     else 
            #         match.model = $in: white_list
            #     if d.picked_tags and d.picked_tags.length
            #         match.tags = $in: d.picked_tags
                
            #     if d.picked_essentials and d.picked_essentials.length
            #         match.efts = $in: d.picked_essentials
            Docs.find match,
                sort:_timestamp:-1
                limit:20
            # else 
            #     Docs.find {model:$in:white_list},
            #         sort:_timestamp:-1
            #         limit:20
            # if model_filters.array().length
            #     Docs.find {model:$in:model_filters.array()},{
            #         limit:Meteor.user().limit
            #         sort:
            #             "#{Meteor.user().sort_key}":Meteor.user().sort_direction
            #     }
            # else 
            #     Docs.find {},
            #         limit:Meteor.user().limit
            #         sort:
            #             "#{Meteor.user().sort_key}":Meteor.user().sort_direction
                    
        
    Template.home.onRendered ->
        # categoryContent = [
        #     { category:'eft', title:'food', color:"FF73EA", icon:'food' }
        #     { category:'eft', title:'housing', color:"B785E1", icon:'home' }
        #     { category:'eft', title:'clothing', color:"7229AF", icon:'tshirt' }
        #     { category:'eft', title:'transportation', color:"1255B8", icon:'car' }
        #     { category:'eft', title:'energy', color:"83DFF4", icon:'lightning' }
        #     { category:'eft', title:'zero waste', color:"42E8C4", icon:'leaf' }
        #     { category:'eft', title:'wellness', color:"40C057", icon:'smile' }
        #     { category:'eft', title:'education', color:"FAB005", icon:'university' }
        #     { category:'eft', title:'art', color:"FD7E14", icon:'paint brush' }
        #     { category:'eft', title:'community core', color:"FF0000", icon:'users' }
        #     { category:'model', title:'org' }
        #     { category:'model', title:'project' }
        #     { category:'model', title:'event' }
        #     { category:'model', title:'role' }
        #     { category:'model', title:'tasks' }
        #     { category:'model', title:'resource' }
        #     { category:'model', title:'post' }
        #     { category:'model', title:'offer' }
        #     { category:'model', title:'request' }
        #     { category:'model', title:'skills' }
        # ]
        
        # $('.ui.search')
        #   .search({
        #     type: 'category',
        #     source: categoryContent
        #     selectFirstResult:true	            
        #   })
        # $('.tabular.menu .item').tab();


    # Template.closest_allies.helpers 
    #     user_docs: ->
    #         Meteor.users.find {}

