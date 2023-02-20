# if Meteor.isClient
    
#     Template.project_card.onCreated ->
#         @autorun => Meteor.subscribe 'doc_comments', @data._id, ->

#     Template.project_edit.helpers
#         child_tasks: ->
#             Docs.find
#                 model:'task'
                
                
#     Template.project_view.helpers
#         child_tasks: ->
#             Docs.find
#                 model:'task'
#                 project_id: Router.current().params.doc_id
                
                
                
#     Template.project_card.events
#         'click .view_project': ->
#             Router.go "/project/#{@_id}"

#     # Template.project_view.events
#     #     'click .add_project_recipe': ->
#     #         new_id = 
#     #             Docs.insert 
#     #                 model:'recipe'
#     #                 project_ids:[@_id]
#     #         Router.go "/recipe/#{new_id}/edit"

#     # Template.favorite_icon_toggle.helpers
#     #     icon_class: ->
#     #         if @favorite_ids and Meteor.userId() in @favorite_ids
#     #             'red'
#     #         else
#     #             'outline'
#     # Template.favorite_icon_toggle.events
#     #     'click .toggle_fav': ->
#     #         if @favorite_ids and Meteor.userId() in @favorite_ids
#     #             Docs.update @_id, 
#     #                 $pull:favorite_ids:Meteor.userId()
#     #         else
#     #             $('body').toast(
#     #                 showIcon: 'heart'
#     #                 message: "marked favorite"
#     #                 showProgress: 'bottom'
#     #                 class: 'success'
#     #                 # displayTime: 'auto',
#     #                 position: "bottom right"
#     #             )

#     #             Docs.update @_id, 
#     #                 $addToSet:favorite_ids:Meteor.userId()
    
    
#     Template.project_edit.events
#         'click .delete_project': ->
#             Swal.fire({
#                 title: "delete project?"
#                 text: "cannot be undone"
#                 icon: 'question'
#                 confirmButtonText: 'delete'
#                 confirmButtonColor: 'red'
#                 showCancelButton: true
#                 cancelButtonText: 'cancel'
#                 reverseButtons: true
#             }).then((result)=>
#                 if result.value
#                     Docs.remove @_id
#                     Swal.fire(
#                         position: 'top-end',
#                         icon: 'success',
#                         title: 'project removed',
#                         showConfirmButton: false,
#                         timer: 1500
#                     )
#                     Router.go "/projects"
#             )

#         'click .publish': ->
#             Swal.fire({
#                 title: "publish project?"
#                 text: "point bounty will be held from your account"
#                 icon: 'question'
#                 confirmButtonText: 'publish'
#                 confirmButtonColor: 'green'
#                 showCancelButton: true
#                 cancelButtonText: 'cancel'
#                 reverseButtons: true
#             }).then((result)=>
#                 if result.value
#                     Meteor.call 'publish_project', @_id, =>
#                         Swal.fire(
#                             position: 'bottom-end',
#                             icon: 'success',
#                             title: 'project published',
#                             showConfirmButton: false,
#                             timer: 1000
#                         )
#             )

#         'click .unpublish': ->
#             Swal.fire({
#                 title: "unpublish project?"
#                 text: "point bounty will be returned to your account"
#                 icon: 'question'
#                 confirmButtonText: 'unpublish'
#                 confirmButtonColor: 'orange'
#                 showCancelButton: true
#                 cancelButtonText: 'cancel'
#                 reverseButtons: true
#             }).then((result)=>
#                 if result.value
#                     Meteor.call 'unpublish_project', @_id, =>
#                         Swal.fire(
#                             position: 'bottom-end',
#                             icon: 'success',
#                             title: 'project unpublished',
#                             showConfirmButton: false,
#                             timer: 1000
#                         )
#             )
            
# if Meteor.isServer
#     Meteor.publish 'user_projects', (username)->
#         user = Meteor.users.findOne username:username
        
#         Docs.find 
#             model:'project'
#             _author_id:user._id
    
#     Meteor.publish 'project_count', (
#         picked_tags
#         picked_sections
#         project_query
#         view_vegan
#         view_gf
#         )->
#         # @unblock()
    
#         # console.log picked_tags
#         self = @
#         match = {model:'project'}
#         if picked_tags.length > 0
#             match.ingredients = $all: picked_tags
#             # sort = 'price_per_serving'
#         if picked_sections.length > 0
#             match.menu_section = $all: picked_sections
#             # sort = 'price_per_serving'
#         # else
#             # match.tags = $nin: ['wikipedia']
#         sort = '_timestamp'
#             # match.source = $ne:'wikipedia'
#         if view_vegan
#             match.vegan = true
#         if view_gf
#             match.gluten_free = true
#         if project_query and project_query.length > 1
#             console.log 'searching project_query', project_query
#             match.title = {$regex:"#{project_query}", $options: 'i'}
#         Counts.publish this, 'project_counter', Docs.find(match)
#         return undefined


# if Meteor.isClient
#     Template.project_card.onCreated ->
#         # @autorun => Meteor.subscribe 'model_docs', 'food'
#     Template.project_card.events
#         'click .quickbuy': ->
#             console.log @
#             Session.set('quickbuying_id', @_id)
#             # $('.ui.dimmable')
#             #     .dimmer('show')
#             # $('.special.cards .image').dimmer({
#             #   on: 'hover'
#             # });
#             # $('.card')
#             #   .dimmer('toggle')
#             $('.ui.modal')
#               .modal('show')

#         'click .goto_food': (e,t)->
#             # $(e.currentTarget).closest('.card').transition('zoom',420)
#             # $('.global_container').transition('scale', 500)
#             Router.go("/food/#{@_id}")
#             # Meteor.setTimeout =>
#             # , 100

#         # 'click .view_card': ->
#         #     $('.container_')

#     Template.project_card.helpers
#         project_card_class: ->
#             # if Session.get('quickbuying_id')
#             #     if Session.equals('quickbuying_id', @_id)
#             #         'raised'
#             #     else
#             #         'active medium dimmer'
#         is_quickbuying: ->
#             Session.equals('quickbuying_id', @_id)

#         food: ->
#             # console.log Meteor.user().roles
#             Docs.find {
#                 model:'food'
#             }, sort:title:1
            
            
# if Meteor.isClient
#     Template.project_crud.onCreated ->
#         @autorun => @subscribe 'project_search_results', Session.get('project_search'), ->
#         @autorun => @subscribe 'child_docs', Router.current().params.doc_id,->
# if Meteor.isServer 
#     Meteor.publish 'child_docs', (id)->
#         Docs.find
#             parent_id:id

#     Meteor.publish 'project_search_results', (title_query)->
#         Docs.find 
#             model:'project'
#             title: {$regex:"#{title_query}",$options:'i'}
# if Meteor.isClient
#     Template.project_crud.helpers
#         project_results: ->
#             if Session.get('project_search') and Session.get('project_search').length > 1
#                 Docs.find 
#                     model:'project'
#                     title: {$regex:"#{Session.get('project_search')}",$options:'i'}
                
#         picked_projects: ->
#             ref_doc = Docs.findOne Router.current().params.doc_id
#             Docs.find 
#                 # model:'project'
#                 _id:$in:ref_doc.project_ids
#         project_search_value: ->
#             Session.get('project_search')
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
            
            
#     Template.project_crud.events
#         'click .toggle_assign': ->
#             Session.set('assigning_docid',@_id)
#         'click .clear_search': (e,t)->
#             Session.set('project_search', null)
#             t.$('.project_search').val('')

#         'click .take_project': ->
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

#         'click .release_project': ->
#             console.log @
#             Docs.update @_id,
#                 $unset:taken_by_user_id:1
#             $('body').toast({
#                 title: "project released: #{@title}"
#                 message: 'yeay'
#                 class : 'info'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })

            
#         'click .remove_project': (e,t)->
#             if confirm "remove #{@title} project?"
#                 Docs.update Router.current().params.doc_id,
#                     $pull:
#                         project_ids:@_id
#                         project_titles:@title
#                 $(e.currentTarget).closest('.card').transition('fly right', 500)

#         'click .pick_project': (e,t)->
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     project_ids:@_id
#                     project_titles:@title
#             Session.set('project_search',null)
#             t.$('.project_search').val('')
                    
#         'keyup .project_search': (e,t)->
#             parent = Docs.findOne Router.current().params.doc_id
#             # if e.which is '13'
#             val = t.$('.project_search').val()
#             console.log val
#             Session.set('project_search', val)
#             if e.which is '13'
#                 new_id = 
#                     Docs.insert 
#                         model:'project'
#                         title:Session.get('project_search')
#                         parent_id:parent._id
#                         parent_model:parent.model
#                 Docs.update Router.current().params.doc_id,
#                     $addToSet:
#                         project_ids:new_id
#                         project_titles:Session.get('project_search')
#                 $('body').toast({
#                     title: "added #{Session.get('project_search')}"
#                     message: 'yeay'
#                     class : 'success'
#                     showIcon:'shield'
#                     showProgress:'bottom'
#                     position:'bottom right'
#                 })
#             val = t.$('.project_search').val('')

#         'click .create_project': ->
#             parent = Docs.findOne Router.current().params.doc_id
#             new_id = 
#                 Docs.insert 
#                     model:'project'
#                     title:Session.get('project_search')
#                     parent_id:parent._id
#                     parent_model:parent.model
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     project_ids:new_id
#                     project_titles:Session.get('project_search')
#             $('body').toast({
#                 title: "added #{Session.get('project_search')}"
#                 message: 'yeay'
#                 class : 'success'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })
                    
#             Session.set('project_search',null)
        
#             val = t.$('.project_search').val('')
#             # Docs.update
#             # Router.go "/project/#{new_id}/edit"

