window.$docsify =
{
  name: '',
  repo: '',
  loadNavbar : false,
  loadSidebar : false,
  homepage : 'Reference.md',
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

        if( href[ 0 ] === '/' )
        href = href.slice( 1 );

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
  })
  .sidebar( 'toggle' )

  /*  */

})

//

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
    let found = obj.find( '.anchor-special' );

    found = found.slice();

    if( found.length )
    {
      target.empty();

      found.each( ( index ,value ) =>
      {
        let self = $(value);
        // let innerText = value.innerText;
        // let match = innerText.match( /(?=.*)[.~].*(?=[(:])/ );
        // if( !match )
        // match = innerText.match( /(?=.*)[.~].*$/ );
        // innerText = match || innerText;
        // var e = `<div class="item"><a href=${value.href}>${innerText}</a></div>`
        let kind = self.attr( 'kind' );
        let name = self.attr( 'name' );
        let id = self.attr( 'id' );
        let href = origin + self.attr( 'url' );
        var e = `<div class="item sidebar-index-item"><code>${kind}</code><a href=${href}> ${name}</a></div>`

        target.append( e )
      })
    }
    else
    {
      found = obj.find( '.anchor' );

      target.empty();

      found.each( ( index ,value ) =>
      {
        let self = $(value);
        let innerText = value.innerText;
        let href = self.attr( 'href' );
        var e = `<div class="item sidebar-index-item"><a href=${href}>${innerText}</a></div>`
        target.append( e )
      })
    }

    let currentActive;

    $('.sidebar-index-item').on( 'click', function ()
    {
      if( currentActive )
      $( currentActive ).removeClass( 'sidebar-index-item-active' );

      currentActive = $( this );
      $( this ).addClass( 'sidebar-index-item-active' )
    })

    next(html);
  });

}

//

function headerLink( hook )
{
  hook.doneEach( function()
  {
    $( '.anchor-special').each( onEach );
    $( '.anchor').each( onEach );
  })

  function onEach( index, value )
  {
      let elem =  $( `<i class="linkify button icon header-url-icon"></i>` );
      $(value).prepend( elem );

      $(value).mouseenter( hoverIn );
      $(value).mouseleave( hoverOut );

      function hoverIn()
      {
        let self = $(this);

        let url = self.attr( 'url' ) || self.attr( 'href' );

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

  }

}