if Meteor.isClient
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'
    
    
    Template.home.onCreated ->
        @autorun => @subscribe 'post_docs',
            picked_tags.array()
            Session.get('post_title_filter')

        @autorun => @subscribe 'post_facets',
            picked_tags.array()
            Session.get('post_title_filter')

    
