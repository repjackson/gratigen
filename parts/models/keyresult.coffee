# if Meteor.isClient
#     Template.keyresult_crud.onCreated ->
#         @autorun => @subscribe 'keyresult_search_results', Session.get('keyresult_search'), ->
#         @autorun => @subscribe 'model_docs', 'keyresult', ->
#     Template.keyresult_crud.helpers
#         keyresult_results: ->
#             if Session.get('keyresult_search') and Session.get('keyresult_search').length > 1
#                 Docs.find 
#                     model:'keyresult'
#                     title: {$regex:"#{Session.get('keyresult_search')}",$options:'i'}
                
#         picked_keyresults: ->
#             ref_doc = Docs.findOne Router.current().params.doc_id
#             Docs.find 
#                 # model:'keyresult'
#                 _id:$in:ref_doc.keyresult_ids
#         keyresult_search_value: ->
#             Session.get('keyresult_search')
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
            
            
#     Template.keyresult_crud.events
#         'click .toggle_assign': ->
#             Session.set('assigning_docid',@_id)

#         'click .take_keyresult': ->
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

#         'click .release_keyresult': ->
#             console.log @
#             Docs.update @_id,
#                 $unset:taken_by_user_id:1
#             $('body').toast({
#                 title: "keyresult released: #{@title}"
#                 message: 'yeay'
#                 class : 'info'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })

            
#         'click .remove_keyresult': (e,t)->
#             if confirm "remove #{@title} keyresult?"
#                 Docs.update Router.current().params.doc_id,
#                     $pull:
#                         keyresult_ids:@_id
#                         keyresult_titles:@title
#                 $(e.currentTarget).closest('.card').transition('fly right', 500)

#         'click .pick_keyresult': (e,t)->
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     keyresult_ids:@_id
#                     keyresult_titles:@title
#             Session.set('keyresult_search',null)
#             t.$('.keyresult_search').val('')
                    
#         'keyup .keyresult_search': (e,t)->
#             # if e.which is '13'
#             val = t.$('.keyresult_search').val()
#             console.log val
#             Session.set('keyresult_search', val)
#             if e.which is '13'
#                 new_id = 
#                     Docs.insert 
#                         model:'keyresult'
#                         title:Session.get('keyresult_search')
#                 Docs.update Router.current().params.doc_id,
#                     $addToSet:
#                         keyresult_ids:new_id
#                         keyresult_titles:Session.get('keyresult_search')
#                 $('body').toast({
#                     title: "added #{Session.get('keyresult_search')}"
#                     message: 'yeay'
#                     class : 'success'
#                     showIcon:'shield'
#                     showProgress:'bottom'
#                     position:'bottom right'
#                 })

#         'click .create_keyresult': ->
#             parent = Docs.findOne Router.current().params.doc_id
#             new_id = 
#                 Docs.insert 
#                     model:'keyresult'
#                     title:Session.get('keyresult_search')
#                     parent_id:parent._id
#                     parent_model:parent.model
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     keyresult_ids:new_id
#                     keyresult_titles:Session.get('keyresult_search')
#             $('body').toast({
#                 title: "added #{Session.get('keyresult_search')}"
#                 message: 'yeay'
#                 class : 'success'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })
                    
#             Session.set('keyresult_search',null)
        
#             # Docs.update
#             # Router.go "/keyresult/#{new_id}/edit"


# if Meteor.isServer 
#     Meteor.publish 'keyresult_search_results', (title_query)->
#         Docs.find 
#             model:'keyresult'
#             title: {$regex:"#{title_query}",$options:'i'}