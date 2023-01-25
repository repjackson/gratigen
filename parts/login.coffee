if Meteor.isClient
    Template.login.onCreated ->
        Session.setDefault 'username', null

    Template.app.events
        'click .hithere':-> console.log 'hi'
        'click .register':->
            Meteor.call 'change_state', {_template:'register'}, ->
        'keyup .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    console.log res
                    Session.set('enter_mode', 'login')

        'blur .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set('enter_mode', 'login')

        'click .login_button': (e,t)->
            # e.preventDefault()
            console.log 'hi'
            username = $('.username').val()
            password = $('.password').val()
            options = {
                username:username
                password:password
                }
            # console.log options
            Meteor.loginWithPassword username, password, (err,res)=>
                if err
                    console.log err
                    $('body').toast({
                        message: err.reason
                    })
                else
                    # console.log res
                    $(e.currentTarget).closest('.grid').transition('fly right', 500)                    
                    Meteor.setTimeout ->
                        Meteor.call 'change_state',{_template:'home'}, ->
                    , 500
                    # gstate_set "/user/#{username}"

        'keyup .password, keyup .username': (e,t)->
            if e.which is 13
                e.preventDefault()
                username = $('.username').val()
                password = $('.password').val()
                if username and username.length > 0 and password and password.length > 0
                    options = {
                        username:username
                        password:password
                        }
                    # console.log options
                    Meteor.loginWithPassword username, password, (err,res)=>
                        if err
                            console.log err
                            $('body').toast({
                                message: err.reason
                            })
                        else
                            # gstate_set "/user/#{username}"
                            Meteor.call 'change_state',{_template:'home'}, ->
                            # gstate_set "/"


    Template.login.helpers
        username: -> Session.get 'username'
        logging_in: -> Session.equals 'enter_mode', 'login'
        enter_class: ->
            if Meteor.loggingIn() then 'loading disabled' else ''
            # if Session.get('username') and Session.get('username').length
            # else
            #     'disabled'
        is_logging_in: -> Meteor.loggingIn()
        
        
        
if Meteor.isClient
    Template.register.onCreated ->
        Session.setDefault 'email', null
        Session.setDefault 'email_status', 'invalid'
        
    Template.register.events
        # 'keyup .first_name': ->
        #     first_name = $('.first_name').val()
        #     Session.set 'first_name', first_name
        # 'keyup .last_name': ->
        #     last_name = $('.last_name').val()
        #     Session.set 'last_name', last_name
        # 'keyup .email_field': ->
        #     email = $('.email_field').val()
        #     Session.set 'email', email
        #     Meteor.call 'validate_email', email, (err,res)->
        #         console.log res
        #         if res is true
        #             Session.set 'email_status', 'valid'
        #         else
        #             Session.set 'email_status', 'invalid'

        'keyup .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set 'enter_mode', 'login'
                else
                    Session.set 'enter_mode', 'register'

        'blur .username': ->
            username = $('.username').val()
            Session.set 'username', username
            Meteor.call 'find_username', username, (err,res)->
                if res
                    Session.set 'enter_mode', 'login'
                else
                    Session.set 'enter_mode', 'register'
        
        'blur .password': ->
            password = $('.password').val()
            Session.set 'password', password

        'click .register': (e,t)->
            username = $('.username').val()
            # email = $('.email_field').val()
            password = $('.password').val()
            # if Session.equals 'enter_mode', 'register'
            # if confirm "register #{username}?"
            # Meteor.call 'validate_email', email, (err,res)->
            #     console.log res
            # options = {
            #     username:username
            #     password:password
            # }
            options = {
                # email:email
                username:username
                password:password
                }
            console.log options
            Meteor.call 'create_user', options, (err,res)=>
                if err
                    alert err
                else
                    console.log res
                    # unless username
                    #     username = "#{Session.get('first_name').toLowerCase()}_#{Session.get('last_name').toLowerCase()}"
                    # console.log username
                    # Meteor.users.update res,
                    #     # $addToSet: 
                    #     #     roles: 'member'
                    #     #     levels: 'member'
                    #     $set:
                    #         # first_name: Session.get('first_name')
                    #         # last_name: Session.get('last_name')
                    #         # app:'nf'
                    #         username:username
                    Meteor.call 'change_state', {_template:'profile', _user_id:Meteor.userId()}, ->
                    # Meteor.loginWithPassword username, password, (err,res)=>
                    #     if err
                    #         alert err.reason
                    #         # if err.error is 403
                    #         #     Session.set 'message', "#{username} not found"
                    #         #     Session.set 'enter_mode', 'register'
                    #         #     Session.set 'username', "#{username}"
                    #     else
                    #         gstate_set '/'
                # else
                #     Meteor.loginWithPassword username, password, (err,res)=>
                #         if err
                #             if err.error is 403
                #                 Session.set 'message', "#{username} not found"
                #                 Session.set 'enter_mode', 'register'
                #                 Session.set 'username', "#{username}"
                #         else
                #             gstate_set '/'


    Template.register.helpers
        can_register: ->
            # Session.get('first_name') and Session.get('last_name') and Session.get('email_status', 'valid') and Session.get('password').length>3
            Session.get('username') and Session.get('password').length>2

            # Session.get('username')

        # email: -> Session.get 'email'
        username: -> Session.get 'username'
        # first_name: -> Session.get 'first_name'
        # last_name: -> Session.get 'last_name'
        registering: -> Session.equals 'enter_mode', 'register'
        enter_class: -> if Meteor.loggingIn() then 'loading disabled' else ''
        # email_valid: ->
        #     Session.equals 'email_status', 'valid'
        # email_invalid: ->
        #     Session.equals 'email_status', 'invalid'

if Meteor.isServer
    Meteor.methods
        set_user_password: (user, password)->
            result = Accounts.setPassword(user._id, password)
            console.log result
            result

        # verify_email: (email)->
        #     (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(email))


        create_user: (options)->
            console.log 'creating user', options
            Accounts.createUser options

        can_submit: ->
            username = Session.get 'username'
            email = Session.get 'email'
            password = Session.get 'password'
            password2 = Session.get 'password2'
            if username and email
                if password.length > 0 and password is password2
                    true
                else
                    false


        find_username: (username)->
            res = Accounts.findUserByUsername(username)
            if res
                # console.log res
                unless res.disabled
                    return res

        new_demo_user: ->
            current_user_count = Meteor.users.find().count()

            options = {
                username:"user#{current_user_count}"
                password:"user#{current_user_count}"
                }

            create = Accounts.createUser options
            new_user = Meteor.users.findOne create
            return new_user        