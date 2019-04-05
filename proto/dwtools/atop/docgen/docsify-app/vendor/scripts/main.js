window.$docsify =
{
  name: '',
  repo: '',
  loadNavbar : false,
  loadSidebar : false,
  homepage : 'ReferenceIndex.md',
  markdown:
  {
    renderer:
    {
      link: function( href, title, text )
      {
        if( /\.md$/.test( href ) )
        {
          let currentPath = document.location.href.replace( document.location.origin + '/#','' );
          let currentDir = currentPath.substr( 1,currentPath.lastIndexOf( '/' ) );
          href = currentDir + '/' + href;
        }
        // return this.origin.link( href,title,text );
        return `<a href="/#/${href}" title="${title}">${text}</a>`
      },
      // heading : function()
      // {
      //   let result = this.origin.heading.apply( this.origin, arguments );
      //   debugger
      //   return result;
      // }
    }
  },
  plugins :
  [
    accordion,
    sidebarIndex,
    headerLink
  ]
}

//

window.onscroll = () =>
{
    let scrollToTop = document.getElementById( 'scrollToTop' );
    if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20)
    scrollToTop.style.display = 'block';
    else
    scrollToTop.style.display = 'none';
}

//

$( document ).ready( () =>
{
  /* menu */

  $('.custom-nav-item').on('click', (e) =>
  {
    $('.custom-nav-item').removeClass( 'active' );
    $( e.currentTarget ).addClass( 'active' );
  })

  /* sidebar */

  $('.custom-sidebar')
  .sidebar
  ({
    dimPage : false,
    closable : false,
    // onHide : sidebarOnHide,
    // onVisible :sidebarOnVisible,
    // transition: 'overlay'
  })
  .sidebar( 'toggle' )

  // $('.custom-sidebar-toggle').on( 'click', () =>  $('.custom-sidebar').sidebar( 'toggle' ) );

  // function sidebarOnHide()
  // {
  //   $('.custom-sidebar-toggle i').removeClass( 'left' ).addClass( 'right' );
  //   // $('.markdown-section').css( 'margin', '0px auto' )
  // }

  // function sidebarOnVisible()
  // {
  //   $('.custom-sidebar-toggle i').removeClass( 'right' ).addClass( 'left' );
  //   // $('.markdown-section').css( 'margin', '0px 300px' )
  // }

  /*  */
})

/**/

function scrollToTop()
{
  document.body.scrollTop = 0;
  document.documentElement.scrollTop = 0;
}

//

function accordion( hook )
{
  hook.doneEach( () =>
  {
    $('.ui.accordion')
    .accordion();
  });
}

//

function sidebarIndex( hook )
{
  hook.afterEach(function(html, next) {

    let target = $( '.ui.index.list' );

    let obj = $( html );
    let found = obj.find( 'a[href].anchor' );

    found = found.slice();

    target.empty();

    found.each( ( index ,value ) =>
    {
      let innerText = value.innerText;
      let match = innerText.match( /(?=.*)[.~].*(?=[(:])/ );
      if( !match )
      match = innerText.match( /(?=.*)[.~].*$/ );
      innerText = match || innerText;
      var e = `<div class="item"><a href=${value.href}>${innerText}</a></div>`
      target.append( e )
    })

    next(html);
  });

}

//

function headerLink( hook )
{
  hook.doneEach( function()
  {
    $( '.anchor-special').each( ( index, value ) =>
    {
      let elem =  $( `<i class="linkify button icon header-url-icon"></i>` );
      $(value).prepend( elem );

      $(value).mouseenter( hoverIn );
      $(value).mouseleave( hoverOut );

      function hoverIn()
      {
        let self = $(this);

        let url = self.attr( 'url' );

        self.find( '.linkify' ).css( 'visibility', 'visible' );

        new ClipboardJS( '.linkify',
        {
          text: function()
          {
            window.history.pushState({ url : url }, document.title, url );
            return origin + url;
          }
        });

      }

      function hoverOut()
      {
        let self = $(this);
        self.find( '.linkify' ).css( 'visibility', 'hidden' );
      }

    })
  })
}