# if Meteor.isClient
#     Template.services.onCreated ->
#         @autorun => @subscribe 'model_docs', 'service', ->
#         # @autorun => @subscribe 'service_docs',
#         #     picked_tags.array()
#         #     Session.get('service_title_filter')

#         # @autorun => @subscribe 'service_facets',
#         #     picked_tags.array()
#         #     Session.get('service_title_filter')

    
    
#     Template.services.events
#         'click .add_service': ->
#             new_id = 
#                 Docs.insert 
#                     model:'service'
#             Router.go "/service/#{new_id}/edit"
            
            
            
#     Template.services.helpers
#         picked_tags: -> picked_tags.array()
    
#         service_docs: ->
#             Docs.find {
#                 model:'service'
#                 private:$ne:true
#             }, sort:_timestamp:-1    
#         tag_results: ->
#             Results.find {
#                 model:'tag'
#             }, sort:_timestamp:-1

#     Template.user_services.onCreated ->
#         @autorun => Meteor.subscribe 'user_services', Router.current().params.username, ->
#     Template.user_services.helpers
#         service_docs: ->
#             Docs.find {
#                 model:'service'
#             }, sort:_timestamp:-1    
    
#     Template.service_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
#     Template.service_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
#     Template.service_card.onCreated ->
#         @autorun => Meteor.subscribe 'doc_comments', @data._id, ->


#     Template.service_card.events
#         'click .view_service': ->
#             Router.go "/service/#{@_id}"
#     Template.service_item.events
#         'click .view_service': ->
#             Router.go "/service/#{@_id}"

#     Template.service_view.events
#         'click .add_service_recipe': ->
#             new_id = 
#                 Docs.insert 
#                     model:'recipe'
#                     service_ids:[@_id]
#             Router.go "/recipe/#{new_id}/edit"

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
    
    
#     Template.service_edit.events
#         'click .delete_service': ->
#             Swal.fire({
#                 title: "delete service?"
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
#                         title: 'service removed',
#                         showConfirmButton: false,
#                         timer: 1500
#                     )
#                     Router.go "/services"
#             )

#         'click .publish': ->
#             Swal.fire({
#                 title: "publish service?"
#                 text: "point bounty will be held from your account"
#                 icon: 'question'
#                 confirmButtonText: 'publish'
#                 confirmButtonColor: 'green'
#                 showCancelButton: true
#                 cancelButtonText: 'cancel'
#                 reverseButtons: true
#             }).then((result)=>
#                 if result.value
#                     Meteor.call 'publish_service', @_id, =>
#                         Swal.fire(
#                             position: 'bottom-end',
#                             icon: 'success',
#                             title: 'service published',
#                             showConfirmButton: false,
#                             timer: 1000
#                         )
#             )

#         'click .unpublish': ->
#             Swal.fire({
#                 title: "unpublish service?"
#                 text: "point bounty will be returned to your account"
#                 icon: 'question'
#                 confirmButtonText: 'unpublish'
#                 confirmButtonColor: 'orange'
#                 showCancelButton: true
#                 cancelButtonText: 'cancel'
#                 reverseButtons: true
#             }).then((result)=>
#                 if result.value
#                     Meteor.call 'unpublish_service', @_id, =>
#                         Swal.fire(
#                             position: 'bottom-end',
#                             icon: 'success',
#                             title: 'service unpublished',
#                             showConfirmButton: false,
#                             timer: 1000
#                         )
#             )
            
# if Meteor.isServer
#     Meteor.publish 'user_services', (username)->
#         user = Meteor.users.findOne username:username
        
#         Docs.find 
#             model:'service'
#             _author_id:user._id
    
#     Meteor.publish 'service_count', (
#         picked_tags
#         picked_sections
#         service_query
#         view_vegan
#         view_gf
#         )->
#         # @unblock()
    
#         # console.log picked_tags
#         self = @
#         match = {model:'service'}
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
#         if service_query and service_query.length > 1
#             console.log 'searching service_query', service_query
#             match.title = {$regex:"#{service_query}", $options: 'i'}
#         Counts.publish this, 'service_counter', Docs.find(match)
#         return undefined


# if Meteor.isClient
#     Template.service_card.onCreated ->
#         # @autorun => Meteor.subscribe 'model_docs', 'food'
#     Template.service_card.events
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

#     Template.service_card.helpers
#         service_card_class: ->
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
#     Router.route '/my_services', (->
#         @layout 'layout'
#         @render 'services'
#         ), name:'my_services'
    
#     Template.services.onCreated ->
#         @autorun => @subscribe 'service_docs',
#             picked_tags.array()
#             Session.get('service_title_filter')

#         @autorun => @subscribe 'service_facets',
#             picked_tags.array()
#             Session.get('service_title_filter')

#     Template.services.events
#         'click .pick_service_tag': -> picked_tags.push @title
#         'click .unpick_service_tag': -> picked_tags.remove @valueOf()

                
            
#     Template.services.helpers
#         picked_tags: -> picked_tags.array()
    
#         service_docs: ->
#             Docs.find 
#                 model:'service'
#                 # service_id: Meteor.user().current_service_id
                
#         service_tag_results: ->
#             Results.find {
#                 model:'service_tag'
#             }, sort:_timestamp:-1
  
                

            
#     Template.service_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
#         @autorun => Meteor.subscribe 'service_work', Router.current().params.doc_id, ->
#         # @autorun => Meteor.subscribe 'model_docs', 'location', ->
#         @autorun => Meteor.subscribe 'child_services_from_parent_id', Router.current().params.doc_id,->
 
#     Template.service_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
#         @autorun => Meteor.subscribe 'service_work', Router.current().params.doc_id, ->
#         # @autorun => Meteor.subscribe 'model_docs', 'location', ->
    


#     # Template.service_view.events
#     #     'click .record_work': ->
#     #         new_id = Docs.insert 
#     #             model:'work'
#     #             service_id: Router.current().params.doc_id
#     #         Router.go "/work/#{new_id}/edit"    
    
                
           
#     Template.service_view.helpers
#         possible_locations: ->
#             service = Docs.findOne Router.current().params.doc_id
#             Docs.find
#                 model:'location'
#                 _id:$in:service.location_ids
                
#         service_work: ->
#             Docs.find 
#                 model:'work'
#                 service_id:Router.current().params.doc_id
                
#     Template.service_edit.helpers
#         service_locations: ->
#             Docs.find
#                 model:'location'
                
#         location_class: ->
#             service = Docs.findOne Router.current().params.doc_id
#             if service.location_ids and @_id in service.location_ids then 'blue' else 'basic'
            
                
#     Template.service_edit.events
#         'click .mark_complete': ->
#             Docs.update Router.current().params.doc_id, 
#                 $set:
#                     complete:true
#                     complete_timestamp: Date.now()
                    
#         'click .select_location': ->
#             service = Docs.findOne Router.current().params.doc_id
#             if service.location_ids and @_id in service.location_ids
#                 Docs.update Router.current().params.doc_id, 
#                     $pull:location_ids:@_id
#             else
#                 Docs.update Router.current().params.doc_id, 
#                     $addToSet:location_ids:@_id

# if Meteor.isClient
#     Template.service_crud.onCreated ->
#         @autorun => @subscribe 'service_search_results', Session.get('service_search'), ->
#         @autorun => @subscribe 'model_docs', 'service', ->
#     Template.service_crud.helpers
#         service_results: ->
#             if Session.get('service_search') and Session.get('service_search').length > 1
#                 Docs.find 
#                     model:'service'
#                     title: {$regex:"#{Session.get('service_search')}",$options:'i'}
                
#         picked_services: ->
#             ref_doc = Docs.findOne Router.current().params.doc_id
#             Docs.find 
#                 # model:'service'
#                 _id:$in:ref_doc.service_ids
#         service_search_value: ->
#             Session.get('service_search')
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
            
            
#     Template.service_crud.events
#         'click .toggle_assign': ->
#             Session.set('assigning_docid',@_id)
#         'click .clear_search': (e,t)->
#             Session.set('service_search', null)
#             t.$('.service_search').val('')

#         'click .take_service': ->
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

#         'click .release_service': ->
#             console.log @
#             Docs.update @_id,
#                 $unset:taken_by_user_id:1
#             $('body').toast({
#                 title: "service released: #{@title}"
#                 message: 'yeay'
#                 class : 'info'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })

            
#         'click .remove_service': (e,t)->
#             if confirm "remove #{@title} service?"
#                 Docs.update Router.current().params.doc_id,
#                     $pull:
#                         service_ids:@_id
#                         service_titles:@title
#                 $(e.currentTarget).closest('.card').transition('fly right', 500)

#         'click .pick_service': (e,t)->
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     service_ids:@_id
#                     service_titles:@title
#             Session.set('service_search',null)
#             t.$('.service_search').val('')
                    
#         'keyup .service_search': (e,t)->
#             # if e.which is '13'
#             val = t.$('.service_search').val()
#             console.log val
#             Session.set('service_search', val)
#             if e.which is '13'
#                 new_id = 
#                     Docs.insert 
#                         model:'service'
#                         title:Session.get('service_search')
#                 Docs.update Router.current().params.doc_id,
#                     $addToSet:
#                         service_ids:new_id
#                         service_titles:Session.get('service_search')
#                 $('body').toast({
#                     title: "added #{Session.get('service_search')}"
#                     message: 'yeay'
#                     class : 'success'
#                     showIcon:'shield'
#                     showProgress:'bottom'
#                     position:'bottom right'
#                 })

#         'click .create_service': ->
#             parent = Docs.findOne Router.current().params.doc_id
#             new_id = 
#                 Docs.insert 
#                     model:'service'
#                     title:Session.get('service_search')
#                     parent_id:parent._id
#                     parent_model:parent.model
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     service_ids:new_id
#                     service_titles:Session.get('service_search')
#             $('body').toast({
#                 title: "added #{Session.get('service_search')}"
#                 message: 'yeay'
#                 class : 'success'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })
                    
#             Session.set('service_search',null)
        
#             # Docs.update
#             # Router.go "/service/#{new_id}/edit"


# if Meteor.isServer 
#     Meteor.publish 'service_search_results', (title_query)->
#         Docs.find 
#             model:'service'
#             title: {$regex:"#{title_query}",$options:'i'}
        