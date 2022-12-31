# if Meteor.isClient
#     # # @picked_tags = new ReactiveArray []
    
#     Router.route '/map', -> @render 'map'
#     # Router.route '/map', -> @render 'localmap'
#     # Router.route '/map2', -> @render 'map2'
#     @current_markers = new ReactiveArray []
    
#     # # @onpush = (event)->
#     # #   console.log(event.data);
    
#     # # self.registration.showNotification("New mail from Alice", {
#     # #   actions: [{action: 'archive', title: "Archive"}]
#     # # });
    
    
    
    
#     Template.mapgl.helpers
#         pos:-> 
#             console.log Geolocation.currentLocation()
#             Geolocation.currentLocation()
#         lat: -> Geolocation.latLng().lat
#         lng: -> Geolocation.latLng().lng
#         current_lat: -> Session.get('current_lat')
#         current_lon: -> Session.get('current_long')
    
#     Template.mapgl.events
#         'click .locate': ->
#             navigator.geolocation.getCurrentPosition (position) =>
#                 console.log 'navigator position', position
#                 Session.set('current_lat', position.coords.latitude)
#                 Session.set('current_long', position.coords.longitude)
                
#                 console.log 'saving long', position.coords.longitude
#                 console.log 'saving lat', position.coords.latitude
            
#                 pos = Geolocation.currentLocation()
#                 # user_position_marker = 
#                 #     Markers.findOne
#                 #         _author_id: Meteor.userId()
#                 #         model:'user_marker'
#                 # unless user_position_marker
#                 #     Markers.insert 
#                 #         model:'user_marker'
#                 #         _author_id: Meteor.userId()
#                 #         latlng:
#                 #             lat:position.coords.latitude
#                 #             long:position.coords.longitude
#                 # if user_position_marker
#                 #     Markers.update user_position_marker._id,
#                 #         $set:
#                 #             latlng:
#                 #                 lat:position.coords.latitude
#         #                         long:position.coords.longitude
#         #         Meteor.users.update Meteor.userId(),
#         #             $set:
#         #                 location:
#         #                     "type": "Point"
#         #                     "coordinates": [
#         #                         position.coords.longitude
#         #                         position.coords.latitude
#         #                     ]
#         #                 current_lat: position.coords.latitude
#         #                 current_long: position.coords.longitude
#         #             # , (err,res)->
#         #             #     console.log res
    
            
            
#         #     $('.main_content')
#         #         .transition('fade out', 250)
#         #         .transition('fade in', 250)
    
    
#     Template.mapgl.onCreated ->
#         # @autorun => Meteor.subscribe 'markers'
#         # if Meteor.user()
#         # @autorun => Meteor.subscribe 'nearby_people', Session.get('current_user')
    
#     Template.mapgl.onRendered =>
#         Meteor.setTimeout =>
#             # pos.coords.latitude
#             # Session.set('current_lat', pos.coords.latitude)
#             # Session.set('current_long', pos.coords.longitude)
#             # Meteor.users.update Meteor.userId(),
#             #     $set:current_position:pos
#             @map = L.map('mapid',{
#                 dragging:false, 
#                 zoomControl:false
#                 bounceAtZoomLimits:false
#                 touchZoom:false
#                 doubleClickZoom:false
#                 }).setView([Session.get('current_lat'), Session.get('current_long')], 16);
    
#             # var map = L.map('map', {
#             # doubleClickZoom: false
#             # }).setView([49.25044, -123.137], 13);
            
#             # L.tileLayer.provider('Stamen.Watercolor').addTo(map);
            
#             # map.on('dblclick', (event)->
#             #     console.log 'clicked', event
#             #     Markers.insert({latlng: event.latlng});
#             # )
#             # // add clustermarkers
#             # markers = L.markerClusterGroup();
#             # map.addLayer(markers);
            
#             query = Markers.find();
#             query.observe
#                 added: (doc)->
#                     console.log 'added marker', doc
#                     # marker = L.marker(doc.latlng).on('click', (event)->
#                     #     Markers.remove({_id: doc._id});
#                     # );
#                     # console.log {{c.url currentUser.profile_image_id height=500 width=500 gravity='face' crop='fill'}}
#                     myIcon = L.icon({
#                         iconUrl:"https://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_100/#{Meteor.user().profile_image_id}"
#                         iconSize: [38, 95],
#                         iconAnchor: [22, 94],
#                         popupAnchor: [-3, -76],
#                         # shadowUrl: 'my-icon-shadow.png',
#                         shadowSize: [68, 95],
#                         shadowAnchor: [22, 94]
#                     });
    
#                     L.marker([doc.latlng.lat, doc.latlng.long],{
#                         draggable:true
#                         icon:myIcon
#                         riseOnHover:true
#                         }).addTo(map)
#                     # markers.addLayer(marker);
                    
#                 removed: (oldDocument)->
#                     layers = map._layers;
#                     for key in layers
#                         val = layers[key];
#                         if (val._latlng)
#                             if val._latlng.lat is oldDocument.latlng.lat and val._latlng.lng is oldDocument.latlng.lng
#                                 markers.removeLayer(val)
                
#             L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
#                 # attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
#                 accessToken:"pk.eyJ1IjoicmVwamFja3NvbiIsImEiOiJja21iN3V5OWgwMGI4Mm5temU0ZHk3bjVsIn0.3nq7qTUAh0up18iIIuOPrQ"
#                 maxZoom: 19,
#                 minZoom: 19,
#                 id: 'mapbox/outdoors-v11',
#                 tileSize: 512,
#                 zoomOffset: -1,
#             }).addTo(map);
#             # L.marker([Session.get('current_lat'), Session.get('current_long')]).addTo(map)
#                 # .openPopup();
#                 # .bindPopup('you')
#             L.circle([Session.get('current_lat'), Session.get('current_long')], {
#                 color: 'blue',
#                 weight: 0
#                 fillColor: '#3b5998',
#                 fillOpacity: 0.16,
#                 radius: 50
#             }).addTo(map);
#             onMapClick = (e)->
#                 alert("You clicked the map at " + e.latlng);
            
#             # map.on('click', onMapClick);
    
#         , 2000
#         Meteor.setInterval ()->
#             navigator.geolocation.getCurrentPosition((position)->
#                 Session.set('lat', position.coords.latitude)
#                 Session.set('lon', position.coords.longitude)
#             , 5000);
#         pos.coords.latitude
#         pos.coords.longitude
#         if Session.get('current_lat')
#             map = L.map('mapid').setView([Session.get('current_lat'), Session.get('current_long')], 13);
#         L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
#             attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
#             maxZoom: 18,
#             id: 'mapbox/outdoors-v11',
#             tileSize: 512,
#             zoomOffset: -1,
#             accessToken: 'your.mapbox.access.token'
#         }).addTo(mymap);
#         L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
#             attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
#         }).addTo(map);
        
    
#         L.marker([53.5, -0.1]).addTo(map)
#             .bindPopup('person')
#             .openPopup();
        
    
#         # home_subs_ready: ->
#         #     Template.instance().subscriptionsReady()
#         #
#         # home_subs_ready: ->
#         #     if Template.instance().subscriptionsReady()
#         #         Session.set('global_subs_ready', true)
#         #     else
#         #         Session.set('global_subs_ready', false)
    
    
#     # Template.nearby_person.onCreated ->
#     #     # console.log Template.parentData()
#     #     # console.log @
#     #     # console.log @data
#     #     # L.marker([@data.current_lat, @data.current_long]).addTo(@map)
#     #     #     .bindPopup('person')
#     #     #     .openPopup();
    
        
#     # # cursor = Meteor.users.find();
#     # # cursor.observeChanges
#     # #     added: (id, object) ->
#     # #         console.log("person added")
    
    
#     # Template.mapgl.helpers
#     #     nearby_people: ->
#     #         Docs.find
#     #             light_mode:true
#         # 'click .init': (e,t)->
#     # Template.mapgl.onRendered ->
#     Template.mapgl.events
#         'click .locate': (e,t)->
#             mapboxgl.accessToken = 'pk.eyJ1IjoiZ29sZHJ1biIsImEiOiJja3c2cTlwd3BmNmhqMnZwZzh3ZW5vdHRjIn0.bSaNtJ5tjrEQ_UitX5FbNQ';
#             t.mapgl = new mapboxgl.Map({
#                 container: 'map', # container ID
#                 style: 'mapbox://styles/mapbox/streets-v11', # style URL
#                 center: [Session.get('current_long'),Session.get('current_lat')], # starting position [lng, lat]
#                 zoom: 17 # starting zoom
#                 boxZoom: false
#                 dragPan:false
#                 scrollZoom:false
#                 doubleClickZoom:false
#             });
#             t.mapgl.on('click', (e)->
#                 # 	alert(e.latlng);
#                 $('body').toast(
#                     showIcon: 'marker'
#                     message: "lat long: #{e.latlng}"
#                     # showProgress: 'bottom'
#                     class: 'success'
#                     displayTime: 'auto',
#                     position: "bottom right"
#                 )
#             )
#             circle = L.circle([Session.get('lat'), Session.get('long')], 200).addTo(t.mapgl);
#             console.log circle.getLatLng()
#             console.log circle.getRadius()
    
        
#     Template.mapgl.onCreated ->
#         @autorun => @subscribe 'some_posts', ->
#     # Template.mapgl.onRendered ->
#     #     # console.log 'hi'
#     #     # console.log @
#     #     L.mapbox.accessToken = 'pk.eyJ1IjoiZ29sZHJ1biIsImEiOiJja3c2cTlwd3BmNmhqMnZwZzh3ZW5vdHRjIn0.bSaNtJ5tjrEQ_UitX5FbNQ';
#     #     @map = L.mapbox.map 'map'
    
#     #     @geocoder = L.mapbox.geocoder 'mapbox.places'
#     #     # @map = L.mapbox.map('map')
#     #     #     .setView([40, -74.50], 9)
#     #     #     .addLayer(L.mapbox.styleLayer('mapbox://styles/mapbox/streets-v11'));
        	
        	
#     #     )
                
#     Template.mapgl.helpers
#         # current_markers: -> current_markers.array()
#         # can_move: -> Session.get 'can_move'
#         # current_zoom_level: -> Session.get 'zoom_level'
#         post_docs: ->
#             Docs.find 
#                 model:'post'
#                 app:'goldrun'
       
#     Template.mapgl.events
#         'click .pick_post': (e,t)->
#             console.log @
#             # options = {
#             #     draggable:true
                
#             #     }
#             # L.marker([50.5, 30.5], options).addTo(t.map);
#             # t.map.setView [50.5, 30.5], 14
#             t.geocoder.query @location, (error, result) ->
#                 console.log 'found post location', result
#                 L.marker(result.latlng).addTo(t.map)
#                 t.map.setView result.latlng, 15
    
#         'click .click_markers': (e,t)->
#             myFeatureLayer = L.mapbox.featureLayer('/mapbox.js/assets/data/sf_locations.geojson').addTo(t.map);
    
#             myFeatureLayer.on('click', (e)=>
#                 t.map.panTo(e.layer.getLatLng());
#             )
    
#         # 'click .add_legend': (e,t)->
#         #     t.map.addControl(L.mapbox.legendControl());
#         'click .add_circle': (e,t)->
#             t.map.setView [50.5, 30.5], 15
#             circle = L.circle([Session.get('lat'), Session.get('long')], 200).addTo(t.map);
#             console.log circle.getLatLng()
#             console.log circle.getRadius()
#         'click .toggle_moving': (e,t)->
#             if Session.get 'can_move'
#                 t.map.dragging.disable() 
#                 t.map.touchZoom.disable() 
#                 t.map.doubleClickZoom.disable() 
#                 t.map.scrollWheelZoom.disable() 
#                 t.map.keyboard.disable() 
#                 Session.set 'can_move',false
#             else
#                 t.map.dragging.enable() 
#                 t.map.touchZoom.enable() 
#                 t.map.doubleClickZoom.enable() 
#                 t.map.scrollWheelZoom.enable() 
#                 t.map.keyboard.enable() 
#                 Session.set('can_move',true)
                
    
#         'change .zoom_level': (e,t)->
#             val = parseInt $('.zoom_level').val()
#             Session.set('zoom_level', val)
#             t.map.setZoom val
                
#         'click .add_marker': (e,t)-> 
#             console.log 'adding marker'
#             options = {
#                 draggable:true
                
#                 }
#             L.marker([50.5, 30.5], options).addTo(t.map);
#             t.map.setView [50.5, 30.5], 14
    
#         'click .zoomin': (e,t)-> 
#             t.map.zoomIn 1
#             Session.set('zoom_level', Session.get('zoom_level')+1)
#         'click .zoomout': (e,t)-> 
#             t.map.zoomOut 1
#             Session.set('zoom_level', Session.get('zoom_level')-1)
                
#         'keyup .add_place': (e,t)->
#             val = $('.add_place').val()
#             if e.which is 13
#                 current_markers.push val
#                 t.geocoder.query val, (error, result) ->
#                     console.log 'found result', result
#                     L.marker(result.latlng).addTo(t.map)
#                     t.map.setView result.latlng, 10
#                 val = $('.add_place').val('')
#         'click .draw': (e,t)->
#             t.map.setView [40, -74.50], 3
#             t.map.addLayer L.mapbox.styleLayer 'mapbox://styles/mapbox/streets-v11'
#             # myFeatureLayer.on('click', (e)=>
#             #     t.map.panTo(e.layer.getLatLng());
#             # )
    
#             add = (placename) ->
#                 t.geocoder.query placename, (error, result) ->
#                     L.marker(result.latlng).addTo(t.map)
    
#             add place for place in ['Washington, DC', 'San Francisco', 'Detroit, MI']
    
            
#         'click .find_me': (e,t)->
#             # console.log Template.currentData()
#             console.log t.map
#             t.map.locate()
#             t.map.on('locationfound', (e)->
#                 map.fitBounds(e.bounds);
            
#                 myLayer.setGeoJSON
#                     type: 'Feature',
#                     geometry:
#                         type: 'Point',
#                         coordinates: [e.latlng.lng, e.latlng.lat]
#                     properties:
#                         'title': 'Here I am!',
#                         'marker-color': '#ff8888',
#                         'marker-symbol': 'star'
#             )
#                 # // And hide the geolocation button
#                 # geolocate.parentNode.removeChild(geolocate);
            
#             # Template.instance().data.map.locate();
    
#     #     'click .goto_user': ->
#     #         $('.main_content')
#     #             .transition('fade out', 250)
#     #             .transition('fade in', 250)
            
#     #         Router.go "/user/#{@username}"
        
    
        
#     #     # 'click .refresh': ->
#     #     #     console.log Geolocation.currentLocation();
#     #     #     navigator.geolocation.getCurrentPosition (position) =>
#     #     #         console.log position
#     #     #     pos = Geolocation.currentLocation()
#     #     #     # pos.coords.latitude
#     #     #     console.log pos
#     #     #     if pos
#     #     #         Session.set('current_lat', pos.coords.latitude)
#     #     #         Session.set('current_long', pos.coords.longitude)
                
#     #     #         map = L.map('mapid').setView([Session.get('current_lat'), Session.get('current_long')], 17);
#     #     #         # L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
#     #     #         #     attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
#     #     #         #     maxZoom: 18,
#     #     #         #     id: 'mapbox/outdoors-v11',
#     #     #         #     tileSize: 512,
#     #     #         #     zoomOffset: -1,
#     #     #         #     accessToken: 'your.mapbox.access.token'
#     #     #         # }).addTo(mymap);
#     #     #         L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
#     #     #             attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
#     #     #             accessToken:"pk.eyJ1IjoicmVwamFja3NvbiIsImEiOiJja21iN3V5OWgwMGI4Mm5temU0ZHk3bjVsIn0.3nq7qTUAh0up18iIIuOPrQ"
#     #     #             maxZoom: 21,
#     #     #             minZoom: 18,
#     #     #             id: 'mapbox/outdoors-v11',
#     #     #             tileSize: 512,
#     #     #             zoomOffset: -1,
#     #     #         }).addTo(map);
#     #     #         console.log map
                
#     #     #         L.marker([51.5, -0.09]).addTo(map)
#     #     #             .bindPopup('person')
#     #     #             .openPopup();
#     #     #         # circle = L.circle([51.508, -0.11], {
#     #     #         #     color: 'red',
#     #     #         #     fillColor: '#f03',
#     #     #         #     fillOpacity: 0.5,
#     #     #         #     radius:100
#     #     #         # }).addTo(mymap);
        
#     #     #         # L.marker([53.5, -0.1]).addTo(map)
#     #     #         #     .bindPopup('person')
#     #     #         #     .openPopup();
    
    
    
    
        
#     #     #         pos.coords.latitude
#     #     #         Session.set('current_lat', pos.coords.latitude)
#     #     #         Session.set('current_long', pos.coords.longitude)
#     #     #         # Meteor.users.update Meteor.userId(),
#     #     #         #     $set:current_position:pos
#     #     #         @map = L.map('mapid',{
#     #     #             dragging:false, 
#     #     #             zoomControl:false
#     #     #             bounceAtZoomLimits:false
#     #     #             touchZoom:false
#     #     #             doubleClickZoom:false
#     #     #             }).setView([Session.get('current_lat'), Session.get('current_long')], 17);
        
#     #     #         # var map = L.map('map', {
#     #     #         # doubleClickZoom: false
#     #     #         # }).setView([49.25044, -123.137], 13);
                
#     #     #         # L.tileLayer.provider('Stamen.Watercolor').addTo(map);
                
#     #     #         # map.on('dblclick', (event)->
#     #     #         #     console.log 'clicked', event
#     #     #         #     Markers.insert({latlng: event.latlng});
#     #     #         # )
#     #     #         # // add clustermarkers
#     #     #         # markers = L.markerClusterGroup();
#     #     #         # map.addLayer(markers);
                
#     #     #         query = Markers.find();
#     #     #         query.observe
#     #     #             added: (doc)->
#     #     #                 console.log 'added marker', doc
#     #     #                 # marker = L.marker(doc.latlng).on('click', (event)->
#     #     #                 #     Markers.remove({_id: doc._id});
#     #     #                 # );
#     #     #                 # console.log {{c.url currentUser.profile_image_id height=500 width=500 gravity='face' crop='fill'}}
#     #     #                 myIcon = L.icon({
#     #     #                     iconUrl:"https://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_100/#{Meteor.user().profile_image_id}"
#     #     #                     iconSize: [38, 95],
#     #     #                     iconAnchor: [22, 94],
#     #     #                     popupAnchor: [-3, -76],
#     #     #                     # shadowUrl: 'my-icon-shadow.png',
#     #     #                     shadowSize: [68, 95],
#     #     #                     shadowAnchor: [22, 94]
#     #     #                 });
        
#     #     #                 L.marker([doc.latlng.lat, doc.latlng.long],{
#     #     #                     draggable:true
#     #     #                     icon:myIcon
#     #     #                     riseOnHover:true
#     #     #                     }).addTo(map)
#     #     #                 # markers.addLayer(marker);
                        
#     #     #             removed: (oldDocument)->
#     #     #                 layers = map._layers;
#     #     #                 for key in layers
#     #     #                     val = layers[key];
#     #     #                     if (val._latlng)
#     #     #                         if val._latlng.lat is oldDocument.latlng.lat and val._latlng.lng is oldDocument.latlng.lng
#     #     #                             markers.removeLayer(val)
                    
#     #     #         L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
#     #     #             # attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
#     #     #             accessToken:"pk.eyJ1IjoicmVwamFja3NvbiIsImEiOiJja21iN3V5OWgwMGI4Mm5temU0ZHk3bjVsIn0.3nq7qTUAh0up18iIIuOPrQ"
#     #     #             maxZoom: 19,
#     #     #             minZoom: 19,
#     #     #             id: 'mapbox/outdoors-v11',
#     #     #             tileSize: 512,
#     #     #             zoomOffset: -1,
#     #     #         }).addTo(map);
#     #     #         # L.marker([Session.get('current_lat'), Session.get('current_long')]).addTo(map)
#     #     #             # .openPopup();
#     #     #             # .bindPopup('you')
#     #     #         L.circle([Session.get('current_lat'), Session.get('current_long')], {
#     #     #             color: 'blue',
#     #     #             weight: 0
#     #     #             fillColor: '#3b5998',
#     #     #             fillOpacity: 0.16,
#     #     #             radius: 50
#     #     #         }).addTo(map);
#     #     #         onMapClick = (e)->
#     #     #             alert("You clicked the map at " + e.latlng);
                
#     #             # map.on('click', onMapClick);
    
    
#     # # @picked_tags = new ReactiveArray []
    
    
    
#     Template.localmap.helpers
#         pos:-> 
#             # console.log Geolocation.currentLocation()
#             Geolocation.currentLocation()
#         # lat: ()-> Geolocation.latLng().lat
#         # lon: ()-> Geolocation.latLng().lon
    
#     Template.mapgl.events
#         'click .locate': ->
#             navigator.geolocation.getCurrentPosition (position) =>
#                 console.log 'navigator position', position
#                 Session.set('current_lat', position.coords.latitude)
#                 Session.set('current_long', position.coords.longitude)
                
#                 console.log 'saving long', position.coords.longitude
#                 console.log 'saving lat', position.coords.latitude
            
#                 pos = Geolocation.currentLocation()
#                 # user_position_marker = 
#                 #     Markers.findOne
#                 #         _author_id: Meteor.userId()
#                 #         model:'user_marker'
#                 # unless user_position_marker
#                 #     Markers.insert 
#                 #         model:'user_marker'
#                 #         _author_id: Meteor.userId()
#                 #         latlng:
#                 #             lat:position.coords.latitude
#                 #             long:position.coords.longitude
#                 # if user_position_marker
#                 #     Markers.update user_position_marker._id,
#                 #         $set:
#                 #             latlng:
#                 #                 lat:position.coords.latitude
#         #                         long:position.coords.longitude
#         #         Meteor.users.update Meteor.userId(),
#         #             $set:
#         #                 location:
#         #                     "type": "Point"
#         #                     "coordinates": [
#         #                         position.coords.longitude
#         #                         position.coords.latitude
#         #                     ]
#         #                 current_lat: position.coords.latitude
#         #                 current_long: position.coords.longitude
#         #             # , (err,res)->
#         #             #     console.log res
    
            
            
#         #     $('.main_content')
#         #         .transition('fade out', 250)
#         #         .transition('fade in', 250)
    
#     Template.localmap.onCreated ->
#         # @autorun => @subscribe 'some_posts', ->
        
#     Template.localmap.onRendered ->
#         # console.log 'hi'
#         # console.log @
#         L.mapbox.accessToken = 'pk.eyJ1IjoiZ29sZHJ1biIsImEiOiJja3c2cTlwd3BmNmhqMnZwZzh3ZW5vdHRjIn0.bSaNtJ5tjrEQ_UitX5FbNQ';
#         @localmap = L.mapbox.map 'localmap'
    
#         # @geocoder = L.mapbox.geocoder 'mapbox.places'
#         # @map = L.mapbox.map('map')
#         #     .setView([40, -74.50], 9)
#         #     .addLayer(L.mapbox.styleLayer('mapbox://styles/mapbox/streets-v11'));
#         # @map.on('click', (e)->
#         #     # 	alert(e.latlng);
#         #     $('body').toast(
#         #         showIcon: 'marker'
#         #         message: "lat long: #{e.latlng}"
#         #         # showProgress: 'bottom'
#         #         class: 'success'
#         #         displayTime: 'auto',
#         #         position: "bottom right"
#         #     )
        	
        	
#         # )
                
#     Template.localmap.helpers
#         current_zoom_level: -> Session.get 'zoom_level'
#         post_docs: ->
#             Docs.find 
#                 model:'post'
#                 app:'goldrun'
       
#     Template.localmap.events
#         'click .refresh': (e,t)->
#             console.log Geolocation.currentLocation();
#             navigator.geolocation.getCurrentPosition (position) =>
#                 console.log position
#             pos = Geolocation.currentLocation()
#             # pos.coords.latitude
#             console.log pos
#             if pos
#                 Session.set('current_lat', pos.coords.latitude)
#                 Session.set('current_long', pos.coords.longitude)
#                 console.log Session.get('current_lat')
#                 console.log t.localmap
#                 t.localmap.setView([Session.get('current_lat'), Session.get('current_long')], 17);
#                 t.localmap.addLayer L.mapbox.styleLayer 'mapbox://styles/mapbox/streets-v11'
    
#                 # L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
#                 #     attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
#                 #     maxZoom: 18,
#                 #     id: 'mapbox/outdoors-v11',
#                 #     tileSize: 512,
#                 #     zoomOffset: -1,
#     #     #         #     accessToken: 'your.mapbox.access.token'
#     #     #         # }).addTo(mymap);
#     #     #         L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
#     #     #             attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
#     #     #             accessToken:"pk.eyJ1IjoicmVwamFja3NvbiIsImEiOiJja21iN3V5OWgwMGI4Mm5temU0ZHk3bjVsIn0.3nq7qTUAh0up18iIIuOPrQ"
#     #     #             maxZoom: 21,
#     #     #             minZoom: 18,
#     #     #             id: 'mapbox/outdoors-v11',
#     #     #             tileSize: 512,
#     #     #             zoomOffset: -1,
#     #     #         }).addTo(map);
#     #     #         console.log map
                
#     #     #         L.marker([51.5, -0.09]).addTo(map)
#     #     #             .bindPopup('person')
#     #     #             .openPopup();
#     #     #         # circle = L.circle([51.508, -0.11], {
#     #     #         #     color: 'red',
#     #     #         #     fillColor: '#f03',
#     #     #         #     fillOpacity: 0.5,
#     #     #         #     radius:100
#     #     #         # }).addTo(mymap);
        
#     #     #         # L.marker([53.5, -0.1]).addTo(map)
#     #     #         #     .bindPopup('person')
#     #     #         #     .openPopup();
    
    
    
    
        
#     #     #         pos.coords.latitude
#     #     #         Session.set('current_lat', pos.coords.latitude)
#     #     #         Session.set('current_long', pos.coords.longitude)
#     #     #         # Meteor.users.update Meteor.userId(),
#     #     #         #     $set:current_position:pos
#     #     #         @map = L.map('mapid',{
#     #     #             dragging:false, 
#     #     #             zoomControl:false
#     #     #             bounceAtZoomLimits:false
#     #     #             touchZoom:false
#     #     #             doubleClickZoom:false
#     #     #             }).setView([Session.get('current_lat'), Session.get('current_long')], 17);
        
#     #     #         # var map = L.map('map', {
#     #     #         # doubleClickZoom: false
#     #     #         # }).setView([49.25044, -123.137], 13);
                
#     #     #         # L.tileLayer.provider('Stamen.Watercolor').addTo(map);
                
#     #     #         # map.on('dblclick', (event)->
#     #     #         #     console.log 'clicked', event
#     #     #         #     Markers.insert({latlng: event.latlng});
#     #     #         # )
#     #     #         # // add clustermarkers
#     #     #         # markers = L.markerClusterGroup();
#     #     #         # map.addLayer(markers);
                
#     #     #         query = Markers.find();
#     #     #         query.observe
#     #     #             added: (doc)->
#     #     #                 console.log 'added marker', doc
#     #     #                 # marker = L.marker(doc.latlng).on('click', (event)->
#     #     #                 #     Markers.remove({_id: doc._id});
#     #     #                 # );
#     #     #                 # console.log {{c.url currentUser.profile_image_id height=500 width=500 gravity='face' crop='fill'}}
#     #     #                 myIcon = L.icon({
#     #     #                     iconUrl:"https://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_100/#{Meteor.user().profile_image_id}"
#     #     #                     iconSize: [38, 95],
#     #     #                     iconAnchor: [22, 94],
#     #     #                     popupAnchor: [-3, -76],
#     #     #                     # shadowUrl: 'my-icon-shadow.png',
#     #     #                     shadowSize: [68, 95],
#     #     #                     shadowAnchor: [22, 94]
#     #     #                 });
        
#     #     #                 L.marker([doc.latlng.lat, doc.latlng.long],{
#     #     #                     draggable:true
#     #     #                     icon:myIcon
#     #     #                     riseOnHover:true
#     #     #                     }).addTo(map)
#     #     #                 # markers.addLayer(marker);
                        
#     #     #             removed: (oldDocument)->
#     #     #                 layers = map._layers;
#     #     #                 for key in layers
#     #     #                     val = layers[key];
#     #     #                     if (val._latlng)
#     #     #                         if val._latlng.lat is oldDocument.latlng.lat and val._latlng.lng is oldDocument.latlng.lng
#     #     #                             markers.removeLayer(val)
                    
#     #     #         L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
#     #     #             # attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
#     #     #             accessToken:"pk.eyJ1IjoicmVwamFja3NvbiIsImEiOiJja21iN3V5OWgwMGI4Mm5temU0ZHk3bjVsIn0.3nq7qTUAh0up18iIIuOPrQ"
#     #     #             maxZoom: 19,
#     #     #             minZoom: 19,
#     #     #             id: 'mapbox/outdoors-v11',
#     #     #             tileSize: 512,
#     #     #             zoomOffset: -1,
#     #     #         }).addTo(map);
#     #     #         # L.marker([Session.get('current_lat'), Session.get('current_long')]).addTo(map)
#     #     #             # .openPopup();
#     #     #             # .bindPopup('you')
#     #     #         L.circle([Session.get('current_lat'), Session.get('current_long')], {
#     #     #             color: 'blue',
#     #     #             weight: 0
#     #     #             fillColor: '#3b5998',
#     #     #             fillOpacity: 0.16,
#     #     #             radius: 50
#     #     #         }).addTo(map);
#     #     #         onMapClick = (e)->
#     #     #             alert("You clicked the map at " + e.latlng);
                
#     #             # map.on('click', onMapClick);