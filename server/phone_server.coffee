accountSid = Meteor.settings.private.TWILIO_ACCOUNT_SID;
authToken = Meteor.settings.private.TWILIO_AUTH_TOKEN;
client = require('twilio')(accountSid, authToken);
Meteor.methods 
    send_sms: (message_body, recipient)->
        console.log 'sending', message_body, recipient
        if message_body and recipient
            if recipient in ['cam','dev2']
                console.log 'texting cam'
                target_number = '+17206456281'
            else
                target_number = '+12407512000'
                console.log 'texting eric'
            stringed = String message_body
            client.messages
                .create({body: stringed, from: '+13854383761', to:target_number})
                .then((message)=> 
                    console.log('message result': message)
                    new_log_id = 
                        Docs.insert 
                            model:'log'
                            log_model:'sms_message'
                            message_body:stringed
                            message_result:message
                  );
