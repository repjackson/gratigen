Template.comet.events
    'click .doit':->
    	CometChatWidget.init({
    		"appID": "230901f80cc862a3",
    		"appRegion": "us",
    		"authKey": "8dacc447cb65a5e171529c11a08ae5da97f8d2c1"
    	}).then((response)=>
    		console.log("Initialization completed successfully");
    		CometChatWidget.login({
    			"uid": Meteor.user().username
    		}).then((response)=>
    			CometChatWidget.launch({
    				"widgetID": "8fbe4a2f-ea19-43fc-83ea-ae4fa5fa7c6b",
    				"docked": "true",
    				"alignment": "left"
    				"roundedCorners": "true",
    				"height": "450px",
    				"width": "400px",
    				"defaultID": 'superhero1'
    				"defaultType": 'user'
    			});
    		)
		)