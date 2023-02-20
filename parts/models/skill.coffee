# if Meteor.isClient
#     Template.skill_crud.onCreated ->
#         @autorun => @subscribe 'skill_search_results', Session.get('skill_search'), ->
#         @autorun => @subscribe 'model_docs', 'skill', ->
#     Template.skill_crud.helpers
#         skill_results: ->
#             if Session.get('skill_search') and Session.get('skill_search').length > 1
#                 Docs.find 
#                     model:'skill'
#                     title: {$regex:"#{Session.get('skill_search')}",$options:'i'}
                
#         picked_skills: ->
#             ref_doc = Docs.findOne Router.current().params.doc_id
#             Docs.find 
#                 # model:'skill'
#                 _id:$in:ref_doc.skill_ids
#         skill_search_value: ->
#             Session.get('skill_search')
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
            
            
#     Template.skill_crud.events
#         'click .toggle_assign': ->
#             Session.set('assigning_docid',@_id)
#         'click .clear_search': (e,t)->
#             Session.set('skill_search', null)
#             t.$('.skill_search').val('')

#         'click .take_skill': ->
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

#         'click .release_skill': ->
#             console.log @
#             Docs.update @_id,
#                 $unset:taken_by_user_id:1
#             $('body').toast({
#                 title: "skill released: #{@title}"
#                 message: 'yeay'
#                 class : 'info'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })

            
#         'click .remove_skill': (e,t)->
#             if confirm "remove #{@title} skill?"
#                 Docs.update Router.current().params.doc_id,
#                     $pull:
#                         skill_ids:@_id
#                         skill_titles:@title
#                 $(e.currentTarget).closest('.card').transition('fly right', 500)

#         'click .pick_skill': (e,t)->
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     skill_ids:@_id
#                     skill_titles:@title
#             Session.set('skill_search',null)
#             t.$('.skill_search').val('')
                    
#         'keyup .skill_search': (e,t)->
#             # if e.which is '13'
#             val = t.$('.skill_search').val()
#             console.log val
#             Session.set('skill_search', val)
#             if e.which is '13'
#                 new_id = 
#                     Docs.insert 
#                         model:'skill'
#                         title:Session.get('skill_search')
#                 Docs.update Router.current().params.doc_id,
#                     $addToSet:
#                         skill_ids:new_id
#                         skill_titles:Session.get('skill_search')
#                 $('body').toast({
#                     title: "added #{Session.get('skill_search')}"
#                     message: 'yeay'
#                     class : 'success'
#                     showIcon:'shield'
#                     showProgress:'bottom'
#                     position:'bottom right'
#                 })

#         'click .create_skill': ->
#             parent = Docs.findOne Router.current().params.doc_id
#             new_id = 
#                 Docs.insert 
#                     model:'skill'
#                     title:Session.get('skill_search')
#                     parent_id:parent._id
#                     parent_model:parent.model
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     skill_ids:new_id
#                     skill_titles:Session.get('skill_search')
#             $('body').toast({
#                 title: "added #{Session.get('skill_search')}"
#                 message: 'yeay'
#                 class : 'success'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })
                    
#             Session.set('skill_search',null)
        
#             # Docs.update
#             # Router.go "/skill/#{new_id}/edit"


# if Meteor.isServer 
#     Meteor.publish 'skill_search_results', (title_query)->
#         Docs.find 
#             model:'skill'
#             title: {$regex:"#{title_query}",$options:'i'}