let Self = exports;
let _ = require( '../../../../Tools.s' )
let path = require( 'path' );
let definitions = require( path.join( __dirname, '../../../../../../node_modules/jsdoc/lib/jsdoc/tag/dictionary/definitions.js') );
let dictionary = require( path.join( __dirname, '../../../../../../node_modules/jsdoc/lib/jsdoc/tag/dictionary.js') );
let jsdocTags = definitions.jsdocTags
let Doclet = require( path.join( __dirname, '../../../../../../node_modules/jsdoc/lib/jsdoc/doclet.js') ).Doclet;

let tagsToMakeCustom =
{
  namespace : 1,
  module : 1,
  class : 1
}
for( let tag in tagsToMakeCustom )
{
  delete dictionary._tags[ tag ];
  _.assert( dictionary._tags[ tag ] === undefined  );
}

let postProcessOriginal = Doclet.prototype.postProcess

Doclet.prototype.postProcess = function postProcess()
{
  let doclet = this;

  if( !doclet.name && doclet.tags )
  {
    doclet.name = '_';
    doclet.custom = true;
  }

  return postProcessOriginal.call( doclet );
}

Self.handlers =
{
  newDoclet: function( e )
  {
    if( e.doclet.custom )
    {
      delete e.doclet.custom;
      delete e.doclet.kind
    }
  }
}


