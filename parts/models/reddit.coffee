if Meteor.isServer
    get_reddit_post: (doc_id, reddit_id, root)->
        doc = Docs.findOne doc_id
        if doc.reddit_id
        else
            
        HTTP.get "http://reddit.com/by_id/t3_#{doc.reddit_id}.json", (err,res)->
            if err 
                console.log err
            else
                rd = res.data.data.children[0].data
                result =
                    Docs.update doc_id,
                        $set:
                            rd: rd
                # if rd.is_video
                #     Meteor.call 'call_watson', doc_id, 'url', 'video', ->
                # else if rd.is_image
                #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                # else
                #     Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                #     Meteor.call 'call_watson', doc_id, 'url', 'image', ->
                #     # Meteor.call 'call_visual', doc_id, ->
                # if rd.selftext
                #     unless rd.is_video
                #         # if Meteor.isDevelopment
                #         Docs.update doc_id, {
                #             $set:
                #                 body: rd.selftext
                #         }, ->
                #         #     Meteor.call 'pull_site', doc_id, url
                # if rd.selftext_html
                #     unless rd.is_video
                #         Docs.update doc_id, {
                #             $set:
                #                 html: rd.selftext_html
                #         }, ->
                #             # Meteor.call 'pull_site', doc_id, url
                # if rd.url
                #     unless rd.is_video
                #         url = rd.url
                #         # if Meteor.isDevelopment
                #         Docs.update doc_id, {
                #             $set:
                #                 reddit_url: url
                #                 url: url
                #         }, ->
                #             # Meteor.call 'call_watson', doc_id, 'url', 'url', ->
                # # update_ob = {}

                Docs.update doc_id,
                    $set:
                        rd: rd
                        url: rd.url
                        thumbnail: rd.thumbnail
                        subreddit: rd.subreddit
                        author: rd.author
                        is_video: rd.is_video
                        ups: rd.ups
                        # downs: rd.downs
                        over_18: rd.over_18
                    # $addToSet:
                    #     tags: $each: [rd.subreddit.toLowerCase()]

    get_reddit_comments: (post_id)->
        post =
            Docs.findOne post_id
        # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
        # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
        # HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)=>
        link = "http://reddit.com/comments/#{post.reddit_id}?depth=1"
        HTTP.get link,(err,response)=>
            # if response.data.data.dist > 1
            #     _.each(response.data.data.children, (item)=>
                    # unless item.domain is "OneWordBan"
                    #     data = item.data

    
    Meteor.publish 'post_tag_results', (
        picked_tags=null
        picked_subreddit=null
        picked_author=null
        # query
        porn=false
        # searching
        dummy
        )->
    
        self = @
        match = {}
    
        # match.model = $in: ['reddit','wikipedia']
        match.model = 'reddit'
        # if query
        # if view_nsfw
        match.over_18 = porn
        if picked_tags and picked_tags.length > 0
            match.tags = $all: picked_tags
            if picked_subreddit
                match.subreddit = picked_subreddit
            limit = 20
            # else
            #     limit = 10
            #     match._timestamp = $gt:moment().subtract(1, 'days')
            # else /
                # match.tags = $all: picked_tags
            agg_doc_count = Docs.find(match).count()
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: "tags": 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                { $match: _id: $nin: picked_tags }
                { $match: count: $lt: agg_doc_count }
                # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
                { $sort: count: -1, _id: 1 }
                { $limit: 11 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ], {
                allowDiskUse: true
            }
        
            tag_cloud.forEach (tag, i) =>
                self.added 'results', Random.id(),
                    name: tag.name
                    count: tag.count
                    model:'tag'
                    # index: i
            subreddit_cloud = Docs.aggregate [
                { $match: match }
                { $project: "subreddit": 1 }
                # { $unwind: "$tags" }
                { $group: _id: "$subreddit", count: $sum: 1 }
                { $match: _id: $ne: picked_subreddit }
                { $match: count: $lt: agg_doc_count }
                # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
                { $sort: count: -1, _id: 1 }
                { $limit: 11 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ], {
                allowDiskUse: true
            }
        
            subreddit_cloud.forEach (sub, i) =>
                self.added 'results', Random.id(),
                    name: sub.name
                    count: sub.count
                    model:'subreddit'
                    # index: i
            
            self.ready()
            # else []
    Meteor.publish 'reddit_doc_results', (
        picked_tags=null
        picked_subreddit=null
        porn=false
        sort_key='_timestamp'
        sort_direction=-1
        # dummy
        # current_query
        # date_setting
        )->
        # else
        self = @
        # match = {model:$in:['reddit','wikipedia']}
        match = {model:'reddit'}
        # match.over_18 = $ne:true
        #         yesterday = now-day
        #         match._timestamp = $gt:yesterday
        # if picked_subreddit
        #     match.subreddit = picked_subreddit
        # if porn
        match.over_18 = porn
        # if picked_tags.length > 0
        #     # if picked_tags.length is 1
        #     #     found_doc = Docs.findOne(title:picked_tags[0])
        #     #
        #     #     match.title = picked_tags[0]
        #     # else
        if picked_tags and picked_tags.length > 0
            match.tags = $all: picked_tags
        else 
            match._timestamp = $gt:moment().subtract(1, 'days')
        Docs.find match,
            sort:
                "#{sort_key}":sort_direction
                points:-1
                ups:-1
            limit:42
            fields:
                # youtube_id:1
                "rd.media_embed":1
                "rd.url":1
                "rd.thumbnail":1
                "rd.analyzed_text":1
                subreddit:1
                thumbnail:1
                doc_sentiment_label:1
                doc_sentiment_score:1
                joy_percent:1
                sadness_percent:1
                fear_percent:1
                disgust_percent:1
                anger_percent:1
                happy_votes:1
                sad_votes:1
                angry_votes:1
                fearful_votes:1
                disgust_votes:1
                funny_votes:1
                over_18:1
                points:1
                upvoter_ids:1
                downvoter_ids:1
                url:1
                ups:1
                "watson.metadata":1
                "watson.analyzed_text":1
                title:1
                model:1
                num_comments:1
                tags:1
                _timestamp:1
                domain:1
        # else 
        #     Docs.find match,
        #         sort:_timestamp:-1
        #         limit:10
    
    
    
    Meteor.methods
        search_reddit: (query,porn=false)->
            # response = HTTP.get("http://reddit.com/search.json?q=#{query}")
            # HTTP.get "http://reddit.com/search.json?q=#{query}+nsfw:0+sort:top",(err,response)=>
            # HTTP.get "http://reddit.com/search.json?q=#{query}",(err,response)=>
            if porn 
                link = "http://reddit.com/search.json?q=#{query}&nsfw=1&include_over_18=on"
            else
                link = "http://reddit.com/search.json?q=#{query}&nsfw=0&include_over_18=off"
            HTTP.get link,(err,response)=>
                if response.data.data.dist > 1
                    _.each(response.data.data.children, (item)=>
                        unless item.domain is "OneWordBan"
                            data = item.data
                            len = 200
                            # added_tags = [query]
                            # added_tags.push data.domain.toLowerCase()
                            # added_tags.push data.author.toLowerCase()
                            # added_tags = _.flatten(added_tags)
                            reddit_post =
                                reddit_id: data.id
                                url: data.url
                                domain: data.domain
                                comment_count: data.num_comments
                                permalink: data.permalink
                                title: data.title
                                # root: query
                                ups:data.ups
                                num_comments:data.num_comments
                                # selftext: false
                                points:0
                                over_18:data.over_18
                                thumbnail: data.thumbnail
                                tags: query
                                model:'reddit'
                            existing_doc = Docs.findOne url:data.url
                            if existing_doc
                                # if Meteor.isDevelopment
                                if typeof(existing_doc.tags) is 'string'
                                    Docs.update existing_doc._id,
                                        $unset: tags: 1
                                Docs.update existing_doc._id,
                                    $addToSet: tags: $each: query
                                    $set:
                                        title:data.title
                                        ups:data.ups
                                        num_comments:data.num_comments
                                        over_18:data.over_18
                                        thumbnail:data.thumbnail
                                        permalink:data.permalink
                                # Meteor.call 'get_reddit_post', existing_doc._id, data.id, (err,res)->
                                # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                            unless existing_doc
                                new_reddit_post_id = Docs.insert reddit_post
                                # Meteor.call 'get_reddit_post', new_reddit_post_id, data.id, (err,res)->
                                # Meteor.call 'call_watson', new_reddit_post_id, data.id, (err,res)->
                            return true
                    )
