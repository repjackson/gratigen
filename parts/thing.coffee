if Meteor.isClient
    Template.thing_maker.events 
        'click .show_modal': ->
            $('.ui.modal').modal({
                inverted:true
                }).modal('show')
            unless Session.get('current_thing_id')
                # unless Meteor.user().current_thing_id
                new_id = 
                    Docs.insert 
                        thing:true
                # Session.set('editing_thing_id')
                Session.set('current_thing_id', new_id)
                # Meteor.users.update Meteor.userId(),
                #     $set:
                #         current_thing_id: new_id
                
        'click .delete_thing':->
            if confirm 'delete?'
                Docs.remove @_id
                Session.set('current_thing_id', null)
                Meteor.users.update Meteor.userId(),
                    $unset:current_thing_id:1
        'click .add_thing':->
            new_id = 
                Docs.insert 
                    thing:true
            Meteor.users.update Meteor.userId(),
                $set:
                    current_thing_id: new_id
    Template.thing_maker.helpers 
        current_thing:->
            # user = Meteor.user()
            # Docs.findOne user.current_thing_id
            Docs.findOne Session.get('current_thing_id')
    Template.thing_picker.helpers
        model_picker_class:->
            if @model is Template.parentData().model
                'big'
            else 
                'basic'
    Template.thing_picker.events
        'click .pick_thing':->
            new_id = 
                Docs.insert 
                    model:@model 
            Session.set('current_thing_id', new_id)      
            Session.set('editmode',true)
            $('.ui.modal').modal({
                inverted:true
                }).modal('show')

            # Docs.update Template.parentData()._id,
            #     $set:
            #         model:@model
