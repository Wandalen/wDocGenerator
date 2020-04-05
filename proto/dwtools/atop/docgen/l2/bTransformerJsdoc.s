( function _bTransformerJsdoc_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  require( '../IncludeBase.s' );
  require( './aTransformer.s' );
}

//

let _ = _global_.wTools;
let Parent = _.docgen.TransformerAbstract;
let Self = function wTransformerJsdoc( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'TransformerJsdoc';

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
}

//

function transform()
{
  let self = this;
  let ready = new _.Consequence();

  self.transformStage0();
  self.transformStage1();
  self.transformStage1();

  ready.take( self.templateData );

  return ready;
}

//

function transformStage0()
{
  let self = this;

  for( let file in self.parsedFiles )
  {
    let currentFileData = self.parsedFiles[ file ];
    self._currentFileDataTransform( currentFileData );
    _.arrayAppendArray( self.templateData, currentFileData );
  }
}

//

function _currentFileDataTransform( currentFileData )
{
  /* transfrom entities with custom tags */

  for( let i = currentFileData.length - 1; i >= 0; i-- )
  {
    let entity = currentFileData[ i ];

    if( !entity.customTags )
    continue;

    let customTags = customTagsToMap( entity.customTags );

    if( customTags.namespaces !== undefined )
    {
      /* transform entity with namespaces tag into two separate entities with jsdoc tag namespace */
      let newEntities = entitiesPopulate( customTags, 'namespaces', ( namespace ) =>
      {
        let newNamespace = _.mapExtend( null, entity );
        newNamespace.longname = _.strReplace( newNamespace.longname, newNamespace.name, namespace );
        newNamespace.id = _.strReplace( newNamespace.id, newNamespace.name, namespace );
        newNamespace.name = namespace;
        newNamespace.kind = 'namespace';
        return newNamespace;
      });
      newEntities.unshift( i, 1 )
      currentFileData.splice.apply( currentFileData, newEntities );
    }
    else if( customTags.memberofs !== undefined )
    {
      /* transform entity with memberofs tag into two separate entities with jsdoc tag memberof */
      let newEntities = entitiesPopulate( customTags, 'memberofs', ( memberof ) =>
      {
        let newEntity = _.mapExtend( null, entity );
        newEntity.memberof = memberof;
        return newEntity;
      });
      newEntities.unshift( i, 1 )
      currentFileData.splice.apply( currentFileData, newEntities );
    }

  }

  /* update entities order prop */

  for( let i = currentFileData.length - 1; i >= 0; i-- )
  currentFileData[ i ].order = i;

  /* */

  function customTagsToMap( customTags )
  {
    let result = Object.create( null );
    customTags.forEach( ( t, i ) =>
    {
      result[ t.tag ] = { index : i, value : t.value }
    })
    return result;
  }

  //

  function entitiesPopulate( customTags, customTagName, onEntity )
  {
    let currentTag = customTags[ customTagName ];
    let parsedEntities = _.strSplitNonPreserving({ src : currentTag.value, delimeter : ',' });

    _.assert( parsedEntities.length >= 1 );

    let result = parsedEntities.map( ( entityName, i ) =>
    {
      if( _.strBeginOf( entityName, '"' ) && _.strEndOf( entityName, '"' ) )
      entityName = _.strInsideOf( entityName, '"', '"' );

      let newEntity = onEntity( entityName );

      newEntity.order += i;
      newEntity.customTags.splice( currentTag.index, 1 );

      return newEntity;
    })

    return result;
  }

}

//

function transformStage1()
{
  let self = this;

  self.templateData.forEach( ( e ) =>
  {
    if( e.kind != 'namespace' )
    return;

    self.namespacesByName[ e.name ] = e;

    if( e.memberof )
    e.name = _.strRemoveBegin( e.longname, e.memberof );
    e.name = _.strRemoveBegin( e.name, '.' );
  })

  /* namespace:* short-cut */

  self.templateData.forEach( ( e ) =>
  {
    if( !e.memberof )
    return;
    if( !_.strBeginOf( e.memberof, 'namespace:' ) )
    return;
    e.memberof = _.strRemoveBegin( e.memberof, 'namespace:' );
    let namespace = self.namespacesByName[ e.memberof ];
    if( namespace )
    e.memberof = namespace.longname;
  })

  /*  */
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
  namespacesByName : _.define.own( {} ),
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

  transform,

  transformStage0,
  transformStage1,
  transformStage1,

  _currentFileDataTransform,

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