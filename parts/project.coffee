if Meteor.isClient
    @selected_user_levels = new ReactiveArray []
    
    Router.route '/project/:doc_id/view', (->
        @layout 'layout'
        @render 'project_view'
        ), name:'project_view'

    Template.project_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
   
   
    Template.project_view.onRendered ->


    Template.project_view.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            if confirm 'confirm?'
                Meteor.call 'send_project', @_id, =>
                    Router.go "/project/#{@_id}/view"


    Template.project_view.helpers
    Template.project_view.events

# if Meteor.isServer
#     Meteor.methods
        # send_project: (project_id)->
        #     project = Docs.findOne project_id
        #     target = Meteor.users.findOne project.recipient_id
        #     gifter = Meteor.users.findOne project._author_id
        #
        #     console.log 'sending project', project
        #     Meteor.users.update target._id,
        #         $inc:
        #             points: project.amount
        #     Meteor.users.update gifter._id,
        #         $inc:
        #             points: -project.amount
        #     Docs.update project_id,
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
    Router.route '/project/:doc_id/edit', (->
        @layout 'layout'
        @render 'project_edit'
        ), name:'project_edit'

    Template.project_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    Template.project_edit.onRendered ->


    Template.project_edit.events
        'click .delete_item': ->
            if confirm 'delete item?'
                Docs.remove @_id

        'click .publish': ->
            Docs.update Router.current().params.doc_id,
                $set:published:true
            if confirm 'confirm?'
                Meteor.call 'publish_project', @_id, =>
                    Router.go "/project/#{@_id}/view"


    Template.project_edit.helpers
    Template.project_edit.events

if Meteor.isServer
    Meteor.methods
        reward_project: (project_id, target_id)->
            project = Docs.findOne project_id
            target = Meteor.users.findOne target_id

            console.log 'rewarding project', project
            Meteor.users.update target._id,
                $addToSet:
                    rewarded_project_ids: project._id