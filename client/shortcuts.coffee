globalHotkeys = new Hotkeys();

globalHotkeys.add
	combo: "c"
	callback: ->
        Session.set('view_chat', !Session.get('view_chat'))

globalHotkeys.add
	combo: "d r"
	callback: ->
        model_slug =  Template.parentData().model_slug
        Session.set 'loading', true
        Meteor.call 'set_facets', model_slug, ->
            Session.set 'loading', false

globalHotkeys.add
	combo: "?"
	callback: ->
		$('.global_search').focus()

		# $('.ui.basic.modal').modal(
		# 	inverted:true
		# 	duration:200
		# 	).modal('show')
		Session.set('current_global_query', null)

globalHotkeys.add
	combo: "d c"
	callback: ->
	    if 'admin' in Meteor.user().roles
            model = Docs.findOne
                model:'model'
                slug: Template.parentData().model_slug
            gstate_set "/model/edit/#{model._id}"

globalHotkeys.add
	combo: "d s"
	callback: ->
        model = Docs.findOne Meteor.user()._model
        gstate_set "/m/#{model.slug}"

globalHotkeys.add
	combo: "d e"
	callback: ->
        doc = Docs.findOne Meteor.user()._model
        gstate_set "/m/#{doc.model}/#{doc._id}/edit"


globalHotkeys.add
	combo: "r a"
	callback: ->
	    Meteor.users.update Meteor.userId(),
	        admin_mode:!Meteor.user().admin_mode
	    
        # if Meteor.userId() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c','YFPxjXCgjhMYEPADS']
        #     if Meteor.user().roles and 'admin' in Meteor.user().roles
        #         Meteor.users.update Meteor.userId(), $pull:roles:'admin'
        #     else
        #         Meteor.users.update Meteor.userId(), $addToSet:roles:'admin'
globalHotkeys.add
	combo: "r s"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c','YFPxjXCgjhMYEPADS']
            if 'steward' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'steward'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'steward'
globalHotkeys.add
	combo: "r d"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c']
            if Meteor.user().roles and 'dev' in Meteor.user().roles
                Meteor.users.update Meteor.userId(), $pull:roles:'dev'
            else
                Meteor.users.update Meteor.userId(), $addToSet:roles:'dev'

# globalHotkeys.add
# 	combo: "m r "
# 	callback: ->
#         if Meteor.userId()
#             Meteor.call ''
#                 Meteor.users.update Meteor.userId(), $pull:roles:'frontdesk'
#             else
#                 Meteor.users.update Meteor.userId(), $addToSet:roles:'frontdesk'



globalHotkeys.add
	combo: "g h"
	callback: -> gstate_set '/'
globalHotkeys.add
	combo: "g d"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c','YFPxjXCgjhMYEPADS']
            gstate_set '/dev'
globalHotkeys.add
	combo: "g p"
	callback: -> gstate_set "/user/#{Meteor.user().username}"



globalHotkeys.add
	combo: "g h"
	callback: -> gstate_set '/'
globalHotkeys.add
	combo: "g d"
	callback: ->
        if Meteor.userId() and Meteor.userId() in ['vwCi2GTJgvBJN5F6c']
            gstate_set '/dev'
globalHotkeys.add
	combo: "s d"
	callback: ->
        _model = Docs.findOne
            model:'model'
            slug: Template.parentData().model_slug
        gstate_set "/m/#{_model.slug}/#{Meteor.user()._model}/view"
globalHotkeys.add
	combo: "g u"
	callback: ->
        model_slug =  Template.parentData().model_slug
        Session.set 'loading', true
        Meteor.call 'set_facets', model_slug, ->
            Session.set 'loading', false
        gstate_set "/m/#{model_slug}/"
globalHotkeys.add
	combo: "g p"
	callback: -> gstate_set "/user/#{Meteor.user().username}"
globalHotkeys.add
	combo: "g i"
	callback: -> gstate_set "/inbox"
# globalHotkeys.add
# 	combo: "g m"
# 	callback: -> gstate_set "/students"
globalHotkeys.add
	combo: "g a"
	callback: -> gstate_set "/admin"


globalHotkeys.add
	combo: "a d"
	callback: ->
        model = Docs.findOne
            model:'model'
            slug: Template.parentData().model_slug
        # console.log model
        if model.collection and model.collection is 'users'
            name = prompt 'first and last name'
            split = name.split ' '
            first_name = split[0]
            last_name = split[1]
            username = name.split(' ').join('_')
            # console.log username
            Meteor.call 'add_user', first_name, last_name, username, 'guest', (err,res)=>
                if err
                    alert err
                else
                    Meteor.users.update res,
                        $set:
                            first_name:first_name
                            last_name:last_name
                    gstate_set "/m/#{model.slug}/#{res}/edit"
        else
            new_doc_id = Docs.insert
                model:model.slug
            gstate_set "/m/#{model.slug}/#{new_doc_id}/edit"
	