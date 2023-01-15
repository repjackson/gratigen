Template.nav.onRendered ->
    Meteor.setTimeout ->
        sidebar = document.querySelector('#sidebar');
        sidebarToggler = document.querySelector('.sidebar_toggler');
        
        
        # // Toggling the Sidebar
        sidebarToggler.addEventListener('click', ()=>
            sidebar.classList.toggle('show');
        );
        
        
        # // Closing the Sidebar on clicking Outside and on the Sidebar-Links
        window.addEventListener('click', (e) =>
            if (e.target.id isnt 'sidebar' and e.target.className isnt 'sidebar_toggler')
                sidebar.classList.remove('show');
        );
    , 2000