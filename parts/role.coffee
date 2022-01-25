if Meteor.isClient
    Router.route '/roles', (->
        @layout 'layout'
        @render 'roles'
        ), name:'roles'
    Router.route '/role/:doc_id/edit', (->
        @layout 'layout'
        @render 'role_edit'
        ), name:'role_edit'
    Router.route '/role/:doc_id', (->
        @layout 'layout'
        @render 'role_view'
        ), name:'role_view'
    Router.route '/role/:doc_id/view', (->
        @layout 'layout'
        @render 'role_view'
        ), name:'role_view_long'
    
    
    Template.roles.onCreated ->
        @autorun => @subscribe 'model_docs', 'role', ->
        # @autorun => @subscribe 'role_docs',
        #     picked_tags.array()
        #     Session.get('role_title_filter')

        # @autorun => @subscribe 'role_facets',
        #     picked_tags.array()
        #     Session.get('role_title_filter')

    
    
    Template.roles.events
        'click .add_role': ->
            new_id = 
                Docs.insert 
                    model:'role'
            Router.go "/role/#{new_id}/edit"
            
            
            
    Template.roles.helpers
        picked_tags: -> picked_tags.array()
    
        role_docs: ->
            Docs.find {
                model:'role'
                private:$ne:true
            }, sort:_timestamp:-1    
        tag_results: ->
            Results.find {
                model:'tag'
            }, sort:_timestamp:-1

    Template.user_roles.onCreated ->
        @autorun => Meteor.subscribe 'user_roles', Router.current().params.username, ->
    Template.user_roles.helpers
        role_docs: ->
            Docs.find {
                model:'role'
            }, sort:_timestamp:-1    
    
    Template.role_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.role_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.role_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


    Template.role_card.events
        'click .view_role': ->
            Router.go "/role/#{@_id}"
    Template.role_item.events
        'click .view_role': ->
            Router.go "/role/#{@_id}"

    Template.role_view.events
        'click .add_role_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    role_ids:[@_id]
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
    
    
    Template.role_edit.events
        'click .delete_role': ->
            Swal.fire({
                title: "delete role?"
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
                        title: 'role removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/roles"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish role?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_role', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'role published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish role?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_role', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'role unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            
if Meteor.isServer
    Meteor.publish 'user_roles', (username)->
        user = Meteor.users.findOne username:username
        
        Docs.find 
            model:'role'
            _author_id:user._id
    
    Meteor.publish 'role_count', (
        picked_tags
        picked_sections
        role_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_tags
        self = @
        match = {model:'role'}
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
        if role_query and role_query.length > 1
            console.log 'searching role_query', role_query
            match.title = {$regex:"#{role_query}", $options: 'i'}
        Counts.publish this, 'role_counter', Docs.find(match)
        return undefined


if Meteor.isClient
    Template.role_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.role_card.events
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

    Template.role_card.helpers
        role_card_class: ->
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
            