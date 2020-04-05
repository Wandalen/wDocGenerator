( function _MarkdownGenerator_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  require( '../IncludeBase.s' );

  var jsdoc2md = require( 'jsdoc-to-markdown' );
  var ddata = require( 'dmd/helpers/ddata.js' )
  var state = require( 'dmd/lib/state.js' );

  var arrayify = require('array-back');
  var where = require('test-value').where;
}

//

let _ = _global_.wTools;
let Parent = null;
let Self = function wMarkdownGenerator( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'MarkdownGenerator';

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
  _.assert( _.arrayIs( self.templateData ) )
  _.assert( _.strDefined( self.outPath ) )
  _.assert( _.strDefined( self.outReferencePath ) )
}

//

function render()
{
  let self = this;
  let ready = new _.Consequence().take( null )

  self.referenceGenerate();

  return ready;
}

function referenceGenerate()
{
  let self = this;
  let path = self.provider.path;

  renderIdentifiers({ kind : 'module' });
  renderIdentifiers({ kind : 'class' });
  renderIdentifiers({ kind : 'namespace' });

  /* index */

  let partial = path.s.join( __dirname, 'templates/index/**' )
  let helper = path.s.join( __dirname, 'helpers/**' );

  let index = jsdoc2md.renderSync
  ({
    data : self.templateData,
    partial: path.s.nativize( partial ),
    helper: path.s.nativize( helper ),
    template : '{{>index}}'
  })

  let filePath = path.join( self.outPath, 'Reference.md' );
  self.provider.fileWrite( filePath,index );

  /* search index */

  searchIndexMake();

  /*  */

  function identifiers( hash )
  {
    let query = {};

    for (var p in hash )
    {
      if ( /^-/.test( p ) )
      {
        query[ p.replace( /^-/, '!') ] = hash[ p ];
      }
      else if ( /^_/.test( p ) )
      {
        query[ p.replace( /^_/, '' ) ] = new RegExp( hash[ p ] );
      }
      else
      {
        query[ p ] = hash[ p ];
      }
    }

    let result = arrayify( self.templateData );

    result = result.filter( where( query ) );
    result = result.filter( ( e ) => !e.ignore && e.access !== 'private' );

    return result;
  }

  /*  */

  function parentObject( e )
  {
    return arrayify( self.templateData ).find( where( { id: e.memberof } ) );
  }

  /*  */

  function escapedAnchor( e )
  {
    let anchor = ddata.anchorName.call( e, state.options );
    anchor = anchor.replace( /[\.\+\/]/g, '_' );
    return anchor;
  }

  /*  */

  function isPrivate ( e ) { return e.access === 'private' }

  /*  */

  function nameNoPrefix( e )
  {
    let firstIsSmall = /[a-z]/.test( e.name[ 0 ] );
    let secondIsCapital = /[A-Z]/.test( e.name[ 1 ] );

    if( firstIsSmall && secondIsCapital )
    return e.name.slice( 1 );
    return e.name;
  }

  function nameForHd( e )
  {
    let name = nameNoPrefix( e );

    if( e.kind === 'namespace' )
    {
      name = name.replace( /[():\s]+/g, '_' );
      name = _.strRemoveBegin( name, '_' );
      name = _.strRemoveEnd( name, '_' );
    }

    return name;
  }

  /*  */

  function renderIdentifiers( hash )
  {
    _.assert( hash.kind );

    let result = identifiers( hash );

    let partial = path.s.join( __dirname, 'templates/main/**' )
    let helper = path.s.join( __dirname, 'helpers/**' );

    let o =
    {
      data : self.templateData,
      partial: path.s.nativize( partial ),
      helper: path.s.nativize( helper ),
      template : '{{>main}}'
    }

    result.forEach( ( e ) =>
    {
      state.currentId = e.id;

      let result = jsdoc2md.renderSync( o );
      let name = nameForHd( e );

      let fileName = name /* + '-' + e.meta.filename + '-' + e.order */ + '.md';
      let filePath = path.join( self.outReferencePath, hash.kind, fileName );
      self.provider.fileWrite( filePath, result );
    })


  }

  /*  */

  function searchIndexMake()
  {
    let searchIndex = Object.create( null );

    self.templateData.forEach( ( e ) =>
    {
      if( isPrivate( e ) )
      return;

      let anchor = escapedAnchor( e );
      let parent = parentObject( e );

      let id = e.name;

      if( parent )
      id = parent.name + '.' + e.name;

      let url;

      let entityName = nameForHd( e );

      if( parent )
      {
        let parentName = nameForHd( parent );
        url = `/#/reference/${parent.kind}/${parentName}#${e.kind}_${entityName}`;
      }
      else
      {
        url = `/#/reference/${e.kind}/${entityName}#${e.kind}_${entityName}`
      }

      searchIndex[ id ] = { title : id, url : url };
    })

    let searchIndexPath = path.join( self.outPath, 'searchIndex.json' );
    self.provider.fileWrite({ filePath : searchIndexPath, data : searchIndex, encoding : 'json.min' });
  }

}

// --
// relations
// --

let Composes =
{
  templateData : null,
  outPath : null,
  outReferencePath : null,
  verbosity : 1
}

let Associates =
{
  logger : _.define.own( new _.Logger({ output : console }) ),
  provider : null
}

let Restricts =
{
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

  render,
  referenceGenerate,

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