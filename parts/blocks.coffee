# if Meteor.isClient
#     Template.html_notifications.events 
#         'click .check_notifications': ->
#             Notification.requestPermission (result) ->
#                 console.log result

#         'click .send_notification': ->
#             if Notification.permission is "granted"
#                 notification = new Notification("Hi there!")


if Meteor.isClient
    Template.publish_button.events
        'click .publish': ->
            Swal.fire({
                title: "publish role?"
                text: "point bounty will be held from your account"
                icon: 'question'
                confirmButtonText: 'publish'
                confirmButtonColor: 'green'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'publish_role', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'role published',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

        'click .unpublish': ->
            Swal.fire({
                title: "unpublish role?"
                text: "point bounty will be returned to your account"
                icon: 'question'
                confirmButtonText: 'unpublish'
                confirmButtonColor: 'orange'
                showCancelButton: true
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'unpublish_role', @_id, =>
                        Swal.fire(
                            position: 'bottom-end',
                            icon: 'success',
                            title: 'role unpublished',
                            showConfirmButton: false,
                            timer: 1000
                        )
            )

    # Template.dash_user_info.events 
    #     'click .print_me': ->
    #         console.log Meteor.user()
    #         alert Meteor.user()
    #         Meteor.call 'print_me', ->
    #         Meteor.users.update Meteor.userId(),
    #             $unset:updated:true


if Meteor.isClient
    Template.latest_activity.onCreated ->
        @autorun => @subscribe 'latest_home_docs', ->
    Template.latest_activity.helpers 
        latest_docs: ->
            Docs.find {_updated_timestamp:$exists:true},
                sort:
                    _updated_timestamp:-1

    Template.online_users.onCreated ->
        @autorun => @subscribe 'online_users', ->
    Template.online_users.helpers 
        online_user_docs: ->
            Meteor.users.find {online:true}
                
if Meteor.isServer
    Meteor.publish 'online_users', ->
        Meteor.users.find {online:true}



if Meteor.isClient
    Template.session_toggle.events
        'click .toggle_session_var': ->
            Session.set(@key, !Session.get(@key))
            $('body').toast(
                # showIcon: 'heart'
                message: "#{@key} #{Session.get(@key)}"
                # showProgress: 'bottom'
                # class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )

    Template.session_toggle.helpers
        session_toggle_class: ->
            if Session.get(@key) then 'active' else 'basic'
   
    Template.print_this.events
        'click .print': ->
            console.log @
   
    Template.bookmark_button.helpers
        is_bookmarked: ->
            Meteor.user().bookmark_ids and @_id in Meteor.user().bookmark_ids
            
    Template.bookmark_button.events
        'click .toggle_bookmark': ->
            if Meteor.user().bookmark_ids and @_id in Meteor.user().bookmark_ids
                Meteor.users.update Meteor.userId(), 
                    $pull: 
                        bookmark_ids:@_id
                $('body').toast(
                    showIcon: 'bookmark'
                    message: 'bookmark removed'
                    # showProgress: 'bottom'
                    class: 'info'
                    displayTime: 'auto',
                    position: "bottom right"
                )
                        
            else 
                Meteor.users.update Meteor.userId(), 
                    $addToSet: 
                        bookmark_ids:@_id
                $('body').toast(
                    showIcon: 'bookmark'
                    message: 'bookmark added'
                    # showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                    position: "bottom right"
                )
                
   
        
    Template.comments.onCreated ->
        # console.log Template.parentData(3)
        # console.log Template.parentData(4)
                
        # if Template.parentData(4)
        #     parent = Template.parentData(4)
        # else if Meteor.user()._doc_id
        #     parent = Docs.findOne Meteor.user()._doc_id
        # else
        #     parent = Template.parentData()
        parent = Template.currentData()
        # console.log Template.instance().data
        # console.log @
            
        if parent
            @autorun => Meteor.subscribe 'children', 'comment', Template.instance().data._id, ->
    Template.comments.helpers
        doc_comments: ->
            # console.log @
            # console.log Template.parentData()
            # console.log Template.parentData(1)
            # console.log Template.parentData(2)
            # console.log Template.parentData(3)
            # if Template.parentData(4)
            #     parent = Template.parentData(4)
            # else if Meteor.user()._doc_id
            #     parent = Docs.findOne Meteor.user()._doc_id
            # else
            #     parent = Docs.findOne Template.parentData()._id
            parent = Template.currentData()
            # if parent
            Docs.find
                parent_id:@_id
                model:'comment'
    Template.comments.events
        'keyup .add_comment': (e,t)->
            if e.which is 13
                # console.log Template.currentData()
                # console.log Template.parentData()
                # console.log Template.parentData(1)
                # console.log Template.parentData(2)
                # console.log Template.parentData(3)
                parent = Template.currentData()
                # if Template.parentData(4)
                #     parent = Template.parentData(4)
                # else if Meteor.user()._doc_id
                #     parent = Docs.findOne Meteor.user()._doc_id
                # else
                #     parent = Docs.findOne Template.parentData()._id
                # parent = Docs.findOne Meteor.user()._doc_id
                comment = t.$('.add_comment').val()
                Docs.insert
                    parent_id: @_id
                    model:'comment'
                    parent_model:@model
                    body:comment
                t.$('.add_comment').val('')

        'click .remove_comment': ->
            if confirm 'Confirm remove comment'
                Docs.remove @_id


    Template.set_sort_key.helpers
        sort_button_class: ->
            if Session.equals('sort_key', @key) then 'blue' else 'basic compact'
    Template.set_sort_key.events
        'click .set_sort': ->
            console.log @
            Session.set('sort_key', @key)
            Session.set('post_sort_label', @label)
            Session.set('post_sort_icon', @icon)


if Meteor.isClient
    Template.model_picker.onCreated ->
        @autorun => @subscribe 'model_search_results', Session.get('model_search'), ->
        @autorun => @subscribe 'model_docs', @data.model, ->
    Template.model_picker.helpers
        model_results: ->
            Docs.find 
                model:Template.currentData().model
                # title: {$regex:"#{Session.get('model_search')}",$options:'i'}
                
        picked_model: ->
            parent_doc = Docs.findOne Meteor.user()._doc_id
            # _id:parent_doc["#{Template.currentData().model}_id"]
            console.log Template.currentData().model
            Docs.findOne
                # model:Template.currentData().model
                _id:parent_doc["#{Template.currentData().model}_id"]
        picked_models: ->
            parent_doc = Docs.findOne Meteor.user()._doc_id
            # _id:parent_doc["#{Template.currentData().model}_id"]
            console.log Template.currentData().model
            Docs.find
                # model:Template.currentData().model
                _id:parent_doc["#{Template.currentData().model}_ids"]
        model_search_value: ->
            Session.get('model_search')
        
    Template.model_picker.events
        'click .clear_search': (e,t)->
            Session.set('model_search', null)
            t.$('.model_search').val('')
            
        'click .remove_model': (e,t)->
            if confirm "remove #{@title} model?"
                Docs.update Meteor.user()._doc_id,
                    $pull:
                        "#{Template.currentData().model}_ids":@_id
                        "#{Template.currentData().model}_titles":@title
        # 'click .remove_model': (e,t)->
        #     if confirm "remove #{@title} model?"
        #         Docs.update Meteor.user()._doc_id,
        #             $unset:
        #                 "#{Template.currentData().model}_id":@_id
        #                 "#{Template.currentData().model}_title":@title
        'click .pick_model': (e,t)->
            Docs.update Meteor.user()._doc_id,
                $set:
                    "#{Template.currentData().model}_ids":@_id
                    "#{Template.currentData().model}_titles":@title
            Session.set('model_search',null)
            t.$('.model_search').val('')
            $('body').toast({
                title: "#{@title} attached"
                # message: 'Please see desk staff for key.'
                class : 'success invert'
                showIcon:'plus'
                # showProgress:'bottom'
                position:'bottom right'
                })

        # 'click .pick_model': (e,t)->
        #     Docs.update Meteor.user()._doc_id,
        #         $set:
        #             "#{Template.currentData().model}_id":@_id
        #             "#{Template.currentData().model}_title":@title
        #     Session.set('model_search',null)
        #     t.$('.model_search').val('')
                    
        'keyup .model_search': (e,t)->
            # if e.which is '13'
            val = t.$('.model_search').val()
            console.log val
            Session.set('model_search', val)

        'click .create_model': ->
            new_model = prompt 'new model name'
            if new_model
                new_id = 
                    Docs.insert 
                        model:'model'
                        title:Session.get('model_search')
                Meteor.call 'update_state', {
                    _template:'delta'
                    _model:new_model
                    _doc_id:new_id
                    edit_mode:true
                }, ->


if Meteor.isServer 
    Meteor.publish 'model_search_results', (model_title_queary)->
        Docs.find 
            model:'model'
            title: {$regex:"#{model_title_queary}",$options:'i'}
        
        


# sdkfjvnkdf
        
if Meteor.isClient
    Template.roles.onCreated ->
        @autorun => @subscribe 'role_search_results', Session.get('role_search'), ->
        @autorun => @subscribe 'model_docs', 'role', ->
    Template.roles.helpers
        role_results: ->
            parent = Docs.findOne Meteor.user()._doc_id
            
            match = {}
            match._id = $nin:parent.role_ids
            match.title = {$regex:"#{Session.get('role_search')}",$options:'i'}
            match.model = 'role'
            
            Docs.find match
        child_roles: ->
            parent = Docs.findOne Meteor.user()._doc_id
            search = Session.get('role_search')
            match = {}    
            if search and search.length > 0
                match.title = {$regex:"#{search}",$options:'i'}
            match.model = 'role'
            match._id = $in:parent.role_ids
            Docs.find match
        role_search_value: ->
            Session.get('role_search')
        
    Template.roles.events
        'click .clear_search': (e,t)->
            Session.set('role_search', null)
            t.$('.role_search').val('')
            
        'click .remove_role': (e,t)->
            if confirm "remove #{@title} role?"
                Docs.update Meteor.user()._doc_id,
                    $pull:
                        role_ids:@_id
                        role_titles:@title
        'click .pick_role': (e,t)->
            Docs.update Meteor.user()._doc_id,
                $addToSet:
                    role_ids:@_id
                    role_titles:@title
            Session.set('role_search',null)
            t.$('.role_search').val('')
                    
        # 'keyup .role_search': _.throttle((e,t)->
        'keyup .role_search': (e,t)->
            # if e.which is '13'
            val = t.$('.role_search').val()
            console.log val
            Session.set('role_search', val)
            # , 200

        'click .create_role': (e,t)->
            title = Session.get('role_search')
            new_id = 
                Docs.insert 
                    model:'role'
                    title:title
            # gstate_set "/role/#{new_id}/edit"
            console.log Meteor.user()._doc_id
            Docs.update {_id:Meteor.user()._doc_id},
                $addToSet:
                    role_ids:new_id
                    role_titles:title
            Session.set('role_search', null)
            val = t.$('.role_search').val('')
if Meteor.isServer 
    Meteor.publish 'role_search_results', (title_query)->
        Docs.find 
            model:'role'
            title: {$regex:"#{title_query}",$options:'i'}
        
        
        
        
        
        
if Meteor.isClient
    Template.voting.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @


    Template.voting_small.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @



    # Template.doc_card.onCreated ->
    #     @autorun => Meteor.subscribe 'doc', Template.currentData().doc_id
    # Template.doc_card.helpers
    #     doc: ->
    #         Docs.findOne
    #             _id:Template.currentData().doc_id





    # Template.call_watson.events
    #     'click .autotag': ->
    #         doc = Docs.findOne Meteor.user()._doc_id
    #         console.log doc
    #         console.log @
    #
    #         Meteor.call 'call_watson', doc._id, @key, @mode

    Template.voting_full.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'upvote', @
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',200)
            Meteor.call 'downvote', @




    Template.role_editor.onCreated ->
        @autorun => Meteor.subscribe 'model', 'role'



    # Template.user_card.onCreated ->
    #     @autorun => Meteor.subscribe 'user_from_username', @data
    # Template.user_card.helpers
    #     user: -> Meteor.users.findOne @valueOf()




    # Template.big_user_card.onCreated ->
    #     @autorun => Meteor.subscribe 'user_from_username', @data
    # Template.big_user_card.helpers
    #     user: -> Meteor.users.findOne username:@valueOf()




    # Template.username_info.onCreated ->
    #     @autorun => Meteor.subscribe 'user_from_username', @data
    # Template.username_info.events
    #     'click .goto_profile': ->
    #         user = Meteor.users.findOne username:@valueOf()
    #         if user.is_current_member
    #             gstate_set "/member/#{user.username}/"
    #         else
    #             gstate_set "/user/#{user.username}/"
    # Template.username_info.helpers
    #     user: -> Meteor.users.findOne username:@valueOf()

    Template.add_model_button.events        
        'click .add_model_doc': ->
            new_id = 
                Docs.insert 
                    model:@model
                    published:false
                    # purchased:false
            gstate_set "/#{@model}/#{new_id}/edit"
            
            
    Template.search_input.events
        'keyup .search_input': (e,t)->
            search_value = $(e.currentTarget).closest('.search_input').val().trim()
            if search_value.length > 1
                console.log 'searching', search_value
                Session.set('search_value', search_value)

    Template.search_input.helpers
        search_input_class: ->
            if Session.get('search_value') then 'large active circular' else 'small'

    # Template.user_info.onCreated ->
    #     @autorun => Meteor.subscribe 'user_from_id', @data
    # Template.user_info.helpers
    #     user: -> Meteor.users.findOne @valueOf()


    Template.toggle_edit.events
        'click .toggle_edit': ->
            console.log @
            console.log Template.currentData()
            console.log Template.parentData()
            console.log Template.parentData(1)
            console.log Template.parentData(2)
            console.log Template.parentData(3)
            console.log Template.parentData(4)




    # Template.user_list_info.onCreated ->
    #     @autorun => Meteor.subscribe 'user', @data

    # Template.user_list_info.helpers
    #     user: ->
    #         console.log @
    #         Meteor.users.findOne @valueOf()



    # Template.user.helpers
    #     key_value: ->
    #         user = Meteor.users.findOne Meteor.user()._doc_id
    #         user["#{@key}"]

    # Template.user.events
    #     'blur .user_field': (e,t)->
    #         value = t.$('.user_field').val()
    #         Meteor.users.update Meteor.user()._doc_id,
    #             $set:"#{@key}":value


    # Template.goto_model.events
    #     'click .goto_model': ->
    #         Session.set 'loading', true
    #         Meteor.call 'set_facets', @slug, ->
    #             Session.set 'loading', false





    Template.viewing.events
        'click .mark_read': (e,t)->
            Docs.update @_id,
                $inc:views:1
            unless @read_ids and Meteor.userId() in @read_ids
                Meteor.call 'mark_read', @_id, ->
                    # $(e.currentTarget).closest('.comment').transition('pulse')
                    $('.unread_icon').transition('pulse')
        'click .mark_unread': (e,t)->
            Docs.update @_id,
                $inc:views:-1
            Meteor.call 'mark_unread', @_id, ->
                # $(e.currentTarget).closest('.comment').transition('pulse')
                $('.unread_icon').transition('pulse')
    Template.viewing.helpers
        viewed_by: -> Meteor.userId() in @read_ids
        readers: ->
            readers = []
            if @read_ids
                for reader_id in @read_ids
                    unless reader_id is @author_id
                        readers.push Meteor.users.findOne reader_id
            readers




    Template.add_button.onCreated ->
        # console.log @
        Meteor.subscribe 'model_from_slug', @data.model
    Template.add_button.helpers
        model: ->
            data = Template.currentData()
            Docs.findOne
                model: 'model'
                slug: data.model
    Template.add_button.events
        'click .add': ->
            new_id = Docs.insert
                model: @model
            gstate_set "/m/#{@model}/#{new_id}/edit"


    Template.remove_button.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                if $(e.currentTarget).closest('.card')
                    $(e.currentTarget).closest('.card').transition('fly right', 1000)
                else
                    $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                    $(e.currentTarget).closest('.item').transition('fly right', 1000)
                    $(e.currentTarget).closest('.content').transition('fly right', 1000)
                    $(e.currentTarget).closest('tr').transition('fly right', 1000)
                    $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000

    Template.remove_icon.events
        'click .remove_doc': (e,t)->
            if confirm "remove #{@model}?"
                if $(e.currentTarget).closest('.card')
                    $(e.currentTarget).closest('.card').transition('fly right', 1000)
                else
                    $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                    $(e.currentTarget).closest('.item').transition('fly right', 1000)
                    $(e.currentTarget).closest('.content').transition('fly right', 1000)
                    $(e.currentTarget).closest('tr').transition('fly right', 1000)
                    $(e.currentTarget).closest('.event').transition('fly right', 1000)
                Meteor.setTimeout =>
                    Docs.remove @_id
                , 1000

    Template.session_set.events
        'click .set_session_value': ->
            # console.log @key
            # console.log @value
            if Session.equals(@key, @value)
                Session.set(@key,null)
            else
                Session.set(@key, @value)

    Template.session_set.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @cl
                res += @cl
            if Session.equals(@key,@value)
                res += ' large'
            else 
                res += ' basic'
            # console.log res
            res

    



    Template.key_value_edit.events
        'click .set_key_value': ->
            # console.log @key
            # console.log @value
            # Docs.update Meteor.user()._doc_id,
            context = Template.parentData()
            if context
                Session.set('loading', true)
                Docs.update({_id:context._id}, {$set:{"#{@key}":@value}},()->
                    Session.set('loading',false)
                    )
            # Session.set(@key, @value)

    Template.key_value_edit.helpers
        calculated_class: ->
            res = ''
            # doc = Docs.findOne Meteor.user()._doc_id
            doc = Template.parentData()
            
            # console.log @
            if @cl
                res += @cl
            # if Session.equals(@key,@value)
            if doc["#{@key}"]  is @value
                res += ' black'
            else 
                res += ' basic'
            # console.log res
            res


    Template.profile_key_value_edit.events
        'click .set_key_value': ->
            # console.log @key
            # console.log @value
            # Docs.update Meteor.user()._doc_id,
            # context = Template.parentData()
            # if context
            if Meteor.user()
                Meteor.users.update Meteor.userId(), 
                    $set:
                        "#{@key}":@value
            # Session.set(@key, @value)
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@key}: #{@value} saved"
                # showProgress: 'bottom'
                class: 'error'
                # displayTime: 'auto',
                position: "bottom right"
            )
            

    Template.profile_key_value_edit.helpers
        calculated_class: ->
            response = ''
            # doc = Docs.findOne Meteor.user()._doc_id
            doc = Template.parentData()
            user = Meteor.user()
            # console.log @
            if @cl
                response += @cl
            # if Session.equals(@key,@value)
            if user["#{@key}"]  is @value
                response += ' large'
            else 
                response += ' inverted basic tertiary'
            # console.log response
            response



    

    Template.session_boolean_toggle.events
        'click .toggle_session_key': ->
            console.log @key
            Session.set(@key, !Session.get(@key))

    Template.session_boolean_toggle.helpers
        calculated_class: ->
            res = ''
            # console.log @
            if @cl
                res += @cl
            if Session.get(@key)
                res += ' blue'
            else
                res += ' basic'

            # console.log res
            res

if Meteor.isServer
    Meteor.methods
        'send_kiosk_message': (message)->
            parent = Docs.findOne message.parent._id
            Docs.update message._id,
                $set:
                    sent: true
                    sent_timestamp: Date.now()
            Docs.insert
                model:'log_event'
                log_type:'kiosk_message_sent'
                text:"kiosk message sent"


    Meteor.publish 'children', (model, parent_id, limit)->
        # console.log model
        # console.log parent_id
        limit = if limit then limit else 10
        match = {parent_id:parent_id}
        if model 
            match.model = model
            
        Docs.find match, 
            limit:limit
            sort:_timestamp:-1
        
if Meteor.isClient
    Template.doc_array_toggle.helpers
        doc_array_toggle_class: ->
            parent = Template.parentData()
            # user = Meteor.users.findOne Template.parentData().username
            if parent["#{@key}"] and @value in parent["#{@key}"] then 'active' else 'basic'
    Template.doc_array_toggle.events
        'click .toggle': (e,t)->
            parent = Template.parentData()
            if parent["#{@key}"]
                if @value in parent["#{@key}"]
                    Docs.update parent._id,
                        $pull: "#{@key}":@value
                else
                    Docs.update parent._id,
                        $addToSet: "#{@key}":@value
            else
                Docs.update parent._id,
                    $addToSet: "#{@key}":@value


    # Template.friend_finder.onCreated ->
    #     @user_results = new ReactiveVar
    # Template.friend_finder.helpers
    #     user_results: ->Template.instance().user_results.get()
    # Template.friend_finder.events
    #     'click .clear_results': (e,t)->
    #         t.user_results.set null
    
    #     'keyup .find_friend': (e,t)->
    #         search_value = $(e.currentTarget).closest('.find_friend').val().trim()
    #         if search_value.length > 1
    #             console.log 'searching', search_value
    #             Meteor.call 'lookup_user', search_value, @role_filter, (err,res)=>
    #                 if err then console.error err
    #                 else
    #                     t.user_results.set res
    
    #     'click .select_user': (e,t) ->
    #         page_doc = Docs.findOne Meteor.user()._doc_id
    #         field = Template.currentData()
    
    #         # console.log @
    #         # console.log Template.currentData()
    #         # console.log Template.parentData()
    #         # console.log Template.parentData(1)
    #         # console.log Template.parentData(2)
    #         # console.log Template.parentData(3)
    #         # console.log Template.parentData(4)
    
    
    #         val = t.$('.edit_text').val()
    #         if field.direct
    #             parent = Template.parentData()
    #         else
    #             parent = Template.parentData(5)
    
    #         doc = Docs.findOne parent._id
    #         if doc
    #             Docs.update parent._id,
    #                 $set:"#{field.key}":@_id
    #         else
    #             Meteor.users.update parent._id,
    #                 $set:"#{field.key}":@_id
                
    #         t.user_results.set null
    #         $('.find_friend').val ''
    #         # Docs.update page_doc._id,
    #         #     $set: assignment_timestamp:Date.now()
    
    #     'click .pull_user': ->
    #         if confirm "remove #{@username}?"
    #             parent = Template.parentData(1)
    #             field = Template.currentData()
    #             doc = Docs.findOne parent._id
    #             if doc
    #                 Docs.update parent._id,
    #                     $unset:"#{field.key}":1
    #             else
    #                 Meteor.users.update parent._id,
    #                     $unset:"#{field.key}":1
    
    #         #     page_doc = Docs.findOne Meteor.user()._doc_id
    #             # Meteor.call 'unassign_user', page_doc._id, @
    
    
    
