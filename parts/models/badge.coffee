if Meteor.isClient
    @selected_user_levels = new ReactiveArray []
    Template.registerHelper 'badgers', () ->
        # badge = Docs.findOne Router.current().params.doc_id
        if @badger_ids
            Meteor.users.find   
                _id:$in:@badger_ids
    
    Template.registerHelper 'honey_badgers', () ->
        badge = Docs.findOne Router.current().params.doc_id
        if badge.honey_badger_ids
            Meteor.users.find   
                _id:$in:badge.honey_badger_ids

    Router.route '/badge/:doc_id', (->
        @layout 'layout'
        @render 'badge_view'
        ), name:'badge_view'
    Router.route '/badge/:doc_id/edit', (->
        @layout 'layout'
        @render 'badge_edit'
        ), name:'badge_edit'

    Template.badge_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
   
    Template.badge_view.onRendered ->


    Template.badge_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            if confirm 'confirm?'
                Meteor.call 'send_badge', @_id, =>
                    Router.go "/badge/#{@_id}/view"


# if Meteor.isServer
#     Meteor.methods
        # send_badge: (badge_id)->
        #     badge = Docs.findOne badge_id
        #     target = Meteor.users.findOne badge.recipient_id
        #     gifter = Meteor.users.findOne badge._author_id
        #
        #     console.log 'sending badge', badge
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: badge.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -badge.amount
        #     Docs.update badge_id,
        #         $set:
        #             publishted:true
        #             submitted_timestamp:Date.now()
        #
        #
        #
        #     Docs.update Router.current().params.doc_id,
        #         $set:
        #             submitted:true


if Meteor.isClient

    Template.badge_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
    Template.badge_edit.onRendered ->


    Template.badge_edit.events
        'click .delete_item': ->
            if confirm 'delete badge?'
                Docs.remove @_id
                Router.go "/m/badge"

        'click .publish': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'publish_badge', @_id, =>
                    Router.go "/badge/#{@_id}/view"

        'click .add_badger': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: 
                    badger_ids: @_id

        'click .remove_badger': ->
            Docs.update Router.current().params.doc_id, 
                $pull: 
                    badger_ids: @_id
        
        'click .add_honey_badger': ->
            Docs.update Router.current().params.doc_id, 
                $addToSet: 
                    honey_badger_ids: @_id

        'click .remove_honey_badger': ->
            Docs.update Router.current().params.doc_id, 
                $pull: 
                    honey_badger_ids: @_id

    Template.badge_edit.helpers
        unselected_badgers: ->
            badge = Docs.findOne Router.current().params.doc_id
            if @badger_ids
                Meteor.users.find({
                    _id:$nin:@badger_ids
                })
            else
                Meteor.users.find({
                })
        unselected_honey_badgers: ->
            badge = Docs.findOne Router.current().params.doc_id
            Meteor.users.find {},
                limit:10
                sort:points:-1
                _id:$nin:badge.honey_badger_ids

if Meteor.isServer
    Meteor.methods
        reward_badge: (badge_id, target_id)->
            badge = Docs.findOne badge_id
            target = Meteor.users.findOne target_id

            console.log 'rewarding badge', badge
            Meteor.users.update target._id,
                $addToSet:
                    rewarded_badge_ids: badge._id
                    
if Meteor.isClient
    Template.badge_crud.onCreated ->
        @autorun => @subscribe 'badge_search_results', Session.get('badge_search'), ->
        @autorun => @subscribe 'model_docs', 'badge', ->
    Template.badge_crud.helpers
        badge_results: ->
            if Session.get('badge_search') and Session.get('badge_search').length > 1
                Docs.find 
                    model:'badge'
                    title: {$regex:"#{Session.get('badge_search')}",$options:'i'}
                
        picked_badges: ->
            ref_doc = Docs.findOne Router.current().params.doc_id
            Docs.find 
                # model:'badge'
                _id:$in:ref_doc.badge_ids
        badge_search_value: ->
            Session.get('badge_search')
        assigned_to: ->
            Meteor.users.findOne
                _id: $in: @assigned_to_user_ids
        is_assigning: ->
            Session.equals 'assigning_docid',@_id
            
        has_taken: ->
            @taken_by_user_id and Meteor.userId() is @taken_by_user_id
            # ref_doc = Docs.findOne Router.current().params.doc_id
            # if ref_doc and ref_doc.taken_by_user_id
            #     if Meteor.userId() and Meteor.userId() is ref_doc.taken_by_user_id
            #         true
            #     else 
            #         false
            # else 
            #     false
        is_taken: ->
            @taken_by_user_id
            # ref_doc = Docs.findOne Router.current().params.doc_id
            # if ref_doc and ref_doc.taken_by_user_id
            #     true
        can_take: ->
            if @taken_by_user_id then false else true
            
            # ref_doc = Docs.findOne Router.current().params.doc_id
            # if ref_doc and @taken_by_user_id
            #     false
            # else true
            #     if Meteor.userId() and Meteor.userId() is ref_doc.taken_by_user_id
            #         true
            #     else 
            #         false
            # eles 
            #     false
        taken_user: ->
            ref_doc = Docs.findOne @_id
            Meteor.users.findOne _id:ref_doc.taken_by_user_id
            
            
    Template.badge_crud.events
        'click .toggle_assign': ->
            Session.set('assigning_docid',@_id)
        'click .clear_search': (e,t)->
            Session.set('badge_search', null)
            t.$('.badge_search').val('')

        'click .take_badge': ->
            console.log @
            Docs.update @_id,
                $set:taken_by_user_id:Meteor.userId()
            $('body').toast({
                title: "#{@title} taken"
                message: 'yeay'
                class : 'success'
                showIcon:'shield'
                showProgress:'bottom'
                position:'bottom right'
            })

        'click .release_badge': ->
            console.log @
            Docs.update @_id,
                $unset:taken_by_user_id:1
            $('body').toast({
                title: "badge released: #{@title}"
                message: 'yeay'
                class : 'info'
                showIcon:'shield'
                showProgress:'bottom'
                position:'bottom right'
            })

            
        'click .remove_badge': (e,t)->
            if confirm "remove #{@title} badge?"
                Docs.update Router.current().params.doc_id,
                    $pull:
                        badge_ids:@_id
                        badge_titles:@title
                $(e.currentTarget).closest('.card').transition('fly right', 500)

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
            if e.which is '13'
                new_id = 
                    Docs.insert 
                        model:'badge'
                        title:Session.get('badge_search')
                Docs.update Router.current().params.doc_id,
                    $addToSet:
                        badge_ids:new_id
                        badge_titles:Session.get('badge_search')
                $('body').toast({
                    title: "added #{Session.get('badge_search')}"
                    message: 'yeay'
                    class : 'success'
                    showIcon:'shield'
                    showProgress:'bottom'
                    position:'bottom right'
                })

        'click .create_badge': ->
            new_id = 
                Docs.insert 
                    model:'badge'
                    title:Session.get('badge_search')
            Docs.update Router.current().params.doc_id,
                $addToSet:
                    badge_ids:new_id
                    badge_titles:Session.get('badge_search')
            $('body').toast({
                title: "added #{Session.get('badge_search')}"
                message: 'yeay'
                class : 'success'
                showIcon:'shield'
                showProgress:'bottom'
                position:'bottom right'
            })
                    
            Session.set('badge_search',null)
        
            # Docs.update
            # Router.go "/badge/#{new_id}/edit"


if Meteor.isServer 
    Meteor.publish 'badge_search_results', (title_query)->
        Docs.find 
            model:'badge'
            title: {$regex:"#{title_query}",$options:'i'}