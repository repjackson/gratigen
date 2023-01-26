if Meteor.isClient
    Template.account.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Template.parentData().username

    Template.account.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000
    Template.nav.onRendered ->
        Meteor.setTimeout ->
            $('.item').popup()
        , 2000


    Template.user_single_doc_ref_editor.onCreated ->
        @autorun => Meteor.subscribe 'type', @data.model

    Template.user_single_doc_ref_editor.events
        'click .select_choice': ->
            context = Template.currentData()
            current_user = Meteor.users.findOne Template.parentData()._id
            Meteor.users.update current_user._id,
                $set: "#{context.key}": @slug

    Template.user_single_doc_ref_editor.helpers
        choices: ->
            Docs.find
                model:@model

        choice_class: ->
            context = Template.parentData()
            current_user = Meteor.users.findOne Template.parentData()._id
            if current_user["#{context.key}"] and @slug is current_user["#{context.key}"] then 'grey' else ''




    # Template.phone_editor.helpers
    #     'newNumber': ->
    #         Phoneformat.formatLocal 'US', Meteor.user().profile.phone

    Template.phone_editor.events
        'click .remove_phone': (event, template) ->
            Meteor.call 'UpdateMobileNo'
            return
        'click .resend_verification': (event, template) ->
            Meteor.call 'generateAuthCode', Meteor.userId(), Meteor.user().profile.phone
            bootbox.prompt 'We texted you a validation code. Enter the code below:', (result) ->
                code = result.toUpperCase()
                if Meteor.user().profile.phone_auth == code
                    Meteor.call 'updatePhoneVerified', (err, res) ->
                        if err
                            toastr.error err.reason
                        else
                            toastr.success 'Your phone was successfully verified!'
                        return
                else
                    toastr.success 'Your verification code does not match.'

        'click .update_phone': ->
            `var phone`
            phone = $('#phone').val()
            phone = Phoneformat.formatE164('US', phone)
            Meteor.call 'savePhone2', Meteor.userId(), phone, (error, result) ->
                if error
                    toastr.success 'There was an error processing your request.'
                else
                    if result.error
                        toastr.success result.message
                    else
                        bootbox.prompt result.message, (result) ->
                            code = result.toUpperCase()
                            if Meteor.user().profile.phone_auth == code
                                Meteor.call 'updatePhoneVerified'
                                toastr.success 'Your phone was successfully verified!'
                            else
                                toastr.success 'Your verification code does not match.'


    Template.account.events
        'click .remove_user': ->
            if confirm "confirm delete #{@username}?  cannot be undone."
                Meteor.users.remove @_id
                gstate_set "/users"

        # "change input[name='profile_image']": (e) ->
        #     files = e.currentTarget.files
        #     Cloudinary.upload files[0],
        #         # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
        #         # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
        #         (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
        #             # console.dir res
        #             if err
        #                 console.error 'Error uploading', err
        #             else
        #                 user = Meteor.users.findOne username:Template.parentData().username
        #                 Meteor.users.update user._id,
        #                     $set: "image_id": res.public_id
        #             return


    Template.username_edit.events
        'click .change_username': (e,t)->
            new_username = t.$('.new_username').val()
            current_user = Meteor.users.findOne username:Template.parentData().username
            if new_username
                if confirm "Change username from #{current_user.username} to #{new_username}?"
                    Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                        if err
                            alert err
                        else
                            gstate_set("/user/#{new_username}")




    Template.password_edit.events
        'click .change_password': (e, t) ->
            Accounts.changePassword $('#password').val(), $('#new_password').val(), (err, res) ->
                if err
                    alert err.reason
                else
                    alert 'password changed'
                    # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

        'click .set_password': (e, t) ->
            new_password = $('#new_password').val()
            current_user = Meteor.users.findOne username:Template.parentData().username
            Meteor.call 'set_password', current_user._id, new_password, ->
                alert "password set to #{new_password}."

        'click .send_password_reset_email': (e,t)->
            current_user = Meteor.users.findOne username:Template.parentData().username
            Meteor.call 'send_password_reset_email', current_user._id, @address, ->
                alert 'password reset email sent'


        'click .send_enrollment_email': (e,t)->
            current_user = Meteor.users.findOne username:Template.parentData().username
            Meteor.call 'send_enrollment_email', current_user._id, @address, ->
                alert 'enrollment email sent'


    Template.emails_edit.helpers
        current_user: ->
            Meteor.users.findOne username:Template.parentData().username

    Template.emails_edit.events
        'click #add_email': ->
            new_email = $('#new_email').val().trim()
            current_user = Meteor.users.findOne username:Template.parentData().username

            re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            valid_email = re.test(new_email)

            if valid_email
                Meteor.call 'add_email', current_user._id, new_email, (error, result) ->
                    if error
                        alert "Error adding email: #{error.reason}"
                    else
                        # alert result
                        $('#new_email').val('')
                    return

        'click .remove_email': ->
            if confirm 'Remove email?'
                current_user = Meteor.users.findOne username:Template.parentData().username
                Meteor.call 'remove_email', current_user._id, @address, (error,result)->
                    if error
                        alert "Error removing email: #{error.reason}"


        'click .send_verification_email': (e,t)->
            current_user = Meteor.users.findOne username:Template.parentData().username
            Meteor.call 'verify_email', current_user._id, @address, ->
                alert 'verification email sent'
                
                
if Meteor.isClient
    Template.account.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Template.parentData().username
        # @autorun -> Meteor.subscribe 'user_from_id', Template.parentData().user_id

    Template.account.onRendered ->
        # Meteor.setTimeout ->
        #     $('.button').popup()
        # , 2000


    # Template.phone_editor.helpers
    #     'newNumber': ->
    #         Phoneformat.formatLocal 'US', Meteor.user().profile.phone

    Template.account.events
        'click .remove_user': ->
            if confirm "confirm delete #{@username}?  cannot be undone."
                Meteor.users.remove @_id
                gstate_set "/users"

        "change input[name='profile_image']": (e) ->
            files = e.currentTarget.files
            Cloudinary.upload files[0],
                # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                # model:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                    # console.dir res
                    if err
                        console.error 'Error uploading', err
                    else
                        user = Meteor.users.findOne username:Template.parentData().username
                        Meteor.users.update user._id,
                            $set: "image_id": res.public_id
                    return


    Template.username_edit.events
        'click .change_username': (e,t)->
            new_username = t.$('.new_username').val()
            current_user = Meteor.users.findOne username:Template.parentData().username
            if new_username
                if confirm "change username from #{current_user.username} to #{new_username}?"
                    Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                        if err
                            alert err
                        else
                            gstate_set("/user/#{new_username}")




    Template.password_edit.events
        'click .change_password': (e, t) ->
            Accounts.changePassword $('#password').val(), $('#new_password').val(), (err, res) ->
                if err
                    alert err.reason
                else
                    alert 'password changed'
                    # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

        'click .set_password': (e, t) ->
            new_password = $('#new_password').val()
            current_user = Meteor.users.findOne username:Template.parentData().username
            Meteor.call 'set_password', current_user._id, new_password, ->
                alert "password set to #{new_password}."

        'click .send_password_reset_email': (e,t)->
            current_user = Meteor.users.findOne username:Template.parentData().username
            Meteor.call 'send_password_reset_email', current_user._id, @address, ->
                alert 'password reset email sent'


        'click .send_enrollment_email': (e,t)->
            current_user = Meteor.users.findOne username:Template.parentData().username
            Meteor.call 'send_enrollment_email', current_user._id, @address, ->
                alert 'enrollment email sent'


    Template.emails_edit.helpers

    Template.emails_edit.events
        'click #add_email': ->
            new_email = $('#new_email').val().trim()
            current_user = Meteor.users.findOne username:Template.parentData().username

            re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            valid_email = re.test(new_email)

            if valid_email
                Meteor.call 'add_email', current_user._id, new_email, (error, result) ->
                    if error
                        alert "error adding email: #{error.reason}"
                    else
                        # alert result
                        $('#new_email').val('')
                    return

        'click .remove_email': ->
            if confirm 'remove email?'
                current_user = Meteor.users.findOne username:Template.parentData().username
                Meteor.call 'remove_email', current_user._id, @address, (error,result)->
                    if error
                        alert "error removing email: #{error.reason}"


        'click .send_verification_email': (e,t)->
            current_user = Meteor.users.findOne username:Template.parentData().username
            Meteor.call 'verify_email', current_user._id, @address, ->
                alert 'verification email sent'
                
                
                
if Meteor.isClient
    Template.account_finance.onCreated ->
        # if Meteor.isDevelopment
        #     pub_key = Meteor.settings.public.stripe_test_publishable
        # else if Meteor.isProduction
        #     pub_key = Meteor.settings.public.stripe_live_publishable
        # Template.instance().checkout = StripeCheckout.configure(
        #     key: pub_key
        #     image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/one_logo.png'
        #     locale: 'auto'
        #     zipCode: true
        #     token: (token) ->
        #         amount = parseInt(Session.get('topup_amount'))
        #         # product = Docs.findOne Meteor.user()._model
        #         charge =
        #             amount: amount*100
        #             currency: 'usd'
        #             source: token.id
        #             description: token.description
        #             # receipt_email: token.email
        #         Meteor.call 'credit_topup', charge, (err,res)=>
        #             if err then alert err.reason, 'danger'
        #             else
        #                 Swal.fire(
        #                     'topup processed',
        #                     ''
        #                     'success'
        #                 Docs.insert
        #                     model:'transaction'
        #                     transaction_type:'topup'
        #                     amount:amount
        #                 Meteor.users.update Meteor.userId(),
        #                     $inc: credit:amount
        #                 )
        # )

    Template.account_finance.onRendered ->

    Template.account_finance.events
        'click .add_five_credits': ->
            console.log Template.instance()
            if confirm 'add 5 credits?'
                Session.set('topup_amount',5)
                Template.instance().checkout.open
                    name: 'credit deposit'
                    # email:Meteor.user().emails[0].address
                    description: 'wc top up'
                    amount: 500





            # Swal.fire({
            #     title: 'add 5 credits?'
            #     text: "this will charge you $5"
            #     icon: 'question'
            #     showCancelButton: true,
            #     confirmButtonText: 'confirm'
            #     cancelButtonText: 'cancel'
            # }).then((result)=>
            #     if result.value
            #         Session.set('topup_amount',5)
            #         Template.instance().checkout.open
            #             name: 'credit deposit'
            #             # email:Meteor.user().emails[0].address
            #             description: 'wc top up'
            #             amount: 5
            #
            #         # Meteor.users.update @_author_id,
            #         #     $inc:credit:@order_price
            #         Swal.fire(
            #             'topup initiated',
            #             ''
            #             'success'
            #         )
            # )