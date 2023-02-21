# if Meteor.isClient
#     Template.shift_crud.onCreated ->
#         @autorun => @subscribe 'shift_search_results', Session.get('shift_search'), ->
#         @autorun => @subscribe 'model_docs', 'shift', ->
#     Template.shift_crud.helpers
#         shift_results: ->
#             if Session.get('shift_search') and Session.get('shift_search').length > 1
#                 Docs.find 
#                     model:'shift'
#                     title: {$regex:"#{Session.get('shift_search')}",$options:'i'}
                
#         picked_shifts: ->
#             ref_doc = Docs.findOne Router.current().params.doc_id
#             Docs.find 
#                 # model:'shift'
#                 _id:$in:ref_doc.shift_ids
#         shift_search_value: ->
#             Session.get('shift_search')
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
            
            
#     Template.shift_crud.events
#         'click .toggle_assign': ->
#             Session.set('assigning_docid',@_id)
#         'click .clear_search': (e,t)->
#             Session.set('shift_search', null)
#             t.$('.shift_search').val('')

#         'click .take_shift': ->
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

#         'click .release_shift': ->
#             console.log @
#             Docs.update @_id,
#                 $unset:taken_by_user_id:1
#             $('body').toast({
#                 title: "shift released: #{@title}"
#                 message: 'yeay'
#                 class : 'info'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })

            
#         'click .remove_shift': (e,t)->
#             if confirm "remove #{@title} shift?"
#                 Docs.update Router.current().params.doc_id,
#                     $pull:
#                         shift_ids:@_id
#                         shift_titles:@title
#                 $(e.currentTarget).closest('.card').transition('fly right', 500)

#         'click .pick_shift': (e,t)->
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     shift_ids:@_id
#                     shift_titles:@title
#             Session.set('shift_search',null)
#             t.$('.shift_search').val('')
                    
#         'keyup .shift_search': (e,t)->
#             # if e.which is '13'
#             val = t.$('.shift_search').val()
#             console.log val
#             Session.set('shift_search', val)
#             if e.which is '13'
#                 new_id = 
#                     Docs.insert 
#                         model:'shift'
#                         title:Session.get('shift_search')
#                 Docs.update Router.current().params.doc_id,
#                     $addToSet:
#                         shift_ids:new_id
#                         shift_titles:Session.get('shift_search')
#                 $('body').toast({
#                     title: "added #{Session.get('shift_search')}"
#                     message: 'yeay'
#                     class : 'success'
#                     showIcon:'shield'
#                     showProgress:'bottom'
#                     position:'bottom right'
#                 })

#         'click .create_shift': ->
#             parent = Docs.findOne Router.current().params.doc_id
#             new_id = 
#                 Docs.insert 
#                     model:'shift'
#                     title:Session.get('shift_search')
#                     parent_id:parent._id
#                     parent_model:parent.model
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     shift_ids:new_id
#                     shift_titles:Session.get('shift_search')
#             $('body').toast({
#                 title: "added #{Session.get('shift_search')}"
#                 message: 'yeay'
#                 class : 'success'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })
                    
#             Session.set('shift_search',null)
        
#             # Docs.update
#             # Router.go "/shift/#{new_id}/edit"


# if Meteor.isServer 
#     Meteor.publish 'shift_search_results', (title_query)->
#         Docs.find 
#             model:'shift'
#             title: {$regex:"#{title_query}",$options:'i'}