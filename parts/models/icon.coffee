Router.route '/icons', (->
    @layout 'layout'
    @render 'icons'
    ), name:'icons'

if Meteor.isClient
    Template.icons.onCreated ->
        @autorun => Meteor.subscribe 'icons', ->
            
    Template.icons.helpers
        icons_docs: ->
            Docs.find {
                model:'icon'
            }, 
                sort:_timestamp:-1
                
    Template.icon_field.onCreated ->
        @autorun => @subscribe 'icons', ->
    Template.icon_field.helpers
        icon_results: ->
            Docs.find
                model:'icon'
    Template.icons.events
        'keyup .search_icon': (e,t)->
            if e.which is 13
                val = t.$('.search_icon').val()
                if val.length > 0
                    Meteor.call 'call_icon', val, ->
                # parent = Template.parentData()
                # doc = Docs.findOne parent._id
                # if doc
                #     Docs.update parent._id,
                #         $set:"#{@key}":val
    
                
    Template.icon_field.events
        'keyup .search_icon': (e,t)->
            if e.which is 13
                val = t.$('.search_icon').val()
                if val.length > 0
                    Meteor.call 'call_icon', val, ->
                # parent = Template.parentData()
                # doc = Docs.findOne parent._id
                # if doc
                #     Docs.update parent._id,
                #         $set:"#{@key}":val
    
                
