# if Meteor.isClient
#     Router.route '/order/:doc_id/', (->
#         @render 'order_view'
#         ), name:'order_view'
#     Template.order_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'rental_by_res_id', Router.current().params.doc_id


#     # Template.rental_view_orders.onCreated ->
#     #     @autorun -> Meteor.subscribe 'rental_orders',
#     #         Template.currentData()
#     #         Session.get 'res_view_mode'
#     #         Session.get 'date_filter'
#     # Template.rental_view_orders.helpers
#     #     orders: ->
#     #         Docs.find {
#     #             model:'order'
#     #         }, sort: start_datetime:-1
#     #     view_res_cards: -> Session.equals 'res_view_mode', 'cards'
#     #     view_res_segments: -> Session.equals 'res_view_mode', 'segments'
#     # Template.rental_view_orders.events
#     #     'click .set_card_view': -> Session.set 'res_view_mode', 'cards'
#     #     'click .set_segment_view': -> Session.set 'res_view_mode', 'segments'

#     Template.order_events.onCreated ->
#         @autorun => Meteor.subscribe 'log_events', Router.current().params.doc_id
#     Template.order_events.helpers
#         log_events: ->
#             Docs.find
#                 model:'log_event'
#                 parent_id: Router.current().params.doc_id

#     # Template.rental_stats.onRendered ->
#     #     Meteor.setTimeout ->
#     #         $('.accordion').accordion()
#     #     , 1000

#     # Template.rental_view_orders.onRendered ->
#     #     Session.setDefault 'view_mode', 'cards'


#     # Template.set_date_filter.events
#     #     'click .set_date_filter': -> Session.set 'date_filter', @key
#     #
#     # Template.set_date_filter.helpers
#     #     date_filter_class: ->
#     #         if Session.equals('date_filter', @key) then 'active' else ''


# if Meteor.isServer
#     # Meteor.publish 'rental_orders', (rental, view_mode, date_filter)->
#     #     console.log view_mode
#     #     console.log date_filter
#     #     Docs.find
#     #         model:'order'
#     #         rental_id: rental._id


#     Meteor.publish 'log_events', (parent_id)->
#         Docs.find
#             model:'log_event'
#             parent_id:parent_id

#     Meteor.publish 'orders_by_product_id', (product_id)->
#         Docs.find
#             model:'order'
#             product_id:product_id

#     Meteor.publish 'rental_by_res_id', (res_id)->
#         order = Docs.findOne res_id
#         if order
#             Docs.find
#                 model:'rental'
#                 _id: order.rental_id

#     Meteor.publish 'owner_by_res_id', (res_id)->
#         order = Docs.findOne res_id
#         rental =
#             Docs.findOne
#                 model:'rental'
#                 _id: order.rental_id

#         Docs.find
#             _id: rental.owner_username


#     Meteor.methods
#         calc_order_stats: ->
#             order_stat_doc = Docs.findOne(model:'order_stats')
#             unless order_stat_doc
#                 new_id = Docs.insert
#                     model:'order_stats'
#                 order_stat_doc = Docs.findOne(model:'order_stats')
#             console.log order_stat_doc
#             total_count = Docs.find(model:'order').count()
#             submitted_count = Docs.find(model:'order', submitted:true).count()
#             current_count = Docs.find(model:'order', current:true).count()
#             unsubmitted_count = Docs.find(model:'order', submitted:$ne:true).count()
#             Docs.update order_stat_doc._id,
#                 $set:
#                     total_count:total_count
#                     submitted_count:submitted_count
#                     current_count:current_count



# if Meteor.isClient
#     Router.route '/order/:doc_id/edit', (->
#         @render 'order_edit'
#         ), name:'order_edit'

#     Template.order_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'rental_by_res_id', Router.current().params.doc_id
#         # @autorun => Meteor.subscribe 'owner_by_res_id', Router.current().params.doc_id
#         # @autorun => Meteor.subscribe 'handler_by_res_id', Router.current().params.doc_id
#         # @autorun => Meteor.subscribe 'user_by_username', 'deb_sclar'
#     # Template.order_edit.onRendered =>
#     #     if Meteor.user()
#     #         Meteor.call 'calc_user_points', Meteor.user().username, ->



#     Template.order_edit.helpers
#         rental: -> Docs.findOne model:'rental'
#         now_button_class: -> if @now then 'active' else ''
#         sel_hr_class: -> if @duration_type is 'hour' then 'active' else ''
#         sel_day_class: -> if @duration_type is 'day' then 'active' else ''

#         is_paying: -> Session.get 'paying'

#         can_buy: ->
#             Meteor.user().points > @total_cost

#         need_credit: ->
#             Meteor.user().points < @total_cost


#         submit_button_class: ->
#             if @start_datetime and @end_datetime then '' else 'disabled'

#         member_balance_after_order: ->
#             rental = Docs.findOne @rental_id
#             if rental
#                 current_balance = Meteor.user().points
#                 (current_balance-@total_cost).toFixed(2)

#         # diff: -> moment(@end_datetime).diff(moment(@start_datetime),'hours',true)

#     # Template.order_edit.events
#     #     'click .add_credit': ->
#     #         deposit_amount = Math.abs(parseFloat($('.adding_credit').val()))
#     #         stripe_charge = parseFloat(deposit_amount)*100*1.02+20
#     #         # stripe_charge = parseInt(deposit_amount*1.02+20)

#     #         # if confirm "add #{deposit_amount} credit?"
#     #         Template.instance().checkout.open
#     #             name: 'credit deposit'
#     #             # email:Meteor.user().emails[0].address
#     #             description: 'gold run'
#     #             amount: stripe_charge

#     #     'click .trigger_recalc': ->
#     #         Meteor.call 'recalc_order_cost', Router.current().params.doc_id
#     #         $('.handler')
#     #           .transition({
#     #             animation : 'pulse'
#     #             duration  : 500
#     #             interval  : 200
#     #           })
#     #         $('.result')
#     #           .transition({
#     #             animation : 'pulse'
#     #             duration  : 500
#     #             interval  : 200
#     #           })


#     #     'click .cancel_order': ->
#     #         if confirm 'delete order?'
#     #             Docs.remove @_id
#     #             Router.go "/rental/#{@rental_id}/"


#     #     #     rental = Docs.findOne @rental_id
#     #     #     # console.log @
#     #     #     Docs.update @_id,
#     #     #         $set:
#     #     #             submitted:true
#     #     #             submitted_timestamp:Date.now()
#     #     #     Meteor.call 'pay_for_order', @_id, =>
#     #     #         Router.go "/order/#{@_id}/"



# if Meteor.isServer
#     Meteor.methods
#         recalc_order_cost: (res_id)->
#             res = Docs.findOne res_id
#             # console.log res
#             rental = Docs.findOne res.rental_id
#             hour_duration = moment(res.end_datetime).diff(moment(res.start_datetime),'hours',true)
#             cost = parseFloat hour_duration*rental.hourly_dollars
#             total_cost = cost
#             taxes_payout = parseFloat((cost*.05))
#             owner_payout = parseFloat((cost*.5))
#             handler_payout = parseFloat((cost*.45))
#             if rental.security_deposit_required
#                 total_cost += rental.security_deposit_amount
#             if res.res_start_dropoff_selected
#                 total_cost += rental.res_start_dropoff_fee
#                 handler_payout += rental.res_start_dropoff_fee
#             if res.res_end_pickup_selected
#                 total_cost += rental.res_end_pickup_fee
#                 handler_payout += rental.res_end_pickup_fee
#             # console.log diff
#             Docs.update res._id,
#                 $set:
#                     hour_duration: hour_duration.toFixed(2)
#                     cost: cost.toFixed(2)
#                     total_cost: total_cost.toFixed(2)
#                     taxes_payout: taxes_payout.toFixed(2)
#                     owner_payout: owner_payout.toFixed(2)
#                     handler_payout: handler_payout.toFixed(2)

#         pay_for_order: (res_id)->
#             res = Docs.findOne res_id
#             # console.log res
#             rental = Docs.findOne res.rental_id

#             Meteor.call 'send_payment', Meteor.user().username, rental.owner_username, res.owner_payout, 'owner_payment', res_id
#             Docs.insert
#                 model:'log_event'
#                 log_type: 'payment'

#             Meteor.call 'send_payment', Meteor.user().username, rental.handler_username, res.handler_payout, 'handler_payment', res_id
#             Meteor.call 'send_payment', Meteor.user().username, 'dev', res.taxes_payout, 'taxes_payment', res_id

#             Docs.insert
#                 model:'log_event'
#                 parent_id:res_id
#                 res_id: res_id
#                 rental_id: res.rental_id
#                 log_type:'order_submission'
#                 text:"order submitted by #{Meteor.user().username}"

#         send_payment: (from_username, to_username, amount, reason, order_id)->
#             console.log 'sending payment from', from_username, 'to', to_username, 'for', amount, reason, order_id
#             res = order_id
#             sender = Docs.findOne username:from_username
#             recipient = Docs.findOne username:to_username


#             console.log 'sender', sender._id
#             console.log 'recipient', recipient._id
#             console.log typeof amount
#             #
#             amount  = parseFloat amount

#             Docs.update sender._id,
#                 $inc: credit: -amount

#             Docs.update recipient._id,
#                 $inc: credit: amount

#             Docs.insert
#                 model:'payment'
#                 sender_username: from_username
#                 sender_id: sender._id
#                 recipient_username: to_username
#                 recipient_id: recipient._id
#                 amount: amount
#                 order_id: order_id
#                 rental_id: res.rental_id
#                 reason:reason
#             Docs.insert
#                 model:'log_event'
#                 log_type: 'payment'
#                 sender_username: from_username
#                 recipient_username: to_username
#                 amount: amount
#                 recipient_id: recipient._id
#                 text:"#{from_username} paid #{to_username} #{amount} for #{reason}."
#                 sender_id: sender._id
#             return






# if Meteor.isClient
#     Router.route '/orders', (->
#         @layout 'layout'
#         @render 'orders'
#         ), name:'orders'
    
#     Template.orders.onCreated ->
#         Session.setDefault 'view_mode', 'list'
#         Session.setDefault 'sort_key', 'daily_rate'
#         Session.setDefault 'sort_label', 'available'
#         Session.setDefault 'limit', 20
#         Session.setDefault 'view_open', true
#         @autorun => @subscribe 'count', ->
#         @autorun => @subscribe 'order_facets',
#             Session.get('query')
#             picked_tags.array()
#             picked_location_tags.array()
#             Session.get('limit')
#             Session.get('sort_key')
#             Session.get('sort_direction')
#             Session.get('view_order')
#             Session.get('view_pickup')
#             Session.get('view_open')

#         @autorun => @subscribe 'order_results',
#             Session.get('query')
#             picked_tags.array()
#             picked_location_tags.array()
#             Session.get('limit')
#             Session.get('sort_key')
#             Session.get('sort_direction')
#             Session.get('view_order')
#             Session.get('view_pickup')
#             Session.get('view_open')

    
#     Template.orders.events
#         'click .request_order': ->
#             title = prompt "different title than #{Session.get('query')}"
#             new_id = 
#                 Docs.insert 
#                     model:'request'
#                     title:Session.get('query')


#         # 'click .toggle_order': -> Session.set('view_order', !Session.get('view_order'))
#         # 'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
#         # 'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

#         'click .tag_result': -> picked_tags.push @title
#         'click .unselect_tag': ->
#             picked_tags.remove @valueOf()
#             # console.log picked_tags.array()
#             # if picked_tags.array().length is 1
#                 # Meteor.call 'call_wiki', search, ->

#             # if picked_tags.array().length > 0
#                 # Meteor.call 'search_reddit', picked_tags.array(), ->

#         'click .clear_picked_tags': ->
#             Session.set('query',null)
#             picked_tags.clear()

#         'keyup .query': _.throttle((e,t)->
#             query = $('.query').val()
#             Session.set('query', query)
#             # console.log Session.get('query')
#             if e.which is 13
#                 search = $('.query').val().trim().toLowerCase()
#                 if search.length > 0
#                     picked_tags.push search
#                     console.log 'search', search
#                     # Meteor.call 'log_term', search, ->
#                     $('.query').val('')
#                     Session.set('query', null)
#                     # # $('#search').val('').blur()
#                     # # $( "p" ).blur();
#                     # Meteor.setTimeout ->
#                     #     Session.set('dummy', !Session.get('dummy'))
#                     # , 10000
#         , 1000)

#         'click .calc_order_count': ->
#             Meteor.call 'calc_order_count', ->

#         # 'keydown #search': _.throttle((e,t)->
#         #     if e.which is 8
#         #         search = $('#search').val()
#         #         if search.length is 0
#         #             last_val = picked_tags.array().slice(-1)
#         #             console.log last_val
#         #             $('#search').val(last_val)
#         #             picked_tags.pop()
#         #             Meteor.call 'search_reddit', picked_tags.array(), ->
#         # , 1000)

#     Template.orders.helpers
#         query_requests: ->
#             Docs.find
#                 model:'request'
#                 title:Session.get('query')
            
#         counter: -> Counts.get('order_counter')
#         tags: -> Results.find({model:'tag', title:$nin:picked_tags.array()})
#         location_tags: -> Results.find({model:'location_tag',title:$nin:picked_location_tags.array()})
#         authors: -> Results.find({model:'author'})

#         result_class: ->
#             if Template.instance().subscriptionsReady()
#                 ''
#             else
#                 'disabled'

#         picked_tags: -> picked_tags.array()
#         picked_tags_plural: -> picked_tags.array().length > 1
#         searching: -> Session.get('searching')

#         one_order: ->
#             Docs.find().count() is 1
#         order_docs: ->
#             # if picked_tags.array().length > 0
#             Docs.find {
#                 model: 'order'
#                 # downvoter_ids:$nin:[Meteor.userId()]
#             },
#                 sort: "#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))
#                 limit:Session.get('limit')

#         subs_ready: ->
#             Template.instance().subscriptionsReady()


# if Meteor.isServer 
#     Meteor.publish 'order_results', (
#         query=''
#         picked_tags=[]
#         picked_location_tags=[]
#         limit=20
#         sort_key='_timestamp'
#         sort_direction=-1
#         view_delivery
#         view_pickup
#         view_open
#         )->
#         console.log picked_tags
#         self = @
#         match = {}
#         match.model = 'order'
        
#         match.app = 'goldrun'
#         # if view_open
#         #     match.open = $ne:false
#         # if view_delivery
#         #     match.delivery = $ne:false
#         # if view_pickup
#         #     match.pickup = $ne:false
#         # if Meteor.userId()
#         #     if Meteor.user().downvoted_ids
#         #         match._id = $nin:Meteor.user().downvoted_ids
#         if query
#             match.title = {$regex:"#{query}", $options: 'i'}
        
#         if picked_tags.length > 0
#             match.tags = $all: picked_tags
#             # sort = 'price_per_serving'
#         # if view_images
#         #     match.is_image = $ne:false
#         # if view_videos
#         #     match.is_video = $ne:false
    
#         # match.tags = $all: picked_tags
#         # if filter then match.model = filter
#         # keys = _.keys(prematch)
#         # for key in keys
#         #     key_array = prematch["#{key}"]
#         #     if key_array and key_array.length > 0
#         #         match["#{key}"] = $all: key_array
#             # console.log 'current facet filter array', current_facet_filter_array
    
#         # console.log 'product match', match
#         # console.log 'sort key', sort_key
#         # console.log 'sort direction', sort_direction
#         Docs.find match,
#             sort:"#{sort_key}":sort_direction
#             # sort:_timestamp:-1
#             limit: limit

# if Meteor.isClient
#     Template.order_edit.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'rental_from_order_id', Router.current().params.doc_id, ->
#         # @autorun => Meteor.subscribe 'model_docs', 'dish'

#     Template.order_edit.helpers
#         # all_dishes: ->
#         #     Docs.find
#         #         model:'dish'
#         can_delete: ->
#             order = Docs.findOne Router.current().params.doc_id
#             if order.order_ids
#                 if order.order_ids.length > 1
#                     false
#                 else
#                     true
#             else
#                 true
#         can_complete: ->
#             order = Docs.findOne Router.current().params.doc_id
#             order.rental_daily_rate < Meteor.user().points 
            
#             # order.order_date
            
            
            
#         points_after_purchase: ->
#             user_points = Meteor.user().points
#             current_order = Docs.findOne Router.current().params.doc_id
#             Meteor.user().points - current_order.rental_daily_rate


#     Template.order_edit.events
#         'click .complete_order': (e,t)->
#             Docs.update Router.current().params.doc_id,
#                 $set:
#                     complete:true
#                     completed_timestamp:Date.now()
                    
#             $('body').toast(
#                 showIcon: 'checkmark'
#                 message: 'order completed'
#                 # showProgress: 'bottom'
#                 class: 'success'
#                 # displayTime: 'auto',
#                 position: "bottom right"
#             )
            
#             Router.go "/order/#{@_id}"


#         'click .delete_order': (e,t)->
#             if confirm 'cancel order?'
#                 doc_id = Router.current().params.doc_id
#                 $(e.currentTarget).closest('.grid').transition('fly right', 500)
#                 Router.go "/rental/#{@rental_id}"

#                 Docs.remove doc_id




# if Meteor.isClient
#     Template.profile_order_item.onCreated ->
#         @autorun => Meteor.subscribe 'rental_from_order_id', @data._id
#     Template.order_view.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'rental_from_order_id', Router.current().params.doc_id


#     Template.order_view.events
#         'click .cancel_order': ->
#             if confirm 'cancel?'
#                 Docs.remove @_id
#                 Router.go "/rental/#{@rental_id}"


#     # Template.order_view.helpers
#     #     can_order: ->
#     #         # if StripeCheckout
#     #         unless @_author_id is Meteor.userId()
#     #             order_count =
#     #                 Docs.find(
#     #                     model:'order'
#     #                     order_id:@_id
#     #                 ).count()
#     #             if order_count is @servings_amount
#     #                 false
#     #             else
#     #                 true
#     #         # else
#     #         #     false




# if Meteor.isServer
#     Meteor.publish 'rental_from_order_id', (order_id)->
#         order = Docs.findOne order_id
#         Docs.find
#             _id: order.rental_id

#     # Meteor.methods
#         # order_order: (order_id)->
#         #     order = Docs.findOne order_id
#         #     Docs.insert
#         #         model:'order'
#         #         order_id: order._id
#         #         order_price: order.price_per_serving
#         #         buyer_id: Meteor.userId()
#         #     Docs.update Meteor.userId(),
#         #         $inc:credit:-order.price_per_serving
#         #     Docs.update order._author_id,
#         #         $inc:credit:order.price_per_serving
#         #     Meteor.call 'calc_order_data', order_id, ->



# if Meteor.isClient
#     Template.user_orders.onCreated ->
#         @autorun => Meteor.subscribe 'user_orders', Router.current().params.username
#         # @autorun => Meteor.subscribe 'model_docs', 'rental'
#     Template.user_orders.helpers
#         orders: ->
#             current_user = Docs.findOne username:Router.current().params.username
#             Docs.find {
#                 model:'order'
#             }, sort:_timestamp:-1

# if Meteor.isServer
#     Meteor.publish 'user_orders', (username)->
#         user = Docs.findOne username:username
#         if user
#             Docs.find({
#                 model:'order'
#                 _author_id: user._id
#             }, limit:20)