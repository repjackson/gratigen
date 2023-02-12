if Meteor.isClient
    Router.route '/noel', (->
        @layout 'layout'
        @render 'noel'
        ), name:'noel'
    # https://github.com/repjackson/gratigen        
    # session var documentation
    # https://docs.meteor.com/api/session.html
    Template.noel.helpers 
        button_clicks: ->
            Session.get('button_clicks')
    Template.noel.events
        'click .increment': (event,template)->
            # if Session.get('button_clicks') or 0
            if Session.get('button_clicks')
                current = Session.get('button_clicks')
                
                Session.set('button_clicks', current+1)
            else 
                Session.set('button_clicks', 1)
                