if Meteor.isClient
    Template.dev.onCreated ->
        # @autorun => @subscribe 'my_current_thing', ->
        @autorun => @subscribe 'my_current_thing', Session.get('current_thing_id'),->
        @autorun => @subscribe 'dev',->
if Meteor.isServer
    Meteor.publish 'dev_file', ->
        Docs.find
            model:'dev'
    
if Meteor.isClient
    Template.dev.events 
    Template.dev.helpers 
        dev_file: ->
            Docs.findOne 
                model:'dev'
                
        