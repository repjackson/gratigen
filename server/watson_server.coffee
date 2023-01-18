NaturalLanguageUnderstandingV1 = require('ibm-watson/natural-language-understanding/v1.js');
{ IamAuthenticator } = require('ibm-watson/auth');

# console.log Meteor.settings.private.language.apikey
# console.log Meteor.settings.private.language.url
natural_language_understanding = new NaturalLanguageUnderstandingV1(
    version: '2019-07-12'
    authenticator: new IamAuthenticator({
        apikey: Meteor.settings.private.language.apikey
    })
    url: Meteor.settings.private.language.url)


Meteor.methods
    call_wiki: (query)->
        console.log 'calling wiki', query
        term = query.split(' ').join('_')
        found_doc =
            Docs.findOne
                url: "https://en.wikipedia.org/wiki/#{term}"
        if found_doc
            console.log 'found wiki doc for term', term, found_doc
            Docs.update found_doc._id,
                $addToSet:tags:'wikipedia'
            Meteor.call 'call_watson', found_doc._id, 'url','url', ->
        else
            new_wiki_id = Docs.insert
                title: "wikipedia: #{query}"
                tags:['wikipedia', query]
                url:"https://en.wikipedia.org/wiki/#{term}"
            Meteor.call 'call_watson', new_wiki_id, 'url','url', ->



    call_watson: (doc_id, key, mode) ->
        console.log 'calling watson'
        self = @
        console.log doc_id
        console.log key
        console.log mode
        doc_id = Meteor.user()._doc_id
        doc = Docs.findOne Meteor.user()._doc_id
        # if doc.skip_watson is true
        #     console.log 'skipping flagged doc', doc.title
        # else
        # console.log 'analyzing', doc.title, 'tags', doc.tags
        parameters =
            concepts:
                limit:20
            features:
                entities:
                    emotion: true
                    sentiment: true
                    # limit: 2
                keywords:
                    emotion: true
                    sentiment: true
                    # limit: 2
                concepts: {}
                categories: {}
                emotion: {}
                metadata: {}
                relations: {}
                semantic_roles: {}
                sentiment: {}

        switch mode
            when 'html'
                parameters.html = doc["#{key}"]
            when 'text'
                parameters.text = doc["#{key}"]
            when 'url'
                parameters.url = doc["#{key}"]
                parameters.return_analyzed_text = true
                parameters.clean = true

        natural_language_understanding.analyze parameters, Meteor.bindEnvironment((err, response) ->
            if err
                # console.log 'watson error for', parameters.url
                console.log err
                unless err.code is 403
                    Docs.update doc_id,
                        $set:skip_watson:true
                    console.log 'not html, flaggged doc for future skip', parameters.url
                else
                    console.log '403 error api key'
            else
                # console.log response.result
                console.log 'adding watson info', doc.title
                response = response.result
                keyword_array = _.pluck(response.keywords, 'text')
                lowered_keywords = keyword_array.map (keyword)-> keyword.toLowerCase()
                # console.log 'lowered keywords', lowered_keywords
                # if Meteor.isDevelopment
                #     console.log 'categories',response.categories
                adding_tags = []
                # if response.categories
                #     for category in response.categories
                #         console.log category.label.split('/')[1..]
                #         console.log category.label.split('/')
                #         for tag in category.label.split('/')
                #             if tag.length > 0 then adding_tags.push tag
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:adding_tags
                if response.entities and response.entities.length > 0
                    for entity in response.entities
                        # console.log entity.type, entity.text
                        unless entity.type is 'Quantity'
                            # if Meteor.isDevelopment
                            #     console.log('quantity', entity.text)
                            # else
                            Docs.update { _id: doc_id },
                                $addToSet:
                                    # "#{entity.type}":entity.text
                                    tags:entity.text.toLowerCase()
                #
                concept_array = _.pluck(response.concepts, 'text')
                lowered_concepts = concept_array.map (concept)-> concept.toLowerCase()
                Docs.update { _id: doc_id },
                    $set:
                #         body:response.analyzed_text
                        watson: response
                #         watson_concepts: lowered_concepts
                #         watson_keywords: lowered_keywords
                        doc_sentiment_score: response.sentiment.document.score
                        doc_sentiment_label: response.sentiment.document.label
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:lowered_concepts
                Docs.update { _id: doc_id },
                    $addToSet:
                        tags:$each:lowered_keywords
                final_doc = Docs.findOne doc_id
                if Meteor.isDevelopment
                    # console.log 'all tags', final_doc.tags
                    console.log 'final doc tag', final_doc.title, final_doc.tags.length, 'length'
        )