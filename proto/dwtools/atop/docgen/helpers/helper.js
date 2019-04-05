( function _Helper_js() {

let state = require( 'dmd/lib/state.js' );
let handlebars = require( 'handlebars' );
let ddata = require( 'dmd/helpers/ddata.js' );
let _ = require( 'wFiles' )

//

function escapedAnchor( src )
{
  if ( typeof src !== 'string' ) return null;
  return src.replace( /[\.\+\/]/g, '_' );
}

//

// function saveToSearchIndex( anchor, parent )
// {
//   let id = this.name;

//   if( parent )
//   id = parent.name + '.' + this.name;

//   let url;

//   if( parent )
//   {
//     url = `/#/Reference/${parent.kind}/${parent.name}?id=${anchor}`;
//   }
//   else
//   {
//     url = `/#/Reference/${this.kind}/${this.name}?id=${anchor}`;
//   }

//   state.searchIndex[ id ] = { title : id, url : url };
// }

//

function emptyLine()
{
  return
  `
  `
}

//

function strCapitalize( src )
{
  return _.strCapitalize( src );
}

//

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

//

function summaryGet()
{
  let result = _.strIsolateInsideOrAll( this.summary, '<p>', '</p>' )[ 2 ];
  return result || this.summary;
}

//

function nameNoPrefix()
{
  let firstIsSmall = /[a-z]/.test( this.name[ 0 ] );
  let secondIsCapital = /[A-Z]/.test( this.name[ 1 ] );

  if( firstIsSmall && secondIsCapital )
  return this.name.slice( 1 );
  return this.name;
}

//

function currentEntity( options )
{
  options.hash.id = state.currentId;
  var result = ddata._identifier(options)
  return result ? options.fn(result) : 'ERROR, Cannot find entity.'
}

//

function entitySignature()
{
  let signature;

  var mSig = ddata.methodSig.call( this );

  if( ddata.isConstructor.call( this ) || ddata.isFunction.call( this ) )
  {
    signature = '( ' + mSig + ' )'
  }
  else if( ddata.isEvent.call( this ) )
  {
    if( mSig ) signature = '( ' + mSig + ' )'
  }

  return signature;
}

//

function debug( src )
{
  logger.log( _.toStr( src, { levels : 99 } ) )
}

exports.escapedAnchor = escapedAnchor;
// exports.saveToSearchIndex = saveToSearchIndex;
exports.emptyLine = emptyLine;

exports.namespaces = namespacesGet;
// exports.modules2 = modules2;
// exports.classes2 = classes2;
exports.summary = summaryGet;
exports.nameNoPrefix = nameNoPrefix;

exports.currentEntity = currentEntity;
exports.entitySignature = entitySignature;
exports.strCapitalize = strCapitalize;

exports.debug = debug;

})();
