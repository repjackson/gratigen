if Meteor.isClient
    Template.cloud.onCreated ->
        @autorun => Meteor.subscribe('tags', picked_tags.array())
        @autorun => Meteor.subscribe('docs', picked_tags.array())


    Template.cloud.helpers
        all_tags: ->
            doc_count = Docs.find({}).count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()

        cloud_tag_class: ->
            button_class = switch
                when @index <= 5 then 'large'
                when @index <= 12 then ''
                when @index <= 20 then 'small'
            return button_class

        picked_tags: -> picked_tags.array()

        settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Tags
                    field: 'name'
                    matchAll: true
                    template: Template.tag_result
                }
                ]
        }

    Template.cloud.events
        'click .select_tag': -> picked_tags.push @name
        'click .unselect_tag': -> picked_tags.remove @valueOf()
        'click #clear_tags': -> picked_tags.clear()