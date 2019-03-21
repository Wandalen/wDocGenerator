( function _Helper_js() {

let state = require( 'dmd/lib/state.js' );
let handlebars = require( 'handlebars' );
let ddata = require( 'dmd/helpers/ddata.js' );
let _ = require( 'wFiles' )


function escapedAnchor( src )
{
  if ( typeof src !== 'string' ) return null;
  return src.replace( /[\.\+\/]/g, '_' );
}

function saveToSearchIndex( src )
{
  let id = this.name;

  if( !this.meta )
  return;

  if( this.memberof )
  id = this.memberof + '.' + this.name;

  let url = `/#/${this.meta.docsifypath}#${escapedAnchor( src.id )}`;
  url.replace( 'module:', '' );
  state.searchIndex[ id ] = { title : id, url : url };
}

function thisToString( src )
{
  logger.log( _.toStr( src, { levels : 99 } ) )
}

function emptyLine()
{
  return
  `
  `
}

function namespacesGet( options )
{
  options.hash.kind = 'namespace'
  return handlebars.helpers.each( ddata._identifiers( options ), options );
}

// function modules2( options )
// {
//   options.hash.kind = 'module';

//   debugger

//   let modules =  ddata._identifiers( options );

//   modules.forEach( ( m ) =>
//   {
//     let result = handlebars.helpers.each( [ m ], options );
//     state.resultsPerModule[ m.name ] = result;
//   })

//   return '';
// }

// function classes2( options )
// {
//   options.hash.kind = 'class';

//   let modules =  ddata._identifiers( options );

//   modules.forEach( ( m ) =>
//   {
//     let result = handlebars.helpers.each( [ m ], options );
//     state.resultsPerClass[ m.name ] = result;
//   })

//   return '';
// }

function currentEntity( options )
{
  options.hash.id = state.currentId;
  var result = ddata._identifier(options)
  return result ? options.fn(result) : 'ERROR, Cannot find entity.'
}

exports.escapedAnchor = escapedAnchor;
exports.saveToSearchIndex = saveToSearchIndex;
exports.thisToString = thisToString;
exports.emptyLine = emptyLine;

exports.namespaces = namespacesGet;
// exports.modules2 = modules2;
// exports.classes2 = classes2;

exports.currentEntity = currentEntity;

})();
