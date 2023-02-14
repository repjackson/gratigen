if Meteor.isClient
    Template.give_money.events 
        'click .give_money': ->
            amount = prompt 'how much will you give?'
            if amount
                console.log amount
                int_amount = parseInt amount
                Docs.insert 
                    model:'gift'
                    gift_type:'money'
                    amount:int_amount
                    parent_id:Router.current().params.doc_id
                alert 'thanks!'   
        'click .add_dollar_credit': ->
            amount = prompt 'how much credit to add?'
            if amount
                console.log amount
                int_amount = parseInt amount
                Docs.insert 
                    model:'deposit'
                    type:'dollar'
                    amount:int_amount
                    parent_id:Router.current().params.doc_id
                Meteor.users.update Meteor.userId(), 
                    $inc: dollar_credit_current:int_amount
                alert 'deposit complete'
            
    Template.money_gift_item.events 
        'click .refund_gift': ->
            if confirm "refund #{@amount} dollar gift?"
                Docs.remove @_id
                alert 'refunded'
                    
                    
    Template.give_money.helpers 
        money_gift_docs: ->
            Docs.find 
                model:'gift'
                gift_type:'money'
                parent_id:Router.current().params.doc_id
        total_gift_amount: ->
            gifts = 
                Docs.find
                    model:'gift'
                    gift_type:'money'
                    parent_id:Router.current().params.doc_id
            total = 0
            for gift in gifts.fetch()
                total += gift.amount
    
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
            alert JSON.stringify(@);
            console.log @
   
    Template.bookmark_button.helpers
        is_bookmarked: -> Meteor.user().bookmarked_ids and @_id in Meteor.user().bookmarked_ids
    Template.bookmark_button.onRendered ->
        Meteor.setTimeout ->
            $('.toggle_bookmark').popup()
        , 1000
    Template.bookmark_button.events
        'click .toggle_bookmark': (e,t)->
            if Meteor.user().bookmarked_ids and @_id in Meteor.user().bookmarked_ids
                Meteor.users.update Meteor.userId(), 
                    $pull: 
                        bookmarked_ids:@_id
                $('body').toast(
                    showIcon: 'bookmark'
                    message: 'bookmark removed'
                    # showProgress: 'bottom'
                    class: 'info'
                    displayTime: 'auto',
                    position: "bottom right"
                )
                $(e.currentTarget).closest('.button').transition('pulse',1000)
            else 
                Meteor.users.update Meteor.userId(), 
                    $addToSet: 
                        bookmarked_ids:@_id
                $('body').toast(
                    showIcon: 'bookmark'
                    message: 'bookmark added'
                    # showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                    position: "bottom right"
                )
                $(e.currentTarget).closest('.button').transition('pulse',1000)
                
   
    Template.subscribe_button.helpers
        is_subscribeed: -> Meteor.user().subscribed_ids and @_id in Meteor.user().subscribed_ids
    Template.subscribe_button.onRendered ->
        Meteor.setTimeout ->
            $('.toggle_subscribe').popup()
        , 1000
    Template.subscribe_button.events
        'click .toggle_subscribe': (e,t)->
            if Meteor.user().subscribed_ids and @_id in Meteor.user().subscribed_ids
                Meteor.users.update Meteor.userId(), 
                    $pull: 
                        subscribed_ids:@_id
                $('body').toast(
                    showIcon: 'undo'
                    message: 'unsubscribed'
                    # showProgress: 'bottom'
                    class: 'info'
                    displayTime: 'auto',
                    position: "bottom right"
                )
                $(e.currentTarget).closest('.button').transition('pulse',1000)
            else 
                Meteor.users.update Meteor.userId(), 
                    $addToSet: 
                        subscribed_ids:@_id
                $('body').toast(
                    showIcon: 'bell'
                    message: 'subscribed'
                    # showProgress: 'bottom'
                    class: 'success'
                    displayTime: 'auto',
                    position: "bottom right"
                )
                $(e.currentTarget).closest('.button').transition('pulse',1000)
                
   
    Template.related_docs.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1000
    Template.related_docs.onCreated ->
        @autorun => Meteor.subscribe 'related_docs', Router.current().params.doc_id, ->
    Template.related_docs.helpers
        related_doc_results: ->
            Docs.find {
                model:@model
            }, limit:3
if Meteor.isServer 
    Meteor.publish 'related_docs', (doc_id)->
        doc = Docs.findOne doc_id
        
        Docs.find {
            model:doc.model
        }, 
            limit:3
            sort:
                points:-1
                
if Meteor.isClient
    Template.comments.onRendered ->
        # Meteor.setTimeout ->
        #     $('.accordion').accordion()
        # , 1000
    Template.comments.onCreated ->
        if Router.current().params.doc_id
            parent = Docs.findOne Router.current().params.doc_id
        else if Router.current().params.username
            parent = Meteor.users.findOne username:Router.current().params.username
        if parent
            @autorun => Meteor.subscribe 'children', 'comment', parent._id, ->
    Template.comments.helpers
        doc_comments: ->
            # this should all just be @_id but i guess works for now
            if Router.current().params.doc_id
                parent = Docs.findOne Router.current().params.doc_id
            else if Router.current().params.username
                parent = Meteor.users.findOne username:Router.current().params.username
            else if @_id
                parent = Docs.findOne @_id
            else if Template.parentData()
                parent = Docs.findOne Template.parentData()._id
            if parent
                Docs.find {
                    # parent_id:parent._id
                    parent_ids:$in:[parent._id]
                    model:'comment'
                }, sort:_timestamp:-1
    Template.comments.events
        'keyup .add_comment': (e,t)->
            # console.log Template.parentData(1)
            # console.log Template.parentData(2).data.data
            # console.log Template.parentData(3)
            if e.which is 13
                parent = Template.parentData(2).data.data
                comment = t.$('.add_comment').val()
                Docs.insert
                    parent_id: parent._id
                    parent_ids:[parent._id]
                    model:'comment'
                    parent_model:parent.model
                    body:comment
                t.$('.add_comment').val('')
                t.$('.add_comment').transition('bounce', 1000)


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


if Meteor.isServer 
    # realtime search results for model_crud
    Meteor.publish 'model_search_results', (model,query)->
        if model and query
            match = {model:model}
            match.title = {$regex:"#{query}",$options:'i'}
            Docs.find match,
                limit:5
    Meteor.publish 'related_model_docs', (model,parent_id)->
        # console.log 'looking for related model docs', model, parent_id
        
        # match publication for related child docs with model_children helper below
        if model and parent_id
            parent = Docs.findOne parent_id
            match = {model:model}
            match._id = $in:parent["#{model}_ids"]
            # match.title = {$regex:"#{model_title_queary}",$options:'i'}
            Docs.find match,
                limit:3

if Meteor.isClient
    Template.block.onCreated ->
        # reactivevars are like Session.get() but template specific 
        @editing = new ReactiveVar false
        @expanded = new ReactiveVar false
        # @query = new ReactiveVar ''
        # console.log @
    Template.block.helpers 
        is_editing: -> Template.instance().editing.get()
        is_expanded: -> Template.instance().expanded.get()
    Template.block.events
        'click .toggle_expanded': (e,t)-> 
            t.expanded.set !t.expanded.get()
            t.$('.grid').transition('pulse',500)
        'click .toggle_editing': (e,t)-> 
            t.editing.set !t.editing.get()
    Template.model_crud.onCreated ->
        # reactivevars are like Session.get() but template specific 
        @editing = new ReactiveVar false
        @expanded = new ReactiveVar false
        @query = new ReactiveVar ''
        console.log @
        
        # this way sucks, using global session vars, will replce with local ReactiveVars
        @autorun => @subscribe 'model_search_results', @data.model, @query.get(), ->
        @autorun => @subscribe 'child_model_docs', @data.model, Router.current().params.doc_id, ->
        # @autorun => @subscribe 'related_model_docs', @data.model, Router.current().params.doc_id, ->
if Meteor.isServer
    Meteor.publish 'child_model_docs', (model, parent_id)->
        console.log 'publishing child model docs', model, parent_id
        Docs.find {
            model:model
            # parent_id:parent_id
            parent_ids:$in:[parent_id]
        }, limit:20

if Meteor.isClient
    Template.model_crud.helpers 
        child_model_item_template: -> "#{@model}_card"
        is_editing: -> Template.instance().editing.get()
        is_expanded: -> Template.instance().expanded.get()
        user_template:->
            # like user_tasks
            "user_#{@key}"
    Template.model_crud.events
        'click .toggle_expanded': (e,t)-> t.expanded.set !t.expanded.get()
        'click .toggle_editing': (e,t)-> t.editing.set !t.editing.get()
    Template.model_crud.helpers
        model_results: ->
            # query = Session.get("#{Template.currentData().model}_model_search")
            query = Template.instance().query.get()
            console.log 'local model query', query
            if query
                Docs.find 
                    model:Template.currentData().model
                    title: {$regex:query,$options:'i'}
                
        model_children: ->
            parent_doc = Docs.findOne Router.current().params.doc_id
            # _id:parent_doc["#{Template.currentData().model}_id"]
            console.log Template.currentData().model
            Docs.find
                model:Template.currentData().model
                # parent_ids:$in:[Router.current().params.doc_id]
                # parent_id:Router.current().params.doc_id
                # _id:$in:parent_doc["#{Template.currentData().model}_ids"]
        # picked_model: ->
        #     parent_doc = Docs.findOne Router.current().params.doc_id
        #     # _id:parent_doc["#{Template.currentData().model}_id"]
        #     console.log Template.currentData().model
        #     Docs.findOne
        #         # model:Template.currentData().model
        #         _id:parent_doc["#{Template.currentData().model}_id"]
        model_search_value: ->
            Template.instance().query.get()
            # Session.get("#{Template.currentData().model}_model_search")
        
    Template.model_crud.events
        'click .clear_search': (e,t)->
            t.instance().query.set(null)
            # t.instance().query.set(null)
            $(e.currentTarget).closest('.model_search').val('')

            
        'click .remove_model': (e,t)->
            if confirm "remove #{@title} #{@model}?"
                # multi ref version
                Docs.update Router.current().params.doc_id,
                    $pull:
                        "#{Template.currentData().model}_ids":@_id
                        "#{Template.currentData().model}_titles":@title
                Docs.update @_id, 
                    $pull:
                        parent_ids:Router.current().params.doc_id
                #   singular ref version
                # Docs.update Router.current().params.doc_id,
                #     $unset:
                #         "#{Template.currentData().model}_id":@_id
                #         "#{Template.currentData().model}_title":@title
        
                $('body').toast(
                    # showIcon: 'heart'
                    message: "#{@title} removed"
                    # showProgress: 'bottom'
                    # class: 'success'
                    displayTime: 'auto',
                    position: "bottom right"
                )

        'click .pick_model': (e,t)->
            # single
            # Docs.update Router.current().params.doc_id,
            #     $set:
            #         "#{Template.currentData().model}_id":@_id
            #         "#{Template.currentData().model}_title":@title
            # multi
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    "#{Template.currentData().model}_ids":@_id
                    "#{Template.currentData().model}_titles":@title
            # update clicked on doc to add current page doc to parent_ids list
            Docs.update @_id, 
                $addToSet:
                    parent_ids:Router.current().params.doc_id
            t.query.set(null)
            $(e.currentTarget).closest('.model_search').val('')
            $('body').toast(
                # showIcon: 'heart'
                message: "#{@title} attached"
                # showProgress: 'bottom'
                # class: 'success'
                displayTime: 'auto',
                position: "bottom right"
            )
        'keyup .model_search': (e,t)->
            # this is all very wrong
            val = t.$('.model_search').val()
            console.log val
            if val.length > 1
                t.query.set(val)
            if e.which is '13'
                if Template.currentData().model
                    # wait till 2 characters to change session var which updates search results, keep fast
                    new_id = 
                        Docs.insert 
                            model:Template.currentData().model
                            title:t.query.get()
                            parent_ids:[Router.current().params.doc_id]
                            parent_id:Router.current().params.doc_id
                            parent_model:@model
                            parent_models:[@model]
                    # Router.go "/model/#{new_id}/edit"
                    Docs.update Router.current().params.doc_id,
                        $addToSet:
                            "#{Template.currentData().model}_ids":@_id
                            "#{Template.currentData().model}_titles":@title
                    t.query.set(null)
                    t.$('.model_search').val('')
    
                    $('body').toast(
                        # showIcon: 'heart'
                        message: "#{val} created and attached"
                        # showProgress: 'bottom'
                        # class: 'success'
                        displayTime: 'auto',
                        position: "bottom right"
                    )

        'click .create_model': (e,t)->
            # Template.currentData().model is the declared argument for the template
            console.log @
            if Template.currentData().model
                new_id = 
                    Docs.insert 
                        model:Template.currentData().model
                        title:t.query.get()
                        # title:Session.get("#{Template.currentData().model}_model_search")
                        parent_id:Router.current().params.doc_id
                        parent_ids:[Router.current().params.doc_id]
                        parent_model:@model
                        parent_models:[@model]
                        
                # Router.go "/model/#{new_id}/edit"
                Docs.update Router.current().params.doc_id,
                    $addToSet:
                        "#{Template.currentData().model}_ids":@_id
                        "#{Template.currentData().model}_titles":@title
                t.query.set(null)
                $(e.currentTarget).closest('.model_search').val('')

                $('body').toast(
                    # showIcon: 'heart'
                    message: "#{@title} created and attached"
                    # showProgress: 'bottom'
                    # class: 'success'
                    displayTime: 'auto',
                    position: "bottom right"
                )


            
if Meteor.isClient
    Template.badge_picker.onCreated ->
        @autorun => @subscribe 'badge_search_results', Session.get('badge_search'), ->
        # @autorun => @subscribe 'model_docs', 'badge', ->
    Template.badge_picker.helpers
        badge_results: ->
            Docs.find 
                model:'badge'
                title: {$regex:"#{Session.get('badge_search')}",$options:'i'}
                
        product_badges: ->
            product = Docs.findOne Router.current().params.doc_id
            Docs.find 
                # model:'badge'
                _id:$in:product.badge_ids
        badge_search_value: ->
            Session.get('badge_search')
        
    Template.badge_picker.events
        'click .clear_search': (e,t)->
            Session.set('badge_search', null)
            t.$('.badge_search').val('')
            
        'click .remove_badge': (e,t)->
            if confirm "remove #{@title} badge?"
                Docs.update Router.current().params.doc_id,
                    $pull:
                        badge_ids:@_id
                        badge_titles:@title
        'click .pick_badge': (e,t)->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    badge_ids:@_id
                    badge_titles:@title
            Session.set('badge_search',null)
            t.$('.badge_search').val('')
                    
        'keyup .badge_search': (e,t)->
            # if e.which is '13'
            val = t.$('.badge_search').val()
            console.log val
            Session.set('badge_search', val)

        'click .create_badge': ->
            new_id = 
                Docs.insert 
                    model:'badge'
                    title:Session.get('badge_search')
            Router.go "/badge/#{new_id}/edit"


if Meteor.isClient
    Template.task_picker.onCreated ->
        @autorun => @subscribe 'task_search_results', Session.get('task_search'), ->
        @autorun => @subscribe 'model_docs', 'task', ->
    Template.task_picker.helpers
        task_results: ->
            Docs.find 
                model:'task'
                title: {$regex:"#{Session.get('task_search')}",$options:'i'}
                
        product_tasks: ->
            product = Docs.findOne Router.current().params.doc_id
            Docs.find 
                # model:'task'
                _id:$in:product.task_ids
        task_search_value: ->
            Session.get('task_search')
        
    Template.task_picker.events
        'click .clear_search': (e,t)->
            Session.set('task_search', null)
            t.$('.task_search').val('')

            
        'click .remove_task': (e,t)->
            if confirm "remove #{@title} task?"
                Docs.update Router.current().params.doc_id,
                    $pull:
                        task_ids:@_id
                        task_titles:@title
        'click .pick_task': (e,t)->
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    task_ids:@_id
                    task_titles:@title
            Session.set('task_search',null)
            t.$('.task_search').val('')
                    
        'keyup .task_search': (e,t)->
            # if e.which is '13'
            val = t.$('.task_search').val()
            console.log val
            Session.set('task_search', val)

        'click .create_task': ->
            new_id = 
                Docs.insert 
                    model:'task'
                    title:Session.get('task_search')
            Router.go "/task/#{new_id}/edit"


        
if Meteor.isClient
    Template.voting.events
        'click .upvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',500)
            Meteor.call 'upvote', @, ->
        'click .downvote': (e,t)->
            $(e.currentTarget).closest('.button').transition('pulse',500)
            Meteor.call 'downvote', @, ->


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
    #         doc = Docs.findOne Router.current().params.doc_id
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
    #             Router.go "/member/#{user.username}/"
    #         else
    #             Router.go "/user/#{user.username}/"
    # Template.username_info.helpers
    #     user: -> Meteor.users.findOne username:@valueOf()

    Template.add_model_button.events        
        'click .add_model_doc': ->
            new_id = 
                Docs.insert 
                    model:@model
                    published:false
                    # purchased:false
            Router.go "/#{@model}/#{new_id}/edit"
            
            
    Template.search_input.events
        'keyup .search_input': (e,t)->
            search_value = $(e.currentTarget).closest('.search_input').val().trim()
            if search_value.length > 1
                console.log 'searching', search_value
                Session.set('search_value', search_value)

    Template.search_input.helpers
        search_input_class: ->
            if Session.get('search_value') then 'large active circular' else 'small'

    Template.user_pill.onRendered ->
        Meteor.setTimeout =>
            $('.label').popup({inline:true})
        , 1000
    Template.user_pill.onCreated ->
        @autorun => Meteor.subscribe 'user_from_id', @data, ->
    # Template.user_pill.helpers
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



    # Template.user_field.helpers
    #     key_value: ->
    #         user = Meteor.users.findOne Router.current().params.doc_id
    #         user["#{@key}"]

    # Template.user_field.events
    #     'blur .user_field': (e,t)->
    #         value = t.$('.user_field').val()
    #         Meteor.users.update Router.current().params.doc_id,
    #             $set:"#{@key}":value


    Template.goto_model.events
        'click .goto_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false





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
        viewed_by: -> @read_ids and Meteor.userId() in @read_ids
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
            Router.go "/d/#{@model}/#{new_id}/"
            Meteor.users.update Meteor.userId(),
                $set:editing:true


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
                res += ' blue'
            else 
                res += ' '
            # console.log res
            res

    



    Template.key_value_edit.events
        'click .set_key_value': ->
            # console.log @key
            # console.log @value
            # Docs.update Router.current().params.doc_id,
            context = Template.parentData()
            if context
                Docs.update context._id, 
                    $set:
                        "#{@key}":@value
            # Session.set(@key, @value)

    Template.key_value_edit.helpers
        calculated_class: ->
            res = ''
            # doc = Docs.findOne Router.current().params.doc_id
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
        Docs.find {
            model:model
            # parent_id:parent_id
            parent_ids:$in:[parent_id]
        }, limit:limit
        
        
if Meteor.isClient
    Template.doc_array_togggle.helpers
        doc_array_toggle_class: ->
            parent = Template.parentData()
            # user = Meteor.users.findOne Router.current().params.username
            if parent["#{@key}"] and @value in parent["#{@key}"] then 'active' else 'basic'
    Template.doc_array_togggle.events
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
    #         page_doc = Docs.findOne Router.current().params.doc_id
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
    
    #         #     page_doc = Docs.findOne Router.current().params.doc_id
    #             # Meteor.call 'unassign_user', page_doc._id, @
    
    
    
