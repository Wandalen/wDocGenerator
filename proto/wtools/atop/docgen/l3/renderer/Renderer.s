( function _Renderer_s_()
{

'use strict';

var handlebars;

if( typeof module !== 'undefined' )
{
  handlebars = require( 'handlebars' )
}

//

const _ = _global_.wTools;
const Parent = null;
const Self = wRenderer;
function wRenderer( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Renderer';

// --
// implementation
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

  _.assert( self.helpers.length > 0 );
  _.assert( self.partials.length > 0 );

  /* register helpers */

  self.helpers.forEach( ( helper ) => handlebars.registerHelper( require( path.nativize( helper.absolute ) ) ) )

  /* register partials */

  self.partials.forEach( ( partial ) => handlebars.registerPartial( partial.name, provider.fileRead( partial.absolute ) ) )


}

//

function render( o )
{
  let self = this;

  _.routine.options_( render, o );

  _.assert( _.strDefined( o.template ) );
  _.assert( _.object.isBasic( o.data ) );

  let compiled = handlebars.compile( o.template, { preventIndent : true, strict : true } )

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
  const fileProvider = self.provider;

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

let Extension =
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
  extend : Extension,
});

_.Copyable.mixin( Self );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

_.docgen[ Self.shortName ] = Self;

})();
