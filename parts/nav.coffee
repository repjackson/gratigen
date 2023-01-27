if Meteor.isClient
    Template.nav.onCreated ->
        @autorun => Meteor.subscribe 'me', ->
        @autorun => Meteor.subscribe 'current_user', ->
        @autorun => Meteor.subscribe 'current_delta', ->
        @autorun => Meteor.subscribe 'current_model', ->
        @autorun => Meteor.subscribe 'current_doc', ->
        @autorun => Meteor.subscribe 'users_min', ->
        # @autorun => Meteor.subscribe 'model_docs', 'model', ->
        @autorun => Meteor.subscribe 'coordination_models', ->
        @autorun => Meteor.subscribe 'history',->
        @autorun => Meteor.subscribe 'model_docs','delta',->
        
        # @autorun => Meteor.subscribe 'my_cart'
        # @autorun => Meteor.subscribe 'my_cart_order'
        # @autorun => Meteor.subscribe 'my_cart_products'

    # Template.leftbar_item.events
    #     'click .click_item': ->
    #         console.log @
    #         Meteor.call 'change_state', {_template:'delta',_model:@slug}, ->
    # Template.model.events
    #     'click .click_item': ->
    #         Meteor.call 'change_state', {_template:'delta',_model:@slug}, ->

    Template.nav.onRendered ->
        $('.item').popup({
            inline: true
            forcePosition:true
            preserve:true
            hoverable:true
            closable:false
            on:'click'
          })

        Session.setDefault('invert_mode', true)
    # Template.secnav.events
    #     'click .goto_model': ->
    #         console.log @
    #         Session.set 'loading', true
    #         Meteor.call 'change_state', { _template:'delta', _model:@slug }, ->
    #             Meteor.call 'set_facets', @slug, true, ->
    #                 Session.set 'loading', false

        # Meteor.setTimeout ->
        #     $('.ui.dropdown').dropdown()
        # , 2000
    # Template.nav.onRendered ->
    #     Meteor.setTimeout ->
    #         $('.menu .item')
    #             .popup()
    #         $('.ui.leftbar')
    #             .sidebar({
    #                 context: $('.layout')
    #                 transition:'push'
    #                 mobileTransition:'push'
    #                 exclusive:false
    #                 duration:200
    #                 closable:false
    #                 dimPage:false
    #                 scrollLock:true
    #             })
    #             .sidebar('attach events', '.toggle_leftbar')
    #         $('.ui.taskbar')
    #             .sidebar({
    #                 context: $('.layout')
    #                 transition:'push'
    #                 mobileTransition:'push'
    #                 exclusive:false
    #                 closable:false
    #                 dimPage:false
    #                 duration:200
    #                 scrollLock:true
    #             })
    #             .sidebar('attach events', '.toggle_taskbar')
    #     , 2000
    #     Meteor.setTimeout ->
    #         $('.ui.rightbar')
    #             .sidebar({
    #                 context: $('.layout')
    #                 transition:'push'
    #                 mobileTransition:'push'
    #                 exclusive:true
    #                 closable:false
    #                 dimPage:false
    #                 duration:200
    #                 scrollLock:true
    #             })
    #             .sidebar('attach events', '.toggle_rightbar')
    #     , 2000
    #     Meteor.setTimeout ->
    #         $('.ui.modelbar')
    #             .sidebar({
    #                 context: $('.layout')
    #                 transition:'push'
    #                 mobileTransition:'push'
    #                 exclusive:false
    #                 dimPage:false
    #                 duration:200
    #                 scrollLock:true
    #             })
    #             .sidebar('attach events', '.toggle_modelbar')
    #     , 2000
    #     Meteor.setTimeout ->
    #         $('.ui.topbar')
    #             .sidebar({
    #                 context: $('.layout')
    #                 transition:'push'
    #                 mobileTransition:'push'
    #                 exclusive:true
    #                 duration:200
    #                 scrollLock:true
    #             })
    #             .sidebar('attach events', '.toggle_topbar')
    #     , 2000
        
        
    Template.nav_item.events
        'click .nav_item': ->
            Session.set 'loading', true
            Meteor.call 'change_state', { _template:@template, _model:@slug }, ->
                Meteor.call 'set_facets', @slug, true, ->
                    Session.set 'loading', false
                    
                    
    Template.nav.events
        # 'mouseover .item': (e)->
            # $(e.currentTarget).closest('.icon').transition('bounce', 1000)

        'click .goto_add': -> 
            Meteor.call 'change_state', {_template:'add'}, ->
        'click .set_home': -> 
            Meteor.call 'change_state', {_template:'home'}, ->
        'click .reset': ->
            # model_slug =  Template.parentData().model_slug
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, true, ->
                Session.set 'loading', false
    
        'click .clear_search': -> Session.set('product_query',null)
        'keyup .global_search': _.throttle((e,t)->
            if e.which is 13
                # console.log Router.current().route.getName()
                # current_name = Router.current().route.getName()
                # $(e.currentTarget).closest('.input').transition('pulse', 100)
    
                # unless current_name is 'shop'
                #     gstate_set '/shop'
                # query = $('.search_site').val()
                # Session.set('product_query', query)
                # console.log Session.get('product_query')
                # if e.key == "Escape"
                #     Session.set('product_query', null)
                    
                # if e.which is 13
                search = $('.global_search').val().trim().toLowerCase()
                if search.length > 0
                    Meteor.call 'change_state', {_template:'search', _search:search}
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('.global_search').val('')
                    Session.set('product_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 500)
        'click .popout_chat': ->
            $('.ui.chat.flyout').flyout('toggle')

        'click .alerts': ->
            Session.set('viewing_alerts', !Session.get('viewing_alerts'))
            
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
        
        # 'click .toggle_leftbar': ->
        #     console.log Meteor.user().show_leftbar
        #     Meteor.users.update Meteor.userId(),
        #         $set:
        #             show_leftbar:!Meteor.user().show_leftbar
        # 'click .toggle_modelbar': (e,t)->
        #     # $('.item').transition('bounce', 1000)
        #     $('.cubes').transition('jiggle', 1000)
        #     # $(e.currentTarget).closest('.item').transition('bounce', 1000)
        #     # $(e.currentTarget).closest('.cubes').transition('jiggle', 1000)
        #     console.log Meteor.user().modelbar
        #     if Meteor.user().modelbar
        #         # $('.modelbar').transition('swing right', 1000)
        #         Meteor.setTimeout ->
        #             Meteor.users.update Meteor.userId(),
        #                 $set:
        #                     modelbar:false
        #         , 1000
        #     else 
        #         Meteor.users.update Meteor.userId(),
        #             $set:
        #                 modelbar:true
        # 'click .toggle_rightbar': ->
        #     console.log Meteor.user().show_rightbar
        #     Meteor.users.update Meteor.userId(),
        #         $set:
        #             show_rightbar:!Meteor.user().show_rightbar
            # Session.set('invert_mode', !Session.get('invert_mode'))
            # console.log Session.get('invert_mode')
    Template.toggle_nav_item.events 
        'click .toggle': ->
            # d = Docs.findOne 
            if Meteor.user()["#{@key}"]
                Meteor.users.update Meteor.userId(),
                    $set:"#{@key}":false
            else 
                Meteor.users.update Meteor.userId(),
                    $set:"#{@key}":true
    Template.toggle_nav_item.helpers 
        toggle_item_class: ->
            if Meteor.user() and Meteor.user()["#{@key}"]
                'active yellow'
            else 
                'grey'
        toggle_item_icon_class: ->
            if Meteor.user() and Meteor.user()["#{@key}"]
                "#{@icon} large"
            else 
                "#{@icon} grey"

        
    Template.nav.helpers
        modelbar_class: ->
            if Meteor.user() and Meteor.user().modelbar
                'large inverted'
        model_docs: ->
            Docs.find 
                model:'model'
        current_site_search: -> Session.get('product_query')
        unread_count: ->
            unread_count = Docs.find({
                model:'message'
                to_username:Meteor.user().username
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
                
        alert_toggle_class: ->
            if Session.get('viewing_alerts') then 'active' else ''
        unread_count: ->
            Docs.find( 
                model:'message'
                recipient_id:Meteor.userId()
                read_ids:$nin:[Meteor.userId()]
            ).count()

if Meteor.isServer
    Meteor.publish 'users_min', ->
        Meteor.users.find {}, 
            fields:
                username:1
                delta_id:1
                image_id:1
                tags:1
                roles:1
                
    Meteor.publish 'history', ->
        if Meteor.user()
            Docs.find 
                _id: $in: Meteor.user().doc_history
    Meteor.publish 'models', ->
        Docs.find 
            model:'model'
    Meteor.publish 'my_cart', ->
        Docs.find 
            model:'cart_item'
