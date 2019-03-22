$( '.ui.search' )
.search
({
  type  : 'standard',
  minCharacters : 3,
  maxResults : 10,
  apiSettings:
  {
    url: '/search?q={query}'
  }
})