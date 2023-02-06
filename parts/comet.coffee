if Meteor.isClient
    Template.nav.events
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
                if Meteor.user().username
                    switch Meteor.user().username
                        when 'dev' then uid = 'dev'
                        when 'dev2' then uid = 'dev2'
                        when 'tryliam' then uid ='tryliam'
                        else uid = 'guest'
                else 
                    uid = 'guest'
                console.log 'logging in with uid', uid
                CometChatWidget.login({
                    "uid": uid
                }).then((response)=>
                	CometChatWidget.launch({
                        "widgetID": "8fbe4a2f-ea19-43fc-83ea-ae4fa5fa7c6b",
                        "roundedCorners": "false",
                        "height": "600px",
                        # "target": "#cometchat",
                        "width": "400px",
                        "docked": "true",
                        # "width": "100%",
                        "defaultID": 'supergroup'
                        "defaultType": 'group'
                	});
                ))
        		
        		
#         const fetch = require('node-fetch');

# const url = 'https://apimgmt.cometchat.io/apps/appId/extensions/widget/v2/settings';
# const options = {
#   method: 'POST',
#   headers: {accept: 'application/json', 'content-type': 'application/json'},
#   body: JSON.stringify({
#     settings: {
#       name: 'Test Chat Widget',
#       version: 'v2',
#       style: {
#         custom_js: 'v2',
#         docked_layout_icon_background: '#03a9f4',
#         docked_layout_icon_close: 'https://widget-js.cometchat.io/v2/resources/chat_close.svg',
#         docked_layout_icon_open: 'https://widget-js.cometchat.io/v2/resources/chat_bubble.svg',
#         primary_color: '#03A9F4',
#         foreground_color: ' #000000',
#         background_color: '#FFFFFF',
#         override_system_background_colors: 'true'
#       },
#       sidebar: {
#         chats: true,
#         users: true,
#         groups: true,
#         recent_chat_listing: 'all_chats',
#         user_listing: 'all_users',
#         sidebar_navigation_sequence: ['chats', 'users', 'groups', 'calls', 'settings'],
#         start_a_new_conversation: 'all_chats',
#         group_listing: 'public_and_password_protected_groups'
#       },
#       main: {
#         allow_add_members: true,
#         allow_delete_groups: true,
#         allow_kick_ban_members: true,
#         block_user: true,
#         create_groups: true,
#         enable_deleting_messages: true,
#         enable_editing_messages: true,
#         enable_sending_messages: true,
#         enable_sound_for_calls: true,
#         enable_sound_for_messages: true,
#         enable_threaded_replies: true,
#         enable_video_calling: true,
#         enable_voice_calling: true,
#         hide_deleted_messages: true,
#         hide_join_leave_notifications: true,
#         join_or_leave_groups: true,
#         send_emojis: true,
#         send_files: true,
#         send_photos_videos: true,
#         share_live_reactions: true,
#         show_call_notifications: true,
#         show_delivery_read_indicators: true,
#         show_emojis_in_larger_size: true,
#         show_stickers: true,
#         show_user_presence: true,
#         view_group_members: true,
#         allow_mention_members: false,
#         enable_replying_to_messages: false,
#         enable_share_copy_forward_messages: false,
#         highlight_messages_from_moderators: false,
#         show_call_recording_option: false,
#         send_voice_notes: false,
#         send_gifs: false,
#         share_location: false,
#         view_shared_media: true,
#         set_groups_in_qna_mode_by_moderators: false,
#         send_reply_in_private_to_group_member: false
#       }
#     }
#   })
# };

# fetch(url, options)
#   .then(res => res.json())
#   .then(json => console.log(json))
#   .catch(err => console.error('error:' + err));