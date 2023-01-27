if Meteor.isClient
    Template.registerHelper 'delta_key_value_is', (key, value) ->
        # console.log 'key', key
        delta = Docs.findOne Meteor.user().delta_id
        # console.log 'value', value
        delta["#{key}"] is value
    Template.registerHelper 'key_value_is', (key, value) ->
        # console.log 'key', key
        # delta = Docs.findOne Meteor.user().delta_id
        # console.log 'value', value
        @["#{key}"] is value
    Template.registerHelper 'fixed', (input) ->
        if input
            input.toFixed(2)
    Template.registerHelper 'sortable_fields', () ->
        model = Docs.findOne
            model:'model'
            slug:Meteor.user()._model
        if model
            Docs.find {
                model:'field'
                parent_id:model._id
                sortable:true
            }, sort:rank:1


    # Template.registerHelper 'view_template', ->
    #     # console.log 'view template this', @
    #     field_type_doc =
    #         Docs.findOne
    #             model:'field_type'
    #             _id: @field_type_id
    #     # console.log 'field type doc', field_type_doc
    #     "#{field_type_doc.slug}_view"


    # Template.registerHelper 'edit_template', ->
    #     field_type_doc =
    #         Docs.findOne
    #             model:'field_type'
    #             _id: @field_type_id

    #     # console.log 'field type doc', field_type_doc
    #     "#{field_type_doc.slug}_edit"


    Template.registerHelper 'fields', () ->
        model = Docs.findOne
            model:'model'
            slug:Meteor.user()._model
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
            slug:Meteor.user()._model
        if model
            Docs.find {
                model:'field'
                parent_id:model._id
                # edit_roles:$in:Meteor.user().roles
            }, sort:rank:1


    Template.registerHelper '_model', ->
        Docs.findOne
            model:'model'
            slug: Meteor.user()._model

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


    Template.delta.onCreated ->
        @autorun -> Meteor.subscribe 'me', ->
        @autorun -> Meteor.subscribe 'model_from_slug', Meteor.user()._model, ->
        # @autorun -> Meteor.subscribe 'model_fields_from_slug', Meteor.user()._model
        @autorun -> Meteor.subscribe 'my_delta', ->
        # @autorun -> Meteor.subscribe 'all_users', ->
        @autorun -> Meteor.subscribe 'model_docs', 'widget', ->

        Session.set 'loading', true
        Meteor.call 'set_facets', Meteor.user()._model, ->
            Session.set 'loading', false
    # Template.delta.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

    Template.delta.helpers
        model_template: ->
            cm = Docs.findOne slug:Meteor.user()._model
            # console.log "#{cm.model}s"
            "#{@slug}s"
        column_class: ->
            console.log @
            switch @column_width
                when 3 then 'three wide column'
                when 4 then 'four wide column'
                when 5 then 'five wide column'
                when 6 then 'six wide column'
                when 7 then 'seven wide column'
                when 8 then 'eight wide column'
                when 9 then 'nine wide column'
                when 10 then 'ten wide column'
                when 11 then 'eleven wide column'
                when 12 then 'twelve wide column'
                when 13 then 'thirteen wide column'
                when 14 then 'fourteen wide column'
                when 15 then 'fifteen wide column'
                when 16 then 'sixteen wide column'
        widget_docs: ->
            _model = Docs.findOne slug:Meteor.user()._model 
            # console.log _model
            # _model.active_blocks
            Docs.find 
                model:'widget'
                parent_model:Meteor.user()._model
                # parent_id:_model._id
    
        result_column_class: ->
            delta = Docs.findOne Meteor.user().delta_id
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
            delta = Docs.findOne Meteor.user().delta_id
            model = Docs.findOne model:'model'
            Docs.find
                model:'field'
                parent_id: model._id
        query_class:->
            delta = Docs.findOne Meteor.user().delta_id
            if delta
                if delta.search_query
                    'focus'
                else
                    'small'
        current_delta_model: ->
            delta = Docs.findOne Meteor.user().delta_id
            model = Docs.findOne model:'model'
            console.log 'delta',delta
            console.log 'model',model

        _model: ->
            Docs.findOne
                model:'model'
                slug: Meteor.user()._model

        sorting_up: ->
            delta = Docs.findOne Meteor.user().delta_id
            if delta
                if delta.sort_direction is 1 then true

        picked_tags: -> picked_tags.list()
        view_mode_template: ->
            # console.log @
            delta = Docs.findOne Meteor.user().delta_id
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
            # delta = Docs.findOne Meteor.user().delta_id
            # count = delta.result_ids.length
            # if count is 1 then true else false

        model_stats_exists: ->
            _model = Meteor.user()._model
            if Template["#{_model}_stats"]
                return true
            else
                return false
        model_stats: ->
            _model = Meteor.user()._model
            "#{_model}_stats"


    Template.delta.events
        'click .toggle_sort_column': ->
            console.log @
            delta = Docs.findOne Meteor.user().delta_id
            console.log delta


        'click .go_home': ->
            Session.set 'loading', true
            Meteor.call 'change_state', {_template:"delta",_model:'model'},->
            # Meteor.call 'log_view', @_id, ->
            Meteor.call 'set_facets', 'model', ->
                Session.set 'loading', false

        'click .clear_query': ->
            # console.log @
            # delta = Docs.findOne Meteor.user().delta_id
            Docs.update Meteor.user().delta_id,
                $unset:search_query:1
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

        'click .set_sort_key': ->
            # console.log @
            delta = Docs.findOne Meteor.user().delta_id
            Docs.update delta._id,
                $set:sort_key:@key
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

        'click .set_sort_direction': (e,t)->
            # console.log @
            # $(e.currentTarget).closest('.button').transition('pulse', 250)

            delta = Docs.findOne Meteor.user().delta_id
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
            new_id = 
                Docs.insert
                    model:'delta'
                    view_mode:'cards'
                    app:'gratigen'
                    model_filter: 'model'
            Meteor.users.update Meteor.userId(),
                $set:delta_id:new_id

        'click .print_delta': (e,t)->
            delta = Docs.findOne Meteor.user().delta_id
            console.log delta

        'click .reset': ->
            delta = Docs.findOne Meteor.user().delta_id
            
            model_slug =  Meteor.user()._model
            Session.set 'loading', true
            Meteor.call 'set_facets', delta._model, true, ->
                Session.set 'loading', false

        'click .delete_delta': (e,t)->
            delta = Docs.findOne Meteor.user().delta_id
            if delta
                if confirm "delete #{delta.name} (#{delta._id})?"
                    Docs.remove delta._id

        # 'mouseenter .add_model_doc': (e,t)->
    	# 	$(e.currentTarget).addClass('spinning')

        'click .add_model_doc': ->
            delta = Docs.findOne Meteor.user().delta_id
            model = Docs.findOne
                model:'model'
                slug: delta._model
            # console.log model
            # if model.collection and model.collection is 'users'
            #     name = prompt 'first and last name'
            #     split = name.split ' '
            #     first_name = split[0]
            #     last_name = split[1]
            #     username = name.split(' ').join('_')
            #     # console.log username
            #     Meteor.call 'add_user', first_name, last_name, username, 'guest', (err,res)=>
            #         if err
            #             alert err
            #         else
            #             Meteor.users.update res,
            #                 $set:
            #                     first_name:first_name
            #                     last_name:last_name
            #             Meteor.call 'change_state', "/m/#{model.slug}/#{res}/edit", ->
            # else if model.slug is 'gift'
            #     new_doc_id = Docs.insert
            #         model:model.slug
            #     Met  eor.call 'change_state', "/debit/#{new_doc_id}/edit", ->
            if model.slug is 'model'
                slug = prompt 'slug:'
                if slug
                    new_doc_id = Docs.insert
                        model:'model'
                        slug:slug
                    ob = {
                        _template:'model_doc_view'
                        edit_mode:true
                        _doc_id:new_doc_id
                        _model:slug
                        _view_permissions:['admin','dev', 'dev2','dj','_author']
                        _edit_permissions:['admin','dev', 'dev2', 'dj','_author']
                        _view_usernames:[]
                        _view_groups:['friends','oracle house']
                        }
                    Meteor.call 'change_state', ob, ->
            else
                console.log model
                new_doc_id = Docs.insert
                    model:model.slug
                # Meteor.call 'change_state', "/m/#{model.slug}/#{new_doc_id}/edit", ->
                Meteor.call 'change_state', 
                    {
                        _template: 'model_doc_view',
                        _model: model.slug 
                        _doc_id:new_doc_id
                    }, ->


        'click .edit_model': ->
            # model = Docs.findOne
            #     model:'model'
            #     slug: Meteor.user()._model
            # Meteor.users.update Meteor.userId(),
            #     $set:
            #         editing_model_id:model._id
            Docs.update Meteor.user().delta_id,
                $set:
                    edit_mode:true
            # Met  eor.call 'change_state', "/model/edit/#{model._id}", ->

        # 'click .page_up': (e,t)->
        #     delta = Docs.findOne Meteor.user().delta_id
        #     Docs.update delta._id,
        #         $inc: current_page:1
        #     Session.set 'is_calculating', true
        #     Meteor.call 'fo', (err,res)->
        #         if err then console.log err
        #         else
        #             Session.set 'is_calculating', false
        #
        # 'click .page_down': (e,t)->
        #     delta = Docs.findOne Meteor.user().delta_id
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
            if query.length > 1
                Session.set('current_query', query)
                delta = Docs.findOne Meteor.user().delta_id
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
            delta = Docs.findOne Meteor.user().delta_id
            console.log 'viewable fields', delta.viewable_fields
            if @_id in delta.viewable_fields
                Docs.update delta._id,
                    $pull:viewable_fields: @_id
            else
                Docs.update delta._id,
                    $addToSet: viewable_fields: @_id

    Template.toggle_visible_field.helpers
        field_visible: ->
            delta = Docs.findOne Meteor.user().delta_id
            @_id in delta.viewable_fields

    Template.set_limit.events
        'click .set': ->
            # console.log @
            delta = Docs.findOne Meteor.user().delta_id
            Docs.update delta._id,
                $set:limit:@amount
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

    Template.set_view_mode.events
        'click .set_view_mode': ->
            # console.log @
            delta = Docs.findOne Meteor.user().delta_id
            Docs.update delta._id,
                $set:view_mode:@title
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false





    # Template.facet.onCreated ->
    #     @viewing_facet = new ReactiveVar true
    

    # Template.facet.events
    #     # 'click .ui.accordion': ->
    #     #     $('.accordion').accordion()
    #     'click .toggle_view_facet': (e,t)->
    #         t.viewing_facet.set !t.viewing_facet.get()

    #     'click .toggle_selection': ->
    #         delta = Docs.findOne Meteor.user().delta_id
    #         facet = Template.currentData()

    #         Session.set 'loading', true
    #         if facet.filters and @name in facet.filters
    #             Meteor.call 'remove_facet_filter', delta._id, facet.key, @name, ->
    #                 Session.set 'loading', false
    #         else
    #             Meteor.call 'add_facet_filter', delta._id, facet.key, @name, ->
    #                 Session.set 'loading', false

    #     'keyup .add_filter': (e,t)->
    #         # console.log @
    #         if e.which is 13
    #             delta = Docs.findOne Meteor.user().delta_id
    #             facet = Template.currentData()
    #             if @field_type is 'number'
    #                 filter = parseInt t.$('.add_filter').val()
    #             else
    #                 filter = t.$('.add_filter').val()
    #             Session.set 'loading', true
    #             Meteor.call 'add_facet_filter', delta._id, facet.key, filter, ->
    #                 Session.set 'loading', false
    #             t.$('.add_filter').val('')








if Meteor.isServer
    Meteor.publish 'model_block_instances', (model_slug)->
        console.log 'blocks for', model_slug
        if model_slug
            Docs.find 
                model:'block_instance'
                parent_model:model_slug
    Meteor.publish 'model_widgets', (model_slug)->
        if model_slug
            Docs.find 
                model:'widget'
                parent_model:model_slug
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
        @autorun -> Meteor.subscribe 'model_from_slug', Meteor.user()._model
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Meteor.user()._model
        @autorun -> Meteor.subscribe 'doc', Meteor.user()._doc_id



if Meteor.isClient
    Template.model_doc_view.onRendered ->
        Meteor.call 'mark_doc_read', Meteor.user()._model, ->
        Meteor.call 'alpha', ->


    Template.model_doc_view.onCreated ->
        @autorun -> Meteor.subscribe 'current_model', ->
        # @autorun -> Meteor.subscribe 'model_fields_from_slug', Meteor.user()._model, ->
        # console.log Meteor.user()._doc_id
        @autorun -> Meteor.subscribe 'current_doc', ->
        # @autorun -> Meteor.subscribe 'upvoters', Meteor.user()._doc_id, ->
        # @autorun -> Meteor.subscribe 'downvoters', Meteor.user()._doc_id, ->
        # @autorun -> Meteor.subscribe 'model_docs', 'field_type', ->

    Template.model_doc_view.events 
        'click .call_alpha': ->
            console.log 'alpha'
            Meteor.call 'alpha', ->
Meteor.methods 
    alpha:->
        console.log 'alpha'
        d = Docs.findOne Meteor.user().delta_id
        doc = Docs.findOne d._doc_id
        # model = Docs.findOne 
        #     model:'model'
        #     slug:Meteor.user()._model
        # template = Docs.findOne Meteor.user()._template
        if doc 
            keys = _.keys doc 
            console.log 'doc keys type', typeof keys
            Docs.update doc._id,
                $set:
                    _keys:keys
if Meteor.isClient
    Template.found_field.helpers
        field_temp_exists: ->
            # false
            # console.log @
            # _model = Meteor.user()._model
            # console.log "#{@}"
            # if Template["#{@}_field"]
            model_list = ['roles','skills','resources','tasks','organizations','groups','projects','events']
            if @ in model_list
                console.log 'found in list'
                true
            else if Template["#{@}"]
                # console.log 'true'
                return true
            else
                # console.log 'false'
                return false
        field_template: ->
            # console.log "#{@}_field"
            "#{@}"

    Template.model.helpers
        model_temp_exists: ->
            # false
            # console.log @
            # _model = Meteor.user()._model
            # console.log "#{@}"
            if Template["#{@model}_view"]
                # console.log 'true'
                return true
            else
                # console.log 'false'
                return false
        model_temp: ->
            # console.log "#{@}_field"
            "#{@model}_view"



    Template.model_doc_view.events
        'click .save_doc':->
            Meteor.call 'change_state', {_template:'model_doc_view',_doc_id:@_id}, ->
    Template.app.events
        'click .edit_doc':->
            Meteor.call 'change_state', {_template:'model_doc_edit',_doc_id:@_id}, ->
        'click .goto_model': (e,t)->
            console.log 'going to model'
            Session.set 'loading', true
            delta = Docs.findOne Meteor.user().delta_id
            if delta and delta._model
                Meteor.call 'set_facets', delta._model, ->
                    Session.set 'loading', false
                $(e.currentTarget).closest('.grid').transition('fade left', 250)
                Meteor.setTimeout ->
                    Meteor.call 'change_state', {_template:'delta',_model:@model}, ->
                , 100




if Meteor.isClient
    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model', Meteor.user()._model, ->
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Meteor.user()._model, ->
        @autorun -> Meteor.subscribe 'docs', picked_tags.array(), Meteor.user()._model, ->

    Template.model_view.helpers
        _model: ->
            Meteor.user()._model
        model: ->
            Docs.findOne
                model:'model'
                slug: Meteor.user()._model

        model_docs: ->
            model = Docs.findOne
                model:'model'
                slug: Meteor.user()._model

            Docs.find
                model:model.slug

        model_doc: ->
            model = Docs.findOne
                model:'model'
                slug: Meteor.user()._model
            "#{model.slug}_view"

        fields: ->
            Docs.find { model:'field' }, sort:rank:1
                # parent_id: Meteor.user()._doc_id

    Template.model_view.events
        'click .add_child': ->
            model = Docs.findOne slug:Meteor.user()._model
            console.log model
            # new_id = Docs.insert
            #     model: Meteor.user()._model
            # Met  eor.call 'change_state', "/edit/#{new_id}", ->


if Meteor.isServer
    Meteor.publish 'model', (slug)->
        Docs.find
            model:'model'
            slug:slug

    # Meteor.publish 'model_fields_from_slug', (slug)->
    #     if slug
    #         console.log 'finding fields for model', slug
    #         model = Docs.findOne
    #             model:'model'
    #             slug:slug
    #         if model
    #             Docs.find
    #                 model:'field'
    #                 parent_id:model._id
    #         else 
    #             console.log 'no model found for ', slug
    
    # Meteor.publish 'model_fields_from_id', (model_id)->
    #     model = Docs.findOne model_id
    #     Docs.find
    #         model:'field'
    #         parent_id:model._id




if Meteor.isServer
    Meteor.methods
        set_facets: (model_slu, force)->
            if Meteor.userId()
                delta = Docs.findOne
                    model:'delta'
                    _author_id:Meteor.userId()
            else
                delta = Docs.findOne
                    model:'delta'
                    _author_id:null
            # console.log 'delta doc', delta
            model_slug =
                Meteor.user()._model
            model = Docs.findOne
                model:'model'
                slug:model_slug
            total_count = 
                Docs.find(model:model_slug).count()
            Docs.update model._id, 
                $set: total_count:total_count
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
            delta = Docs.findOne Meteor.user().delta_id
    
            model = Docs.findOne
                model:'model'
                slug:delta._model
    
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
                unless delta._model is 'user'
                    # built_query.roles = $in:[delta.model_filter]
                    built_query.disabled = $ne:true
            else
                # unless delta.model_filter is 'post'
                built_query.model = delta._model
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
                limit = 42
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
    
    
if Meteor.isClient
    Template.voting.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
    Template.delta_result_card.onCreated ->
        @autorun => Meteor.subscribe 'doc', @data._id
        @autorun => Meteor.subscribe 'user_from_id', @data._id

    Template.delta_result_card.helpers
        template_exists: ->
            d = Docs.findOne Meteor.user().delta_id
            if d
                _model = d._model
                if _model
                    if Template["#{_model}_card"]
                        return true
                    else
                        return false

        model_template: ->
            _model = Meteor.user()._model
            "#{_model}_card"

        toggle_value_class: ->
            facet = Template.parentData()
            delta = Docs.findOne Meteor.user().delta_id
            if Session.equals 'loading', true
                 'disabled'
            else if facet.filters.length > 0 and @name in facet.filters
                'active'
            else ''

        result: ->
            if Docs.findOne @_id
                # console.log 'doc'
                result = Docs.findOne @_id
                if result.private is true
                    if result._author_id is Meteor.userId()
                        result
                else
                    result
            else if Meteor.users.findOne @_id
                # console.log 'user'
                Meteor.users.findOne @_id

    Template.app.events
        'click .goto_string_doc': (e,t)->
            console.log @valueOf()
            Meteor.users.update Meteor.userId(),
                $set:
                    search_query:null
                    _template:'model_doc_view'
                    _doc_id:@valueOf()
            
        # 'click .goto_doc': (e,t)->
        #     # console.log @
        #     model_slug =  Meteor.user()._model
        #     # $(e.currentTarget).closest('.result').transition('fade')
        #     if Meteor.user()
        #         Docs.update @_id,
        #             $inc: views: 1
        #             $addToSet:viewer_usernames:Meteor.user().username
                
        #     # else
        #     #     Docs.update @_id,
        #     #         $inc: views: 1
        #     delta = Docs.findOne Meteor.user().delta_id
        #     Meteor.users.update Meteor.userId(),
        #         $set:
        #             search_query:null
        #             _template:'model_doc_view'
        #             _doc_id:@_id
        #         $addToSet:
        #             doc_history:@_id

        #     if model_slug is 'model'
        #         Session.set 'loading', true
        #         Meteor.call 'set_facets', @slug, ->
        #             Session.set 'loading', false

        #     if @model is 'model'
        #         Meteor.call 'change_state', {_template:'delta'}, ->
        #     else
        #         Meteor.call 'change_state', {_template:'model_doc_view'}, ->

        'click .set_model': ->
            Meteor.call 'set_delta_facets', @slug, Meteor.userId()

        'click .route_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false
            # delta = Docs.findOne Meteor.user().delta_id
            # Docs.update delta._id,
            #     $set:model_filter:@slug
            #
            # Meteor.call 'fum', delta._id, (err,res)->
    
    
    
if Meteor.isClient
    Template.delta_list_result.onRendered ->
        # Meteor.setTimeout ->
        #     $('.progress').popup()
        # , 2000
    Template.delta_list_result.onCreated ->
        @autorun => Meteor.subscribe 'doc', @data._id
        @autorun => Meteor.subscribe 'user_from_id', @data._id

    Template.delta_list_result.helpers
        visible_fields: ->
            delta = Docs.findOne Meteor.user().delta_id
            if delta.visible_fields
                delta.visible_fields

        template_exists: ->
            _model = Meteor.user()._model
            if _model
                if Template["#{_model}_card"]
                    # console.log 'true'
                    return true
                else
                    # console.log 'false'
                    return false

        model_template: ->
            _model = Meteor.user()._model
            "#{_model}_item"

        toggle_value_class: ->
            facet = Template.parentData()
            delta = Docs.findOne Meteor.user().delta_id
            if Session.equals 'loading', true
                 'disabled'
            else if facet.filters.length > 0 and @name in facet.filters
                'active'
            else ''

        result: ->
            if Docs.findOne @_id
                # console.log 'doc'
                result = Docs.findOne @_id
                if result.private is true
                    if result._author_id is Meteor.userId()
                        result
                else
                    result
            else if Meteor.users.findOne @_id
                # console.log 'user'
                Meteor.users.findOne @_id

    Template.delta_list_result.events
        'click .result': (e,t)->
            # console.log @
            # d 
            # model_slug =  Meteor.user()._model
            delta = Docs.findOne Meteor.user().delta_id
            # $(e.currentTarget).closest('.result').transition('fade')
            if Meteor.user()
                Docs.update @_id,
                    $inc: 
                        views: 1
                    $addToSet:viewer_usernames:Meteor.user().username
            # else
            #     Docs.update @_id,
            #         $inc: views: 1
            Docs.update delta._id,
                $set:search_query:null

            if delta._model is 'model'
                Session.set 'loading', true
                Meteor.call 'set_facets', @slug, ->
                    Session.set 'loading', false

            if @model is 'model'
                Meteor.call 'change_state', {_template:'delta', _model:@slug}, ->
            else
                Meteor.call 'change_state', {_template:'model_doc_view', _model:@model, _doc_id:@_id}, ->

        'click .set_model': ->
            Meteor.call 'set_delta_facets', @slug, Meteor.userId()

        'click .route_model': ->
            Session.set 'loading', true
            Meteor.call 'set_facets', @slug, ->
                Session.set 'loading', false
            # delta = Docs.findOne Meteor.user().delta_id
            # Docs.update delta._id,
            #     $set:model_filter:@slug
            #
            # Meteor.call 'fum', delta._id, (err,res)->
if Meteor.isClient
    Template.model_doc_view.onCreated ->
        # @autorun -> Meteor.subscribe 'me', ->
        # @autorun -> Meteor.subscribe 'doc', Meteor.user()._doc_id, ->
        # @autorun -> Meteor.subscribe 'model_fields_from_slug', Meteor.user()._model, ->
        # @autorun -> Meteor.subscribe 'model_from_slug', Meteor.user()._model, ->
        # @autorun -> Meteor.subscribe 'model_docs', 'field_type', ->

    Template.model_doc_view.helpers
        template_exists: ->
            _model = Docs.findOne(Meteor.user()._doc_id).model
            unless _model is 'model'
                if Template["#{_model}_edit"]
                    return true
                else
                    return false
            else
                return false
            # false
            # false
            # # _model = Docs.findOne(slug:Meteor.user()._model).model
            # _model = Meteor.user()._model
            # if Template["#{_model}_doc_edit"]
            #     # console.log 'true'
            #     return true
            # else
            #     # console.log 'false'
            #     return false

        model_template: ->
            # _model = Docs.findOne(slug:Meteor.user()._model).model
            _model = Meteor.user()._model
            "#{_model}_edit"


    Template.model_doc_view.events
        'click #delete_doc': ->
            if confirm 'Confirm delete doc'
                Docs.remove @_id
                Meteor.call 'change_state', "/m/#{@model}", ->

if Meteor.isClient
    Template.delta_result_table_row.onRendered ->
        # Meteor.setTimeout ->
        #     $('table').tablesort()
        # , 2000


    Template.delta_result_table_row.onCreated ->
        @autorun => Meteor.subscribe 'doc', @data._id
        @autorun => Meteor.subscribe 'user_from_id', @data._id

    Template.delta_result_table_row.helpers
        visible_fields: ->
            delta = Docs.findOne Meteor.user().delta_id
            if delta.visible_fields
                delta.visible_fields


        template_exists: ->
            _model = Meteor.user()._model
            if _model
                if Template["#{_model}_card"]
                    # console.log 'true'
                    return true
                else
                    # console.log 'false'
                    return false

        model_template: ->
            _model = Meteor.user()._model
            "#{_model}_card"

        toggle_value_class: ->
            facet = Template.parentData()
            delta = Docs.findOne Meteor.user().delta_id
            if Session.equals 'loading', true
                 'disabled'
            else if facet.filters.length > 0 and @name in facet.filters
                'active'
            else ''


        result: ->
            console.log @
            if Docs.findOne @_id
                # console.log 'doc'
                result = Docs.findOne @_id
                if result.private is true
                    if result._author_id is Meteor.userId()
                        result
                else
                    result
            else if Meteor.users.findOne @_id
                # console.log 'user'
                Meteor.users.findOne @_id

    Template.dr_table_cell.helpers
        result_value: ->
            field = @
            # console.log Template.currentData()
            parent = Template.parentData()
            if Docs.findOne parent._id
                # console.log 'doc'
                result = Docs.findOne parent._id
                # if result.private is true
                #     if result._author_id is Meteor.userId()
                #         result
                # else
                #     result
                result["#{field.key}"]


    Template.delta_result_table_row.events


if Meteor.isClient
    Template.model_edit.onCreated ->
        # @autorun -> Meteor.subscribe 'child_docs', Meteor.user()._doc_id, ->
        # @autorun -> Meteor.subscribe 'doc', Meteor.user()._doc_id
        # @autorun -> Meteor.subscribe 'model_fields_from_id', Meteor.user()._doc_id
        @autorun -> Meteor.subscribe 'model_from_slug', Meteor.user()._model, ->
        @autorun -> Meteor.subscribe 'model_widgets', Meteor.user()._model, ->
        @autorun -> Meteor.subscribe 'model_block_instances', Meteor.user()._model, ->


    # object['key']['subkey']
    # object.key
    Template.model_edit.helpers 
        active_block_docs: ->
            Docs.find 
                model:'block_instance'
                parent_model:Meteor.user()._model
                # parent_id:_model._id
        widget_docs: ->
            _model = Docs.findOne slug:Meteor.user()._model 
            # console.log _model
            # _model.active_blocks
            Docs.find 
                model:'widget'
                parent_model:Meteor.user()._model
                # parent_id:_model._id
    Template.model_edit.events
        'click .save_model': ->
            Docs.update Meteor.user().delta_id, 
                $set:edit_mode:false
            # Meteor.users.update Meteor.userId(),
            #     $set:editing_model_id:null
                
        'click #delete_model': (e,t)->
            if confirm 'delete model?'
                Docs.remove Meteor.user()._doc_id, ->
                    Meteor.call 'change_state',{_template:'delta',_model:'model'}, ->

        'click .add_widget': ->
            Docs.insert
                model:'widget'
                parent_model:Meteor.user()._model
                # parent_id: Meteor.user()._doc_id
                view_roles: ['dev', 'admin', 'user', 'public']
                edit_roles: ['dev', 'admin', 'user']




    Template.block_editor.events 
        'click .remove_block_instance': (event,template)->
            if confirm 'delete?'
                $(event.currentTarget).closest('.accordion').transition('fly right', 1000)
                Meteor.setTimeout ->
                    Docs.remove @_id
                , 1000



    Template.field_edit.onRendered ->


    Template.field_edit.helpers
        viewing_content: ->
            Session.equals('expand_field', @_id)

    Template.field_edit.events
        'click .field_edit': (e,t)->
            $('.segment').removeClass('raised')

            $(e.currentTarget).closest('.segment').toggleClass('raised')

            if Session.equals('expand_field', @_id)
                Session.set('expand_field', null)
            else
                Session.set('expand_field', @_id)




    Template.model_edit_fields.helpers
        fields: ->
            Docs.find {
                model:'field'
                parent_id: Meteor.user()._doc_id
            }, sort:rank:1

    Template.model_block_menu_item.events
        'click .add_new_block': ->
            # alert 'hi'
            cm = Docs.findOne slug:Meteor.user()._model
            if cm
                new_id = 
                    Docs.insert
                        model:'block_instance'
                        parent_model:Meteor.user()._model
                        parent_id:cm._id
                        type:@type
                console.log new_id

    Template.field_edit.helpers
        is_ref: ->
            ref_field_types =
                Docs.find(
                    model:'field_type'
                    slug: $in: ['single_doc', 'multi_doc','children']
                ).fetch()
            ids = _.pluck(ref_field_types, '_id')
            # console.log ids
            @field_type_id in ids

        is_user_ref: ->
            @field_type in ['single_user', 'multi_user']



    # Template.model_edit.events
    #     'click #delete_model': ->
    #         if confirm 'Confirm delete doc'
    #             Docs.remove @_id
    #             Met  eor.call 'change_state', "delta", ->
    
    