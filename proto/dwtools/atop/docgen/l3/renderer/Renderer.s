( function _Renderer_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  var handlebars = require( 'handlebars' )
}

//

let _ = _global_.wTools;
let Parent = null;
let Self = function wRenderer( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Renderer';

// --
// routines
// --

function init( o )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( !self.logger )
  self.logger = new _.Logger({ output : console });

  if( !self.provider )
  self.provider = _.FileProvider.HardDrive();

  _.workpiece.initFields( self );
  Object.preventExtensions( self );

  if( o )
  self.copy( o );
}

//

function finit()
{
  return _.Copyable.prototype.finit.apply( this, arguments );
}

//

function form()
{
  let self = this;
  _.assert( arguments.length === 0 );
  
  let provider = self.provider;
  let path = provider.path;
  
  /* find partials and helpers */
  
  let find = provider.filesFinder
  ({ 
    filter : { recursive : 2 },
    withTerminals : 1,
    withDirs : 0,
    withStem : 0,
  })
  
  find({ filePath : path.join( __dirname, 'helpers' ), result : self.helpers })
  find({ filePath : path.join( __dirname, 'templates' ), result : self.partials })
  
  _.assert( self.helpers.length );
  _.assert( self.partials.length );
  
  /* register helpers */
  
  self.helpers.forEach( ( helper ) => handlebars.registerHelper( require( path.nativize( helper.absolute ) ) ) ) 
  
  /* register partials */
  
  self.partials.forEach( ( partial ) => handlebars.registerPartial( partial.name, provider.fileRead( partial.absolute ) ) ) 
  
  
  
}

//

function render( o )
{
  let self = this;
  
  _.routineOptions( render, o );
  
  _.assert( _.strDefined( o.template ) );
  _.assert( _.objectIs( o.data ) );
  
  let compiled = handlebars.compile( o.template, { preventIndent: true, strict: true } )
  
  return compiled( o.data );
}

render.defaults = 
{
  template : null,
  data : null
}

//

/* function filesFind()
{
  let self = this;
  let fileProvider = self.provider;

  self.inPath = fileProvider.recordFilter
  ({
    filePath : self.inPath,
    ends : self.exts
  });
  self.inPath.form();
  // if( o.basePath === null )
  // o.basePath = o.inPath.basePathSimplest()
  // if( o.basePath === null )
  // o.basePath = path.current();
  // if( o.inPath.prefixPath && path.isRelative( o.inPath.prefixPath ) )
  // o.basePath = path.resolve( o.basePath );
  // o.inPath.basePathUse( o.basePath );
  self.files = fileProvider.filesFind
  ({
    filter : self.inPath,
    mode : 'distinct',
    outputFormat : 'absolute',
    withDirs : false
  });
} */

// --
// relations
// --

let Composes =
{
  verbosity : 1
}

let Associates =
{
  logger : _.define.own( new _.Logger({ output : console }) ),
  provider : null
}

let Restricts =
{
  partials : _.define.own( [] ),
  helpers : _.define.own( [] ),
}

let Medials =
{
}

let Statics =
{
}

let Events =
{
}

let Forbids =
{
}

// --
// declare
// --

let Extend =
{

  init,
  finit,

  _form : null,
  form,

  render,

  // relations

  Composes,
  Associates,
  Restricts,
  Medials,
  Statics,
  Events,
  Forbids,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
});

_.Copyable.mixin( Self );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

_.docgen[ Self.shortName ] = Self;

})();
