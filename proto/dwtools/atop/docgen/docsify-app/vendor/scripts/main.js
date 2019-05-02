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
        let r = /^(\/#|#\/|\/)/;
        if( !r.test( href ) )
        {
          let currentPath = uri( docsifyApp.router.getCurrentPath() ).path();
          let currentDir = currentPath.substr( 1,currentPath.lastIndexOf( '/' ) );
          href = '/#/' + currentDir + '/' + href;
          href = href.replace( /\/{2}/, '/' );
          href = href.replace( /\/\.\//, '/' );
          return `<a href="${href}" title="${title}">${text}</a>`
        }
        return this.origin.link.apply( this.origin, arguments );
      }
    }
  },
  plugins :
  [
    accordion,
    sidebarIndex,
    headerLink,
    handleATags
  ]
}

//

let currentActive;
let currentActiveId;

$( document ).ready( () =>
{
  /* menu */

  $('.custom-nav-item').on('click', (e) =>
  {
    $('.custom-nav-item').removeClass( 'active' );
    $( e.currentTarget ).addClass( 'active' );
  })

  /* sidebar */

  let visible = true;

  $('.custom-sidebar-toggle').on( 'click', function()
  {
    if( visible )
    {
      $( this ).css( 'left', '10px' );
      $( this ).css( 'margin-left', '0px' );
      $('.custom-sidebar').css( 'display', 'none' );
      visible = false;
    }
    else
    {
      $('.custom-sidebar').css( 'display', 'block' );
      let left = $('.custom-sidebar').css( 'width' );
      $( this ).css( 'left', left );
      visible = true;
    }
  })

  /* scrollToTop */

  $( window ).on( 'scroll', () =>
  {
    let scrollToTop = $('.scrollToTop' );
    if ( document.body.scrollTop > 20 || document.documentElement.scrollTop > 20 )
    scrollToTop.css( 'display', 'block' );
    else
    scrollToTop.css( 'display', 'none' );
  })

  $( '.scrollToTop' ).on( 'click', () =>
  {
    document.body.scrollTop = 0;
    document.documentElement.scrollTop = 0;
  })

  /*  */


  $( window ).scroll( function()
  {
    let headers = {};
    $('h1, h2, h3, h4, h5, h6').each( function()
    {
      let id = this.id;
      if( !id )
      id = $(this).find( 'a[id]' ).attr( 'id' );
      headers[ id ] = this.getBoundingClientRect().top;
    });

    for( var id in headers )
    {
      if( headers[ id ] > 0 && headers[ id ] < 200 )
      {
        if( currentActiveId != id )
        {
          if( currentActive )
          $(currentActive).removeClass( 'sidebar-index-item-active' )

          currentActiveId = id;
          currentActive = $(`.item.sidebar-index-item a[data-key=${id}]`);

          if( currentActive )
          $(currentActive).addClass( 'sidebar-index-item-active' )
        }
        break;
      }
    }

  })

})

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
  hook.doneEach(function() {

    let target = $( '.ui.index.list' );

    let obj = $( '.markdown-section' );
    
    target.empty();
    
    obj.find('h1, h2, h3, h4, h5, h6 a').each( function( index, value )
    { 
      let self = $(value);
      
      let anchor = self.find('a');
      
      if( !anchor.length )
      return;
      
      anchor = $(anchor);
      
      if( anchor.hasClass( 'anchor-special' ) )
      {
        let kind = anchor.attr( 'kind' );
        let name = anchor.attr( 'name' );
        let id = anchor.attr( 'id' );
        let href = origin + anchor.attr( 'url' );
        
        let colorAttribute = self.attr( 'data-color' );
        let astyle = colorAttribute ? `color:${colorAttribute}` : ''
        let a = `<a data-key=${id} href=${href} style=${astyle}> ${name}</a>`
        var e = `<div class="item sidebar-index-item"><code>${kind}</code>${a}</div>`

        target.append( e )
      }
      else
      {
        let innerText = anchor[0].innerText || anchor.attr( 'data-id' );
        innerText = innerText.replace( /^(-)/, '' );
        let href = decodeURI( anchor.attr( 'href' ) );
        let colorAttribute = self.attr( 'data-color' );
        let astyle = colorAttribute ? `color:${colorAttribute}` : ''
        let a = `<a href=${href} style=${astyle}>${innerText}</a>`
        var e = `<div class="item sidebar-index-item">${a}</div>`
        target.append( e )
      }
    });

    $('.sidebar-index-item').on( 'click', function ()
    {
      if( currentActive )
      $( currentActive ).removeClass( 'sidebar-index-item-active' );

      currentActive = $( this ).find( 'a' );
      currentActiveId = $( currentActive ).data( 'key' );

      $( currentActive ).addClass( 'sidebar-index-item-active' );

    })

  });

}

//

function headerLink( hook )
{
  hook.doneEach( function()
  {
    $( '.anchor-special').each( onEachSpecial );
    $( '.anchor').each( onEachAnchor );
  })

  function onEachSpecial( index, value )
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

  }

  function onEachAnchor( index, value )
  {
      let elem =  $( `<i class="linkify button icon header-url-icon"></i>` );
      $(value).prepend( elem );

      $(value).mouseenter( hoverIn );
      $(value).mouseleave( hoverOut );

      function hoverIn()
      {
        let self = $(this);

        let base = uri(docsifyApp.router.getCurrentPath() );
        let id = self.attr( 'data-id' );
        let url = '/#' + base.path() + '#' + id;

        self.find( '.linkify' ).css( 'visibility', 'visible' );
        self.removeAttr( 'href' );

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

//

function handleATags( hook )
{
  hook.doneEach( function()
  {
    $( '.markdown-section a[href]').each( ( index, value ) =>
    {
      let href =  $(value).attr( 'href' );

      let r = /^(\/#|#\/|\/)/;
      if( !r.test( href ) )
      {
        let currentPath = uri( docsifyApp.router.getCurrentPath() ).path();
        let currentDir = currentPath.substr( 1,currentPath.lastIndexOf( '/' ) );
        href = '/#/' + currentDir + '/' + href;
        href = href.replace( /\/{2}/, '/' );
        href = href.replace( /\/\.\//, '/' );
        $(value).attr( 'href', href );
      }
    });
  })
}