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
  self.transformStage2();
  self.transformStage3();
  self.transformStage4();

  debugger

  ready.take( self.templateData );

  return ready;
}

//

function transformStage0()
{
  let self = this;

  for( let file in self.parsedFiles )
  {
    let currentFile = self.parsedFiles[ file ];

    currentFile.forEach( ( e ) =>
    {
      if( e.undocumented )
      return;
      if( e.kind === 'package' || e.kind === 'file' )
      return;

      if( e.tags )
      {
        e.customTags = Object.create( null );
        e.tags.forEach( ( t ) =>
        {
          if( _.strBeginOf( t.value, '"' ) && _.strEndOf( t.value, '"' ) )
          t.value = _.strInsideOf( t.value, '"', '"' );
          t.value = _removePrefix( t.value );
          e.customTags[ t.title ] = t;
        });
        delete e.tags;
      }
      self.templateData.push( e );
    })
  }

}

//

function transformStage1()
{
  let self = this;

  for( let i = self.templateData.length - 1; i >= 0; i-- )
  {
    let entity = self.templateData[ i ];

    if( !entity.customTags )
    continue;

    let customTags = entity.customTags;

    if( customTags.namespaces !== undefined )
    {
      /* transform entity with namespaces tag into two separate entities with jsdoc tag namespace */
      let newEntities = entitiesPopulate( customTags, 'namespaces', ( namespace ) =>
      {
        let newNamespace = _.mapExtend( null, entity );
        newNamespace.customTags = _.mapExtend( null, newNamespace.customTags );
        newNamespace.customTags.namespace = { title : 'namespace', value : namespace }
        return newNamespace;
      });
      newEntities.unshift( i, 1 )
      self.templateData.splice.apply( self.templateData, newEntities );
    }
    else if( customTags.memberofs !== undefined )
    {
      /* transform entity with memberofs tag into two separate entities with jsdoc tag memberof */
      let newEntities = entitiesPopulate( customTags, 'memberofs', ( memberof ) =>
      {
        let newEntity = _.mapExtend( null, entity );
        newEntity.customTags = _.mapExtend( null, newEntity.customTags );

        if( _.strBegins( memberof, 'module:' ) )
        newEntity.customTags.module = { title : 'module', value : _.strRemoveBegin( memberof, 'module:' )}
        else if( _.strBegins( memberof, 'namespace:' ) )
        newEntity.customTags.namespace = { title : 'namespace', value : _.strRemoveBegin( memberof, 'namespace:' )}
        else if( _.strBegins( memberof, 'class:' ) )
        newEntity.customTags.class = { title : 'class', value : _.strRemoveBegin( memberof, 'class:' )}

        return newEntity;
      });
      newEntities.unshift( i, 1 )
      self.templateData.splice.apply( self.templateData, newEntities );
    }

  }

  /* update entities order prop */

  for( let i = self.templateData.length - 1; i >= 0; i-- )
  {
    self.templateData[ i ].order = i;
  }

  /* */

  function entitiesPopulate( customTags, customTagName, onEntity )
  {
    let currentTag = customTags[ customTagName ];
    let parsedEntities = _.strSplitNonPreserving({ src : currentTag.text, delimeter : ',' });

    _.assert( parsedEntities.length >= 1 );

    let result = parsedEntities.map( ( entityName, i ) =>
    {
      if( _.strBeginOf( entityName, '"' ) && _.strEndOf( entityName, '"' ) )
      entityName = _.strInsideOf( entityName, '"', '"' );

      let newEntity = onEntity( entityName );

      newEntity.order += i;
      delete newEntity.customTags[ currentTag.title ];

      return newEntity;
    })

    return result;
  }



}

//

function transformStage2()
{
  let self = this;

  for( let i = self.templateData.length - 1; i >= 0; i-- )
  {
    let e = self.templateData[ i ];

    if( e.customTags)
    entityTagsModify( e );

    if( e.kind )
    entityWithKind( e );
    else
    entityNoKind( e );

    entityRegister( e );
  }

  function isModule( e )
  {
    if( e.kind )
    return false;
    if( !e.customTags )
    return false;
    if( !e.customTags.module )
    return false;
    if( e.customTags.namespace || e.customTags.namespaces || e.customTags.class )
    return false;
    return true;
  }

  function isNamespace( e )
  {
    if( e.kind )
    return false;
    if( !e.customTags )
    return false;
    if( !e.customTags.namespace && !e.customTags.namespaces )
    return false;
    if( e.customTags.class )
    return false;
    return true;
  }

  function isClass( e )
  {
    if( e.kind )
    return false;
    if( !e.customTags )
    return false;
    if( !e.customTags.class )
    return false;
    return true;
  }

  function isMemberOfModule( e )
  {
    if( !e.kind )
    return false;
    if( !e.customTags )
    return false;
    if( !e.customTags.module )
    return false;
    if( e.customTags.class || e.customTags.namespace )
    return false;
    return true;
  }

  function isMemberOfNamespace( e )
  {
    if( !e.kind )
    return false;
    if( !e.customTags )
    return false;
    if( !e.customTags.namespace )
    return false;
    if( e.customTags.class )
    return false;
    return true;
  }

  function isMemberOfClass( e )
  {
    if( !e.kind )
    return false;
    if( !e.customTags )
    return false;
    if( !e.customTags.class )
    return false;
    return true;
  }

  function entityTagsModify( e )
  {
    for( let k in e.customTags )
    {
      let tag = e.customTags[ k ];
      tag.value = _removePrefix( tag.value );
    }
  }

  function entityWithKind( e )
  {
    let customTags = e.customTags;
    if( !customTags )
    return;

    if( isMemberOfModule( e ) )
    {
      e.memberof = 'module:' + customTags.module.value;
    }
    else if( isMemberOfNamespace( e ) )
    {
      e.memberof = 'namespace:' + customTags.namespace.value;
    }
    else if( isMemberOfClass( e ) )
    {
      e.memberof = 'class:' + customTags.class.value;
      if( e.scope !== 'static' )
      e.scope = 'instance'
    }
  }

  function entityNoKind( e )
  {
    let customTags = e.customTags;

    if( isModule( e ) )
    {
      e.name = customTags.module.value;
      e.longname = 'module:' + e.name;
      e.id = e.longname;
      e.kind = 'module';
      delete e.memberof;
      delete e.scope;
    }
    else if( isNamespace( e ) )
    {
      if( e.customTags.namespace )
      e.name = customTags.namespace.value;
      e.longname = e.name;
      e.id = e.longname;
      e.kind = 'namespace';
      if( customTags.module )
      e.memberof = 'module:' + customTags.module.value;
      e.scope = 'global'
    }
    else if( isClass( e ) )
    {
      e.name = customTags.class.value;
      e.longname = e.name;
      e.id = e.longname;
      e.kind = 'class';
      e.scope = 'static';

      if( customTags.module )
      e.memberof = 'module:' + customTags.module.value;

    }
  }

  function entityRegister( e )
  {
    if( !e.name )
    debugger

    _.assert( _.strDefined( e.name ) );

    if( e.kind === 'module' )
    {
      _.assert( !self.modules[ e.name ] );
      self.modules[ e.name ] = e;
    }
    else if( e.kind === 'namespace' )
    {
      if( self.namespaces[ e.name ] )
      return false;
      self.namespaces[ e.name ] = e;
    }
    else if( e.kind === 'class' )
    {
      _.assert( !self.classes[ e.name ] );
      self.classes[ e.name ] = e;
    }

    return e;
  }

}

//

function transformStage3()
{
  let self = this;
  self.templateData.forEach( e =>
  {
    if( !e.memberof )
    return;

    if( _.strBegins( e.memberof, 'module:' ) )
    {
      e.longname = e.memberof + '.' + e.name;
      e.id = e.longname;
    }
    else if( _.strBegins( e.memberof, 'namespace:' ) )
    {
      let namespaceName = _.strRemoveBegin( e.memberof, 'namespace:' );
      let namespaceEntity = self.namespaces[ namespaceName ];
      e.memberof = namespaceName;
      e.longname = namespaceName + '.' + e.name;
      if( namespaceEntity && namespaceEntity.memberof )
      {
        e.memberof = namespaceEntity.memberof + '.' + namespaceName;
        e.longname = e.memberof + '.' + e.name;
      }
      e.id = e.longname;
    }
    else if( _.strBegins( e.memberof, 'class:' ) )
    {
      let className = _.strRemoveBegin( e.memberof, 'class:' );
      let classEntity = self.classes[ className ];
      e.memberof = className;
      if( classEntity && classEntity.memberof )
      {
        e.memberof = classEntity.memberof + '.' + className;
        e.longname = e.memberof + '.' + e.name;
      }
      e.id = e.longname;
    }

  })
}

//

function transformStage4()
{
  let self = this;
  // self.templateData.forEach( e =>
  // {
  // })
}

function _removePrefix( src )
{
  let firstIsSmall = /[a-z]/.test( src[ 0 ] );
  let secondIsCapital = /[A-Z]/.test( src[ 1 ] );

  if( firstIsSmall && secondIsCapital )
  return src.slice( 1 );
  return src;
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
  // namespacesByName : _.define.own( {} ),
  // classesByName : _.define.own( {} ),

  modules : _.define.own( {} ),
  namespaces : _.define.own( {} ),
  classes : _.define.own( {} ),
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
  transformStage2,
  transformStage3,
  transformStage4,

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