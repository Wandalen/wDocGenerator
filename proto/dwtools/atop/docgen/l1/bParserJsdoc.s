( function _bParserJsdoc_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  require( '../IncludeBase.s' );
  require( './aParser.s' )

  var jsdoc2md = require( 'jsdoc-to-markdown' );
}

//

let _ = _global_.wTools;
let Parent = _.docgen.ParserAbstract;
let Self = function wParserJsdoc( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ParserJsdoc';

// --
// routines
// --

function init( o )
{
  let self = this;
  Parent.prototype.init.apply( self,arguments );
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

  Parent.prototype.form.call( self );

  let path = self.provider.path;

  self.configPath = path.nativize( path.join( __dirname,  self.configPath ) );
}

//

function parseAct( file )
{
  let self = this;
  let path = self.provider.path;

  let o =
  {
    files : [ path.nativize( file ) ],
    configure : self.configPath,
    'no-cache' : true,
  }

  return _.Consequence.From( jsdoc2md.getTemplateData( o ) )
}

// --
// relations
// --

let Composes =
{
}

let Associates =
{
}

let Restricts =
{
  configPath : 'conf/doc.json'
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

  form,

  parseAct,

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

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

_.docgen[ Self.shortName ] = Self;

})();