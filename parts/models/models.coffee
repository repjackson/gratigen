if Meteor.isClient
    @picked_tags = new ReactiveArray []
    
            
if Meteor.isServer
    Meteor.publish 'task_work', (task_id)->
        Docs.find   
            model:'work'
            task_id:task_id
    # Meteor.publish 'work_task', (work_id)->
    #     work = Docs.findOne work_id
    #     Docs.find   
    #         model:'task'
    #         _id: work.task_id
            
            
    Meteor.publish 'user_sent_task', (username)->
        Docs.find   
            model:'task'
            _author_username:username
    Meteor.publish 'product_task', (product_id)->
        Docs.find   
            model:'task'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/task/:doc_id/edit', (->
        @layout 'layout'
        @render 'task_edit'
        ), name:'task_edit'





    Template.task_edit.events
        'click .send_task': ->
            Swal.fire({
                title: 'confirm send card'
                text: "#{@amount} credits"
                icon: 'question'
                showCancelButton: true,
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
            }).then((result) =>
                if result.value
                    task = Docs.findOne Router.current().params.doc_id
                    Meteor.users.update Meteor.userId(),
                        $inc:credit:-@amount
                    Docs.update task._id,
                        $set:
                            sent:true
                            sent_timestamp:Date.now()
                    Swal.fire(
                        'task sent',
                        ''
                        'success'
                    Router.go "/task/#{@_id}/"
                    )
            )

        'click .delete_task':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/tasks"
            
    Template.task_edit.helpers
        all_shop: ->
            Docs.find
                model:'task'


        current_subgroups: ->
            Docs.find 
                model:'group'
                parent_group_id:Meteor.user().current_group_id
                
                
                
if Meteor.isClient
    @picked_authors = new ReactiveArray []
    @picked_locations = new ReactiveArray []
    @picked_tasks = new ReactiveArray []
    @picked_timestamp_tags = new ReactiveArray []
    
    Router.route '/work', (->
        @layout 'layout'
        @render 'work'
        ), name:'work'
    Router.route '/user/:username/work', (->
        @layout 'user_layout'
        @render 'user_work'
        ), name:'user_work'
    Router.route '/work/:doc_id', (->
        @layout 'layout'
        @render 'work_view'
        ), name:'work_view'
    
    
    
    Template.work.onCreated ->
        @autorun => @subscribe 'work_docs',
            picked_authors.array()
            picked_tasks.array()
            picked_locations.array()
            picked_timestamp_tags.array()
        @autorun => @subscribe 'work_facets',
            picked_authors.array()
            picked_tasks.array()
            picked_locations.array()
            picked_timestamp_tags.array()
            
            
    Template.work_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'location', ->
        @autorun => Meteor.subscribe 'model_docs', 'staff', ->

    Template.work_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'work_task', Router.current().params.doc_id, ->


    Template.work.helpers
        task_results: ->
            Results.find {
                model:'task'
            }, sort:_timestamp:-1
        timestamp_tag_results: ->
            Results.find {
                model:'timestamp_tag'
            }, sort:_timestamp:-1
        author_results: ->
            Results.find {
                model:'author'
            }, sort:_timestamp:-1
        location_results: ->
            Results.find {
                model:'location'
            }, sort:_timestamp:-1
        work_list: ->
            Docs.find {
                model:'work'
            }, sort:_timestamp:-1
        eric_total: ->
            Docs.find({
                model:'work'
                _author_username: 'dev'
            }).count()
        ryan_total: ->
            Docs.find({
                model:'work'
                _author_username: 'ryan'
            }).count()
        picked_tasks: -> picked_tasks.array()
        picked_locations: -> picked_locations.array()
        picked_authors: -> picked_authors.array()
        picked_timestamp_tags: -> picked_timestamp_tags.array()
    Template.work.events
        'click .pick_timestamp_tag': -> picked_timestamp_tags.push @title
        'click .unpick_timestamp_tag': -> picked_timestamp_tags.remove @valueOf()
        'click .pick_task': -> picked_tasks.push @title
        'click .unpick_task': -> picked_tasks.remove @valueOf()
        'click .pick_location': -> picked_locations.push @title
        'click .unpick_location': -> picked_locations.remove @valueOf()
        'click .pick_author': -> picked_authors.push @title
        'click .unpick_author': -> picked_authors.remove @valueOf()
        'click .add_work': ->
            new_id = Docs.insert 
                model:'work'
            Router.go "/work/#{new_id}/edit"    
      
        'click .add_task': ->
            new_id = Docs.insert 
                model:'task'
            Router.go "/task/#{new_id}/edit"    
    
                
    Template.work_edit.events
        'click .pick_staff': ->
            Docs.update Router.current().params.doc_id, 
                $set:
                    staff_id:@_id
                    staff_name: "#{@first_name} #{@last_name}"
                    staff_image_id: @image_id
        
        'click .pick_location': ->
            Docs.update Router.current().params.doc_id, 
                $set:
                    location_id:@_id
                    location_title: @title
                    location_image_id: @image_id
        
        
        
    Template.work_edit.helpers
        task_locations: ->
            work_doc = Docs.findOne(model:'task')
            Docs.find 
                model:'location'
                _id: $in: work_doc.location_ids
                
        porter_staff: ->
            Docs.find 
                model:'staff'
                
        # staff_picker_class: ->
        #     work = Docs.findOne Router.current().params.doc_id
        #     if work.staff_id is @_id then 'blue big' else 'basic large'
            
        location_picker_class: ->
            work = Docs.findOne Router.current().params.doc_id
            if work.location_id is @_id then 'blue massive' else 'basic big'
            
        
if Meteor.isServer
    Meteor.publish 'user_received_work', (username)->
        Docs.find   
            model:'work'
            recipient_username:username
            
            
    Meteor.publish 'user_sent_work', (username)->
        Docs.find   
            model:'work'
            _author_username:username
    Meteor.publish 'product_work', (product_id)->
        Docs.find   
            model:'work'
            product_id:product_id
            
            
            
            
if Meteor.isClient
    Router.route '/work/:doc_id/edit', (->
        @layout 'layout'
        @render 'work_edit'
        ), name:'work_edit'



    Template.work_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'work_task', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.work_edit.events
        # 'click .send_work': ->
        #     Swal.fire({
        #         title: 'confirm send card'
        #         text: "#{@amount} credits"
        #         icon: 'question'
        #         showCancelButton: true,
        #         confirmButtonText: 'confirm'
        #         cancelButtonText: 'cancel'
        #     }).then((result) =>
        #         if result.value
        #             work = Docs.findOne Router.current().params.doc_id
        #             Meteor.users.update Meteor.userId(),
        #                 $inc:credit:-@amount
        #             Docs.update work._id,
        #                 $set:
        #                     sent:true
        #                     sent_timestamp:Date.now()
        #             Swal.fire(
        #                 'work sent',
        #                 ''
        #                 'success'
        #             Router.go "/work/#{@_id}/"
        #             )
        #     )

        'click .delete_work':(e,t)->
            # Swal.fire({
            #     title: "delete work entry?"
            #     text: "for #{@task_title}"
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            # }).then((result) =>
            #     if result.value
            $(e.currentTarget).closest('.grid').transition('fly right', 750)
            Meteor.setTimeout =>
                Docs.remove @_id
                Router.go "/work"
            , 750    
                
            $('body').toast(
                showIcon: 'remove'
                message: "#{@task_title} work entry"
                showProgress: 'bottom'
                class: 'error'
                # displayTime: 'auto',
                position: "bottom right"
            )
        'click .submit_work':(e,t)->
            $(e.currentTarget).closest('.grid').transition('fly left', 750)
            Meteor.setTimeout =>
                Router.go "/work"
            , 750
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@task_title} work entry"
                showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )
            
    Template.work_edit.helpers
        all_shop: ->
            Docs.find
                model:'work'

if Meteor.isServer
    # Meteor.publish 'user_received_task', (username)->
    #     Docs.find   
    #         model:'task'
    #         recipient_username:username
            
    Meteor.publish 'work_task', (work_id)->
        work = Docs.findOne work_id
        Docs.find   
            model:'task'
            _id: work.task_id                
            
            
            
if Meteor.isClient
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
    Meteor.publish 'user_authored', (username,model)->
        user = Meteor.users.findOne username:username
        
        Docs.find 
            model:model
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
            