if Meteor.isClient
    Router.route '/projects', (->
        @layout 'layout'
        @render 'projects'
        ), name:'projects'
    Router.route '/project/:doc_id/edit', (->
        @layout 'layout'
        @render 'project_edit'
        ), name:'project_edit'
    Router.route '/project/:doc_id', (->
        @layout 'layout'
        @render 'project_view'
        ), name:'project_view'
    Router.route '/project/:doc_id/view', (->
        @layout 'layout'
        @render 'project_view'
        ), name:'project_view_long'
    
    
    Template.projects.onCreated ->
        @autorun => @subscribe 'model_docs', 'project', ->
        # @autorun => @subscribe 'project_docs',
        #     picked_tags.array()
        #     Session.get('project_title_filter')

        # @autorun => @subscribe 'project_facets',
        #     picked_tags.array()
        #     Session.get('project_title_filter')

    
    
    Template.projects.events
        'click .add_project': ->
            new_id = 
                Docs.insert 
                    model:'project'
            Router.go "/project/#{new_id}/edit"
            
            
            
    Template.projects.helpers
        picked_tags: -> picked_tags.array()
    
        project_docs: ->
            Docs.find {
                model:'project'
                private:$ne:true
            }, sort:_timestamp:-1    
        tag_results: ->
            Results.find {
                model:'tag'
            }, sort:_timestamp:-1

    Template.user_projects.onCreated ->
        @autorun => Meteor.subscribe 'user_projects', Router.current().params.username, ->
    Template.user_projects.helpers
        project_docs: ->
            Docs.find {
                model:'project'
            }, sort:_timestamp:-1    
    
    Template.project_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'task', ->
        
    Template.project_edit.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'task', ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.project_card.onCreated ->
        @autorun => Meteor.subscribe 'doc_comments', @data._id, ->

    Template.project_edit.helpers
        child_tasks: ->
            Docs.find
                model:'task'
                
                
    Template.project_view.helpers
        child_tasks: ->
            Docs.find
                model:'task'
                project_id: Router.current().params.doc_id
                
                
                
    Template.project_card.events
        'click .view_project': ->
            Router.go "/project/#{@_id}"

    Template.project_view.events
        'click .add_project_recipe': ->
            new_id = 
                Docs.insert 
                    model:'recipe'
                    project_ids:[@_id]
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
    
    
    Template.project_edit.events
        'click .delete_project': ->
            Swal.fire({
                title: "delete project?"
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
                        title: 'project removed',
                        showConfirmButton: false,
                        timer: 1500
                    )
                    Router.go "/projects"
            )

        'click .publish': ->
            Swal.fire({
                title: "publish project?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_project', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'project published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish project?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_project', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'project unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )
            
if Meteor.isServer
    Meteor.publish 'user_projects', (username)->
        user = Meteor.users.findOne username:username
        
        Docs.find 
            model:'project'
            _author_id:user._id
    
    Meteor.publish 'project_count', (
        picked_tags
        picked_sections
        project_query
        view_vegan
        view_gf
        )->
        # @unblock()
    
        # console.log picked_tags
        self = @
        match = {model:'project'}
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
        if project_query and project_query.length > 1
            console.log 'searching project_query', project_query
            match.title = {$regex:"#{project_query}", $options: 'i'}
        Counts.publish this, 'project_counter', Docs.find(match)
        return undefined


if Meteor.isClient
    Template.project_card.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.project_card.events
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

    Template.project_card.helpers
        project_card_class: ->
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
            