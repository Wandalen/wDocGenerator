( function _Helper_js()
{

/* qqq : for Vova : bad : rename all files using camel */

const _ = require( 'wTools' )
_.include( 'wLogger' );

let handlebars = require( 'handlebars' );

//

function log( src )
{
  logger.log( _.entity.exportString( src, { levels : 99 } ) )
}

//

function code( src )
{
  return `<code>${src}</code>`
}

//

function forEachMember( context, options )
{
  //runs provided template for each member of current entity

  let result = '';
  let product = _.docgen.state.product;
  let parentByNameMap = product.byParent[ context.kind ];

  let members = parentByNameMap[ context.name ] || [];
  members.forEach( ( entity ) =>
  {
    let templateData = entity.templateDataMake();
    result += options.fn( templateData );
  })

  return result;
}

//

function ifModuleOrNamespace( context, options )
{
  if( context.kind === 'namespace' || context.kind === 'class' )
  return options.fn( context );
  return options.inverse( context );
}

//

function entityArgsList( entity )
{
  //returns arguments of current entity as string: "( arg1, arg2, ... )"

  let result = '';

  if( !entity.params )
  return result;

  //exclude params without name and params that can be properties of other argument, like "o.property"
  let args = entity.params.filter( ( e ) =>
  {
    return _.strDefined( e.name ) && !_.strHas( e.name, '.' );
  })

  if( !args.length )
  return result;

  result = args.map( ( e ) => e.name ).join( ', ' )
  result = `( ${result} )`;

  return result
}

//

function helperTemplateDataGet( context )
{
  // console.log(context )
  return context.templateDataMake();
}

//

function highlight( src )
{
  //highlight text wrapped by format {-text-}

  if( !src )
  return '';

  let prefix = '<strong>';
  let postfix = '</strong>';

  src = _.strReplaceAll( src, /\{\-(.*?)\-\}/g, ( src, ins ) =>
  {
    return `${prefix}${ins.groups[ 0 ]}${postfix}`
  })

  src = _.strLinesSplit( src );
  src = _.str.lines.strip( src );
  src = src.join( '<br>' )

  return src;
}

//

function escape( src )
{
  if( !src )
  return '';
  return _.strReplaceAll( src, '|', '\\|' );
}

//

function joinReturnsTypes( returns )
{
  _.assert( _.arrayIs( returns ) );
  return returns.map( ( e ) => e.type || '' ).join( '|' )
}

// --
//
// --

let Extension =
{
  log,
  code,
  forEachMember,
  ifModuleOrNamespace,
  entityArgsList,
  helperTemplateDataGet,
  highlight,
  escape,
  joinReturnsTypes
}

_.props.extend( module.exports, Extension )

})();
