if Meteor.isClient
    Template.essential_facet.onCreated ->
        Meteor.subscribe 'model_docs','model', ->
    Template.model_facet.helpers
        picked_model: -> Session.get('picked_model')
        model_results: -> Results.find key:'model'
        model_doc_ref: -> 
            console.log @
            Docs.findOne 
                model:'model'
                slug:@name
    Template.essential_facet.onCreated ->
        Meteor.subscribe 'model_docs','eft', ->
    Template.essential_facet.helpers
        picked_essential: -> picked_essentials.array()
        essential_results: -> Results.find key:'essential'
        essential_doc_ref: -> 
            console.log @
            Docs.findOne 
                model:'eft'
                title:@name
    Template.tag_facet.helpers
        picked_tag: -> picked_tags.array()
        tag_results: -> Results.find key:'tag'
        # tag_doc_ref: -> 
        #     console.log @
        #     Docs.findOne 
        #         model:'tag'
        #         title:@name
    Template.facet.helpers
        # picked_filters: ->
        #     # console.log @
        #     delta = Docs.findOne Meteor.user().delta_id
        #     # console.log delta["picked_#{@key}s"]
        #     delta["picked_#{@key}s"]
        # viewing_results: ->
        #     Template.instance().viewing_facet.get()
        # filtering_res: ->
        #     delta = Docs.findOne Meteor.user().delta_id
        #     filtering_res = []
        #     # console.log @key
        #     Results.find {key:@key}
        #     # if @key is '_keys'
        #     #     @res
        #     # else
        #     #     for filter in @res
        #     #         if filter.count < delta.total
        #     #             filtering_res.push filter
        #     #         else if filter.name in @filters
        #     #             filtering_res.push filter
        #     #     filtering_res
        # toggle_value_class: ->
        #     facet = Template.parentData()
        #     delta = Docs.findOne Meteor.user().delta_id
        #     if Session.equals 'loading', true
        #          'disabled basic'
        #     # else if facet.filters.length > 0 and @name in facet.filters
        #     #     'active'
        #     # else ''
    
    
    Template.home.onCreated ->
        @autorun => Meteor.subscribe 'facet',
            Session.get('picked_model'),
            picked_essentials.array(),
            picked_tags.array(),
        , ->
        # @autorun => Meteor.subscribe('docs', picked_tags.array())
    # Template.pick_result.events
    #     'click .pick': ->
    #         console.log @
    #         d = Docs.findOne Meteor.user().delta_id 
    #         Docs.update d._id, 
    #             $addToSet:
    #                 "picked_#{@model}s":@name
    #         d = Docs.findOne Meteor.user().delta_id 
    #         # console.log d
    # Template.app.helpers
    #     result_helper: (model)-> 
    #         Results.find model:model
        # cloud_tag_class: ->
        #     button_class = switch
        #         when @index <= 5 then 'large'
        #         when @index <= 12 then ''
        #         when @index <= 20 then 'small'
        #     return button_class

    # Template.facet.events
    #     'click .pick_filter': -> 
    #         Docs.update Meteor.user().delta_id, 
    #             $addToSet:"picked_#{@key}s":@name
    # Template.facet.events
        # 'click .unpick': -> 
        #     console.log Template.instance()
        #     console.log Template.currentData()
        #     parent = Template.parentData()
        #     console.log "picked_#{@key}s", @valueOf()
        #     console.log 'unpick', @valueOf()
        #     Docs.update Meteor.user().delta_id, 
        #         $pull:"picked_#{parent.key}s":@valueOf()
        #     # location.reload()
        #     # picked_tags.remove @valueOf()
    Template.tag_facet.events
        'click .pick_tag': -> picked_tags.push @name
        'click .unpick_tag': -> picked_tags.remove @valueOf()
        'click #clear_tags': -> picked_tags.clear()
        
    Template.model_facet.events
        'click .pick_model': -> Session.set('picked_model', @name)
        'click .unpick_model': -> Session.set('picked_model',null)

    Template.essential_facet.events
        'click .pick_essential': -> picked_essentials.push @name
        'click .unpick_essential': -> picked_essentials.remove @valueOf()


        
if Meteor.isServer
    Meteor.publish 'facet', (
        picked_model=null
        picked_essentials=[]
        picked_tags=[]
        )->
        d = Docs.findOne Meteor.user().delta_id
        if d
            self = @
            match = {}
            # console.log d
            coordination_models = ['post', 'offer', 'request', 'org', 'event', 'role', 'task', 'skill', 'resource', 'product', 'service', 'trip']
            match.model = $in: coordination_models
            # enabled_facets = ['model','essential','tag']
            # for key in enabled_facets
            #     if d["picked_#{key}s"]
            #         if d["picked_#{key}s"].length > 0 then match["#{key}"] = $all: d["picked_#{key}s"]
            # if d.picked_models
            if picked_model then match.model = picked_model
            if picked_essentials.length > 0 then match.efts = $all: picked_essentials
            if picked_tags.length > 0 then match.tags = $all: picked_tags
            # if d.picked_essentials
            #     if d.picked_essentials.length > 0 then match.efts = $all: d.picked_essentials
            # if d.picked_timestamp_tags
            #     if d.picked_timestamp_tags.length > 0 then match.timestamp_tags = $all: d.picked_timestamp_tags
            # if d.picked_authors
            #     if d.picked_authors.length > 0 then match._author_username = $all: d.picked_authors
    
            # if d.picked_tags 
            #     picked_tags = d.picked_tags
            # else 
            #     picked_tags = []
            limit = 10
            console.log 'match', match
            # for key in enabled_facets   
            # console.log 'key', key
            # console.log  "picked_#{key}s"
            model_cloud = Docs.aggregate [
                { $match: match }
                { $project: "model": 1 }
                { $group: _id: "$model", count: $sum: 1 }
                # { $match: _id: $nin: d["picked_#{key}s"] }
                { $sort: count: -1, _id: 1 }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'result cloud', key, model_cloud
            model_cloud.forEach (result) =>
                # console.log 'cloud res', result
                self.added 'results', Random.id(),
                    name: result.name
                    count: result.count
                    key:'model'
                    # index: i
                
            essential_cloud = Docs.aggregate [
                { $match: match }
                { $project: "efts": 1 }
                { $unwind: "$efts" }
                { $group: _id: "$efts", count: $sum: 1 }
                { $match: _id: $nin: picked_essentials }
                { $sort: count: -1, _id: 1 }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'result cloud', key, essential_cloud
            essential_cloud.forEach (result) =>
                # console.log 'cloud res', result
                self.added 'results', Random.id(),
                    name: result.name
                    count: result.count
                    key:'essential'
                    # index: i
                
    
                
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: "tags": 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                { $match: _id: $nin: picked_essentials }
                { $sort: count: -1, _id: 1 }
                { $limit: 10 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            # console.log 'result cloud', key, tag_cloud
            tag_cloud.forEach (result) =>
                # console.log 'cloud res', result
                self.added 'results', Random.id(),
                    name: result.name
                    count: result.count
                    key:'tag'
                    # index: i
                
    
            # found_docs = Docs.find(match).fetch()
            # found_docs.forEach (found_doc) ->
            #     self.added 'docs', doc._id, fields
            #         text: author_id.text
            #         count: author_id.count
    
            # doc_results = []
            # int_doc_limit = parseInt doc_limit
            subHandle = Docs.find(match, {limit:20, sort: timestamp:-1}).observeChanges(
                added: (id, fields) ->
                    # console.log 'added doc', id, fields
                    # doc_results.push id
                    self.added 'docs', id, fields
                changed: (id, fields) ->
                    # console.log 'changed doc', id, fields
                    self.changed 'docs', id, fields
                removed: (id) ->
                    # console.log 'removed doc', id, fields
                    # doc_results.pull id
                    self.removed 'docs', id
            )
    
            # for doc_result in doc_results
    
            # user_results = Meteor.users.find(_id:$in:doc_results).observeChanges(
            #     added: (id, fields) ->
            #         # console.log 'added doc', id, fields
            #         self.added 'docs', id, fields
            #     changed: (id, fields) ->
            #         # console.log 'changed doc', id, fields
            #         self.changed 'docs', id, fields
            #     removed: (id) ->
            #         # console.log 'removed doc', id, fields
            #         self.removed 'docs', id
            # )
    
    
    
            # console.log 'doc handle count', subHandle
    
            self.ready()
    
            self.onStop ()-> subHandle.stop()

# Meteor.publish 'ancestor_id_docs', (ancestor_ids)->
#     console.log ancestor_ids
#     # Docs.find
#     #     _id: $in: ancestor_ids




# Meteor.publish 'ancestor_ids', (doc_id, username)->
#     match = {}
#     self = @
#     if doc_id
#         # doc = Docs.findOne doc_id
#         match._id = doc_id
#     if username
#         user = Meteor.users.findOne username:username
#         match.author_id = user._id

#     match.ancestor_array = $exists:true
#     # match._id = doc_id
#     # console.log match
#     # one_child = Docs.findOne(parent_id:doc_id)
#     # if one_child
#     #     match_array = one_child.ancestor_array
#     #     children = Docs.find(parent_id:one_child._id).fetch()
#     #     for child in children
#     #         match_array.push child._id
#     # else
#     #     match_array = doc.ancestor_array
#     # match.parent_id = $in:match_array

#     # console.log 'match',match
#     # if picked_ancestor_ids.length > 0 then match.ancestor_array = $all: picked_ancestor_ids
#     ancestor_ids_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: ancestor_array: 1 }
#         { $unwind: "$ancestor_array" }
#         { $group: _id: '$ancestor_array', count: $sum: 1 }
#         # { $match: _id: $nin: picked_ancestor_ids }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 10 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     # console.log 'ancestor_ids_cloud, ', ancestor_ids_cloud
#     ancestor_ids_cloud.forEach (ancestor_id, i) ->
#         self.added 'ancestor_ids', Random.id(),
#             name: ancestor_id.name
#             count: ancestor_id.count
#             index: i

#     ancestor_doc_ids =  _.pluck ancestor_ids_cloud, 'name'

#     # if username
#     subHandle = Docs.find( {_id:$in:ancestor_doc_ids}, {limit:20, sort: timestamp:-1}).observeChanges(
#         added: (id, fields) ->
#             # console.log 'added doc', id, fields
#             # doc_results.push id
#             self.added 'docs', id, fields
#         changed: (id, fields) ->
#             # console.log 'changed doc', id, fields
#             self.changed 'docs', id, fields
#         removed: (id) ->
#             # console.log 'removed doc', id, fields
#             # doc_results.pull id
#             self.removed 'docs', id
#     )

#     self.ready()

#     self.onStop ()-> subHandle.stop()


# # Meteor.publish 'parent_ids', (username, picked_parent_id)->
# #         parent_tag_cloud = Docs.aggregate [
# #             { $match: author_id:Meteor.userId() }
# #             { $project: parent_id: 1 }
# #             # { $unwind: "$tags" }
# #             { $group: _id: '$parent_id', count: $sum: 1 }
# #             { $match: _id: $nin: picked_tags }
# #             { $sort: count: -1, _id: 1 }
# #             { $limit: limit }
# #             { $project: _id: 0, name: '$_id', count: 1 }
# #             ]
# #         # console.log 'theme parent_tag_cloud, ', parent_tag_cloud
# #         parent_tag_cloud.forEach (tag, i) ->
# #             self.added 'tags', Random.id(),
# #                 name: tag.doc_id
# #                 count: tag.count
# #                 index: i
