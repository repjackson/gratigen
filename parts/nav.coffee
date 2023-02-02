if Meteor.isClient
    Template.historybar.onCreated ->
        @autorun => Meteor.subscribe 'my_history_docs', ->
        @autorun => Meteor.subscribe 'my_history_users', ->
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
    Meteor.publish 'my_history_docs', ->
        if Meteor.user().history_ids
            Meteor.users.find 
                _id:$in:Meteor.user().history_ids
if Meteor.isClient 
    Template.nav.onCreated ->
        @autorun => Meteor.subscribe 'me', ->
        # @autorun => Meteor.subscribe 'all_users', ->
        
        # @autorun => Meteor.subscribe 'model_docs', 'model', ->
        @autorun => Meteor.subscribe 'doc_search_results', Session.get('current_query'), ->
        @autorun => Meteor.subscribe 'user_search_results', Session.get('current_query'), ->
        # @autorun => Meteor.subscribe 'my_cart_products'
    
if Meteor.isServer
    Meteor.publish 'doc_search_results', (query)->
        match = {model:$nin:['reddit','recipe']}
        if query and query.length > 2
            match.title =  {$regex:"#{query}", $options: 'i'}
            Docs.find match,{ 
                limit:5
                sort:points:-1
            }
    Meteor.publish 'user_search_results', (query)->
        match = {}
        if query and query.length > 2
            match.username =  {$regex:"#{query}", $options: 'i'}
            Meteorusers.find match, 
                limit:10
if Meteor.isClient
    Template.add.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
    Template.add.events 
        'click .save_doc': ->
            # current_doc = 
            #     Docs.findOne Meteor.user()._doc_id
            # if current_doc
            Meteor.users.update Meteor.userId(), 
                $set:_doc_id:null
    Template.nav.onRendered ->
        Session.setDefault('invert_mode', false)
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
        
        
    Template.historybar.events
        'click .goto_doc': ->
            doc = Docs.findOne @_id 
            console.log @
            if doc 
                # console.log @
                Router.go "/#{@model}/#{@_id}"
            else 
                Router.go "/user/#{@username}"
            Meteor.users.update Meteor.userId(),
                $addToSet:
                    history_ids:@_id
            $('.search_site').val('')
            Session.set('current_query', null)
    Template.nav.events
        'click .goto_doc': ->
            doc = Docs.findOne @_id 
            console.log @
            if doc 
                # console.log @
                Router.go "/#{@model}/#{@_id}"
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
    Template.nav.events
        'click .reset': ->
            # model_slug =  Router.current().params.model_slug
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, true, ->
                Session.set 'loading', false
    
        'click .clear_search': -> Session.set('current_query',null)
        'keyup .search_site': _.throttle((e,t)->
            # console.log Router.current().route.getName()
            # current_name = Router.current().route.getName()
            $(e.currentTarget).closest('.input').transition('pulse', 100)

            # unless current_name is 'shop'
            #     Router.go '/shop'
            
            
            query = $('.search_site').val()
            if query.length > 2
                Session.set('current_query', query)
            # console.log Session.get('current_query')
            if e.key == "Escape"
                Session.set('current_query', null)
                $('.search_site').val('')
                
            if e.which is 13
                search = $('.search_site').val().trim().toLowerCase()
                if search.length > 0
                    match = {}
                    match.title =  {$regex:"#{Session.get('current_query')}", $options: 'i'}
                    found_results = Docs.find(match).count()
                    if found_results is 1
                        found_result = Docs.findOne match 
                        console.log found_result
                        Router.go "/#{found_result.model}/#{found_result._id}"
                    else 
                        picked_tags.push search
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
    
        'click .toggle_invert': ->
            Meteor.users.update Meteor.userId(),
                $set:
                    invert_mode:!Meteor.user().invert_mode
            Session.set('invert_mode', !Session.get('invert_mode'))
            console.log Session.get('invert_mode')
        
    Template.nav.helpers
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

        picked_tags:-> picked_tags.array()
        model_docs: ->
            Docs.find 
                model:'model'
        current_site_search: -> Session.get('current_query')
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
