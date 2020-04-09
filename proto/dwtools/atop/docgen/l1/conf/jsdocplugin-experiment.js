let Self = exports;
let _ = require( '../../../../Tools.s' )
let path = require( 'path' );
let jsdoc = require( path.join( __dirname, '../../../../../../node_modules/jsdoc/lib/jsdoc/tag/dictionary/definitions.js') );
let doclet = require( path.join( __dirname, '../../../../../../node_modules/jsdoc/lib/jsdoc/doclet.js') );
let tag = require( path.join( __dirname, '../../../../../../node_modules/jsdoc/lib/jsdoc/tag.js') );
let Doclet = doclet.Doclet;

let originalAddTag = Doclet.prototype.addTag;
let originalPostProcess = Doclet.prototype.postProcess;

let tagsToOverride =
{
  namespace : 1,
  module : 1,
  class : 1
}
let tagsPriority = [ 'class', 'namespace', 'module' ]

Doclet.prototype.addTag = function addTag( title, text )
{
  let doclet = this;

  if( doclet._processed )
  return originalAddTag.call( doclet, title, text );

  if( tagsToOverride[ title ] )
  doclet[ `_${title}` ] = { title, text }
  else
  originalAddTag.call( doclet, title, text );
}

Doclet.prototype.postProcess = function postProcess()
{
  let doclet = this;

  if( !doclet._processed )
  {
    doclet._processed = true;

    if( doclet.kind )
    forKind();
    else
    forEntityNoKind();
  }

  return originalPostProcess.call( doclet );

  //

  function forKind()
  {
    for( let tag in tagsToOverride )
    {
      let _tag = `_${tag}`;
      let docletTag = doclet[ _tag ];
      if( docletTag )
      {
        if( !doclet._memberofs )
        doclet._memberofs = [];
        let docletTagText = _.strRemoveEnd( docletTag.text, '\n' );
        doclet._memberofs.push( `${tag}:${docletTagText}` )
      }
    }

    if( doclet._memberofs && _.longIs( doclet._memberofs ) )
    {
      doclet._memberofs = doclet._memberofs.join( ',' )
      originalAddTag.call( doclet, 'memberofs', doclet._memberofs );
    }
  }

  function forEntityNoKind()
  {
    for( let i in tagsPriority )
    {
      let _tag = `_${tagsPriority[ i ]}`;
      let docletTag = doclet[ _tag ];
      if( docletTag )
      {
        delete doclet[ _tag ];
        originalAddTag.call( doclet, docletTag.title, docletTag.text );
        return forKind();
      }
    }
  }
}

Self.handlers =
{
  newDoclet : function( e )
  {

    let doclet = e.doclet;
    delete doclet._processed;
    delete doclet._namespace;
    delete doclet._module;
    if( doclet._memberofs )
    {
      delete doclet._memberofs;
      delete doclet.memberof;
    }
  }
}