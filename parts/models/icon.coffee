Router.route '/icons', (->
    @layout 'layout'
    @render 'icons'
    ), name:'icons'

if Meteor.isClient
    Template.icons.onCreated ->
        @autorun => Meteor.subscribe 'icons', picked_tags.array(),->
        @autorun => Meteor.subscribe 'icon_facets', picked_tags.array(), ->
        @autorun => Meteor.subscribe 'icon_counter', ->
        @autorun => Meteor.subscribe 'eric_counter', ->
        @autorun => Meteor.subscribe 'cam_counter', ->
            
    Template.icons.helpers
        icon_count: -> Counts.get('icon_counter')
        cam_count: -> Counts.get('cam_counter')
        eric_count: -> Counts.get('eric_counter')
        picked_tags_helper: ->
            picked_tags.array()
        
        icons_docs: ->
            Docs.find {
                model:'icon'
            }, 
                sort:_timestamp:-1
        icon_tag_results:->
            Results.find(model:'tag')
        title_results:->
            Results.find(model:'title')
                
    Template.icon_field.onCreated ->
        # @autorun => @subscribe 'icons', ->
    Template.icon_field.helpers
    Template.icon_item.events
        'click .pick_tag': ->
            console.log @
            # lowered = @icons8.name.toLowerCase()
            picked_tags.push @valueOf()
            Meteor.call 'call_icon', @valueOf, ->
                
            synth = window.speechSynthesis;
            utterThis = new SpeechSynthesisUtterance(@valueOf())
            synth.speak(utterThis);
        'click .search_title': (e,t)->
            console.log @
            lowered = @icons8.name.toLowerCase()
            picked_tags.push lowered
            Meteor.call 'call_icon', lowered, ->
                
            synth = window.speechSynthesis;
            utterThis = new SpeechSynthesisUtterance(lowered)
            synth.speak(utterThis);
            
            
    Template.icons.events
        'click .unpick': (e,t)->
            picked_tags.remove @valueOf()
        'click .pick': (e,t)->
            picked_tags.push @name
            Meteor.call 'call_icon',@name, ->
                
            synth = window.speechSynthesis;
            utterThis = new SpeechSynthesisUtterance(@name)
            synth.speak(utterThis);
            # Meteor.call 'call_icon', picked_tags.array(), ->
        'keyup .search_icon': (e,t)->
            if e.which is 13
                val = t.$('.search_icon').val()
                if val.length > 0
                    picked_tags.push val
                    synth = window.speechSynthesis;
                    utterThis = new SpeechSynthesisUtterance(val)
                    synth.speak(utterThis);
                    Meteor.call 'call_icon', val, ->
                    # Meteor.call 'call_icon', picked_tags.array(), ->
                    $('body').toast({
                        title: "#{val} searched and tagged"
                        # message: 'Please see desk staff for key.'
                        class : 'success'
                        # showIcon:''
                        showProgress:'bottom'
                        position:'bottom right'
                        })
                    val = t.$('.search_icon').val('')
                # parent = Template.parentData()
                # doc = Docs.findOne parent._id
                # if doc
                #     Docs.update parent._id,
                #         $set:"#{@key}":val

                
    Template.icon_field.events
        # 'keyup .search_icon': (e,t)->
        #     if e.which is 13
        #         val = t.$('.search_icon').val()
        #         if val.length > 0
        #             Meteor.call 'call_icon', val, ->
        #         # parent = Template.parentData()
        #         # doc = Docs.findOne parent._id
        #         # if doc
        #         #     Docs.update parent._id,
        #         #         $set:"#{@key}":val
    
    Template.icon_field.onCreated ->
        # @autorun => @subscribe 'icons', ->
    Template.icon_field.helpers
        icon_results: ->
            Docs.find
                model:'icon'
            
if Meteor.isServer   
    Meteor.publish 'icon_counter', ->
      Counts.publish this, 'icon_counter', Docs.find({model:'icon'})
      return undefined    # otherwise coffeescript returns a Counts.publish
    Meteor.publish 'cam_counter', ->
      Counts.publish this, 'cam_counter', Docs.find({model:'icon', _author_username:'Dev2'})
      return undefined    # otherwise coffeescript returns a Counts.publish
    Meteor.publish 'eric_counter', ->
      Counts.publish this, 'eric_counter', Docs.find({model:'icon', _author_username:'dev'})
      return undefined    # otherwise coffeescript returns a Counts.publish
    
    Meteor.publish 'icons', (picked_tags=[])->
        user = Meteor.user()
        match = {model:'icon'}
        if picked_tags.length > 0 then match.tags = $all: picked_tags
        
        # limit = if user._limit then user._limit else 42
        Docs.find match,{
            limit:5
            sort:_timestamp:-1
        }
    Meteor.methods
        'call_icon':(query)->
            # query is array
            # const request = require('request');
            
            # request('https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY', { json: true }, (err, res, body) => {
            #   if (err) { return console.log(err); }
            #   console.log(body.url);
            #   console.log(body.explanation);
            # });
            
            console.log 'calling icon', query
            icons8_key = Meteor.settings.private.icons8
            console.log 'key', icons8_key
            HTTP.get "https://search.icons8.com/api/iconsets/v5/search?term=#{query}&token=#{icons8_key}", (err, response)->
                if err 
                    # then Throw new Meteor.Error
                    console.log err
                else 
                    # console.log response
                    data = response.data 
                    console.log data.icons.length
                    # if data.icons.length 
                    console.log query, typeof query
                    # if typeof query is 'array'
                    for icon in data.icons[..420]
                        found_icon_doc = 
                            Docs.findOne 
                                model:'icon'
                                "icons8.id":icon.id
                        if found_icon_doc
                            console.log 'found icon doc', found_icon_doc.icons8.name
                            Docs.update found_icon_doc._id, 
                                # $addToSet:tags:$each:query
                                $addToSet:tags:query
                            # category
                            lowered_category = found_icon_doc.icons8.category.toLowerCase().split(',')
                            console.log 'lowered_category',lowered_category
                            Docs.update found_icon_doc._id, 
                                # $addToSet:tags:$each:query
                                $addToSet:tags:$each:lowered_category
                            # adding name to existing docs
                            lowered_name = found_icon_doc.icons8.name.toLowerCase()
                            Docs.update found_icon_doc._id, 
                                # $addToSet:tags:$each:query
                                $addToSet:tags:lowered_name
                            console.log "added #{lowered_category} category to #{found_icon_doc.icons8.name}"
                            console.log "added #{lowered_name} name to #{found_icon_doc.icons8.name}"
                        unless found_icon_doc 
                            tags = icon.category.toLowerCase().split(',')
                            console.log 'new tags', tags 
                            tags.push query
                            tags.push icon.name.toLowerCase()
                            console.log 'new tags with query and name', tags 
                            
                            new_icon_id = 
                                Docs.insert 
                                    model:'icon'
                                    icons8:icon
                                    tags:tags
                            new_doc = Docs.findOne new_icon_id
                            console.log 'new icon doc', new_doc.icons8.name
                    #         # {
                    #         # "id": "pgnkAal3-Ns3",
                    #         # "name": "Car",
                    #         # "commonName": "car",
                    #         # "category": "Transport",
                    #         # "platform": "example123",
                    #         # "isAnimated": false,
                    #         # "isFree": true,
                    #         # "isExternal": true,
                    #         # "isColor": true,
                    #         # "sourceFormat": "example123"
                    #         # }
if Meteor.isServer
    Meteor.publish 'icon_facets', (
        picked_tags=[]
        name_search=''
        )->
    
            self = @
            match = {}
    
            # match.tags = $all: picked_tags
            match.model = 'icon'
            # if parent_id then match.parent_id = parent_id
    
            # if view_private is true
            #     match.author_id = Meteor.userId()
            if name_search.length > 1
                match["icons8.commonName"] = {$regex:"#{name_search}", $options: 'i'}

            # if view_private is false
            #     match.published = $in: [0,1]
    
            if picked_tags.length > 0 then match.tags = $all: picked_tags
            # if picked_styles.length > 0 then match.strStyle = $all: picked_styles
            # if picked_moods.length > 0 then match.strMood = $all: picked_moods
            # if picked_genres.length > 0 then match.strGenre = $all: picked_genres

            total_count = Docs.find(match).count()
            # console.log 'total count', total_count
            # console.log 'facet match', match
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $group: _id: '$tags', count: $sum: 1 }
                { $match: _id: $nin: picked_tags }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: total_count }
                { $limit: 20}
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'theme tag_cloud, ', tag_cloud
            tag_cloud.forEach (tag, i) ->
                # console.log tag
                self.added 'results', Random.id(),
                    name: tag.name
                    count: tag.count
                    model:'tag'
                    index: i
                    
            title_cloud = Docs.aggregate [
                { $match: match }
                { $project: "icons8.name": 1 }
                # { $unwind: "$tags" }
                { $group: _id: "$icons8.name", count: $sum: 1 }
                # { $match: _id: $nin: picked_tags }
                { $sort: count: -1, _id: 1 }
                # { $match: count: $lt: total_count }
                { $limit: 15}
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'themetitle_cloud, ',title_cloud
            title_cloud.forEach (title, i) ->
                # console.log title
                self.added 'results', Random.id(),
                    name: title.name
                    count: title.count
                    model:'title'
                    index: i
                    
            self.ready()
