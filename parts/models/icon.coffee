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
    
if Meteor.isServer            
    Meteor.publish 'icons', ->
        user = Meteor.user()
        limit = if user._limit then user._limit else 50
        Docs.find {
            model:'icon'
        },{
            limit:limit
            sort:_timestamp:-1
        }
    Meteor.methods
        'call_icon':(query)->
            console.log 'calling icon', query
            HTTP.get "https://search.icons8.com/api/iconsets/v5/search?term=#{query}&token=402e8373258e2ef9000ec9df86ffa46bb7ac442a", (err, response)->
                if err 
                    # then Throw new Meteor.Error
                    console.log err
                else 
                    console.log response
                    data = response.data 
                    console.log data.icons.length
                    # if data.icons.length 
                    for icon in data.icons 
                        found_icon_doc = 
                            Docs.findOne 
                                model:'icon'
                                "icons8.id":icon.id
                        if found_icon_doc
                            console.log 'found icon doc', found_icon_doc.icons8.name
                            Docs.update found_icon_doc._id, 
                                $addToSet:tags:query
                        unless found_icon_doc 
                            new_icon_id = 
                                Docs.insert 
                                    model:'icon'
                                    icons8:icon
                                    tags:[query]
                            new_doc = Docs.findOne new_icon_id
                            console.log 'new icon doc', new_doc.icons8.name
                            # {
                            # "id": "pgnkAal3-Ns3",
                            # "name": "Car",
                            # "commonName": "car",
                            # "category": "Transport",
                            # "platform": "example123",
                            # "isAnimated": false,
                            # "isFree": true,
                            # "isExternal": true,
                            # "isColor": true,
                            # "sourceFormat": "example123"
                            # }
