if Meteor.isClient
    Template.group_crud.onCreated ->
        @autorun => @subscribe 'group_search_results', Session.get('group_search'), ->
        @autorun => @subscribe 'model_docs', 'group', ->
    Template.group_crud.helpers
        group_results: ->
            if Session.get('group_search') and Session.get('group_search').length > 1
                Docs.find 
                    model:'group'
                    title: {$regex:"#{Session.get('group_search')}",$options:'i'}
                
        picked_groups: ->
            ref_doc = Docs.findOne Router.current().params.doc_id
            Docs.find 
                # model:'group'
                _id:$in:ref_doc.group_ids
        group_search_value: ->
            Session.get('group_search')
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
            
            
    Template.group_crud.events
        'click .toggle_assign': ->
            Session.set('assigning_docid',@_id)
        'click .clear_search': (e,t)->
            Session.set('group_search', null)
            t.$('.group_search').val('')

        'click .take_group': ->
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

        'click .release_group': ->
            console.log @
            Docs.update @_id,
                $unset:taken_by_user_id:1
            $('body').toast({
                title: "group released: #{@title}"
                message: 'yeay'
                class : 'info'
                showIcon:'shield'
                showProgress:'bottom'
                position:'bottom right'
            })

            
        'click .remove_group': (e,t)->
            if confirm "remove #{@title} group?"
                Docs.update Router.current().params.doc_id,
                    $pull:
                        group_ids:@_id
                        group_titles:@title
                $(e.currentTarget).closest('.card').transition('fly right', 500)

        'click .pick_group': (e,t)->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    group_ids:@_id
                    group_titles:@title
            Session.set('group_search',null)
            t.$('.group_search').val('')
                    
        'keyup .group_search': (e,t)->
            # if e.which is '13'
            val = t.$('.group_search').val()
            console.log val
            Session.set('group_search', val)
            if e.which is '13'
                new_id = 
                    Docs.insert 
                        model:'group'
                        title:Session.get('group_search')
                Docs.update Router.current().params.doc_id,
                    $addToSet:
                        group_ids:new_id
                        group_titles:Session.get('group_search')
                $('body').toast({
                    title: "added #{Session.get('group_search')}"
                    message: 'yeay'
                    class : 'success'
                    showIcon:'shield'
                    showProgress:'bottom'
                    position:'bottom right'
                })

        'click .create_group': ->
            parent = Docs.findOne Router.current().params.doc_id
            new_id = 
                Docs.insert 
                    model:'group'
                    title:Session.get('group_search')
                    parent_id:parent._id
                    parent_model:parent.model
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    group_ids:new_id
                    group_titles:Session.get('group_search')
            $('body').toast({
                title: "added #{Session.get('group_search')}"
                message: 'yeay'
                class : 'success'
                showIcon:'shield'
                showProgress:'bottom'
                position:'bottom right'
            })
                    
            Session.set('group_search',null)
        
            # Docs.update
            # Router.go "/group/#{new_id}/edit"


if Meteor.isServer 
    Meteor.publish 'group_search_results', (title_query)->
        Docs.find 
            model:'group'
            title: {$regex:"#{title_query}",$options:'i'}
        