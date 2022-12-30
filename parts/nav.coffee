if Meteor.isClient
    Template.nav.onCreated ->
        @autorun => Meteor.subscribe 'me'
        @autorun => Meteor.subscribe 'all_users'
        
        # @autorun => Meteor.subscribe 'my_cart'
        # @autorun => Meteor.subscribe 'my_cart_order'
        # @autorun => Meteor.subscribe 'my_cart_products'

    Template.nav.onRendered ->
        Session.setDefault('invert_mode', false)
    Template.nav.onRendered ->
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
        #     $('.ui.rightbar')
        #         .sidebar({
        #             context: $('.bottom.segment')
        #             transition:'push'
        #             mobileTransition:'push'
        #             exclusive:true
        #             duration:200
        #             scrollLock:true
        #         })
        #         .sidebar('attach events', '.toggle_rightbar')
        # , 3000
        # Meteor.setTimeout ->
        #     $('.ui.topbar')
        #         .sidebar({
        #             context: $('.bottom.segment')
        #             transition:'push'
        #             mobileTransition:'push'
        #             exclusive:true
        #             duration:200
        #             scrollLock:true
        #         })
        #         .sidebar('attach events', '.toggle_topbar')
        # , 2000
        
        
    Template.nav.events
        'click .reset': ->
            # model_slug =  Router.current().params.model_slug
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, true, ->
                Session.set 'loading', false
    
        'click .clear_search': -> Session.set('product_query',null)
        # 'keyup .search_site': _.throttle((e,t)->
        #     # console.log Router.current().route.getName()
        #     current_name = Router.current().route.getName()
        #     # $(e.currentTarget).closest('.input').transition('pulse', 100)

        #     unless current_name is 'shop'
        #         Router.go '/shop'
        #     query = $('.search_site').val()
        #     Session.set('product_query', query)
        #     # console.log Session.get('product_query')
        #     if e.key == "Escape"
        #         Session.set('product_query', null)
                
        #     if e.which is 13
        #         search = $('.search_site').val().trim().toLowerCase()
        #         if search.length > 0
        #             picked_tags.push search
        #             console.log 'search', search
        #             # Meteor.call 'log_term', search, ->
        #             $('.search_site').val('')
        #             Session.set('product_query', null)
        #             # # $('#search').val('').blur()
        #             # # $( "p" ).blur();
        #             # Meteor.setTimeout ->
        #             #     Session.set('dummy', !Session.get('dummy'))
        #             # , 10000
        # , 500)
    
        'click .alerts': ->
            Session.set('viewing_alerts', !Session.get('viewing_alerts'))
            
        'click .toggle_admin': ->
            if 'admin' in Meteor.user().roles
                Meteor.users.update Meteor.userId(),
                    $pull:'roles':'admin'
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet:'roles':'admin'
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
    Meteor.publish 'models', ->
        Docs.find 
            model:'model'
    Meteor.publish 'my_cart', ->
        Docs.find 
            model:'cart_item'
