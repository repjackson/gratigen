Template.geolocate_button.events 
    'click .geolocate': ->
        # alert @location
        Meteor.call 'geolocate', Meteor.user()._model, @location, (err,res)->
            console.log res


Template.youtube_edit.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000

Template.youtube_view.onRendered ->
    Meteor.setTimeout ->
        $('.ui.embed').embed();
    , 1000


Template.youtube_edit.events
    'blur .youtube_id': (e,t)->
        parent = Template.parentData()
        console.log @
        console.log Template.parentData()
        field = Template.currentData()
        console.log Template.parentData(2)
        console.log Template.parentData(3)
        val = t.$('.youtube_id').val()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{field.key}":val



Template.color_edit.events
    'blur .edit_color': (e,t)->
        val = t.$('.edit_color').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val



Template.html_edit.onRendered ->
    @editor = SUNEDITOR.create((document.getElementById('sample') || 'sample'),{
    # 	"tabDisable": false
        # "minHeight": "400px"
        buttonList: [
            [
                'undo' 
                'redo'
                'font' 
                'fontSize' 
                # 'formatBlock' 
                'paragraphStyle' 
                # 'blockquote'
                'bold' 
                'underline' 
                'italic' 
                # 'strike' 
                # 'subscript' 
                # 'superscript'
                'fontColor' 
                # 'hiliteColor' 
                'textStyle'
                'removeFormat'
                'outdent' 
                'indent'
                'align' 
                # 'horizontalRule' 
                'list' 
                # 'lineHeight'
                'fullScreen' 
                # 'showBlocks' 
                # 'codeView' 
                # 'preview' 
                # 'table' 
                # 'image' 
                # 'video' 
                # 'audio' 
                'link'
            ]
        ]
        lang: SUNEDITOR_LANG['en']
        # codeMirror: CodeMirror
    });

Template.html_edit.events
    'blur .testsun': (e,t)->
        html = t.editor.getContents(onlyContents: Boolean);

        parent = Template.parentData()
        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":html
        else 
            Meteor.users.update parent._id,
                $set:"#{@key}":html


Template.html_edit.helpers
        


Template.color_icon_edit.events
    'blur .color_icon': (e,t)->
        val = t.$('.color_icon').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val




Template.clear_value.events
    'click .clear_value': ->
        if confirm "Clear #{@title} field?"
            parent = Template.parentData()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{@key}":1
            else 
                Meteor.users.update parent._id,
                    $unset:"#{@key}":1

Template.link_edit.events
    'blur .edit_url': (e,t)->
        val = t.$('.edit_url').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else 
            Meteor.users.update parent._id,
                $set:"#{@key}":val
                
        $('body').toast(
            showIcon: 'checkmark'
            message: "saved"
            # showProgress: 'bottom'
            class: 'success'
            # displayTime: 'auto',
            position: "bottom right"
        )
            

Template.datetime_edit.events
    'blur .edit_datetime': (e,t)->
        val = t.$('.edit_datetime').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else
            Meteor.users.update parent._id,
                $set:"#{@key}":val
        $('body').toast(
            showIcon: 'checkmark'
            message: "saved"
            # showProgress: 'bottom'
            class: 'success'
            # displayTime: 'auto',
            position: "bottom right"
        )


# Template.i.onCreated ->
#     @hovering = new ReactiveVar false
# Template.i.events
#     'mouseover .content': (e,t)-> t.hovering.set true
#     'mouseleave .content': (e,t)-> t.hovering.set false
# Template.i.helpers
#     is_hovering: -> Template.instance().hovering.get()

# Template.ibig.onCreated ->
#     @hovering = new ReactiveVar false
# Template.ibig.events
#     'mouseover .content': (e,t)-> t.hovering.set true
#     'mouseleave .content': (e,t)-> t.hovering.set false
# Template.ibig.helpers
#     is_hovering: -> Template.instance().hovering.get()

Template.icon_edit.events
    'blur .icon_val': (e,t)->
        val = t.$('.icon_val').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
            $('body').toast(
                showIcon: 'checkmark'
                message: "saved"
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )

Template.image_link_edit.events
    'blur .image_link_val': (e,t)->
        val = t.$('.image_link_val').val()
        parent = Template.parentData()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
            $('body').toast(
                showIcon: 'checkmark'
                message: "saved"
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )


Template.image_edit.events
    "change input[name='upload_image']": (e) ->
        files = e.currentTarget.files
        parent = Template.parentData()
        Cloudinary.upload files[0],
            # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
            # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
            (err,res) => #optional callback, you can catch with the Cloudinary collection as well
                if err
                    console.error 'Error uploading', err
                else
                    doc = Docs.findOne parent._id
                    if doc
                        Docs.update parent._id,
                            $set:"#{@key}":res.public_id
                    else 
                        Meteor.users.update parent._id,
                            $set:"#{@key}":res.public_id
                            
                        
    'click .call_cloud_visual': (e,t)->
        Meteor.call 'call_visual', Meteor.user()._model, 'cloud', ->
            $('body').toast(
                showIcon: 'dna'
                message: 'image autotagged'
                # showProgress: 'bottom'
                class: 'success'
                displayTime: 'auto',
                position: "bottom center"
            )


    'blur .cloudinary_id': (e,t)->
        cloudinary_id = t.$('.cloudinary_id').val()
        parent = Template.parentData()
        Docs.update parent._id,
            $set:"#{@key}":cloudinary_id


    'click #remove_photo': ->
        parent = Template.parentData()

        if confirm 'remove photo?'
            # Docs.update parent._id,
            #     $unset:"#{@key}":1
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{@key}":1
            else 
                Meteor.users.update parent._id,
                    $unset:"#{@key}":1
            $('body').toast(
                showIcon: 'checkmark'
                message: "saved"
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )






Template.array_edit.events
    'click .touch_element': (e,t)->
        $(e.currentTarget).closest('.touch_element').transition('slide left')
        
    'click .pick_tag': (e,t)->
        # console.log @
        picked_tags.clear()
        picked_tags.push @valueOf()
        gstate_set "/#{Template.parentData().group}"

    'keyup .new_element': (e,t)->
        if e.which is 13
            element_val = t.$('.new_element').val().trim()
            if element_val.length>0
                parent = Template.parentData()
                # if true
                # else
                #     parent = Template.parentData(5)
                doc = Docs.findOne parent._id
                console.log element_val.split("\n")

                if doc
                    Docs.update parent._id,
                        $addToSet:"#{@key}":element_val
                else 
                    Meteor.users.update parent._id,
                        $addToSet:"#{@key}":element_val
                # window.speechSynthesis.speak new SpeechSynthesisUtterance element_val
                t.$('.new_element').val('')

    'click .remove_element': (e,t)->
        # $(e.currentTarget).closest('.touch_element').transition('slide left', 1000)

        element = @valueOf()
        console.log element
        field = Template.currentData()
        parent = Template.parentData()
        # if field.direct
        # else
        #     parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        user = Meteor.users.findOne parent._id
        if doc
            Docs.update parent._id,
                $pull:"#{field.key}":element
        else if user
            Meteor.users.update parent._id,
                $pull:"#{field.key}":element
        t.$('.new_element').focus()
        t.$('.new_element').val(element)

# Template.textarea.onCreated ->
#     @editing = new ReactiveVar false

# Template.textarea.helpers
#     is_editing: -> Template.instance().editing.get()


Template.textarea_edit.events
    # 'click .toggle_edit': (e,t)->
    #     t.editing.set !t.editing.get()

    'blur .edit_textarea': (e,t)->
        textarea_val = t.$('.edit_textarea').val()
        parent = Template.parentData()

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":textarea_val


# Template.raw_edit.events
#     # 'click .toggle_edit': (e,t)->
#     #     t.editing.set !t.editing.get()

#     'blur .edit_textarea': (e,t)->
#         textarea_val = t.$('.edit_textarea').val()
#         parent = Template.parentData()

#         doc = Docs.findOne parent._id
#         if doc
#             Docs.update parent._id,
#                 $set:"#{@key}":textarea_val



Template.text_edit.events
    'blur .edit_text': (e,t)->
        val = t.$('.edit_text').val()
        if @direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else 
            Meteor.users.update parent._id,
                $set:"#{@key}":val




Template.number_edit.events
    'blur .edit_number': (e,t)->
        console.log @
        parent = Template.parentData()
        val = parseInt t.$('.edit_number').val()
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val
        else 
            Meteor.users.update parent._id,
                $set:"#{@key}":val
# Template.float_edit.events
#     'blur .edit_float': (e,t)->
#         parent = Template.parentData()
#         val = parseFloat t.$('.edit_float').val()
#         doc = Docs.findOne parent._id
#         if doc
#             Docs.update parent._id,
#                 $set:"#{@key}":val


Template.slug_edit.events
    'blur .edit_text': (e,t)->
        val = t.$('.edit_text').val()
        parent = Template.parentData()

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":val


#     'click .slugify_title': (e,t)->
#         page_doc = Docs.findOne Meteor.user()._model
#         # val = t.$('.edit_text').val()
#         parent = Template.parentData()
#         doc = Docs.findOne parent._id
#         Meteor.call 'slugify', page_doc._id, (err,res)=>
#             Docs.update page_doc._id,
#                 $set:slug:res

Template.kvs.helpers
    kve_class: ->
        parent = Template.parentData()
        if parent["#{@key}"] is @value then 'active' else 'basic'


Template.kvs.events
    'click .set_value': (e,t)->
        parent = Template.parentData()
        # $(e.currentTarget).closest('.button').transition('pulse', 100)
        if parent
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set:"#{@key}":@value



Template.skvs.helpers
    kve_class: ->
        if Session.equals(@key, @value) then 'active' else 'basic'


Template.skvs.events
    'click .set_value': (e,t)->
        # $(e.currentTarget).closest('.button').transition('pulse', 100)

        Session.set(@key,@value)




Template.boolean_edit.helpers
    boolean_toggle_class: ->
        if @direct
            parent = Template.parentData()
        else 
            parent = Template.parentData(5)
            
        if parent["#{@key}"] then 'active' else 'basic'


Template.boolean_edit.events
    'click .toggle_boolean': (e,t)->
        parent = Template.parentData()
        $(e.currentTarget).closest('.button').transition('bounce', 1000)
        if @direct
            parent = Template.parentData()
        else 
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]
        else 
            Meteor.users.update parent._id,
                $set:"#{@key}":!parent["#{@key}"]
Template.single_doc_view.onCreated ->
    # @autorun => Meteor.subscribe 'model_docs', @data.ref_model

Template.single_doc_view.helpers
    choices: ->
        Docs.find
            model:@ref_model




Template.single_doc_edit.onCreated ->
    @autorun => Meteor.subscribe 'model_docs', @data.ref_model, ->

Template.single_doc_edit.helpers
    choices: ->
        if @ref_model
            Docs.find {
                model:@ref_model
            }, sort:slug:1
    calculated_label: ->
        ref_doc = Template.currentData()
        key = Template.parentData().button_label
        ref_doc["#{key}"]

    choice_class: ->
        selection = @
        current = Template.currentData()
        ref_field = Template.parentData(1)
        if ref_field.direct
            parent = Template.parentData(2)
        else
            parent = Template.parentData(5)
        target = Template.parentData(2)
        # if true
        #     if target["#{ref_field.key}"]
        #         if @ref_field is target["#{ref_field.key}"] then 'active' else ''
        #     else ''
        # else
        if parent["#{ref_field.key}"]
            if @_id is parent["#{ref_field.key}"] then 'active large' else 'compact'
        # else ''


Template.single_doc_edit.events
    'click .remove': ->
        ref_field = Template.currentData()
        if ref_field.direct
            parent = Template.parentData(1)
        else
            parent = Template.parentData(5)

        Docs.update parent._id,
            $unset:"#{ref_field.key}":1

    'click .select_choice': ->
        selection = @
        console.log @
        
        console.log Template.parentData(1)
        console.log Template.parentData(2)
        console.log Template.parentData(3)
        console.log Template.parentData(4)
        console.log Template.parentData(5)
        console.log Template.parentData(6)
        ref_field = Template.currentData()
        if ref_field.direct
            parent = Template.parentData(1)
        else
            parent = Template.parentData(5)
        # parent = Template.parentData(1)

        # key = ref_field.button_key
        key = ref_field.key
        console.log ref_field, 'ref field'


        # if parent["#{key}"] and @["#{ref_field.button_key}"] in parent["#{key}"]
        if parent["#{key}"] and @_id is parent["#{key}"]
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{ref_field.key}":1
        else
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $set: "#{ref_field.key}": @_id


Template.multi_doc_view.onCreated ->
    @autorun => Meteor.subscribe 'model_docs', @data.ref_model

Template.multi_doc_view.helpers
    choices: ->
        Docs.find {
            model:@ref_model
        }, sort:number:-1

# Template.multi_doc_edit.onRendered ->
#     $('.ui.dropdown').dropdown(
#         clearable:true
#         action: 'activate'
#         onChange: (text,value,$pickedItem)->
#         )



Template.multi_doc_edit.onCreated ->
    @autorun => Meteor.subscribe 'model_docs', @data.ref_model, (err,res)->
        console.log res
Template.multi_doc_edit.helpers
    choices: ->
        Docs.find model:@ref_model

    choice_class: ->
        selection = @
        current = Template.currentData()
        parent = Template.parentData()
        ref_field = Template.parentData(1)
        target = Template.parentData(2)

        if target["#{ref_field.key}"]
            if @_id in target["#{ref_field.key}"] then 'active large' else 'compact circular small'
        else
            ''

Template.multi_doc_edit.events
    'click .clear_ref_field': ->
        console.log @
        parent = Template.parentData()
        if @direct
            if confirm "clear #{@key}?"
                Docs.update parent._id,
                    $unset:
                        "#{@key}":1
        # console.log Template.parentData(2)
    'click .pick_choice': ->
        selection = @
        ref_field = Template.currentData()
        if ref_field.direct
            parent = Template.parentData(2)
        else
            parent = Template.parentData(6)
        parent = Template.parentData(1)
        parent2 = Template.parentData(2)
        parent3 = Template.parentData(3)
        parent4 = Template.parentData(4)
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)
        parent7 = Template.parentData(7)

        #

        if parent["#{ref_field.key}"] and @_id in parent["#{ref_field.key}"]
            doc = Docs.findOne parent._id
            console.log 'pulling from', doc
            if doc
                Docs.update parent._id,
                    $pull:"#{ref_field.key}":@_id
        else
            doc = Docs.findOne parent._id
            console.log 'adding to on', doc
            if doc
                Docs.update parent._id,
                    $addToSet: "#{ref_field.key}": @_id



Template.multi_user_edit.onCreated ->
    @user_results = new ReactiveVar
    @autorun => @subscribe 'all_users'
Template.multi_user_edit.helpers
    user_results: -> 
        console.log Template.instance().user_results.get()
        Template.instance().user_results.get()
Template.multi_user_edit.events
    'click .clear_results': (e,t)->
        t.user_results.set null

    'keyup .multi_user_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('.multi_user_select_input').val().trim()
        if search_value.length > 1
            console.log 'searching', search_value
            Meteor.call 'lookup_user', search_value, @role_filter, (err,res)=>
                if err then console.error err
                else
                    t.user_results.set res

    'click .select_user': (e,t) ->
        page_doc = Docs.findOne Meteor.user()._model
        field = Template.currentData()

        # console.log @
        console.log 'adding', @
        console.log Template.parentData()
        console.log Template.currentData()
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        # console.log Template.parentData(4)


        val = t.$('.multi_user_select_input').val()
        if field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)
        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $addToSet:
                    "#{field.key}":@_id
                    "#{field.key}_usernames":@username
        else
            Meteor.users.update parent._id,
                $addToSet:
                    "#{field.key}":@_id
                    "#{field.key}_usernames":@username
            
        t.user_results.set null
        $('.multi_user_select_input').val ''
        # Docs.update page_doc._id,
        #     $set: assignment_timestamp:Date.now()

    'click .pull_user': ->
        if confirm "remove #{@username}?"
            parent = Template.parentData(1)
            field = Template.currentData()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $pull:
                        "#{field.key}":@_id
                        "#{field.key}_usernames":@username
            else
                Meteor.users.update parent._id,
                    $pull:
                        "#{field.key}":@_id
                        "#{field.key}_usernames":@username

        #     page_doc = Docs.findOne Meteor.user()._model
            # Meteor.call 'unassign_user', page_doc._id, @


Template.single_user_edit.onCreated ->
    @user_results = new ReactiveVar
Template.single_user_edit.helpers
    user_results: -> Template.instance().user_results.get()
Template.single_user_edit.events
    'click .clear_results': (e,t)->
        t.user_results.set null

    'keyup .single_user_select_input': (e,t)->
        search_value = $(e.currentTarget).closest('.single_user_select_input').val().trim()
        if search_value.length > 1
            console.log 'searching', search_value
            Meteor.call 'lookup_user', search_value, @role_filter, (err,res)=>
                if err then console.error err
                else
                    t.user_results.set res

    'click .select_user': (e,t) ->
        page_doc = Docs.findOne Meteor.user()._model
        field = Template.currentData()

        # console.log @
        # console.log Template.currentData()
        # console.log Template.parentData()
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        # console.log Template.parentData(4)


        val = t.$('.edit_text').val()
        if field.direct
            parent = Template.parentData()
        else
            parent = Template.parentData(5)

        doc = Docs.findOne parent._id
        if doc
            Docs.update parent._id,
                $set:"#{field.key}":@_id
        else
            Meteor.users.update parent._id,
                $set:"#{field.key}":@_id
            
        t.user_results.set null
        $('.single_user_select_input').val ''
        # Docs.update page_doc._id,
        #     $set: assignment_timestamp:Date.now()

    'click .pull_user': ->
        if confirm "remove #{@username}?"
            parent = Template.parentData(1)
            field = Template.currentData()
            doc = Docs.findOne parent._id
            if doc
                Docs.update parent._id,
                    $unset:"#{field.key}":1
            else
                Meteor.users.update parent._id,
                    $unset:"#{field.key}":1

        #     page_doc = Docs.findOne Meteor.user()._model
            # Meteor.call 'unassign_user', page_doc._id, @



