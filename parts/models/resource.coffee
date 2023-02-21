# if Meteor.isServer
#     Meteor.publish 'resource_results', (
#         picked_tags
#         lat=50
#         long=100
#         limit=42
#         doc_sort_key
#         doc_sort_direction
#         )->
#         # console.log picked_tags
#         if doc_sort_key
#             sort_key = doc_sort_key
#         if doc_sort_direction
#             sort_direction = parseInt(doc_sort_direction)
#         self = @
#         match = {model:'resource'}
#         if picked_tags.length > 0
#             match.tags = $all: picked_tags
#             # sort = 'price_per_serving'
#         else
#             # match.tags = $nin: ['wikipedia']
#             sort = '_timestamp'
#             # match.source = $ne:'wikipedia'
#         # if Meteor.userId()
#         #     match._author_id = $ne:Meteor.userId()

#         # match.tags = $all: picked_tags
#         # if filter then match.model = filter
#         # keys = _.keys(prematch)
#         # for key in keys
#         #     key_array = prematch["#{key}"]
#         #     if key_array and key_array.length > 0
#         #         match["#{key}"] = $all: key_array
#             # console.log 'current facet filter array', current_facet_filter_array
#         # match.location = 
#         #    { $near : [ -73.9667, 40.78 ], $maxDistance: 110 }
            
#         #   { $near :
#         #       {
#         #         $geometry: { type: "Point",  coordinates: [ long, lat ] },
#         #         $minDistance: 1000,
#         #         $maxDistance: 5000
#         #       }
#         #   }
        

#         # console.log 'resource match', match
#         # console.log 'sort key', sort_key
#         # console.log 'sort direction', sort_direction
#         Docs.find match,
#             sort:"#{sort_key}":sort_direction
#             # sort:_timestamp:-1
#             limit: limit

#     Meteor.publish 'resource_facets', (
#         picked_tags=[]
#         lat
#         long
#         picked_timestamp_tags
#         query
#         doc_limit
#         doc_sort_key
#         doc_sort_direction
#         )->
#         # console.log 'lat', lat
#         # console.log 'long', long
#         # console.log 'selected tags', picked_tags

#         self = @
#         match = {}
#         match.model = 'resource'
#         if Meteor.userId()
#             match._author_id = $ne:Meteor.userId()
#         if picked_tags.length > 0 then match.tags = $all: picked_tags
#             # match.$regex:"#{current_query}", $options: 'i'}
#         # if lat
#         #     match.location = 
#         #        { $near :
#         #           {
#         #             $geometry: { type: "Point",  coordinates: [ lat, long ] },
#         #             $minDistance: 1000,
#         #             $maxDistance: 5000
#         #           }
#         #        }
#         agg_doc_count = Docs.find(match).count()
#         # console.log match
#         tag_cloud = Docs.aggregate [
#             { $match: match }
#             { $project: "tags": 1 }
#             { $unwind: "$tags" }
#             { $group: _id: "$tags", count: $sum: 1 }
#             { $match: _id: $nin: picked_tags }
#             { $match: count: $lt: agg_doc_count }
#             { $sort: count: -1, _id: 1 }
#             { $limit: 20 }
#             { $project: _id: 0, title: '$_id', count: 1 }
#         ], {
#             allowDiskUse: true
#         }

#         tag_cloud.forEach (tag, i) =>
#             # console.log 'tag result ', tag
#             self.added 'results', Random.id(),
#                 title: tag.title
#                 count: tag.count
#                 model:'tag'
#                 # category:key
#                 # index: i
#         self.ready()




# if Meteor.isClient
#     Router.route '/resource/:doc_id/', (->
#         @layout 'layout'
#         @render 'resource_view'
#         ), name:'resource_view'
#     Router.route '/resource/:doc_id/edit', (->
#         @layout 'layout'
#         @render 'resource_edit'
#         ), name:'resource_edit'


    
#     Template.resource_big_card.onCreated ->
#         @autorun => @subscribe 'resource_orders',@data._id, ->
#     Template.resource_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => @subscribe 'resource_orders',Router.current().params.doc_id, ->
#     Template.resource_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => @subscribe 'resource_orders',Router.current().params.doc_id, ->
#     Template.resource_view.onRendered ->
#         Docs.update Router.current().params.doc_id, 
#             $inc:views:1
    
#     Template.resource_view.helpers
#         future_order_docs: ->
#             Docs.find 
#                 model:'order'
#                 resource_id:Router.current().params.doc_id
                
                
                
#     Template.resource_card.events
#         'click .flat_pick_tag': -> picked_tags.push @valueOf()
        
#     Template.resource_view.events
#         'click .new_order': (e,t)->
#             resource = Docs.findOne Router.current().params.doc_id
#             new_order_id = Docs.insert
#                 model:'order'
#                 resource_id: @_id
#                 resource_id:resource._id
#                 resource_title:resource.title
#                 resource_image_id:resource.image_id
#                 resource_image_link:resource.image_link
#                 resource_daily_rate:resource.daily_rate
#             Router.go "/order/#{new_order_id}/edit"
            
#         'click .goto_tag': ->
#             picked_tags.push @valueOf()
#             Router.go '/'
            
#         'click .cancel_order': ->
#             console.log 'hi'
#             Swal.fire({
#                 title: "cancel?"
#                 # text: "this will charge you $5"
#                 icon: 'question'
#                 showCancelButton: true,
#                 confirmButtonText: 'confirm'
#                 cancelButtonText: 'cancel'
#             }).then((result)=>
#                 if result.value
#                     Docs.remove @_id
#                 )

#     Template.quickbuy.helpers
#         button_class: ->
#             tech_form = moment().add(@day_diff, 'days').format('YYYY-MM-DD')
#             found_order = 
#                 Docs.findOne
#                     model:'order'
#                     order_date:tech_form
#             if found_order
#                 'disabled'
#             else 
#                 'large'
                    
                    
                    
#         human_form: ->
#             moment().add(@day_diff, 'days').format('ddd, MMM Do')
#         from_form: ->
#             moment().add(@day_diff, 'days').fromNow()
            
#     Template.quickbuy.events
#         'click .buy': ->
#             console.log @
#             context = Template.parentData()
#             human_form = moment().add(@day_diff, 'days').format('dddd, MMM Do')
#             tech_form = moment().add(@day_diff, 'days').format('YYYY-MM-DD')
#             Swal.fire({
#                 title: "quickbuy #{human_form}?"
#                 # text: "this will charge you $5"
#                 icon: 'question'
#                 showCancelButton: true,
#                 confirmButtonText: 'confirm'
#                 cancelButtonText: 'cancel'
#             }).then((result)=>
#                 if result.value
#                     resource = Docs.findOne context._id
#                     new_order_id = Docs.insert
#                         model:'order'
#                         resource_id: resource._id
#                         order_date: tech_form
#                         _seller_username:resource._author_username
#                         resource_id:resource._id
#                         resource_title:resource.title
#                         resource_image_id:resource.image_id
#                         resource_image_link:resource.image_link
#                         resource_daily_rate:resource.daily_rate
#                     Swal.fire(
#                         "reserved for #{human_form}",
#                         ''
#                         'success'
#                     )
#             )

            

# if Meteor.isServer
#     Meteor.publish 'user_resources', (username)->
#         user = Meteor.users.findOne username:username
#         Docs.find
#             model:'resource'
#             _author_id: user._id
            
#     Meteor.publish 'resource_orders', (doc_id)->
#         resource = Docs.findOne doc_id
#         Docs.find
#             model:'order'
#             resource_id:resource._id
            
            
            
            
# if Meteor.isClient
#     Template.resource_stats.events
#         'click .refresh_resource_stats': ->
#             Meteor.call 'refresh_resource_stats', @_id




#     Template.order_segment.events
#         'click .calc_res_numbers': ->
#             start_date = moment(@start_timestamp).date()
#             start_month = moment(@start_timestamp).month()
#             start_minute = moment(@start_timestamp).minute()
#             start_hour = moment(@start_timestamp).hour()
#             Docs.update @_id,
#                 $set:
#                     start_date:start_date
#                     start_month:start_month
#                     start_hour:start_hour
#                     start_minute:start_minute



# if Meteor.isServer
#     Meteor.publish 'resource_orders_by_id', (resource_id)->
#         Docs.find
#             model:'order'
#             resource_id: resource_id


#     Meteor.publish 'order_by_day', (product_id, month_day)->
#         # console.log month_day
#         # console.log product_id
#         orders = Docs.find(model:'order',product_id:product_id).fetch()
#         # for order in orders
#             # console.log 'id', order._id
#             # console.log order.paid_amount
#         Docs.find
#             model:'order'
#             product_id:product_id

#     Meteor.publish 'order_slot', (moment_ob)->
#         resources_return = []
#         for day in [0..6]
#             day_number++
#             # long_form = moment(now).add(day, 'days').format('dddd MMM Do')
#             date_string =  moment(now).add(day, 'days').format('YYYY-MM-DD')
#             console.log date_string
#             resources.return.push date_string
#         resources_return

#         # data.long_form
#         # Docs.find
#         #     model:'order_slot'


#     Meteor.methods
#         refresh_resource_stats: (resource_id)->
#             resource = Docs.findOne resource_id
#             # console.log resource
#             orders = Docs.find({model:'order', resource_id:resource_id})
#             order_count = orders.count()
#             total_earnings = 0
#             total_resource_hours = 0
#             average_resource_duration = 0

#             # shortest_order =
#             # longest_order =

#             for res in orders.fetch()
#                 total_earnings += parseFloat(res.cost)
#                 total_resource_hours += parseFloat(res.hour_duration)

#             average_resource_cost = total_earnings/order_count
#             average_resource_duration = total_resource_hours/order_count

#             Docs.update resource_id,
#                 $set:
#                     order_count: order_count
#                     total_earnings: total_earnings.toFixed(0)
#                     total_resource_hours: total_resource_hours.toFixed(0)
#                     average_resource_cost: average_resource_cost.toFixed(0)
#                     average_resource_duration: average_resource_duration.toFixed(0)
                    
                    
# if Meteor.isClient
#     Template.resource_crud.onCreated ->
#         @autorun => @subscribe 'resource_search_results', Session.get('resource_search'), ->
#         @autorun => @subscribe 'model_docs', 'resource', ->
#     Template.resource_crud.helpers
#         resource_results: ->
#             if Session.get('resource_search') and Session.get('resource_search').length > 1
#                 Docs.find 
#                     model:'resource'
#                     title: {$regex:"#{Session.get('resource_search')}",$options:'i'}
                
#         picked_resources: ->
#             ref_doc = Docs.findOne Router.current().params.doc_id
#             Docs.find 
#                 # model:'resource'
#                 _id:$in:ref_doc.resource_ids
#         resource_search_value: ->
#             Session.get('resource_search')
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
            
            
#     Template.resource_crud.events
#         'click .toggle_assign': ->
#             Session.set('assigning_docid',@_id)
#         'click .clear_search': (e,t)->
#             Session.set('resource_search', null)
#             t.$('.resource_search').val('')

#         'click .take_resource': ->
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

#         'click .release_resource': ->
#             console.log @
#             Docs.update @_id,
#                 $unset:taken_by_user_id:1
#             $('body').toast({
#                 title: "resource released: #{@title}"
#                 message: 'yeay'
#                 class : 'info'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })

            
#         'click .remove_resource': (e,t)->
#             if confirm "remove #{@title} resource?"
#                 Docs.update Router.current().params.doc_id,
#                     $pull:
#                         resource_ids:@_id
#                         resource_titles:@title
#                 $(e.currentTarget).closest('.card').transition('fly right', 500)

#         'click .pick_resource': (e,t)->
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     resource_ids:@_id
#                     resource_titles:@title
#             Session.set('resource_search',null)
#             t.$('.resource_search').val('')
                    
#         'keyup .resource_search': (e,t)->
#             # if e.which is '13'
#             val = t.$('.resource_search').val()
#             console.log val
#             Session.set('resource_search', val)
#             if e.which is '13'
#                 new_id = 
#                     Docs.insert 
#                         model:'resource'
#                         title:Session.get('resource_search')
#                 Docs.update Router.current().params.doc_id,
#                     $addToSet:
#                         resource_ids:new_id
#                         resource_titles:Session.get('resource_search')
#                 $('body').toast({
#                     title: "added #{Session.get('resource_search')}"
#                     message: 'yeay'
#                     class : 'success'
#                     showIcon:'shield'
#                     showProgress:'bottom'
#                     position:'bottom right'
#                 })

#         'click .create_resource': ->
#             parent = Docs.findOne Router.current().params.doc_id
#             new_id = 
#                 Docs.insert 
#                     model:'resource'
#                     title:Session.get('resource_search')
#                     parent_id:parent._id
#                     parent_model:parent.model
#             Docs.update Router.current().params.doc_id,
#                 $addToSet:
#                     resource_ids:new_id
#                     resource_titles:Session.get('resource_search')
#             $('body').toast({
#                 title: "added #{Session.get('resource_search')}"
#                 message: 'yeay'
#                 class : 'success'
#                 showIcon:'shield'
#                 showProgress:'bottom'
#                 position:'bottom right'
#             })
                    
#             Session.set('resource_search',null)
        
#             # Docs.update
#             # Router.go "/resource/#{new_id}/edit"


# if Meteor.isServer 
#     Meteor.publish 'resource_search_results', (title_query)->
#         Docs.find 
#             model:'resource'
#             title: {$regex:"#{title_query}",$options:'i'}