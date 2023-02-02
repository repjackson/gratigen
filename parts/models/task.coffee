if Meteor.isClient    
    Router.route '/task/:doc_id', (->
        @layout 'layout'
        @render 'task_view'
        ), name:'task_view'
    Router.route '/tasks', (->
        @layout 'layout'
        @render 'tasks'
        ), name:'tasks'
    Router.route '/my_tasks', (->
        @layout 'layout'
        @render 'tasks'
        ), name:'my_tasks'
    
    Template.tasks.onCreated ->
        @autorun => @subscribe 'task_docs',
            picked_tags.array()
            Session.get('task_title_filter')

        @autorun => @subscribe 'task_facets',
            picked_tags.array()
            Session.get('task_title_filter')

    Template.tasks.events
        'click .pick_task_tag': -> picked_tags.push @title
        'click .unpick_task_tag': -> picked_tags.remove @valueOf()

                
            
    Template.tasks.helpers
        picked_tags: -> picked_tags.array()
    
        task_docs: ->
            Docs.find 
                model:'task'
                # task_id: Meteor.user().current_task_id
                
        task_tag_results: ->
            Results.find {
                model:'task_tag'
            }, sort:_timestamp:-1
  
                

            
    Template.task_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'task_work', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'model_docs', 'location', ->
        @autorun => Meteor.subscribe 'child_tasks_from_parent_id', Router.current().params.doc_id,->
 
    Template.task_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'task_work', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'model_docs', 'location', ->
    


    Template.task_view.events
        'click .record_work': ->
            new_id = Docs.insert 
                model:'work'
                task_id: Router.current().params.doc_id
            Router.go "/work/#{new_id}/edit"    
    
                
           
    Template.task_view.helpers
        possible_locations: ->
            task = Docs.findOne Router.current().params.doc_id
            Docs.find
                model:'location'
                _id:$in:task.location_ids
                
        task_work: ->
            Docs.find 
                model:'work'
                task_id:Router.current().params.doc_id
                
    Template.task_edit.helpers
        task_locations: ->
            Docs.find
                model:'location'
                
        location_class: ->
            task = Docs.findOne Router.current().params.doc_id
            if task.location_ids and @_id in task.location_ids then 'blue' else 'basic'
            
                
    Template.task_edit.events
        'click .mark_complete': ->
            Docs.update Router.current().params.doc_id, 
                $set:
                    complete:true
                    complete_timestamp: Date.now()
                    
        'click .select_location': ->
            task = Docs.findOne Router.current().params.doc_id
            if task.location_ids and @_id in task.location_ids
                Docs.update Router.current().params.doc_id, 
                    $pull:location_ids:@_id
            else
                Docs.update Router.current().params.doc_id, 
                    $addToSet:location_ids:@_id

if Meteor.isClient
    Template.task_crud.onCreated ->
        @autorun => @subscribe 'task_search_results', Session.get('task_search'), ->
        @autorun => @subscribe 'model_docs', 'task', ->
    Template.task_crud.helpers
        task_results: ->
            if Session.get('task_search') and Session.get('task_search').length > 1
                Docs.find 
                    model:'task'
                    title: {$regex:"#{Session.get('task_search')}",$options:'i'}
                
        picked_tasks: ->
            ref_doc = Docs.findOne Router.current().params.doc_id
            Docs.find 
                # model:'task'
                _id:$in:ref_doc.task_ids
        task_search_value: ->
            Session.get('task_search')
        assigned_to: ->
            Meteor.users.findOne
                _id: $in: @assigned_to_user_ids
        is_assigning: ->
            Session.equals 'assigning_docid',@_id
            
        has_taken: ->
            @taken_by_user_id and Meteor.userId() is @taken_by_user_id
            # ref_doc = Docs.findOne Router.current().params.doc_id
            # if ref_doc and ref_doc.taken_by_user_id
            #     if Meteor.userId() and Meteor.userId() is ref_doc.taken_by_user_id
            #         true
            #     else 
            #         false
            # else 
            #     false
        is_taken: ->
            @taken_by_user_id
            # ref_doc = Docs.findOne Router.current().params.doc_id
            # if ref_doc and ref_doc.taken_by_user_id
            #     true
        can_take: ->
            if @taken_by_user_id then false else true
            
            # ref_doc = Docs.findOne Router.current().params.doc_id
            # if ref_doc and @taken_by_user_id
            #     false
            # else true
            #     if Meteor.userId() and Meteor.userId() is ref_doc.taken_by_user_id
            #         true
            #     else 
            #         false
            # eles 
            #     false
        taken_user: ->
            ref_doc = Docs.findOne @_id
            Meteor.users.findOne _id:ref_doc.taken_by_user_id
            
            
    Template.task_crud.events
        'click .toggle_assign': ->
            Session.set('assigning_docid',@_id)
        'click .clear_search': (e,t)->
            Session.set('task_search', null)
            t.$('.task_search').val('')

        'click .take_task': ->
            console.log @
            Docs.update @_id,
                $set:taken_by_user_id:Meteor.userId()
            $('body').toast({
                title: "#{@title} taken"
                message: 'yeay'
                class : 'success'
                showIcon:'shield'
                showProgress:'bottom'
                position:'bottom right'
            })

        'click .release_task': ->
            console.log @
            Docs.update @_id,
                $unset:taken_by_user_id:1
            $('body').toast({
                title: "task released: #{@title}"
                message: 'yeay'
                class : 'info'
                showIcon:'shield'
                showProgress:'bottom'
                position:'bottom right'
            })

            
        'click .remove_task': (e,t)->
            if confirm "remove #{@title} task?"
                Docs.update Router.current().params.doc_id,
                    $pull:
                        task_ids:@_id
                        task_titles:@title
                $(e.currentTarget).closest('.card').transition('fly right', 500)

        'click .pick_task': (e,t)->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    task_ids:@_id
                    task_titles:@title
            Session.set('task_search',null)
            t.$('.task_search').val('')
                    
        'keyup .task_search': (e,t)->
            # if e.which is '13'
            val = t.$('.task_search').val()
            console.log val
            Session.set('task_search', val)
            if e.which is '13'
                new_id = 
                    Docs.insert 
                        model:'task'
                        title:Session.get('task_search')
                Docs.update Router.current().params.doc_id,
                    $addToSet:
                        task_ids:new_id
                        task_titles:Session.get('task_search')
                $('body').toast({
                    title: "added #{Session.get('task_search')}"
                    message: 'yeay'
                    class : 'success'
                    showIcon:'shield'
                    showProgress:'bottom'
                    position:'bottom right'
                })

        'click .create_task': ->
            new_id = 
                Docs.insert 
                    model:'task'
                    title:Session.get('task_search')
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    task_ids:new_id
                    task_titles:Session.get('task_search')
            $('body').toast({
                title: "added #{Session.get('task_search')}"
                message: 'yeay'
                class : 'success'
                showIcon:'shield'
                showProgress:'bottom'
                position:'bottom right'
            })
                    
            Session.set('task_search',null)
        
            # Docs.update
            # Router.go "/task/#{new_id}/edit"


if Meteor.isServer 
    Meteor.publish 'task_search_results', (title_query)->
        Docs.find 
            model:'task'
            title: {$regex:"#{title_query}",$options:'i'}
        