$( '.ui.search' )
.search
({
  type  : 'standard',
  minCharacters : 3,
  maxResults : 10,
  cache : true,
  onResultsOpen : onResultsOpen,
  apiSettings:
  {
    url: '/search?q={query}'
  }
})

function onResultsOpen()
{
  $( '.results' ).css( 'left','10px' )
}