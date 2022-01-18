if Meteor.isClient
    Template.registerHelper 'delta_key_value_is', (key, value) ->
        # console.log 'key', key
        delta = Docs.findOne model:'delta'
        # console.log 'value', value
        delta["#{key}"] is value
    Template.registerHelper 'key_value_is', (key, value) ->
        # console.log 'key', key
        # delta = Docs.findOne model:'delta'
        # console.log 'value', value
        @["#{key}"] is value
    Template.registerHelper 'fixed', (input) ->
        if input
            input.toFixed(2)
    Template.registerHelper 'sortable_fields', () ->
        model = Docs.findOne
            model:'model'
            slug:Router.current().params.model_slug
        if model
            Docs.find {
                model:'field'
                parent_id:model._id
                sortable:true
            }, sort:rank:1


    Template.registerHelper 'current_delta', () -> Docs.findOne model:'delta'
    Template.registerHelper 'view_template', ->
        # console.log 'view template this', @
        field_type_doc =
            Docs.findOne
                model:'field_type'
                _id: @field_type_id
        # console.log 'field type doc', field_type_doc
        "#{field_type_doc.slug}_view"


    Template.registerHelper 'edit_template', ->
        field_type_doc =
            Docs.findOne
                model:'field_type'
                _id: @field_type_id

        # console.log 'field type doc', field_type_doc
        "#{field_type_doc.slug}_edit"


    Template.registerHelper 'fields', () ->
        model = Docs.findOne
            model:'model'
            slug:Router.current().params.model_slug
        if model
            match = {}
            # if Meteor.user()
            #     match.view_roles = $in:Meteor.user().roles
            match.model = 'field'
            match.parent_id = model._id
            # console.log model
            cur = Docs.find match,
                sort:rank:1
            # console.log cur.fetch()
            cur

    Template.registerHelper 'edit_fields', () ->
        console.log 'finding edit fields'
        model = Docs.findOne
            model:'model'
            slug:Router.current().params.model_slug
        if model
            Docs.find {
                model:'field'
                # parent_id:model._id
                # edit_roles:$in:Meteor.user().roles
            }, sort:rank:1


    Template.registerHelper 'view_template', -> "#{@field_type}_view"
    Template.registerHelper 'edit_template', -> "#{@field_type}_edit"

    Template.registerHelper 'current_model', ->
        Docs.findOne
            model:'model'
            slug: Router.current().params.model_slug

    Template.registerHelper 'is_loading', () ->
        Session.get('loading')
    Template.registerHelper 'field_value', () ->
        # console.log @
        parent = Template.parentData()
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)


        if @direct
            parent = Template.parentData()
        else if parent5
            if parent5._id
                parent = Template.parentData(5)
        else if parent6
            if parent6._id
                parent = Template.parentData(6)
        # console.log 'parent', parent
        if parent
            parent["#{@key}"]


    Template.registerHelper 'sorted_field_values', () ->
        # console.log @
        parent = Template.parentData()
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)


        if @direct
            parent = Template.parentData()
        else if parent5._id
            parent = Template.parentData(5)
        else if parent6._id
            parent = Template.parentData(6)
        if parent
            _.sortBy parent["#{@key}"], 'number'


    Router.route '/m/:model_slug', (->
        @render 'delta'
        ), name:'delta'

    Template.delta.onCreated ->
        @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'my_delta'
        @autorun -> Meteor.subscribe 'all_users'

        Session.set 'loading', true
        Meteor.call 'set_facets', Router.current().params.model_slug, ->
            Session.set 'loading', false
    # Template.delta.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

    Template.delta.helpers
        result_column_class: ->
            delta = Docs.findOne model:'delta'
            model = Docs.findOne model:'model'
            if model.show_facets
                'twelve wide column'
            else
                'sixteen wide column'
    
        subs_ready: ->
            Template.instance().subscriptionsReady()
        table_header_column: ->
            console.log @


        model_fields: ->
            delta = Docs.findOne model:'delta'
            model = Docs.findOne model:'model'
            Docs.find
                model:'field'
                parent_id: model._id
        query_class:->
            delta = Docs.findOne model:'delta'
            if delta
                if delta.search_query
                    'focus'
                else
                    'small'
        current_delta_model: ->
            delta = Docs.findOne model:'delta'
            model = Docs.findOne model:'model'
            console.log 'delta',delta
            console.log 'model',model

        current_model: ->
            Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug

        sorting_up: ->
            delta = Docs.findOne model:'delta'
            if delta
                if delta.sort_direction is 1 then true

        picked_tags: -> picked_tags.list()
        view_mode_template: ->
            # console.log @
            delta = Docs.findOne model:'delta'
            if delta
                "delta_#{delta.view_mode}"

        sorted_facets: ->
            current_delta =
                Docs.findOne
                    model:'delta'
            if current_delta
                # console.log _.sortBy current_delta.facets,'rank'
                _.sortBy current_delta.facets,'rank'

        global_tags: ->
            doc_count = Docs.find().count()
            if 0 < doc_count < 3 then Tags.find { count: $lt: doc_count } else Tags.find()

        single_doc: ->
            false
            # delta = Docs.findOne model:'delta'
            # count = delta.result_ids.length
            # if count is 1 then true else false

        model_stats_exists: ->
            current_model = Router.current().params.model_slug
            if Template["#{current_model}_stats"]
                return true
            else
                return false
        model_stats: ->
            current_model = Router.current().params.model_slug
            "#{current_model}_stats"


    Template.delta.events
        'click .toggle_sort_column': ->
            console.log @
            delta = Docs.findOne model:'delta'
            console.log delta


        'click .go_home': ->
            Session.set 'loading', true
            Router.go "/m/model"
            # Meteor.call 'log_view', @_id, ->
            Meteor.call 'set_facets', 'model', ->
                Session.set 'loading', false

        'click .create_model': ->
            new_model_id = Docs.insert
                model:'model'
                slug: Router.current().params.model_slug
            new_model = Docs.findOne new_model_id
            Router.go "/model/edit/#{new_model._id}"


        'click .clear_query': ->
            # console.log @
            delta = Docs.findOne model:'delta'
            Docs.update delta._id,
                $unset:search_query:1
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

        'click .set_sort_key': ->
            # console.log @
            delta = Docs.findOne model:'delta'
            Docs.update delta._id,
                $set:sort_key:@key
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

        'click .set_sort_direction': (e,t)->
            # console.log @
            # $(e.currentTarget).closest('.button').transition('pulse', 250)

            delta = Docs.findOne model:'delta'
            if delta.sort_direction is -1
                Docs.update delta._id,
                    $set:sort_direction:1
            else
                Docs.update delta._id,
                    $set:sort_direction:-1
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

        'click .create_delta': (e,t)->
            console.log 'create delta'
            Docs.insert
                model:'delta'
                view_mode:'cards'
                app:'stand'
                model_filter: Router.current().params.model_slug

        'click .print_delta': (e,t)->
            delta = Docs.findOne model:'delta'
            console.log delta

        'click .reset': ->
            model_slug =  Router.current().params.model_slug
            Session.set 'loading', true
            Meteor.call 'set_facets', model_slug, true, ->
                Session.set 'loading', false

        'click .delete_delta': (e,t)->
            delta = Docs.findOne model:'delta'
            if delta
                if confirm "delete  #{delta._id}?"
                    Docs.remove delta._id

        # 'mouseenter .add_model_doc': (e,t)->
    	# 	$(e.currentTarget).addClass('spinning')

        'click .add_model_doc': ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug
            # console.log model
            if model.collection and model.collection is 'users'
                name = prompt 'first and last name'
                split = name.split ' '
                first_name = split[0]
                last_name = split[1]
                username = name.split(' ').join('_')
                # console.log username
                Meteor.call 'add_user', first_name, last_name, username, 'guest', (err,res)=>
                    if err
                        alert err
                    else
                        Meteor.users.update res,
                            $set:
                                first_name:first_name
                                last_name:last_name
                        Router.go "/m/#{model.slug}/#{res}/edit"
            # else if model.slug is 'gift'
            #     new_doc_id = Docs.insert
            #         model:model.slug
            #     Router.go "/debit/#{new_doc_id}/edit"
            else if model.slug is 'model'
                new_doc_id = Docs.insert
                    model:'model'
                Router.go "/model/edit/#{new_doc_id}"
            else
                console.log model
                new_doc_id = Docs.insert
                    model:model.slug
                Router.go "/m/#{model.slug}/#{new_doc_id}/edit"


        'click .edit_model': ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug
            Router.go "/model/edit/#{model._id}"

        # 'click .page_up': (e,t)->
        #     delta = Docs.findOne model:'delta'
        #     Docs.update delta._id,
        #         $inc: current_page:1
        #     Session.set 'is_calculating', true
        #     Meteor.call 'fo', (err,res)->
        #         if err then console.log err
        #         else
        #             Session.set 'is_calculating', false
        #
        # 'click .page_down': (e,t)->
        #     delta = Docs.findOne model:'delta'
        #     Docs.update delta._id,
        #         $inc: current_page:-1
        #     Session.set 'is_calculating', true
        #     Meteor.call 'fo', (err,res)->
        #         if err then console.log err
        #         else
        #             Session.set 'is_calculating', false

        # 'click .select_tag': -> picked_tags.push @name
        # 'click .unselect_tag': -> picked_tags.remove @valueOf()
        # 'click #clear_tags': -> picked_tags.clear()
        #
        # 'keyup #search': (e)->
            # switch e.which
            #     when 13
            #         if e.target.value is 'clear'
            #             picked_tags.clear()
            #             $('#search').val('')
            #         else
            #             picked_tags.push e.target.value.toLowerCase().trim()
            #             $('#search').val('')
            #     when 8
            #         if e.target.value is ''
            #             picked_tags.pop()
        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('current_query', query)
            delta = Docs.findOne model:'delta'
            Docs.update delta._id,
                $set:search_query:query
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

            # console.log Session.get('current_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#search').val('')
                    Session.set('current_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)




    Template.toggle_visible_field.events
        'click .toggle_visibility': ->
            console.log @
            delta = Docs.findOne model:'delta'
            console.log 'viewable fields', delta.viewable_fields
            if @_id in delta.viewable_fields
                Docs.update delta._id,
                    $pull:viewable_fields: @_id
            else
                Docs.update delta._id,
                    $addToSet: viewable_fields: @_id

    Template.toggle_visible_field.helpers
        field_visible: ->
            delta = Docs.findOne model:'delta'
            @_id in delta.viewable_fields

    Template.set_limit.events
        'click .set_limit': ->
            # console.log @
            delta = Docs.findOne model:'delta'
            Docs.update delta._id,
                $set:limit:@amount
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

    Template.set_view_mode.events
        'click .set_view_mode': ->
            # console.log @
            delta = Docs.findOne model:'delta'
            Docs.update delta._id,
                $set:view_mode:@title
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false





    Template.facet.onCreated ->
        @viewing_facet = new ReactiveVar true
    
    Template.facet.onRendered ->
        Meteor.setTimeout ->
            $('.accordion').accordion()
        , 1500

    Template.facet.events
        # 'click .ui.accordion': ->
        #     $('.accordion').accordion()
        'click .toggle_view_facet': (e,t)->
            t.viewing_facet.set !t.viewing_facet.get()

        'click .toggle_selection': ->
            delta = Docs.findOne model:'delta'
            facet = Template.currentData()

            Session.set 'loading', true
            if facet.filters and @name in facet.filters
                Meteor.call 'remove_facet_filter', delta._id, facet.key, @name, ->
                    Session.set 'loading', false
            else
                Meteor.call 'add_facet_filter', delta._id, facet.key, @name, ->
                    Session.set 'loading', false

        'keyup .add_filter': (e,t)->
            # console.log @
            if e.which is 13
                delta = Docs.findOne model:'delta'
                facet = Template.currentData()
                if @field_type is 'number'
                    filter = parseInt t.$('.add_filter').val()
                else
                    filter = t.$('.add_filter').val()
                Session.set 'loading', true
                Meteor.call 'add_facet_filter', delta._id, facet.key, filter, ->
                    Session.set 'loading', false
                t.$('.add_filter').val('')




    Template.facet.helpers
        viewing_results: ->
            Template.instance().viewing_facet.get()
        filtering_res: ->
            delta = Docs.findOne model:'delta'
            filtering_res = []
            if @key is '_keys'
                @res
            else
                for filter in @res
                    if filter.count < delta.total
                        filtering_res.push filter
                    else if filter.name in @filters
                        filtering_res.push filter
                filtering_res
        toggle_value_class: ->
            facet = Template.parentData()
            delta = Docs.findOne model:'delta'
            if Session.equals 'loading', true
                 'disabled basic'
            else if facet.filters.length > 0 and @name in facet.filters
                'active'
            else ''




if Meteor.isServer
    Meteor.publish 'model_from_slug', (model_slug)->
        # if model_slug in ['model','brick','field','tribe','block','page']
        #     Docs.find
        #         model:'model'
        #         slug:model_slug
        # else
        match = {}
        # if tribe_slug then match.slug = tribe_slug
        match.model = 'model'
        match.slug = model_slug

        Docs.find match


    Meteor.publish 'my_delta', ->
        # Docs.find
        #     model:'delta'
        if Meteor.userId()
            Docs.find
                _author_id:Meteor.userId()
                model:'delta'
        else
            Docs.find
                _author_id:null
                model:'delta'



if Meteor.isClient
    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id



if Meteor.isClient
    Template.model_doc_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        # console.log Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'upvoters', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'downvoters', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_docs', 'field_type'

    Template.model_doc_view.helpers
        # current_model: ->

            # Router.current().params.model_slug
        template_exists: ->
            # false
            current_model = Router.current().params.model_slug
            console.log "#{current_model}_view"
            if Template["#{current_model}_view"]
                # console.log 'true'
                return true
            else
                # console.log 'false'
                return false
        model_template: ->
            current_model = Router.current().params.model_slug
            console.log "#{current_model}_view"
            "#{current_model}_view"



    Template.model_doc_view.events
        'click .back_to_model': (e,t)->
            Session.set 'loading', true
            current_model = Router.current().params.model_slug
            Meteor.call 'set_facets', current_model, ->
                Session.set 'loading', false
            $(e.currentTarget).closest('.grid').transition('fade left', 250)
            Meteor.setTimeout ->
                Router.go "/m/#{current_model}"
            , 100




if Meteor.isClient
    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'docs', picked_tags.array(), Router.current().params.model_slug

    Template.model_view.helpers
        current_model: ->
            Router.current().params.model_slug
        model: ->
            Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug

        model_docs: ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug

            Docs.find
                model:model.slug

        model_doc: ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug
            "#{model.slug}_view"

        fields: ->
            Docs.find { model:'field' }, sort:rank:1
                # parent_id: Router.current().params.doc_id

    Template.model_view.events
        'click .add_child': ->
            model = Docs.findOne slug:Router.current().params.model_slug
            console.log model
            # new_id = Docs.insert
            #     model: Router.current().params.model_slug
            # Router.go "/edit/#{new_id}"


if Meteor.isServer
    Meteor.publish 'model', (slug)->
        Docs.find
            model:'model'
            slug:slug

    Meteor.publish 'model_fields_from_slug', (slug)->
        console.log 'finding fields for model', slug
        model = Docs.findOne
            model:'model'
            slug:slug
        if model
            Docs.find
                model:'field'
                parent_id:model._id
        console.log 'no model found for ', slug
    
    Meteor.publish 'model_fields_from_id', (model_id)->
        model = Docs.findOne model_id
        Docs.find
            model:'field'
            parent_id:model._id




if Meteor.isServer
    Meteor.methods
        set_facets: (model_slug, force)->
            if Meteor.userId()
                delta = Docs.findOne
                    model:'delta'
                    _author_id:Meteor.userId()
            else
                delta = Docs.findOne
                    model:'delta'
                    _author_id:null
            # console.log 'delta doc', delta
            model = Docs.findOne
                model:'model'
                slug:model_slug
    
            # if model_slug is delta.model_filter
            #     return
            # else
            fields =
                Docs.find
                    model:'field'
                    parent_id:model._id
    
            Docs.update model._id,
                $inc: views: 1
    
            # console.log 'fields', fields.fetch()
    
            Docs.update delta._id,
                $set:model_filter:model_slug
    
            # Docs.update delta._id,
            #     $set:facets:[
            #         {
            #             key:'_timestamp_tags'
            #             filters:[]
            #             res:[]
            #         }
            #     ]
            Docs.update delta._id,
                $set:facets:[]
            for field in fields.fetch()
                if field.faceted is true
                    # console.log field
                    # if Meteor.user()
                    # console.log _.intersection(Meteor.user().roles,field.view_roles)
                    # if _.intersection(Meteor.user().roles,field.view_roles).length > 0
                    Docs.update delta._id,
                        $addToSet:
                            facets: {
                                title:field.title
                                icon:field.icon
                                key:field.key
                                rank:field.rank
                                field_type:field.field_type
                                filters:[]
                                res:[]
                            }
    
            field_ids = _.pluck(fields.fetch(), '_id')
    
            Docs.update delta._id,
                $set:
                    viewable_fields: field_ids
            Meteor.call 'fum', delta._id
    
    
        fum: (delta_id)->
            delta = Docs.findOne delta_id
    
            model = Docs.findOne
                model:'model'
                slug:delta.model_filter
    
            # console.log 'running fum,', delta, model
            built_query = {}
            if delta.search_query
                if model.collection and model.collection is 'users'
                    built_query.username = {$regex:"#{delta.search_query}", $options: 'i'}
                else
                    built_query.title = {$regex:"#{delta.search_query}", $options: 'i'}
    
            fields =
                Docs.find
                    model:'field'
                    parent_id:model._id
            if model.collection and model.collection is 'users'
                unless delta.model_filter is 'user'
                    # built_query.roles = $in:[delta.model_filter]
                    built_query.disabled = $ne:true
            else
                # unless delta.model_filter is 'post'
                built_query.model = delta.model_filter
            # unless Meteor.user() and 'admin' in Meteor.user().roles
            #     built_query.app = 'stand'
    
            # if delta.model_filter is 'model'
            #     unless 'dev' in Meteor.user().roles
            #         built_query.view_roles = $in:Meteor.user().roles
    
            # if not delta.facets
            #     # console.log 'no facets'
            #     Docs.update delta_id,
            #         $set:
            #             facets: [{
            #                 key:'_keys'
            #                 filters:[]
            #                 res:[]
            #             }
            #             # {
            #             #     key:'_timestamp_tags'
            #             #     filters:[]
            #             #     res:[]
            #             # }
            #             ]
            #
            #     delta.facets = [
            #         key:'_keys'
            #         filters:[]
            #         res:[]
            #     ]
            #
    
    
            # for facet in delta.facets
            #     if facet.filters.length > 0
            #         built_query["#{facet.key}"] = $all: facet.filters
    
            if model.collection and model.collection is 'users'
                total = Meteor.users.find(built_query).count()
            else
                total = Docs.find(built_query).count()
            # console.log 'built query', built_query
            # response
            # for facet in delta.facets
            #     values = []
            #     local_return = []
    
            #     agg_res = Meteor.call 'agg', built_query, facet.key, model.collection
            #     # agg_res = Meteor.call 'agg', built_query, facet.key
    
            #     if agg_res
            #         Docs.update { _id:delta._id, 'facets.key':facet.key},
            #             { $set: 'facets.$.res': agg_res }
            if delta.sort_key
                # console.log 'found sort key', delta.sort_key
                sort_by = delta.sort_key
            else
                sort_by = 'views'
    
            if delta.sort_direction
                sort_direction = delta.sort_direction
            else
                sort_direction = -1
            if delta.limit
                limit = delta.limit
            else
                limit = 10
            modifier =
                {
                    fields:_id:1
                    limit:limit
                    sort:"#{sort_by}":sort_direction
                }
    
            # results_cursor =
            #     Docs.find( built_query, modifier )
    
            if model and model.collection and model.collection is 'users'
                results_cursor = Meteor.users.find(built_query, modifier)
                # else
                #     results_cursor = global["#{model.collection}"].find(built_query, modifier)
            else
                results_cursor = Docs.find built_query, modifier
    
    
            # if total is 1
            #     result_ids = results_cursor.fetch()
            # else
            #     result_ids = []
            result_ids = results_cursor.fetch()
            # console.log result_ids
    
            Docs.update {_id:delta._id},
                {$set:
                    total: total
                    result_ids:result_ids
                }, ->
            return true
    
    
            # delta = Docs.findOne delta_id
    
        agg: (query, key, collection)->
            console.log 'running agg', query
            limit=20
            options = { explain:false }
            # options = { explain:true }
            pipe =  [
                { $match: query }
                { $project: "#{key}": 1 }
                { $unwind: "$#{key}" }
                { $group: _id: "$#{key}", count: $sum: 1 }
                { $sort: count: -1, _id: 1 }
                { $limit: limit }
                { $project: _id: 0, name: '$_id', count: 1 }
                # { $out : "results" }
            ]
            if pipe
                if collection and collection is 'users'
                    agg = Meteor.users.rawCollection().aggregate(pipe,options)
                else
                    agg = global['Docs'].rawCollection().aggregate(pipe,options)
                # else
                # res = {}
                # if agg
                    # console.log 'have agg', agg
                    # agg.toArray()
                    # agg.forEach (tag, i) ->
                    #     console.log 'tag', tag
    
            else
                return null
    