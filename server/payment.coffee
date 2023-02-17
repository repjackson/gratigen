# Future = Npm.require('fibers/future')

# Meteor.methods
#     STRIPE_single_charge: (charge, user) ->
#         # console.log 'charge', charge
#         # console.log 'user', user
#         if Meteor.isDevelopment
#             Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
#         else
#             Stripe = StripeAPI(Meteor.settings.private.stripe_live_secret)
#         # account = Meteor.users.findOne(data.church)
#         # #console.log(data)
#         # console.log '------------------------------------------------------'
#         # console.log account
#         # if !account.stripe
#         #     retVal = error:
#         #         error: 'Donation Failed'
#         #         message: 'Not ready for donations, please contact your Organization.'
#         #     return retVal
#         # console.log account.stripe
#         charge_card = new Future
#         # fee_addition = 0
#         # if account.profile.isJGFeesApply
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 70)
#         # else
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 30)
#         # #console.log(fee_addition);
#         charge_data =
#             amount: charge.amount
#             currency: 'usd'
#             source: charge.source
#             description: "credit topup"
#             # destination: account.stripe.stripeId
#         Stripe.charges.create charge_data, (error, result) ->
#             if error
#                 charge_card.return error: error
#             else
#                 charge_card.return result: result
#             return
#         new_charge = charge_card.wait()
#         console.log new_charge
#         new_charge


#     credit_topup: (charge) ->
#         console.log 'charge', charge
#         # console.log 'user', user
#         if Meteor.isDevelopment
#             Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
#         else
#             Stripe = StripeAPI(Meteor.settings.private.stripe_live_secret)
#         charge_card = new Future
#         # fee_addition = 0
#         # if account.profile.isJGFeesApply
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 70)
#         # else
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 30)
#         # #console.log(fee_addition);
#         charge_data =
#             amount: charge.amount
#             currency: 'usd'
#             source: charge.source
#             description: "credit topup"
#             # destination: account.stripe.stripeId
#         Stripe.charges.create charge_data, (error, result) ->
#             if error
#                 charge_card.return error: error
#             else
#                 charge_card.return result: result
#             return
#         new_charge = charge_card.wait()
#         console.log new_charge
#         new_charge
        
        
#     buy_membership: (charge) ->
#         console.log 'charge', charge
#         # console.log 'user', user
#         if Meteor.isDevelopment
#             Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
#         else
#             Stripe = StripeAPI(Meteor.settings.private.stripe_live_secret)
#         charge_card = new Future
#         # fee_addition = 0
#         # if account.profile.isJGFeesApply
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 70)
#         # else
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 30)
#         # #console.log(fee_addition);
#         charge_data =
#             amount: charge.amount
#             currency: 'usd'
#             source: charge.source
#             description: "riverside membership"
#             # destination: account.stripe.stripeId
#         Stripe.charges.create charge_data, (error, result) ->
#             if error
#                 charge_card.return error: error
#             else
#                 charge_card.return result: result
#             return
#         new_charge = charge_card.wait()
#         console.log new_charge
#         if new_charge
#             Docs.insert
#                 model:'transaction'
#                 transaction_type:'membership'
#                 amount:25000
#                 charge: new_charge
#             Meteor.users.update Meteor.userId(),
#                 $inc: points:500
    
    
#     buy_meal: (charge, meal_id) ->
#         console.log 'charge', charge
#         # console.log 'user', user
#         if Meteor.isDevelopment
#             Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
#         else
#             Stripe = StripeAPI(Meteor.settings.private.stripe_dao_live_secret)
#         charge_card = new Future
#         # fee_addition = 0
#         # if account.profile.isJGFeesApply
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 70)
#         # else
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 30)
#         # #console.log(fee_addition);
#         charge_data =
#             amount: charge.amount
#             currency: 'usd'
#             source: charge.source
#             description: "buy tiffen"
#             # destination: account.stripe.stripeId
#         Stripe.charges.create charge_data, (error, result) ->
#             if error
#                 charge_card.return error: error
#             else
#                 charge_card.return result: result
#             return
#         new_charge = charge_card.wait()
#         console.log 'new chaarge', new_charge
#         if new_charge
#             Docs.insert
#                 model:'mealorder'
#                 meal_id:meal_id
#                 transaction_type:'1 tiffen'
#                 amount:11
#                 charge: new_charge
    
#     send_tip: (charge, dollar_debit_id) ->
#         console.log 'charge', charge
#         # console.log 'user', user
#         if Meteor.isDevelopment
#             Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
#         else
#             Stripe = StripeAPI(Meteor.settings.private.stripe_dao_live_secret)
#         charge_card = new Future
#         # fee_addition = 0
#         # if account.profile.isJGFeesApply
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 70)
#         # else
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 30)
#         # #console.log(fee_addition);
#         charge_data =
#             amount: charge.amount
#             currency: 'usd'
#             source: charge.source
#             description: "tip"
#             # destination: account.stripe.stripeId
#         Stripe.charges.create charge_data, (error, result) ->
#             if error
#                 charge_card.return error: error
#             else
#                 charge_card.return result: result
#             return
#         new_charge = charge_card.wait()
#         console.log new_charge
#         if new_charge
#             Docs.update dollar_debit_id,
#                 $set:
#                     charge: new_charge
        
#     buy_product: (charge) ->
#         console.log 'charge', charge
#         # console.log 'user', user
#         if Meteor.isDevelopment
#             Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
#         else
#             Stripe = StripeAPI(Meteor.settings.private.stripe_live_secret)
#         charge_card = new Future
#         # fee_addition = 0
#         # if account.profile.isJGFeesApply
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 70)
#         # else
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 30)
#         # #console.log(fee_addition);
#         charge_data =
#             amount: charge.amount
#             currency: 'usd'
#             source: charge.source
#             description: charge.product_title
#             # destination: account.stripe.stripeId
#         Stripe.charges.create charge_data, (error, result) ->
#             if error
#                 charge_card.return error: error
#             else
#                 charge_card.return result: result
#             return
#         new_charge = charge_card.wait()
#         console.log new_charge
#         if new_charge
#             Docs.insert
#                 model:'order'
#                 transaction_type:'shop_purchase'
#                 payment_type:'usd'
#                 is_usd:true
#                 amount:charge.amount
#                 product_id:charge.product_id
#                 charge: new_charge
#             # Meteor.users.update Meteor.userId(),
#             #     $inc: points:500
#             Docs.update charge.product_id, 
#                 $inc:inventory:-1
    
    
    
#     buy_ticket: (charge) ->
#         console.log 'charge', charge
#         # console.log 'user', user
#         if Meteor.isDevelopment
#             Stripe = StripeAPI(Meteor.settings.private.stripe_test_secret)
#         else
#             Stripe = StripeAPI(Meteor.settings.private.stripe_live_secret)
#         charge_card = new Future
#         # fee_addition = 0
#         # if account.profile.isJGFeesApply
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 70)
#         # else
#         #     fee_addition = Math.round(data.amount * 100 * 0.019 + 30)
#         # #console.log(fee_addition);
#         charge_data =
#             amount: charge.amount
#             currency: 'usd'
#             source: charge.source
#             description: charge.event_title
#             # destination: account.stripe.stripeId
#         Stripe.charges.create charge_data, (error, result) ->
#             if error
#                 charge_card.return error: error
#             else
#                 charge_card.return result: result
#             return
#         new_charge = charge_card.wait()
#         console.log new_charge
#         if new_charge
#             Docs.insert
#                 model:'order'
#                 transaction_type:'ticket_purchase'
#                 payment_type:'usd'
#                 is_usd:true
#                 amount:charge.amount
#                 event_id:charge.event_id
#                 charge: new_charge
#             # Meteor.users.update Meteor.userId(),
#             #     $inc: points:500
#             Docs.update charge.event_id, 
#                 $inc:
#                     tickets_purchased:1
                    
                    
                    
                    
# # stripe = require('stripe')('sk_test_5103F9t2l80WEvLLPcQfRPWGFslvo4htyZRCjRQ4YQ8DnRO0Qp18WNWRw7KSOxX9N0f45WU0eYeGXpkAx9MnXkaa700I9qwX0HQ');
# # Meteor.methods
# #   stripe: ()=>
# #     paymentIntent = stripe.paymentIntents.create({
# #       amount: 1000,
# #       currency: 'usd',
# #       payment_method_types: ['card'],
# #       receipt_email: 'jenny.rosen@example.com',
# #     });


# # stripe = require('stripe')
# # # ('sk_test_5103F9t2l80WEvLLPcQfRPWGFslvo4htyZRCjRQ4YQ8DnRO0Qp18WNWRw7KSOxX9N0f45WU0eYeGXpkAx9MnXkaa700I9qwX0HQ');

# # YOUR_DOMAIN = 'http://localhost:4242';

# # # app.post('/create-checkout-session', async (req, res) => {
# # Meteor.methods 
# #     stripe: (req, res) =>
# #         console.log 'stripe', stripe
# #         session = stripe.checkout.sessions.create({
# #             line_items: [
# #                 {
# #                 # // Provide the exact Price ID (for example, pr_1234) of the product you want to sell
# #                     price: 'business',
# #                     quantity: 1,
# #                 },
# #             ],
# #             mode: 'payment',
# #             success_url: "#{YOUR_DOMAIN}/success.html",
# #             cancel_url: "#{YOUR_DOMAIN}/cancel.html",
# #       })