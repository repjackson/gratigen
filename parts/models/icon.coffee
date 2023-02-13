Router.route '/icons', (->
    @layout 'layout'
    @render 'icons'
    ), name:'icons'

if Meteor.isClient
    Template.icons.onCreated ->
        @autorun => Meteor.subscribe 'icons', ->
        @autorun => Meteor.subscribe 'icon_facets', ->
            
    Template.icons.helpers
        icons_docs: ->
            Docs.find {
                model:'icon'
            }, 
                sort:_timestamp:-1
        icon_tag_results:->
            Results.find()
                
    Template.icon_field.onCreated ->
        # @autorun => @subscribe 'icons', ->
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
if Meteor.isServer
    Meteor.publish 'icon_facets', (
        picked_recipe_tags=[]
        name_search=''
        )->
    
            self = @
            match = {}
    
            # match.tags = $all: picked_recipe_tags
            match.model = 'icon'
            # if parent_id then match.parent_id = parent_id
    
            # if view_private is true
            #     match.author_id = Meteor.userId()
            if name_search.length > 1
                match["icons8.commonName"] = {$regex:"#{name_search}", $options: 'i'}

            # if view_private is false
            #     match.published = $in: [0,1]
    
            if picked_recipe_tags.length > 0 then match.tags = $all: picked_recipe_tags
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
                { $match: _id: $nin: picked_recipe_tags }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: total_count }
                { $limit: 15}
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
                    
            category_cloud = Docs.aggregate [
                { $match: match }
                { $project: "category": 1 }
                # { $unwind: "$tags" }
                { $group: _id: '$category', count: $sum: 1 }
                # { $match: _id: $nin: picked_recipe_tags }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: total_count }
                { $limit: 15}
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'themecategory_cloud, ',category_cloud
            category_cloud.forEach (category, i) ->
                # console.log category
                self.added 'results', Random.id(),
                    name: category.name
                    count: category.count
                    model:'category'
                    index: i
                    
            self.ready()
