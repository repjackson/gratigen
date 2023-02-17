if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'
    
    Template.smaba.events
        # 'keyup .search_site': _.throttle((e,t)->
        'keyup .search_site': (e,t)->
            # console.log Router.current().route.getName()
            # current_name = Router.current().route.getName()
            $(e.currentTarget).closest('.search_site').transition('pulse', 100)

            # unless current_name is 'shop'
            #     Router.go '/shop'
            
            search = t.$('.search_site').val().trim().toLowerCase()
            
            # query = $('.search_site').val()
            if search.length > 2
                Session.set('current_query', search)
                console.log 'searching', search
            # console.log Session.get('current_query')
            if e.key is 8
                if search.length is 0
                    Session.set('current_query', null)
                    
                    
            if e.key is "Escape"
                Session.set('current_query', null)
                $('.search_site').val('')
            # # e.which is keycode and 13 is 'enter'
            # if e.which is 13
            #     console.log e 
            #     console.log t
            #     if search.length > 0
            #         match = {}
            #         match.title =  {$regex:search, $options: 'i'}
            #         found_results = Docs.find(match).count()
            #         if found_results is 1
            #             found_result = Docs.findOne match 
            #             console.log found_result
            #             Meteor.users.update Meteor.userId(),
            #                 $addToSet:
            #                     history_ids:found_result._id
            #             Router.go "/d/#{found_result.model}/#{found_result._id}"
            #         else 
            #             picked_tags.push search
            #             Meteor.call 'call_icon', search, ->
            #             console.log 'search', search
            #         # Meteor.call 'log_term', search, ->
            #         $('.search_site').val('')
            #         Session.set('current_query', null)
                    
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        # , 100)
    
    Template.home.helpers
        view_latest_class: -> 
            if Session.get('view_latest') then 'large active' else 'compact basic'
    Template.home.events
        'click .view_latest': ->
            # trying different view session storage
            current_role = Docs.findOne Meteor.user().current_role_id
            if current_role
                Docs.update current_role._id, 
                    $set: view_latest:true
            if Session.get('view_latest')
                Session.set('view_latest',false)
            else 
                Session.set('view_latest',true)
                
            # Meteor.users.update Meteor.userId(),
            #     $set:view_latest:true
            $('body').toast({
                title: "viewing latest #{Sesssion.get('view_latest')}"
                class : 'success'
                showProgress:'bottom'
                position:'bottom right'
            })
                
        'click .add_doc': ->
            new_id = 
                Docs.insert 
                    model:'post'
                    published:false
            Router.go "/add/#{new_id}"
            Meteor.users.update Meteor.userId(),
                $set:
                    editing:true
                    _doc_id:new_id

    Template.layout.helpers 
        current_image_id:->
            if Router.current().params.doc_id
                doc = Docs.findOne Router.current().params.doc_id
                if doc 
                    if doc.banner_image_id
                        doc.banner_image_id
                    else if doc.image_id
                        doc.image_id
            else if Meteor.user()
                if Meteor.user().banner_image_id
                    Meteor.user().banner_image_id
            else 
                'nightbg'
    # Template.bookmark_block.onCreated ->
    #     @autorun => @subscribe 'my_bookmarks',->
    # Template.latest_updated_block.onCreated ->
    #     @autorun => @subscribe 'latest_updated',->
    # Template.latest_updated_block.helpers
    #     latest_updated_docs: ->
    #         Docs.find {_updated_timestamp:$exists:true}, {
    #             sort:_updated_timestamp:-1
    #             limit:5
    #         }
# if Meteor.isServer
#     Meteor.publish 'my_bookmarks', ()->
#         Docs.find {_id: $in: Meteor.user().bookmarked_ids},{
#             fields:
#                 model:1
#                 title:1
#                 image_id:1
#                 _timestamp:1
#                 _updated_timestamp:1
#         }
# if Meteor.isServer
#     Meteor.publish 'latest_updated', ()->
#         Docs.find {_updated_timestamp:$exists:true},{
#             sort:_updated_timestamp:-1
#             limit:5
#             fields:
#                 model:1
#                 title:1
#                 image_id:1
#                 _timestamp:1
#                 _updated_timestamp:1
#         }
if Meteor.isClient
    Template.model_block.onCreated ->
        @autorun => @subscribe 'model_docs', @data.model, 5,->
    Template.model_block.helpers
        model_block_docs: ->
            Docs.find {
                model:@model
            }, limit:5
if Meteor.isServer
    Meteor.publish 'my_current_thing', (current_thing_id)->
        # user = Meteor.user()
        Docs.find current_thing_id
# if Meteor.isClient
    # Template.quickchat.onCreated ->
    #     @autorun => @subscribe 'model_docs', 'quickchat_message', 10,->
    # Template.quickchat.events
    #     'keyup .add_quickchat': (e,t)->
    #         if e.which is 13
    #             body = t.$('.add_quickchat').val().trim()
    #             if body.length>0
    #                 parent = Template.parentData()
    #                 new_id = 
    #                     Docs.insert 
    #                         model:'quickchat'
    #                         body:body 
    #             $('.add_quickchat').val('')
                    
    #                 # if true

    
if Meteor.isClient
    Template.home.helpers
        is_searching: -> Session.get('current_query')
        # model_filters: -> model_filters.array()
        view_template: -> "#{@model}_view"
        edit_template: -> "#{@model}_edit"
        current_viewing_thing: ->
            Docs.findOne Session.get('current_thing_id')
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
            match = {}
            if Session.get('current_query')
                match.title = {$regex:Session.get('current_query'), $options:'i'}
            # if Meteor.user() and Meteor.user().eft_filter_array and Meteor.user().eft_filter_array.length > 0
            #     match.efts = $in:Meteor.user().eft_filter_array
            # if model_filters.array().length
            if Session.get('model_filter')
                # match.model = $in:model_filters.array()
                match.model = Session.get('model_filter')
            else 
                match.model = $nin:['model','comment','message'] 
            Docs.find match,
                sort:_timestamp:-1
                limit:20
            
    Template.add_tab.events 
        # 'click .toggle_addmode': ->
        #     Session.set('addmode', !Session.get('addmode'))
    Template.home.events 
        'click .unpick_model': -> 
            # model_filters.remove @valueOf()
            Session.set('model_filter',null)
        'click .toggle_editing':->
            Session.set('editing', !Session.get('editing'))
            console.log Session.get('editing')
        'click .show_modal': (e,t)->
            Session.set('current_thing_id', @_id)
            console.log @
            # $(e.currentTarget).closest('.ui.modal').modal({
            $('.ui.modal').modal({
                inverted:true
                # blurring:true
                }).modal('show')
    # Template.thing_maker.events 
    #     'click .show_modal': ->
    #         $('.ui.modal').modal({
    #             inverted:true
    #             }).modal('show')
    #         unless Session.get('current_thing_id')
    #             # unless Meteor.user().current_thing_id
    #             new_id = 
    #                 Docs.insert 
    #                     thing:true
    #             # Session.set('editing_thing_id')
    #             Session.set('current_thing_id', new_id)
    #             # Meteor.users.update Meteor.userId(),
    #             #     $set:
    #             #         current_thing_id: new_id
                
    #     'click .delete_thing':->
    #         if confirm 'delete?'
    #             Docs.remove @_id
    #             Session.set('current_thing_id', null)
    #             Meteor.users.update Meteor.userId(),
    #                 $unset:current_thing_id:1
    #     'click .add_thing':->
    #         new_id = 
    #             Docs.insert 
    #                 thing:true
    #         Meteor.users.update Meteor.userId(),
    #             $set:
    #                 current_thing_id: new_id
    # Template.thing_maker.helpers 
    #     current_thing:->
    #         # user = Meteor.user()
    #         # Docs.findOne user.current_thing_id
    #         Docs.findOne Session.get('current_thing_id')
    Template.thing_picker.helpers
        model_crud_class:->
            current_doc = Docs.findOne Meteor.user()._doc_id
            if current_doc and @model is current_doc.model
                'big'
            else 
                'basic'
            # if @model is Template.parentData().model
            # parent = Template.parentData()
            # if parent and parent.model
    Template.add_doc.onCreated ->
        @autorun => Meteor.subscribe 'user_current_doc', ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            
    Router.route '/add/:doc_id', (->
        @layout 'layout'
        @render 'add_doc'
        ), name:'add_doc'
        
            
if Meteor.isServer 
    Meteor.publish 'user_current_doc', ->
        if Meteor.user()
            Docs.find 
                _id: Meteor.user()._doc_id
if Meteor.isClient
    Template.add_doc.helpers 
        # current_doc: ->
        #     Docs.findOne Meteor.user()._doc_id, 
        model_edit_template: ->
            "#{@model}_view"
        
    Template.thing_picker.events
        'click .pick_thing':->
            doc_id = Router.current().params.doc_id
            if doc_id
                edit_post = Docs.findOne doc_id
                Docs.update doc_id, 
                    $set:
                        model:@model
            # else 
            #     new_id = 
            #         Docs.insert 
            #             model:@model 
            Meteor.users.update Meteor.userId(), 
                $set:
                    editing:true
            
            # Session.set('current_thing_id', new_id)      
            Session.set('editing',true)
            # $('.ui.modal').modal({
            #     inverted:true
            #     }).modal('show')

            # Docs.update Template.parentData()._id,
            #     $set:
            #         model:@model
    
    Template.eft_filter.events
        'click .toggle_item': (e,t)->
            console.log @label 
            console.log Meteor.user().eft_filter_array
            if Meteor.user().eft_filter_array
                if @label in Meteor.user().eft_filter_array
                    Meteor.users.update Meteor.userId(),
                        $pull:eft_filter_array:@label
                else 
                    Meteor.users.update Meteor.userId(),
                        $addToSet:eft_filter_array:@label
            else 
                Meteor.users.update Meteor.userId(),
                    $addToSet:eft_filter_array:@label
            # $(e.currentTarget).closest('.toggle_item').transition('pulse', 500)
    Template.eft_filter.helpers
        is_toggled: ->
            @label in Meteor.user().eft_filter_array
        side_item_class: ->
            if Meteor.user() and Meteor.user().eft_filter_array
                if Meteor.user().eft_filter_array and @label in Meteor.user().eft_filter_array
                    'gactive small' 
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
    Template.online_users.onRendered ->
        Meteor.setTimeout =>
            $('.online_user_item').popup({
                # inline: true
                position:'bottom center'
              })
        , 2000

    Template.online_users.helpers 
        online_user_docs: ->
            Meteor.users.find {online:true}
        latest_users: ->
            Meteor.users.find {},   
            
if Meteor.isServer
    Meteor.publish 'online_users', ->
        Meteor.users.find {online:true}, 
            fields:
                username:1
                image_id:1
                tags:1
                first_name:1
                views:1
        
    # Meteor.publish 'latest_home_docs', (model_filters=[])->
    #     match = {}
    #     essentials = ['post','offer','request','org','project','event','role','task','resource','skill']
    #     # user = Meteor.user()
    #     # console.log Meteor.user().model_filters
    #     if model_filters.length > 0
    #         match.model = $in:model_filters
    #     else 
    #         match.model = model:$in:essentials
    #     Docs.find match,
    #         limit:20
    #         sort:_timestamp:-1
    #         fields:
    #             title:1
    #             model:1
    #             image_id:1
    #             views:1
    #             points:1
    #             parent_id:1
    #             efts:1
    #             link:1
    
    
if Meteor.isClient
    # @model_filters = new ReactiveArray []
    
    Template.home_card.onDestroyed ->
        # console.log 'destroy', @data
        if @data
            found = Markers.findOne
                lat:@data.lat
            if found
                Markers.remove found._id
    Template.calendar_view.onRendered ->
        $('#inline_calendar')
          .calendar()

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
                
            
    Template.home.onCreated ->
        # @autorun => @subscribe 'my_current_thing', ->
        @autorun => @subscribe 'my_current_thing', Session.get('current_thing_id'),->
        
        @autorun => @subscribe 'home_docs',
            Session.get('current_query')
            Session.get('model_filter')
            # model_filters.array()
            picked_tags.array()
            Session.get('view_latest')
            # Session.get('post_title_filter')
        
        # @autorun => @subscribe 'all_markers',->
        # @autorun => @subscribe 'latest_home_docs',model_filters.array(),->
        
        @autorun => @subscribe 'all_users', ->
        @autorun => @subscribe 'post_facets',
            picked_tags.array()
            Session.get('post_title_filter')

if Meteor.isServer
    Meteor.publish 'home_docs', (
        search=null
        model_filter=null
        view_latest=false
        )->
        match = {}
        essentials = ['post','offer','request','org','project','event','role','task','resource','skill']
        # user = Meteor.user()
        # console.log Meteor.user().model_filters
        if search 
            match.title = {$regex:search, $options:'i'}  
        # if model_filters.length > 0
        #     match.model = $in:model_filters
        sort_key = "_timestamp"
        # sort_key = "_timestamp"
        sort_direction = -1
        
        if view_latest
            sort_key = '_timestamp'
            sort_direction = -1
        if model_filter
            match.model = model_filter
        else 
            match.model = model:$in:essentials
        console.log 'home match', match, model_filter
        result_count = Docs.find(match).count()
        console.log result_count
        Docs.find match,
            limit:10
            sort:"#{sort_key}":sort_direction
            fields:
                title:1
                model:1
                body:1
                image_id:1
                views:1
                points:1
                link:1
                parent_id:1
                efts:1
                _author_id:1
                _timestamp:1
    
    # Meteor.publish 'post_docs', (
    #     model_filters=[]
    #     # title_filter
    #     # picked_authors=[]
    #     # picked_tasks=[]
    #     # picked_locations=[]
    #     # picked_timestamp_tags=[]
    #     # product_query
    #     # view_vegan
    #     # view_gf
    #     # doc_limit
    #     # doc_sort_key
    #     # doc_sort_direction
    #     )->
    
    #     self = @
    #     match = {}
    #     # match = {app:'pes'}
    #     # match.model = 'post'
    #     # match.group_id = Meteor.user().current_group_id
    #     # if title_filter and title_filter.length > 1
    #     #     match.title = {$regex:title_filter, $options:'i'}
        
    #     # if view_vegan
    #     #     match.vegan = true
    #     # if view_gf
    #     #     match.gluten_free = true
    #     # if view_local
    #     #     match.local = true
    #     # if picked_authors.length > 0 then match._author_username = $in:picked_authors
    #     if model_filters.length > 0 then match.model = $all:model_filters 
    #     # if picked_locations.length > 0 then match.location_title = $in:picked_locations 
    #     # if picked_timestamp_tags.length > 0 then match._timestamp_tags = $in:picked_timestamp_tags 
    #     console.log match
    #     Docs.find match, 
    #         limit:10
    #         sort:
    #             _timestamp:-1
    #         fields:
    #             title:1
    #             model:1
    #             image_id:1
    #             tags:1
    #             _timestamp:1
    #             _author_id:1
    #             _author_username:1
    #             body:1
    #             points:1
    #             views:1
    #             parent_id:1
    #             efts:1
    
if Meteor.isClient    
    Template.filter_model.helpers
        button_class:->
            if @model is Session.get('model_filter')
                'large active'
            else 
                'small secondary basic'
            # if @model in model_filters.array()
            #     'gactive'
            # else 
            #     'small secondary'
            # if Session.equals('model_filter',@model) then 'blue large' else 'small'
            # if  @model in Meteor.user().model_filters then 'blue big' else 'small basic'
    Template.filter_model.events
        'click .pick_model': ->
            Session.set('model_filter',@model)
            
            # if @model in model_filters.array()
            #     model_filters.remove @model 
            # else 
            #     model_filters.push @model 
                
            # # if @model in Meteor.user().model_filters 
            # if @model in Meteor.user().model_filters 
            #     Meteor.users.update Meteor.userId(),
            #         $pull:
            #             model_filters:@model
            # else 
            #     Meteor.users.update Meteor.userId(),
            #         $addToSet:
            #             model_filters:@model
                
    
    
    Template.alerts.events 
        'click .check_notifications': ->
            Notification.requestPermission (result) ->
                console.log result

        'click .send_notification': ->
            if Notification.permission is "granted"
                notification = new Notification("Hi there!")


                
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
        $('.dropdown').dropdown({
            inline: true
          })
        # $('.ui.search')
        #   .search({
        #     type: 'category',
        #     source: categoryContent
        #     selectFirstResult:true	            
        #   })
        # $('.tabular.menu .item').tab();
    Template.nav.onRendered ->
        $('.menu .item').popup();
        # $('.tabular.menu .item').tab();


    # Template.closest_allies.helpers 
    #     user_docs: ->
    #         Meteor.users.find {}

