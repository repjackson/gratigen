
if Meteor.isClient
    Template.send_sms_button.events 
        'click .send_message': ->
            body = prompt 'whats the message'
            if body
                console.log 'prompt', body
                # target = 'recipient'
                string_body  = String(body)
                # current_user = Meteor.users.findOne username:Router.current().params.username
                current_username = Router.current().params.username
                # if current_username and body
                Meteor.call 'send_sms', string_body, current_username,->
                # Meteor.call 'send_sms', 'work please', 'dev',->

