# if Meteor.isClient
#     Template.objective_crud.onCreated ->
#         @autorun => @subscribe 'objective_search_results', Session.get('objective_search'), ->
#         @autorun => @subscribe 'model_docs', 'objective', ->
#     Template.objective_crud.helpers
#         objective_results: ->
#             if Session.get('objective_search') and Session.get('objective_search').length > 1
#                 Docs.find 
#                     model:'objective'
#                     title: {$regex:"#{Session.get('objective_search')}",$options:'i'}
                
#         picked_objectives: ->
#             ref_doc = Docs.findOne Router.current().params.doc_id
#             Docs.find 
#                 # model:'objective'
#                 _id:$in:ref_doc.objective_ids
#         objective_search_value: ->
#             Session.get('objective_search')
#         assigned_to: ->
#             Meteor.users.findOne
#                 _id: $in: @assigned_to_user_ids
#         is_assigning: ->
#             Session.equals 'assigning_docid',@_id
            
#         has_taken: ->
#             @taken_by_user_id and Meteor.userId() is @taken_by_user_id
#             # ref_doc = Docs.findOne Router.current().params.doc_id
#             # if ref_doc and ref_doc.taken_by_user_id
#             #     if Meteor.userId() and Meteor.userId() is ref_doc.taken_by_user_id
#             #         true
#             #     else 
#             #         false
#             # else 
#             #     false
#         is_taken: ->
#             @taken_by_user_id
#             # ref_doc = Docs.findOne Router.current().params.doc_id
#             # if ref_doc and ref_doc.taken_by_user_id
#             #     true
#         can_take: ->
#             if @taken_by_user_id then false else true
            
#             # ref_doc = Docs.findOne Router.current().params.doc_id
#             # if ref_doc and @taken_by_user_id
#             #     false
#             # else true
#             #     if Meteor.userId() and Meteor.userId() is ref_doc.taken_by_user_id
#             #         true
#             #     else 
#             #         false
#             # eles 
#             #     false
#         taken_user: ->
#             ref_doc = Docs.findOne @_id
#             Meteor.users.findOne _id:ref_doc.taken_by_user_id
            
            
#     Template.objective_crud.events
#         'click .toggle_assign': ->
#             Session.set('assigning_docid',@_id)
#         'click .clear_search': (e,t)->
#             Session.set('objective_search', null)
#             t.$('.objective_search').val('')

#         'click .take_objective': ->
#             console.log @
#             Docs.update @_id,
#                 $set:taken_by_user_id:Meteor.userId()
#             $('body').toast({
#                 title: "#{@title} taken"
#                 message: 'yeay'
#                 class : 'success'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })

#         'click .release_objective': ->
#             console.log @
#             Docs.update @_id,
#                 $unset:taken_by_user_id:1
#             $('body').toast({
#                 title: "objective released: #{@title}"
#                 message: 'yeay'
#                 class : 'info'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })

            
#         'click .remove_objective': (e,t)->
#             if confirm "remove #{@title} objective?"
#                 Docs.update Router.current().params.doc_id,
#                     $pull:
#                         objective_ids:@_id
#                         objective_titles:@title
#                 $(e.currentTarget).closest('.card').transition('fly right', 500)

#         'click .pick_objective': (e,t)->
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     objective_ids:@_id
#                     objective_titles:@title
#             Session.set('objective_search',null)
#             t.$('.objective_search').val('')
                    
#         'keyup .objective_search': (e,t)->
#             # if e.which is '13'
#             val = t.$('.objective_search').val()
#             console.log val
#             Session.set('objective_search', val)
#             if e.which is '13'
#                 new_id = 
#                     Docs.insert 
#                         model:'objective'
#                         title:Session.get('objective_search')
#                 Docs.update Router.current().params.doc_id,
#                     $addToSet:
#                         objective_ids:new_id
#                         objective_titles:Session.get('objective_search')
#                 $('body').toast({
#                     title: "added #{Session.get('objective_search')}"
#                     message: 'yeay'
#                     class : 'success'
#                     showIcon:'shield'
#                     showProgress:'bottom'
#                     position:'bottom right'
#                 })

#         'click .create_objective': ->
#             parent = Docs.findOne Router.current().params.doc_id
#             new_id = 
#                 Docs.insert 
#                     model:'objective'
#                     title:Session.get('objective_search')
#                     parent_id:parent._id
#                     parent_model:parent.model
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     objective_ids:new_id
#                     objective_titles:Session.get('objective_search')
#             $('body').toast({
#                 title: "added #{Session.get('objective_search')}"
#                 message: 'yeay'
#                 class : 'success'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })
                    
#             Session.set('objective_search',null)
        
#             # Docs.update
#             # Router.go "/objective/#{new_id}/edit"


# if Meteor.isServer 
#     Meteor.publish 'objective_search_results', (title_query)->
#         Docs.find 
#             model:'objective'
#             title: {$regex:"#{title_query}",$options:'i'}