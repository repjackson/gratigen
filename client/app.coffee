@picked_essentials = new ReactiveArray []
@picked_tags = new ReactiveArray []
@picked_models = new ReactiveArray []
@picked_sections = new ReactiveArray []
@picked_ingredients = new ReactiveArray []
@current_markers = new ReactiveArray []




moment.locale('en', {
    relativeTime: {
        future: 'in %s',
        # past: '%s ago',
        past: '%s',
        s:  'seconds',
        ss: '%ss',
        m:  'a minute',
        mm: '%dm',
        h:  'an hour',
        hh: '%dh',
        d:  'a day',
        dd: '%dd',
        M:  'a month',
        MM: '%dM',
        y:  'a year',
        yy: '%dY'
    }
});


Template.app.events
    'click .printme':-> console.log @
# Template.app.onRendered ->
    # Meteor.setInterval ->
    #     d = Docs.findOne Meteor.user().delta_id
    #     if Meteor.user().username is 'dev'
    #         $(".friend_cursor").css({top: d.dev2_y, left: d.dev2_x, position:'absolute'});
    #     else if Meteor.user().username is 'dev2'
    #         $(".friend_cursor").css({top: d.dev_y, left: d.dev_x, position:'absolute'});
    # , 1000    
    # Meteor.setInterval ->
    #     handleMouseMove = (event) ->
    #         eventDoc = undefined
    #         doc = undefined
    #         body = undefined
    #         event = event or window.event
    #         # IE-ism
    #         # If pageX/Y aren't available and clientX/Y are,
    #         # calculate pageX/Y - logic taken from jQuery.
    #         # (This is to support old IE)
    #         if event.pageX == null and event.clientX != null
    #             eventDoc = event.target and event.target.ownerDocument or document
    #             doc = eventDoc.documentElement
    #             body = eventDoc.body
    #             event.pageX = event.clientX + (doc and doc.scrollLeft or body and body.scrollLeft or 0) - (doc and doc.clientLeft or body and body.clientLeft or 0)
    #             event.pageY = event.clientY + (doc and doc.scrollTop or body and body.scrollTop or 0) - (doc and doc.clientTop or body and body.clientTop or 0)
    #         # Use event.pageX / event.pageY here
    #         # console.log event.pageX
    #         # console.log event.pageY
    #         if Meteor.user().username is 'dev'
    #             Docs.update Meteor.user().delta_id, 
    #                 $set:
    #                     dev_x:event.pageX
    #                     dev_y:event.pageY
    #             # $(".friend_cursor").css({top: event.pageY, left: event.pageX, position:'absolute'});
    #         else if Meteor.user().username is 'dev2'
    #             Docs.update Meteor.user().delta_id, 
    #                 $set:
    #                     dev2_x:event.pageX
    #                     dev2_y:event.pageY
    #             # $(".friend_cursor").css({top: event.pageY, left: event.pageX, position:'absolute'});
                
    #         Meteor.users.update({_id:Meteor.userId()},{
    #             $set:
    #                 pageX:event.pageX
    #                 pageY:event.pageY
    #         }, ->
    #             # console.log 'updated', event.pageX
    #         )
            
    #       document.onmousemove = handleMouseMove
    # , 100


# Template.gridstack.onRendered ->
#       items = [
#           {content: 'my first widget'},
#         #   # will default to location (0,0) and 1x1
#           {w: 2, content: 'another longer widget!'}
#         #   # will be placed next at (1,0) and 2x1
#       ];
#       grid = GridStack.init();
#       grid.load(items);

# Template.gridstack.events 
#     'click .make': ->
#         Template.instance().items = [
#             {content: 'my first widget'}, 
#             # // will default to location (0,0) and 1x1
#             {w: 2, content: 'another longer widget!'}
#             # // will be placed next at (1,0) and 2x1
#         ];
#         Template.instance().grid = GridStack.init({
#             minRow: 1, # don't let it collapse when empty
#             cellHeight: '7rem'
#             # alwaysShowResizeHandle: false
#             animate: true
#             # auto: true
#             # cellHeight: 7
#             # cellHeightUnit: "rem"
#             # column: 12
#             # ddPlugin: class o
#             # disableDrag: false
#             # disableOneColumnMode: false
#             # disableResize: false
#             # dragIn: undefined
#             # dragInOptions: {revert: 'invalid', handle: '.grid-stack-item-content', scroll: false, appendTo: 'body'}
#             # draggable: {handle: '.grid-stack-item-content', scroll: false, appendTo: 'body'}
#             float: true
#             # handle: ".grid-stack-item-content"
#             # handleClass: null
#             # itemClass: "grid-stack-item"
#             # margin: 10
#             # marginBottom: 10
#             # marginLeft: 10
#             # marginRight: 10
#             # marginTop: 10
#             # marginUnit: "px"
#             # maxRow: 0
#             # minRow: 1
#             # minWidth: 768
#             # oneColumnModeDomSort: false
#             # placeholderClass: "grid-stack-placeholder"
#             # placeholderText: "oh hello"
#             # removable: true
#             # removableOptions: {accept: '.grid-stack-item'}
#             # removeTimeout: 2000
#             # resizable: {autoHide: true, handles: 'se'}
#             # rtl: false
#             # staticGrid: false
#             # styleInHead: false
#             # _class: "grid-stack-instance-1286"
#             # _isNested: false
#         });
#         Template.instance().grid.load(Template.instance().items);
        
#     'click .toggle_float': (e,t)->
#         console.log @
#         console.log Template.instance()
#         Template.instance().grid.float(! Template.instance().grid.getFloat());
#         # document.querySelector('#float').innerHTML = 'float: ' + grid.getFloat();

#     'click .add': -> 
        
#         # count = 0
#         # getNode = ()->
#         #     n = Template.instance().items[count] or {
#         #         x: Math.round(12 * Math.random()),
#         #         y: Math.round(5 * Math.random()),
#         #         w: Math.round(1 + 3 * Math.random()),
#         #         h: Math.round(1 + 3 * Math.random())
#         #     };
#         #     n.content = n.content or String(count);
#         #     count++;
#         #     return n;
#         # Template.instance().grid.addWidget(getNode());
#         Template.instance().grid.addWidget();
#     'click .clear_all': -> Template.instance().grid.removeAll();
#     'click .remove_widget': (e)->
#           el.remove();
#           Template.instance().grid.removeWidget(el, false);
        
#     'click .enable': -> Template.instance().grid.enable();
#     'click .disable': -> Template.instance().grid.disable();

#         # grid = GridStack.init({
        
#         #     # // accept widgets dragged from other grids or from outside
#         #     # // true (uses '.grid-stack-item' class filter) or false
#         #     # // string for explicit class name
#         #     # //  (i: number, element: Element): boolean
#         #     acceptWidgets: false,
        
#         #     # // turns animation on
#         #     animate: false,
        
#         #     # // amount of columns and rows
#         #     column: 12,
#         #     row: 0,
        
#         #     # // max/min number of rows
#         #     maxRow: 0,
#         #     minRow: 0,
        
#         #     # // minimal width before grid will be shown in one column mode (default?: 768) */
#         #     oneColumnSize: 768,
        
#         #     # // set to true if you want oneColumnMode to use the DOM order and ignore x,y from normal multi column layouts during sorting. 
#         #     # // This enables you to have custom 1 column layout that differ from the rest. (default?: false)
#         #     oneColumnModeDomSort: false,
        
#         #     # // widget class
#         #     itemClass: 'grid-stack-item',
        
#         #     # // class for placeholder
#         #     placeholderClass: 'grid-stack-placeholder',
        
#         #     # // text for placeholder
#         #     placeholderText: '',
        
#         #     # // draggable handle selector
#         #     handle: '.grid-stack-item-content',
        
#         #     # // class for handle
#         #     handleClass: null,
        
#         #     # // allow for selecting older behavior (adding STYLE element to HEAD element instead of parentNode)
#         #     styleInHead: false,
        
#         #     # // an integer (px)
#         #     # // a string (ex: '100px', '10em', '10rem'). Note: % doesn't right - see CellHeight
#         #     # // 0, in which case the library will not generate styles for rows. Everything must be defined in your own CSS files.
#         #     # // auto - height will be calculated for square cells (width / column) and up<a href="https://www.jqueryscript.net/time-clock/">date</a>d live as you resize the window
#         #     # // initial - similar to 'auto' (start at square cells) but stay that size during window resizing.
#         #     cellHeight: 60,
        
#         #     # // throttle time delay (in ms) used when cellHeight='auto' to improve performance vs usability
#         #     cellHeightThrottle: 100,
        
#         #     # // list of children items to create when calling load() or addGrid()
#         #     # // see item options below
#         #     children: [],
        
#         #     # // additional class on top of '.grid-stack' (which is required for our CSS) to differentiate this instance.
#         #     class: '',
        
#         #     # // cell height unit
#         #     cellHeightUnit: 'px',
        
#         #     # // margin
#         #     margin: 10,
#         #     marginUnit: 'px',
        
#         #     # // or
#         #     marginTop: 10,
#         #     marginBottom: 10,
#         #     marginLeft: 10,
#         #     marginRight: 10
        
#         #     # // if false it tells to do not initialize existing items
#         #     auto: true,
            
#         #     # // minimal width.
#         #     minWidth: 768,
        
#         #     # // class set on grid when in one column mode
#         #     oneColumnModeClass: 'grid-stack-one-column-mode',
        
#         #     # // set to true if you want oneColumnMode to use the DOM order and ignore x,y from normal multi column layouts during sorting. 
#         #     # // This enables you to have custom 1 column layout that differ from the rest.
#         #     oneColumnModeDomSort: false,
        
#         #     # // enable floating widgets
#         #     float: false,
        
#         #     # // makes grid static
#         #     staticGrid: false,
        
#         #     # // false the resizing handles are only shown while hovering over a widget
#         #     # // true the resizing handles are always shown
#         #     # // 'mobile' if running on a mobile device, default to true (since there is no hovering per say), else false. this uses this condition on browser agent check: alwaysShowResizeHandle: /<a href="https://www.jqueryscript.net/tags.php?/Android/">Android</a>|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test( navigator.userAgent )
#         #     alwaysShowResizeHandle: 'mobile',
        
#         #     # // allows to owerride <a href="https://www.jqueryscript.net/tags.php?/jQuery UI/">jQuery UI</a> draggable options
#         #     draggable: {
#         #       handle: '.grid-stack-item-content', 
#         #       scroll: true, 
#         #       appendTo: 'body'
#         #     },
        
#         #     # // specify the class of items that can be dragged into the grid
#         #     dragIn: false,
#         #     dragInOptions : {
#         #       helper: 'clone',
#         #       handle: '.grid-stack-item-content',
#         #       appendTo: 'body'
#         #     },
        
#         #     # // the type of engine to create (so you can subclass)
#         #     engineClass: 'GridStackEngine',
        
#         #     # // allows to owerride jQuery UI resizable options
#         #     resizable: {autoHide: true, handles: 'se'},
        
#         #     # // disallows dragging of widgets
#         #     disableDrag: false
        
#         #     # // disallows resizing of widgets
#         #     disableResize: false,
        
#         #     # // if `true` turns grid to RTL. 
#         #     # // Possible values are `true`, `false`, `'auto'`
#         #     rtl: 'auto',
        
#         #     # // if `true` widgets could be removed by dragging outside of the grid
#         #     removable: false,
#         #     removableOptions: {
#         #       accept: 'grid-stack-item'
#         #     },
        
#         #     # // time in milliseconds before widget is being removed while dragging outside of the grid
#         #     removeTimeout: 2000,
        
#         #     # // disables the oneColumnMode when the grid width is less than minW
#         #     disableOneColumnMode: 'false',
            
#         # });          
          
#     'click .test': ->
#         # grid.on('added removed change', (e, items)->
#         #   if (!items) return;
#         #   str = '';
#         #   items.forEach((item) { str += ' (x,y)=' + item.x + ',' + item.y; });
#         #   console.log(e.type + ' ' + items.length + ' items:' + str );
#         # ;
    
#         # serializedData = [
#         #   {x: 0, y: 0, w: 2, h: 2, id: '0'},
#         #   {x: 3, y: 1, h: 2, id: '1', 
#         #   content: "<button onclick=\"alert('clicked!')\">Press me</button><div>text area</div><div><textarea></textarea></div><div>Input Field</div><input type='text'><div contentEditable=\"true\">Editable Div</div>"},
#         #   {x: 4, y: 1, id: '2'},
#         #   {x: 2, y: 3, w: 3, id: '3'},
#         #   {x: 1, y: 3, id: '4'}
#         # ];
#         # serializedData.forEach((n, i) =>
#         #   n.content = `<button onClick="removeWidget(this.parentElement.parentElement)">X</button><br> ${i}<br> ${n.content ? n.content : ''}`);
#         # serializedFull;
    
#         # # 2.x method - just saving list of widgets with content (default)
#         #  loadGrid() {
#         #   grid.load(serializedData, true); # update things
#         # }
    
#         # 2.x method
#         #  saveGrid() {
#         #   delete serializedFull;
#         #   serializedData = grid.save();
#         #   document.querySelector('#saved-data').value = JSON.stringify(serializedData, null, '  ');
#         # }
    
#         # # 3.1 full method saving the grid options + children (which is recursive for nested grids)
#         #  saveFullGrid() {
#         #   serializedFull = grid.save(true, true);
#         #   serializedData = serializedFull.children;
#         #   document.querySelector('#saved-data').value = JSON.stringify(serializedFull, null, '  ');
#         # }
    
#         # # 3.1 full method to reload from scratch - delete the grid and add it back from JSON
#         #  loadFullGrid() {
#         #   if (!serializedFull) return;
#         #   grid.destroy(true); # nuke everything
#         #   grid = GridStack.addGrid(document.querySelector('#gridCont'), serializedFull)
#         # }
    
#         #  clearGrid() {
#         #   grid.removeAll();
#         # }
    
#         #  removeWidget(el) {
#         #   # TEST removing from DOM first like Angular/React/Vue would do
#         #   el.remove();
#         #   grid.removeWidget(el, false);
#         # }
#         # loadGrid();



Template.app.helpers
    ct: -> 
        # console.log Meteor.user()._template
        delta = Docs.findOne Meteor.user().delta_id
        # console.log delta
        if delta
            delta._template

Template.sessionbar.helpers
    delta_item_class: ->
        if @_id is Meteor.user().delta_id
            'active blue large invert'
        else 
            'small'
    editing_delta: ->
        Session.equals('editing_id', @_id)
    delta_users: ->
        Meteor.users.find
            delta_id:@_id
Template.sessionbar.events 
    'dblclick .pick_delta': ->
        Session.set('editing_id', @_id)
    'blur .pick_delta':(e)->
        if Session.get('editing_id')
            Session.set('editing_id', null)
            $('body').toast({
                title: "#{name} saved"
                # message: 'Please see desk staff for key.'
                class : 'success invert'
                showIcon:'checkmark'
                # showProgress:'bottom'
                position:'bottom right'
                })

    'click .add_session': ->
        name = prompt 'name session'
        if name
            new_id = 
                Docs.insert 
                    model:'delta'
                    name:name
            Session.set('loading',true)
            Meteor.users.update Meteor.userId(),
                $set:
                    delta_id:new_id
            $('body').toast({
                title: "#{name} session made"
                # message: 'Please see desk staff for key.'
                class : 'success'
                showIcon:'yin yang'
                # showProgress:'bottom'
                position:'bottom right'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
            Session.set('loading',false)

    'click .pick_delta': (e)->
        Session.set('loading',true)
        if Meteor.user().delta_id and @_id is Meteor.user().delta_id
            Meteor.users.update({_id:Meteor.userId()},{$unset:delta_id:1})
            $(e.currentTarget).closest('.item').transition('shake', 500)
            Session.set('loading',false)
        else 
            Meteor.users.update({_id:Meteor.userId()},{$set:delta_id:@_id})
            $(e.currentTarget).closest('.item').transition('bounce', 500)
            Session.set('loading',false)

        # console.log @_id
        # console.log Meteor.user().delta_id


Template.doc_history_button.onRendered ->
    $('.goto_doc')
      .popup({
        inline: true
      })
    

# Template.doc_history_button.events 
#     'click .delete_history_item': ->
#         console.log @
#         Docs.update Meteor.user().delta_id, 
#             $pull:
#                 _doc_history:@_id
# Template.doc_history_button.helpers 
#     doc_from_id:->
#         # console.log @, @valueOf()
#         Docs.findOne @valueOf()
        
Template.nav.events 
    'click .goto_profile': ->
        console.log 'profile'
        # delta = Docs.findOne Meteor.user().delta_id
        if @_id 
            user = Meteor.users.findOne @_id
        else 
            user = Meteor.user()
        if Meteor.user().delta_id
            Docs.update Meteor.user().delta_id,
                $set:
                    _template:'profile_layout'
                    _username:user.username
                    _user_id:user._id
                $addToSet:
                    _doc_history:user._id
            
Template.app.events 
    'click .edit_this': ->
        console.log 'editoing to', @title
        # delta = Docs.findOne Meteor.user().delta_id
        if @model is 'model'
            Docs.update Meteor.user().delta_id,
                $set:
                    _template:'delta'
                    _doc_id:@_id
                    _model:@slug
                    edit_mode:true
                $addToSet:
                    _doc_history:@_id
        else 
            Docs.update Meteor.user().delta_id,
                $set:
                    _template:'model_doc_view'
                    _doc_id:@_id
                    _model:@model
                    edit_mode:true
                $addToSet:
                    _doc_history:@_id
    'click .goto_doc': (e,t)->
        console.log 'going to', @title
        state_object = {
            foo: "bar",
        }
        history.pushState(state_object, @title, @title)
        
        # delta = Docs.findOne Meteor.user().delta_id
        $(e.currentTarget).closest('.grid').transition('fly right', 500)
        if @model is 'model'
            Docs.update Meteor.user().delta_id,
                $set:
                    _template:'delta'
                    _doc_id:@_id
                    _model:@slug
                $addToSet:
                    _doc_history:@_id
        else 
            Docs.update Meteor.user().delta_id,
                $set:
                    _template:'model_doc_view'
                    _doc_id:@_id
                    _model:@model
                $addToSet:
                    _doc_history:@_id
    'click .set_template': (e,t)->
        console.log @
        
        # console.log e.currentTarget.attributes[1].value
        Session.set('loading',true)
        Meteor.call 'set_template', e.currentTarget.attributes[1].value, ->
            Session.set('loading',false)
        # delta = Docs.findOne Meteor.user().delta_id
        # Docs.update Meteor.user().delta_id,
        #     $set:
        #         _doc_id:@_id
        #     $addToSet:
        #         _doc_history:@_id

Template.comet.helpers 
    current_chat: ->
        console.log Meteor.user().username


Template.add_model_doc_button.events 
    'click .add_model_doc': ->
        new_id = 
            Docs.insert 
                model:@slug 
        Meteor.call 'change_state',{ _template:'model_doc_view', _model:@slug, _doc_id:new_id, edit_mode:true }, ->


# # Meteor.users.find(_id:Meteor.userId()).observe({
# #     changed: (new_doc, old_doc)->
#         difference = new_doc.points-old_doc.points
#         if difference > 0
#             $('body').toast({
#                 title: "#{new_doc.points-old_doc.points}p earned"
#                 # message: 'Please see desk staff for key.'
#                 class : 'success'
#                 showIcon:'hashtag'
#                 # showProgress:'bottom'
#                 position:'bottom right'
#                 # className:
#                 #     toast: 'ui massive message'
#                 # displayTime: 5000
#                 transition:
#                   showMethod   : 'zoom',
#                   showDuration : 250,
#                   hideMethod   : 'fade',
#                   hideDuration : 250
#                 })

# })

# Docs.find(model:'delta', name:'red').observe({
#     changed: (new_doc, old_doc)->
#         console.log new_doc.dev_x, 'dev x'
#         console.log new_doc.dev2_x, 'dev2 x'
# })


Template.app.helpers 
    invert_class: ->
        if Meteor.user().invert_mode 
            'invert'

Template.footer.events 
    'click .print_me': -> console.log @
Template.footer.helpers
    doc_docs: -> Docs.find {}
    result_docs: -> Results.find {}

    user_docs: -> Meteor.users.find()


    

$.cloudinary.config
    cloud_name:"facet"
Template.app.events
    # 'click .fly_out': -> 
    #     # Meteor.users.update({_id:Meteor.userId()}, {$set:flyout_doc_id:@_id})
    #     # d=Docs.findOne Meteor.user().delta_id 
    #     if @_id
    #         Docs.update Meteor.user().delta_id, 
    #             $set:
    #                 flyout_doc_id:@_id
    #         $('.ui.flyout').flyout('toggle')
    # 'click .show_modal': ->
    #     console.log @
    #     Docs.update Meteor.user().delta_id, 
    #         $set:
    #             modal_doc_id:@_id
    #     # $('.ui.flyout').flyout('toggle')
    #     # Meteor.users.update({_id:Meteor.userId()}, {$set:modal_doc_id:@_id})
    #     $('.ui.modal').modal({
    #         inverted:true
    #         # blurring:true
    #         }).modal('show')


    'click .fly_right': (e,t)-> $(e.currentTarget).closest('.card').transition('fly right', 500)
    'click .zoom': (e,t)-> $(e.currentTarget).closest('.card').transition('drop', 500)
    'click .fly_left': (e,t)-> 
        $(e.currentTarget).closest('.segment').transition('fly left', 500)
        $(e.currentTarget).closest('.card').transition('fly left', 500)
    'click .fly_down': (e,t)-> $(e.currentTarget).closest('.card').transition('fly down', 500)
    # 'click .button': ->
    #     $(e.currentTarget).closest('.button').transition('bounce', 1000)

    # 'click a(not:': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)

    'click .log_view': ->
        # console.log Template.currentData()
        # console.log @
        Docs.update @_id,
            $inc: views: 1

# Template.healthclub.events
    # 'click .button': ->
    #     $('.global_container')
    #     .transition('fade out', 5000)
    #     .transition('fade in', 5000)

# Stripe.setPublishableKey Meteor.settings.public.stripe_publishable
