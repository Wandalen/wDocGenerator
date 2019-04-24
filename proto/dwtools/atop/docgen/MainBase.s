( function _MainBase_s_() {

'use strict';

/**
 * Utility to generate documentation from jsdoc annotated source code.
  @module Tools/wDocGenerator
*/

/**
 * @file Main.base.s
 */

if( typeof module !== 'undefined' )
{

  require( './IncludeBase.s' );

  var jsdoc2md = require('jsdoc-to-markdown')
  var ddata = require( 'dmd/helpers/ddata.js' )
  var state = require( 'dmd/lib/state.js' );

  var arrayify = require('array-back');
  var where = require('test-value').where;

}

//

let _ = _global_.wTools;
let Parent = null;
let Self = function wDocGenerator( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'DocGenerator';

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

  _.instanceInit( self );
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

function form( e )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  let appArgs;

  if( !e )
  {
    appArgs = _.appArgs();
  }
  else
  {
    appArgs =
    {
      subject : e.argument,
      map : e.propertiesMap
    }
  }

  _.appArgsReadTo
  ({
    dst : self,
    namesMap :
    {
      verbosity : 'verbosity',
      v : 'verbosity',
      outPath : 'outPath',
      out : 'outPath',
      docsify : 'docsify',
      includingConcepts : 'includingConcepts',
      includingTutorials : 'includingTutorials',
      conceptsPath : 'conceptsPath',
      manuals: 'conceptsPath',
      tutorialsPath : 'tutorialsPath',
      tutorials : 'tutorialsPath',
      useWillForManuals : 'useWillForManuals',
      willModulePath : 'willModulePath',
    },
    propertiesMap : appArgs.map
  });

  // _.sure( _.strDefined( appArgs.subject ), '{-referencePath-} needs value, please pass a subject' );

  self.referencePath = appArgs.subject;

  self.pathsResolve();

  // _.assert( self.provider.fileExists( self.referencePath ), 'Provided referencePath doesn`t exist:', self.referencePath );

  if( self.includeAny )
  self.includeAny = new RegExp( self.includeAny );
  if( self.excludeAny )
  self.excludeAny = new RegExp( self.excludeAny );

  if( self.useWillForManuals )
  {
    self.will = new _.Will({ verbosity : self.verbosity });
  }
}

//

function pathsResolve()
{
  let self = this;
  let path = self.provider.path;

  if( self.referencePath )
  self.referencePath = path.resolve( path.current(), self.inPath, self.referencePath );
  self.conceptsPath = path.resolve( path.current(), self.inPath, self.conceptsPath );
  self.tutorialsPath = path.resolve( path.current(), self.inPath, self.tutorialsPath );
  self.outPath = path.resolve( path.current(), self.inPath, self.outPath );

  self.willModulePath = path.resolve( path.current(), self.inPath, self.willModulePath );

  if( !self.env )
  self.env = _.TemplateTreeEnvironment({ tree : self });
  self.env.pathsNormalize();

  self.outReferencePath = path.resolve( path.current(), self.inPath, self.outReferencePath );
  self.outConceptsPath = path.resolve( path.current(), self.inPath, self.outConceptsPath );
  self.outTutorialsPath = path.resolve( path.current(), self.inPath, self.outTutorialsPath );

}

//

//

function templateDataRead()
{
  let self = this;
  let logger = self.logger;
  let path = self.provider.path;

  _.sure( _.strDefined( self.referencePath ), '{-referencePath-} needs value, please pass a subject' );
  _.assert( self.provider.fileExists( self.referencePath ), 'Provided referencePath doesn`t exist:', self.referencePath );

  let files = self.provider.filesFind
  ({
    filePath : self.referencePath,
    filter :
    {
      ends : [ '.s','.ss','.js' ],
      maskAll :
      {
        includeAny : self.includeAny,
        excludeAny : self.excludeAny
      }
    },
    includingTransient : 0,
	  includingDirs : 0,
    outputFormat : 'absolute',
    recursive : 2,
  });

  _.assert( files.length, 'No files found at referencePath:', self.referencePath )

  let configPathNative = path.nativize( path.join( __dirname,  'conf/doc.json' ) );

  files.forEach( ( file ) =>
  {
    try
    {
      let currentFileData = jsdoc2md.getTemplateDataSync
      ({
        files : [ path.nativize( file ) ],
        configure : configPathNative
      });

      _.arrayAppendArray( self.templateData,currentFileData  )
    }
    catch( err )
    {
      if( self.verbosity > 1 )
      _.errLogOnce( _.err( 'jsdoc2md: Error during parse:', file, err ) );
    }
  })

  //

  self.templateData.forEach( ( e ) =>
  {
    if( e.kind != 'namespace' )
    return;

    if( e.memberof )
    e.name = _.strRemoveBegin( e.longname, e.memberof );
    e.name = _.strRemoveBegin( e.name, '.' );

  })

  // logger.log( _.toStr( self.parsedTemplateData, { jsLike : 1 } ) )
}

//

function docsifyAppBaseCopy()
{
  let self = this;
  let path = self.provider.path;

  _.assert( arguments.length === 0 );

  let docsifyAppPath = path.join( __dirname, 'docsify-app' );

  _.sure( self.provider.fileExists( docsifyAppPath ) );

  self.provider.filesReflect({ reflectMap : { [ docsifyAppPath ] : self.outPath } });

  return true;
}

//

function markdownGenerate()
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

//

function prepareConcepts()
{
  let self = this;
  let provider =  self.provider;
  let path = provider.path;

  let index;

  if( self.useWillForManuals )
  {
    let o =
    {
      docPathSelector : 'path::doc.concepts',
      outDirPath : self.outConceptsPath,
      indexTitle : 'Concepts',
      indexPathSelector : 'path::doc.concepts.index'
    }
    index = self._prepareManualsUsingWill( o );
  }
  else
  {
    provider.filesReflect
    ({
      reflectMap : { [ self.conceptsPath ] : self.outConceptsPath },
    });

    if( !provider.fileExists( self.outConceptsPath ) )
    return;

    index =  self.indexGenerate( self.outConceptsPath, 'Concepts', 'README.md' );
  }

  let indexPath = path.join( self.outPath, 'Concepts.md' )
  self.provider.fileWrite( indexPath, index );
}

//

function prepareTutorials()
{
  let self = this;
  let provider =  self.provider;
  let path = provider.path;

  let index;

  if( self.useWillForManuals )
  {
    let o =
    {
      docPathSelector : 'path::doc.tutorials',
      outDirPath : self.outTutorialsPath,
      indexTitle : 'Tutorials',
      indexPathSelector : 'path::doc.tutorials.index'
    }
    index = self._prepareManualsUsingWill( o );
  }
  else
  {
    provider.filesReflect
    ({
      reflectMap : { [ self.tutorialsPath ] : self.outTutorialsPath },
    });

    if( !provider.fileExists( self.outTutorialsPath ) )
    return;

    index = self.indexGenerate( self.outTutorialsPath, 'Tutorials', 'README.md' );
  }

  let indexPath = path.join( self.outPath, 'Tutorials.md' )
  self.provider.fileWrite( indexPath, index );
}

//

function _prepareManualsUsingWill( o )
{
  let self = this;
  let provider = self.provider;
  let module = self.will.moduleMake({ dirPath : self.willModulePath });

  module.ready.deasync();

  let submodules = module.submodulesResolve({ selector : '*' });

  let index = `### ${o.indexTitle}\n`;

  submodules.forEach( ( sub ) =>
  {
    let srcPath;
    let moduleDirPath = sub.loadedModule.resolve( 'path::in' );

    try
    {
      srcPath = sub.loadedModule.resolve( o.docPathSelector );
    }
    catch( err )
    {
      srcPath = provider.path.join( moduleDirPath, 'doc' );
    }

    if( !provider.fileExists( srcPath ) )
    return;

    let name = sub.loadedModule.resolve( 'about::name' );
    let dstPath = provider.path.join( o.outDirPath, name );

    let files = provider.filesReflect
    ({
      reflectMap : { [ srcPath ] : dstPath },
      srcFilter :
      {
        ends : 'md'
      }
    });

    if( !files.length )
    return;

    let srcIndexPath;

    try
    {
      srcIndexPath = sub.loadedModule.resolve( o.indexPathSelector );
    }
    catch( err )
    {
      srcIndexPath = provider.path.join( srcPath, 'README.md' );
    }

    if( !provider.fileExists( srcIndexPath ) )
    return;

    index += '\n';
    index += `* [${ name }](${ provider.path.name( o.outDirPath ) + '/' + provider.path.relative( o.outDirPath, srcIndexPath )})`
    index += '\n';

  })

  return index;

}

//

function indexGenerate( srcPath, title, targetFileName )
{
  let self = this;
  let provider = self.provider;
  let path = provider.path;

  let results = {};

  let dirs = provider.filesFind
  ({
    filePath : srcPath,
    recursive : 1,
    includingTerminals : 0,
    includingDirs : 1,
    includingStem : 0,
  })

  dirs.forEach( ( f ) =>
  {
    let dirRelative = path.relative( srcPath, f.absolute );
    dirRelative = _.strAppendOnce( dirRelative, '/' )
    let moduleName = _.strIsolateLeftOrNone( path.undot( dirRelative ), '/' )[ 0 ];

    let files = provider.filesFind
    ({
      filePath : f.absolute,
      recursive : 1,
      includingTerminals : 1,
      includingDirs : 0,
      includingStem : 0,
      filter : { ends : 'md' },
    })

    if( !files.length )
    return;

    var relative = _.select( files, '*/relative' );

    if( _.arrayHas( relative, `./${targetFileName}` ) )
    {
      let filePath = path.join( f.absolute, targetFileName );
      results[ moduleName ] = path.relative( srcPath, filePath );
    }
    else if( _.arrayHas( relative, `./README.md` ) )
    {
      let filePath = path.join( f.absolute, `./README.md` );
      results[ moduleName ] = path.relative( srcPath, filePath );
    }
  })

  /*  */

  let index = `### ${title}\n`;

  for( let m in results )
  {
    let name = m;

    index += '\n';
    index += `* [${ name }](${ path.name( srcPath ) + '/' + results[ m ]})`
    index += '\n';
  }

  return index;
}

// --
// relations
// --

let Composes =
{

  verbosity : 1,

  referencePath : 'proto',
  conceptsPath : 'doc/concepts',
  tutorialsPath : 'doc/tutorial',

  willModulePath : '.',

  inPath : '.',
  outPath : 'out/doc',

  includeAny : ".+\\.(js|ss|s)(doc)?$",
  excludeAny : "(^|\\/|\\.)(-|node_modules|3rd|external|test)",

  docsify : 1,

  includingConcepts : 1,
  includingTutorials : 1,

  useWillForManuals : 0

}

let Associates =
{
  logger : _.define.own( new _.Logger({ output : console }) ),
  provider : null
}

let Restricts =
{
  env : null,
  templateData : _.define.own( [] ),

  outReferencePath : '{{outPath}}/Reference',
  outConceptsPath : '{{outPath}}/Concepts',
  outTutorialsPath : '{{outPath}}/Tutorials',

  will : null
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

  init : init,
  finit : finit,

  form : form,

  pathsResolve : pathsResolve,

  templateDataRead : templateDataRead,
  docsifyAppBaseCopy : docsifyAppBaseCopy,
  markdownGenerate : markdownGenerate,

  prepareConcepts : prepareConcepts,
  prepareTutorials : prepareTutorials,

  indexGenerate : indexGenerate,
  _prepareManualsUsingWill : _prepareManualsUsingWill,

  // relations

  Composes : Composes,
  Associates : Associates,
  Restricts : Restricts,
  Medials : Medials,
  Statics : Statics,
  Events : Events,
  Forbids : Forbids,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
});

_.Copyable.mixin( Self );
_.Verbal.mixin( Self );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;
wTools[ Self.shortName ] = Self;

})();
