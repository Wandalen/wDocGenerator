( function _Helper_js() {

let _ = require( 'wTools' )
_.include( 'wLogger' );

let handlebars = require( 'handlebars' );

let Self = exports;

//

function log( src )
{ 
  logger.log( _.toStr( src, { levels : 99 } ) )
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
  let members = product.byParent[ context.name ] || [];
  members.forEach( ( entity ) => 
  {
    let templateData = entity.templateDataMake();
    result += options.fn( templateData );
  })
  return result;
}

//

function forNamespaceAndModule( context, options )
{
  let result = '';
  if( context.kind === 'namespace' || context.kind === 'class' )
  result += options.fn( context );
  return result;
}

//

function entityArgsList( entity )
{
  //returns arguments of current entity as string: "( arg1, arg2, ... )"
  
  let result = '';
  
  if( !entity.params )
  return result;
  
  let args = entity.params.map( e => e.name );
  
  //exclude params that can be properties of other argument, like "o.property"
  args = args.filter( arg => 
  { 
    return !_.strHas( arg, '.' ) 
  })
  
  args = args.join( ', ' );
  
  result = `( ${args} )`;
  
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
  
  let wrap = '**';
  
  return _.strReplaceAll( src, /\{\-(.*?)\-\}/g, ( src, ins ) =>
  {
    return `${wrap}${ins.groups[ 0 ]}${wrap}`
  })
}

//

function escape( src )
{
  return _.strReplaceAll( src, '|', '\\|' );
}


let Extension = 
{
  log,
  code,
  forEachMember,
  forNamespaceAndModule,
  entityArgsList,
  helperTemplateDataGet,
  highlight,
  escape
}

_.mapExtend( Self, Extension )

})();
