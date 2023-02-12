if Meteor.isClient
    Template.historybar.onCreated ->
        @autorun => Meteor.subscribe 'my_history_docs', ->
        @autorun => Meteor.subscribe 'my_history_users', ->
    Template.historybar.helpers 
        history_item_class: ->
            if @valueOf() is Router.current().params.doc_id then 'active' else ''
    Template.historybar.events 
        'click .clear_history_doc': (e)->
            # console.log @
            Meteor.setTimeout =>
                Meteor.users.update Meteor.userId(),
                    $pull: history_ids:@valueOf()
            , 500
            $(e.currentTarget).closest('.item').transition('zoom', 500)

if Meteor.isServer 
    Meteor.publish 'my_history_docs', ->
        if Meteor.user().history_ids
            Docs.find
                _id:$in:Meteor.user().history_ids
    Meteor.publish 'my_history_users', ->
        if Meteor.user().history_ids
            Meteor.users.find 
                _id:$in:Meteor.user().history_ids
if Meteor.isClient 
    Template.nav.onCreated ->
        @autorun => Meteor.subscribe 'me', ->
        @autorun => Meteor.subscribe 'all_users', ->
        @autorun => Meteor.subscribe 'my_drafts', ->
        @autorun => Meteor.subscribe 'my_current_doc', ->
        
    Template.nav_search.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'model', ->
        @autorun => Meteor.subscribe 'doc_search_results', Session.get('current_query'), ->
        @autorun => Meteor.subscribe 'user_search_results', Session.get('current_query'), ->
        # @autorun => Meteor.subscribe 'my_cart_products'
    
if Meteor.isServer
    Meteor.publish 'my_drafts', ()->
        Docs.find 
            _author_id:Meteor.userId()
            published:false
    
    Meteor.publish 'my_current_doc', ()->
        if Meteor.user() and Meteor.user()._doc_id
            Docs.find Meteor.user()._doc_id
    Meteor.publish 'doc_search_results', (query)->
        match = {model:$nin:['reddit','recipe']}
        if query and query.length > 2
            match.title =  {$regex:"#{query}", $options: 'i'}
            Docs.find match,{ 
                limit:3
                sort:points:-1
            }
    Meteor.publish 'user_search_results', (query)->
        match = {}
        if query and query.length > 2
            match.username =  {$regex:"#{query}", $options: 'i'}
            Meteor.users.find match, 
                limit:3
if Meteor.isClient
    Template.add_doc.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
    Template.add_doc.events 
        'click .save_doc': ->
            # console.log @
            Router.go "/d/#{@model}/#{@_id}"
            # current_doc = 
            #     Docs.findOne Meteor.user()._doc_id
            # if current_doc
            Meteor.users.update Meteor.userId(), 
                $set:
                    _doc_id:null
                    editing:false
    Template.nav.onRendered ->
        Session.setDefault('darkmode', false)
        Meteor.setTimeout ->
            $('.menu .item')
                .popup()
            # $('.ui.left.sidebar')
            #     .sidebar({
            #         context: $('.bottom.segment')
            #         transition:'push'
            #         mobileTransition:'push'
            #         exclusive:true
            #         duration:200
            #         scrollLock:true
            #     })
            #     .sidebar('attach events', '.toggle_leftbar')
        , 3000
        # Meteor.setTimeout ->
        #     $('.ui.chatbar')
        #         .sidebar({
        #             context: $('.pushable')
        #             transition:'push'
        #             mobileTransition:'push'
        #             exclusive:true
        #             duration:200
        #             dimPage:false
        #             scrollLock:true
        #         })
        #         .sidebar('attach events', '.toggle_chatbar')
        # , 3000
        # Meteor.setTimeout ->
        #     $('.ui.sidebar')
        #         .sidebar({
        #             context: $('.maincontent')
        #             transition:'push'
        #             mobileTransition:'push'
        #             exclusive:true
        #             duration:100
        #             dimPage:false
        #             scrollLock:true
        #         })
        #         .sidebar('attach events', '.toggle_addmode')
        # , 2000
        
        
    Template.layout.events
        'click .goto_doc': ->
            doc = Docs.findOne @_id 
            console.log @
            if doc 
                # console.log @
                Router.go "/d/#{@model}/#{@_id}"
            else 
                Router.go "/user/#{@username}"
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    history_ids:@_id
            $('.search_site').val('')
            Session.set('current_query', null)
    Template.historybar.events
        'click .goto_doc': ->
            doc = Docs.findOne @_id 
            console.log @
            if doc 
                # console.log @
                Router.go "/d/#{@model}/#{@_id}"
            else 
                Router.go "/user/#{@username}"
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    history_ids:@_id
            $('.search_site').val('')
            Session.set('current_query', null)
    Template.nav.events
        'click .add_doc': ->
            new_id = 
                Docs.insert 
                    model:'post'
                    published:false
            # Router.go "/add/#{new_id}"
            Meteor.users.update Meteor.userId(),
                $set:
                    editing:true
                    _doc_id:new_id
        'click .toggle_online': ->
            if Meteor.user().online
                Meteor.users.update Meteor.userId(),
                    $set:   
                        online:false
                        last_online_timestamp:Date.now()
                $('body').toast(
                    showIcon: 'eye'
                    message: 'online'
                    # showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                    position: "bottom right"
                )
                        
            else 
                Meteor.users.update Meteor.userId(),
                    $set:
                        online:true
                        last_offline_timestamp:Date.now()
                $('body').toast(
                    showIcon: 'eye slash'
                    message: 'offline'
                    # showProgress: 'bottom'
                    class: 'info'
                    displayTime: 'auto',
                    position: "bottom right"
                )
        
        'click .goto_doc': ->
            doc = Docs.findOne @_id 
            console.log @
            if doc 
                # console.log @
                Router.go "/d/#{@model}/#{@_id}"
            else 
                Router.go "/user/#{@username}"
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    history_ids:@_id
            $('.search_site').val('')
            Session.set('current_query', null)
        'click .goto_user': ->
            console.log @
            Router.go "/user/#{@username}"
            $('.search_site').val('')
            Session.set('current_query', null)
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    history_ids:@_id
    Template.nav_search.events
        'click .clear_search': -> Session.set('current_query',null)
        'keyup .search_site': _.throttle((e,t)->
            
            # console.log Router.current().route.getName()
            # current_name = Router.current().route.getName()
            $(e.currentTarget).closest('.input').transition('pulse', 200)

            # unless current_name is 'shop'
            #     Router.go '/shop'
            
            search = $('.search_site').val().trim().toLowerCase()
            
            # query = $('.search_site').val()
            if search.length > 2
                Session.set('current_query', search)
            # console.log Session.get('current_query')
            if e.key == "Escape"
                Session.set('current_query', null)
                $('.search_site').val('')
            # e.which is keycode and 13 is 'enter'
            if e.which is 13
                console.log e 
                console.log t
                if search.length > 0
                    match = {}
                    match.title =  {$regex:search, $options: 'i'}
                    found_results = Docs.find(match).count()
                    if found_results is 1
                        found_result = Docs.findOne match 
                        console.log found_result
                        Meteor.users.update Meteor.userId(),
                            $addToSet:
                                history_ids:found_result._id
                        Router.go "/d/#{found_result.model}/#{found_result._id}"
                    else 
                        picked_tags.push search
                        Meteor.call 'call_icon', search, ->
                        console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('.search_site').val('')
                    Session.set('current_query', null)
                    
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 500)
    
    Template.nav.events
        'click .reset': ->
            # model_slug =  Router.current().params.model_slug
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, true, ->
                Session.set 'loading', false
    
        'click .alerts': ->
            Session.set('viewing_alerts', !Session.get('viewing_alerts'))
            
        'click .toggle_admin_mode': ->
            if Meteor.user().admin_mode
                Meteor.users.update Meteor.userId(),
                    $set:admin_mode:false
            else 
                Meteor.users.update Meteor.userId(),
                    $set:admin_mode:true
            # if 'admin' in Meteor.user().roles
            #     Meteor.users.update Meteor.userId(),
            #         $pull:'roles':'admin'
            # else
            #     Meteor.users.update Meteor.userId(),
            #         $addToSet:'roles':'admin'
        'click .toggle_dev': ->
            if 'dev' in Meteor.user().roles
                Meteor.users.update Meteor.userId(),
                    $pull:'roles':'dev'
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet:'roles':'dev'
        'click .view_profile': ->
            Meteor.call 'calc_user_points', Meteor.userId(), ->
            
        'click .clear_tags': -> picked_tags.clear()
    
        'click .toggle_chatbar': ->
            Meteor.users.update Meteor.userId(),
                $set:
                    view_chatbar:!Meteor.user().view_chatbar
        'click .toggle_invert': (e,t)->
            element = document.body;
            element.classList.toggle("dark-mode");

            $('.grid').transition('pulse', 500)


            Meteor.users.update Meteor.userId(),
                $set:
                    darkmode:!Meteor.user().darkmode
            Session.set('darkmode', !Session.get('darkmode'))
            console.log Session.get('darkmode')
        
    Template.nav_search.helpers
        doc_search_results: ->
            if Session.get('current_query') and Session.get('current_query').length > 2
                match = {}
                match.title =  {$regex:"#{Session.get('current_query')}", $options: 'i'}
                Docs.find match, 
                    limit:5
        user_search_results: ->
            if Session.get('current_query') and Session.get('current_query').length > 2
                match = {}
                match.username =  {$regex:"#{Session.get('current_query')}", $options: 'i'}
                Meteor.users.find match, 
                    limit:5
        current_site_search: -> Session.get('current_query')

    Template.nav.helpers
        picked_tags:-> picked_tags.array()
        model_docs: ->
            Docs.find 
                model:'model'
        unread_count: ->
            unread_count = Docs.find({
                model:'message'
                # to_username:Meteor.user().username
                read_by_ids:$nin:[Meteor.userId()]
            }).count()

        cart_amount: ->
            cart_amount = Docs.find({
                model:'cart_item'
                status:'cart'
                _author_id:Meteor.userId()
            }).count()
        cart_items: ->
            # co = 
            #     Docs.findOne 
            #         model:'order'
            #         status:'cart'
            #         _author_id:Meteor.userId()
            # if co 
            Docs.find 
                model:'cart_item'
                _author_id: Meteor.userId()
                # order_id:co._id
                # status:'cart'
                
        admin_mode_class: ->
            if Meteor.user().admin_mode then 'blue active' else 'grey'
        alert_toggle_class: ->
            if Session.get('viewing_alerts') then 'active' else ''
        unread_count: ->
            Docs.find( 
                model:'message'
                recipient_id:Meteor.userId()
                read_ids:$nin:[Meteor.userId()]
            ).count()

if Meteor.isServer
    Meteor.publish 'models', ->
        Docs.find 
            model:'model'
    Meteor.publish 'my_cart', ->
        Docs.find 
            model:'cart_item'
