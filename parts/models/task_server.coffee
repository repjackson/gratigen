# Meteor.publish 'task_facets', (
#     picked_tags=[]
#     title_filter
#     picked_authors=[]
#     picked_tasks=[]
#     picked_locations=[]
#     picked_timestamp_tags=[]
#     )->
#     # console.log 'dummy', dummy
#     # console.log 'query', query
#     # console.log 'picked staff', picked_authors

#     self = @
#     match = {}
#     # match = {app:'pes'}
#     # match.group_id = Meteor.user().current_group_id
    
#     match.model = 'task'
#     if title_filter and title_filter.length > 1
#         match.title = {$regex:title_filter, $options:'i'}
    
#     # if view_vegan
#     #     match.vegan = true
#     # if view_gf
#     #     match.gluten_free = true
#     # if view_local
#     #     match.local = true
#     if picked_authors.length > 0 then match._author_username = $in:picked_authors
#     if picked_tags.length > 0 then match.tags = $all:picked_tags 
#     if picked_locations.length > 0 then match.location_title = $in:picked_locations 
#     if picked_timestamp_tags.length > 0 then match._timestamp_tags = $in:picked_timestamp_tags 
#     # match.$regex:"#{product_query}", $options: 'i'}
#     # if product_query and product_query.length > 1
#     author_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "_author_username": 1 }
#         { $group: _id: "$_author_username", count: $sum: 1 }
#         { $match: _id: $nin: picked_authors }
#         # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 10 }
#         { $project: _id: 0, title: '$_id', count: 1 }
#     ], {
#         allowDiskUse: true
#     }
    
#     author_cloud.forEach (author, i) =>
#         # console.log 'queried author ', author
#         # console.log 'key', key
#         self.added 'results', Random.id(),
#             title: author.title
#             count: author.count
#             model:'author'
#             # category:key
#             # index: i

#     tag_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "tags": 1 }
#         { $unwind: "$tags" }
#         { $group: _id: "$tags", count: $sum: 1 }
#         { $match: _id: $nin: picked_tags }
#         # { $match: _id: {$regex:"#{product_query}", $options: 'i'} }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 20 }
#         { $project: _id: 0, title: '$_id', count: 1 }
#     ], {
#         allowDiskUse: true
#     }
    
#     tag_cloud.forEach (tag, i) =>
#         # console.log 'queried tag ', tag
#         # console.log 'key', key
#         self.added 'results', Random.id(),
#             title: tag.title
#             count: tag.count
#             model:'task_tag'
#             # category:key
#             # index: i


#     location_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "location_title": 1 }
#         # { $unwind: "$locations" }
#         { $match: _id: $nin: picked_locations }
#         { $group: _id: "$location_title", count: $sum: 1 }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 10 }
#         { $project: _id: 0, title: '$_id', count: 1 }
#     ], {
#         allowDiskUse: true
#     }

#     location_cloud.forEach (location, i) =>
#         # console.log 'location result ', location
#         self.added 'results', Random.id(),
#             title: location.title
#             count: location.count
#             model:'location'
#             # category:key
#             # index: i

#     timestamp_tag_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: "_timestamp_tags": 1 }
#         { $unwind: "$_timestamp_tags" }
#         { $match: _id: $nin: picked_timestamp_tags }
#         { $group: _id: "$_timestamp_tags", count: $sum: 1 }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 10 }
#         { $project: _id: 0, title: '$_id', count: 1 }
#     ], {
#         allowDiskUse: true
#     }

#     timestamp_tag_cloud.forEach (timestamp_tag, i) =>
#         # console.log 'timestamp_tag result ', timestamp_tag
#         self.added 'results', Random.id(),
#             title: timestamp_tag.title
#             count: timestamp_tag.count
#             model:'timestamp_tag'
#             # category:key
#             # index: i




#     self.ready()
    
# Meteor.publish 'task_docs', (
#     picked_tags
#     title_filter
#     picked_authors=[]
#     picked_tasks=[]
#     picked_locations=[]
#     picked_timestamp_tags=[]
#     # product_query
#     # view_vegan
#     # view_gf
#     # doc_limit
#     # doc_sort_key
#     # doc_sort_direction
#     )->

#     self = @
#     match = {}
#     # match = {app:'pes'}
#     match.model = 'task'
#     # match.group_id = Meteor.user().current_group_id
    
#     if title_filter and title_filter.length > 1
#         match.title = {$regex:title_filter, $options:'i'}
    
#     # if view_vegan
#     #     match.vegan = true
#     # if view_gf
#     #     match.gluten_free = true
#     # if view_local
#     #     match.local = true
#     if picked_authors.length > 0 then match._author_username = $in:picked_authors
#     if picked_tags.length > 0 then match.tags = $all:picked_tags 
#     if picked_locations.length > 0 then match.location_title = $in:picked_locations 
#     if picked_timestamp_tags.length > 0 then match._timestamp_tags = $in:picked_timestamp_tags 
#     console.log match
#     Docs.find match, 
#         limit:20
#         sort:
#             _timestamp:-1