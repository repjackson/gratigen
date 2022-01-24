if Meteor.isClient
    Router.route '/services', (->
        @layout 'layout'
        @render 'services'
        ), name:'services'
    Router.route '/service/:doc_id/edit', (->
        @layout 'layout'
        @render 'service_edit'
        ), name:'service_edit'
    Router.route '/service/:doc_id', (->
        @layout 'layout'
        @render 'service_view'
        ), name:'service_view'
    Router.route '/service/:doc_id/view', (->
        @layout 'layout'
        @render 'service_view'
        ), name:'service_view_long'
    
    
    Template.services.onCreated ->
        @autorun => @subscribe 'model_docs', 'service', ->
        # @autorun => @subscribe 'service_docs',
        #     picked_tags.array()
        #     Session.get('service_title_filter')

        # @autorun => @subscribe 'service_facets',
        #     picked_tags.array()
        #     Session.get('service_title_filter')

    
    
    Template.services.events
        'click .add_service': ->
            new_id = 
                Docs.insert 
                    model:'service'
            Router.go "/service/#{new_id}/edit"
            
            
            
    Template.services.helpers
        picked_tags: -> picked_tags.array()
    
        service_docs: ->
            Docs.find {
                model:'service'
                private:$ne:true
            }, sort:_timestamp:-1    
        tag_results: ->
            Results.find {
                model:'tag'
            }, sort:_timestamp:-1

    Template.user_services.onCreated ->
        @autorun => Meteor.subscribe 'user_services', Router.current().params.username, ->
    Template.user_services.helpers
        service_docs: ->
            Docs.find {
                model:'service'
            }, sort:_timestamp:-1    
    
    Template.service_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.service_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.service_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


    Template.service_card.events
        'click .view_service': ->
            Router.go "/service/#{@_id}"
    Template.service_item.events
        'click .view_service': ->
            Router.go "/service/#{@_id}"

    Template.service_view.events
        'click .add_service_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    service_ids:[@_id]
            Router.go "/recipe/#{new_id}/edit"

    # Template.favorite_icon_toggle.helpers
    #     icon_class: ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             'red'
    #         else
    #             'outline'
    # Template.favorite_icon_toggle.events
    #     'click .toggle_fav': ->
    #         if @favorite_ids and Meteor.userId() in @favorite_ids
    #             Docs.update @_id, 
    #                 $pull:favorite_ids:Meteor.userId()
    #         else
    #             $('body').toast(
    #                 showIcon: 'heart'
    #                 message: "marked favorite"
    #                 showProgress: 'bottom'
    #                 class: 'success'
    #                 # displayTime: 'auto',
    #                 position: "bottom right"
    #             )

    #             Docs.update @_id, 
    #                 $addToSet:favorite_ids:Meteor.userId()
    
    
    Template.service_edit.events
        'click .delete_service': ->
            Swal.fire({
                title: "delete service?"
                text: "cannot be undone"
                icon: 'question'
                confirmButtonText: 'delete'
                confirmButtonColor: 'red'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Swal.fire(
                        position: 'top-end',
                        icon: 'success',
                        title: 'service removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/services"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish service?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_service', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'service published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish service?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_service', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'service unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            
if Meteor.isServer
    Meteor.publish 'user_services', (username)->
        user = Meteor.users.findOne username:username
        
        Docs.find 
            model:'service'
            _author_id:user._id
    
    Meteor.publish 'service_count', (
        picked_tags
        picked_sections
        service_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_tags
        self = @
        match = {model:'service'}
        if picked_tags.length > 0
            match.ingredients = $all: picked_tags
            # sort = 'price_per_serving'
        if picked_sections.length > 0
            match.menu_section = $all: picked_sections
            # sort = 'price_per_serving'
        # else
            # match.tags = $nin: ['wikipedia']
        sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        if view_vegan
            match.vegan = true
        if view_gf
            match.gluten_free = true
        if service_query and service_query.length > 1
            console.log 'searching service_query', service_query
            match.title = {$regex:"#{service_query}", $options: 'i'}
        Counts.publish this, 'service_counter', Docs.find(match)
        return undefined


if Meteor.isClient
    Template.service_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.service_card.events
        'click .quickbuy': ->
            console.log @
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            Router.go("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_card': ->
        #     $('.container_')

    Template.service_card.helpers
        service_card_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            # console.log Meteor.user().roles
            Docs.find {
                model:'food'
            }, sort:title:1
            