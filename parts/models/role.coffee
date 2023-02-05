if Meteor.isClient
    Template.role_crud.onCreated ->
        @autorun => @subscribe 'role_search_results', Session.get('role_search'), ->
        @autorun => @subscribe 'model_docs', 'role', ->
    Template.role_crud.helpers
        role_results: ->
            if Session.get('role_search') and Session.get('role_search').length > 1
                Docs.find 
                    model:'role'
                    title: {$regex:"#{Session.get('role_search')}",$options:'i'}
                
        picked_roles: ->
            ref_doc = Docs.findOne Router.current().params.doc_id
            Docs.find 
                # model:'role'
                _id:$in:ref_doc.role_ids
        role_search_value: ->
            Session.get('role_search')
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
            
            
    Template.role_crud.events
        'click .toggle_assign': ->
            Session.set('assigning_docid',@_id)
        'click .clear_search': (e,t)->
            Session.set('role_search', null)
            t.$('.role_search').val('')

        'click .take_role': ->
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

        'click .release_role': ->
            console.log @
            Docs.update @_id,
                $unset:taken_by_user_id:1
            $('body').toast({
                title: "role released: #{@title}"
                message: 'yeay'
                class : 'info'
                showIcon:'shield'
                showProgress:'bottom'
                position:'bottom right'
            })

            
        'click .remove_role': (e,t)->
            if confirm "remove #{@title} role?"
                Docs.update Router.current().params.doc_id,
                    $pull:
                        role_ids:@_id
                        role_titles:@title
                $(e.currentTarget).closest('.card').transition('fly right', 500)

        'click .pick_role': (e,t)->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    role_ids:@_id
                    role_titles:@title
            Session.set('role_search',null)
            t.$('.role_search').val('')
                    
        'keyup .role_search': (e,t)->
            # if e.which is '13'
            val = t.$('.role_search').val()
            console.log val
            Session.set('role_search', val)
            if e.which is '13'
                new_id = 
                    Docs.insert 
                        model:'role'
                        title:Session.get('role_search')
                Docs.update Router.current().params.doc_id,
                    $addToSet:
                        role_ids:new_id
                        role_titles:Session.get('role_search')
                $('body').toast({
                    title: "added #{Session.get('role_search')}"
                    message: 'yeay'
                    class : 'success'
                    showIcon:'shield'
                    showProgress:'bottom'
                    position:'bottom right'
                })

        'click .create_role': ->
            parent = Docs.findOne Router.current().params.doc_id
            new_id = 
                Docs.insert 
                    model:'role'
                    title:Session.get('role_search')
                    parent_id:parent._id
                    parent_model:parent.model
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    role_ids:new_id
                    role_titles:Session.get('role_search')
            $('body').toast({
                title: "added #{Session.get('role_search')}"
                message: 'yeay'
                class : 'success'
                showIcon:'shield'
                showProgress:'bottom'
                position:'bottom right'
            })
                    
            Session.set('role_search',null)
        
            # Docs.update
            # Router.go "/role/#{new_id}/edit"


if Meteor.isServer 
    Meteor.publish 'role_search_results', (title_query)->
        Docs.find 
            model:'role'
            title: {$regex:"#{title_query}",$options:'i'}