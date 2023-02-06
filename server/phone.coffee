accountSid = Meteor.settings.private.TWILIO_ACCOUNT_SID;
authToken = Meteor.settings.private.TWILIO_AUTH_TOKEN;
client = require('twilio')(accountSid, authToken);

Meteor.methods 
    send_sms: ->
        client.messages
              .create({body: 'Hi there', from: '+12407512000', to: '+12407512000'})
              .then(message => console.log(message.sid));
