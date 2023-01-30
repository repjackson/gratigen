if Meteor.isClient
    Template.launch_comet.events
        'click .launch':->
            # $('body').toast({
            #     title: "initializing chat widget for #{name}"
            #     # message: 'Please see desk staff for key.'
            #     class : 'info'
            #     showIcon:'clock'
            #     showProgress:'bottom'
            #     position:'bottom right'
            # })
        	CometChatWidget.init({
        		"appID": "230901f80cc862a3",
        		"appRegion": "us",
        		"authKey": "8dacc447cb65a5e171529c11a08ae5da97f8d2c1"
        	}).then((response)=>
                # $('body').toast({
                #     title: "Initialization completed successfully"
                #     # message: 'Please see desk staff for key.'
                #     class : 'success'
                #     showIcon:'hashtag'
                #     # showProgress:'bottom'
                #     position:'bottom right'
                #     # className:
                #     #     toast: 'ui massive message'
                #     # displayTime: 5000
                # })
        	    
        		CometChatWidget.login({
        			"uid": @id
        		}).then((response)=>
        			CometChatWidget.launch({
        				"widgetID": "8fbe4a2f-ea19-43fc-83ea-ae4fa5fa7c6b",
        				"roundedCorners": "true",
        				"height": "450px",
        				"target": "#cometchat",
        				"width": "400px",
        				"defaultID": 'supergroup'
        				"defaultType": 'group'
        			});
        		))