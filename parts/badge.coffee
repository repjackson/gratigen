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

    Router.route '/badges', (->
        @layout 'layout'
        @render 'badges'
        ), name:'badges'
    Router.route '/badge/:doc_id', (->
        @layout 'layout'
        @render 'badge_view'
        ), name:'badge_view'
    Router.route '/badge/:doc_id/edit', (->
        @layout 'layout'
        @render 'badge_edit'
        ), name:'badge_edit'

    Template.badges.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'badge'
   
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


    Template.badges.helpers
        badges: ->
            Docs.find   
                model:'badge'
    
    Template.badge_view.helpers
    Template.badge_view.events
    

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