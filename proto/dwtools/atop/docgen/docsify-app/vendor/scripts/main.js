window.$docsify =
{
  name: '',
  repo: '',
  loadNavbar : false,
  loadSidebar : false,
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
      }
    }
  },
  plugins :
  [
    accordion,
    sidebarIndex
  ]
}

window.onscroll = () =>
{
    let scrollToTop = document.getElementById( 'scrollToTop' );
    if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20)
    scrollToTop.style.display = 'block';
    else
    scrollToTop.style.display = 'none';
}

function scrollToTop()
{
  document.body.scrollTop = 0;
  document.documentElement.scrollTop = 0;
}

function accordion( hook )
{
  hook.doneEach( () =>
  {
    $('.ui.accordion')
    .accordion();
  });
}

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
      var e = `<div class="item"><a href=${value.href}>${value.innerText}</a></div>`
      target.append( e )
    })

    next(html);
  });

}