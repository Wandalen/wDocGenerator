( function _MainBase_s_() {

'use strict';

/**
 * Utility to generate documentation from jsdoc annotated source code.
  @module Tools/top/DocGenerator
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
  return _.workpiece.construct( Self, this, arguments );
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

function form( e )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  self.will = new _.Will({ verbosity : self.verbosity });

  self._optionsFromArgsRead();
  self._optionsFromWillRead();
  self._optionsFromArgsApply()
  self._pathsResolve();

  // _.assert( self.provider.fileExists( self.referencePath ), 'Provided referencePath doesn`t exist:', self.referencePath );

  if( self.includeAny )
  self.includeAny = new RegExp( self.includeAny );
  if( self.excludeAny )
  self.excludeAny = new RegExp( self.excludeAny );
}

//

function _optionsFromWillRead()
{
  let self = this;
  let provider = self.provider;
  let path = provider.path;

  self.submodule = self.appArgs.map.submodule;

  try
  {
    self.module = self.will.moduleMake({ willfilesPath : path.current() });
    self.module.ready.deasync();
    if( self.submodule )
    self.submodule = self.module.submodulesResolve({ selector : self.submodule });
    else
    self.submodules = self.module.submodulesResolve({ selector : '*' });
  }
  catch( err )
  {
    if( self.verbosity )
    _.errLogOnce( err );
  }

  if( !self.module )
  return;

  let optionSelectorMap =
  {
    inPath : 'path::in',
    referencePath : 'path::reference',
    outPath : 'path::out.doc',
    docPath : 'path::doc',
    conceptsPath : 'path::concepts',
    tutorialsPath : 'path::tutorials',
    lintPath : 'path::lint',
    testingPath : 'path::testing',
    readmePath : 'path::readme'
  }

  let readOptions = Object.create( null );
  let module = _.objectIs( self.submodule ) ? self.submodule : self.module;

  for( let option in optionSelectorMap )
  {
    try
    {
      readOptions[ option ] = module.resolve( optionSelectorMap[ option ] );
    }
    catch( err )
    {
      // if( self.verbosity )
      // _.errLogOnce( err );
    }
  }

  _.mapExtend( self, readOptions );

}

//

function _optionsFromArgsRead( e )
{
  let self = this;

  if( !e )
  {
    self.appArgs = _.appArgs();
  }
  else
  {
    self.appArgs =
    {
      subject : e.argument,
      map : e.propertiesMap
    }
  }

  let appArgs = self.appArgs;

  if( appArgs.scriptArgs[ 1 ] && !appArgs.map.referencePath )
  self.referencePath = appArgs.scriptArgs[ 1 ];

  _.assertMapHasOnly( self.appArgs.map, optionsNamesMap );
}

//

function _optionsFromArgsApply( e )
{
  let self = this;

  _.appArgsReadTo
  ({
    dst : self,
    namesMap : optionsNamesMap,
    propertiesMap : self.appArgs.map
  });
}

//

function _pathsResolve()
{
  let self = this;
  let path = self.provider.path;

  self.inPath = path.resolve( path.current(), self.inPath );

  if( self.referencePath )
  self.referencePath = path.resolve( path.current(), self.inPath, self.referencePath );

  self.outPath = path.resolve( path.current(), /* self.inPath, */ self.outPath );
  self.docPath = path.resolve( path.current(), self.inPath, self.docPath );

  if( self.conceptsPath )
  self.conceptsPath = path.resolve( path.current(), self.inPath, self.conceptsPath );
  else
  self.conceptsPath = path.resolve( self.docPath, 'README.md' );

  if( self.tutorialsPath )
  self.tutorialsPath = path.resolve( path.current(), self.inPath, self.tutorialsPath );
  else
  self.tutorialsPath = path.resolve( self.docPath, 'README.md' );

  if( self.lintPath )
  self.lintPath = path.resolve( path.current(), self.inPath, self.lintPath );
  else
  self.lintPath = path.resolve( self.docPath, 'lint' );

  if( self.testingPath )
  self.testingPath = path.resolve( path.current(), self.inPath, self.testingPath );
  else
  self.testingPath = path.resolve( self.docPath, 'testing' );

  if( self.readmePath )
  self.readmePath = path.resolve( path.current(), self.inPath, self.readmePath );

  // self.willModulePath = path.resolve( path.current(), self.inPath, self.willModulePath );

  if( !self.env )
  self.env = _.TemplateTreeEnvironment({ tree : self });
  self.env.pathsNormalize();

  self.outReferencePath = path.resolve( path.current(), /* self.inPath, */ self.outReferencePath );
  self.outDocPath = path.resolve( path.current(), /* self.inPath, */ self.outDocPath );
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

function performDocsifyApp()
{
  let self = this;
  let path = self.provider.path;

  _.assert( arguments.length === 0 );

  let docsifyAppPath = path.join( __dirname, 'docsify-app' );

  _.sure( self.provider.fileExists( docsifyAppPath ) );

  self.provider.filesReflect({ reflectMap : { [ docsifyAppPath ] : self.outPath } });

  if( self.readmePath )
  {
    _.sure( path.ext( self.readmePath ) === 'md' );
    self.provider.fileCopy({ srcPath : self.readmePath, dstPath : path.join( self.outPath, 'README.md' ) })
  }

  return true;
}

//

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

//

function performConcepts()
{
  let self = this;
  let provider =  self.provider;
  let path = provider.path;

  let index = `### Concepts\n`;

  /* current */

  index += self._indexForModule( self.docPath, self.inPath, self.conceptsPath );

  /* submodules */

  if( self.includingSubmodules )
  index += self._indexForSubmodules( 'path::concepts' );
  else
  index += self._indexForSubmodulesFilesBased( self.outDocPath,'Concepts.md' );

  /* write index */

  let indexPath = path.join( self.outPath, 'Concepts.md' )
  provider.fileWrite( indexPath, index );
}

//

function performTutorials()
{
  let self = this;
  let provider =  self.provider;
  let path = provider.path;

  let index = `### Tutorials\n`;

  /* current */

  index += self._indexForModule( self.docPath, self.inPath, self.tutorialsPath );

  /* submodules */

  if( self.includingSubmodules )
  index += self._indexForSubmodules( 'path::tutorials' );
  else
  index += self._indexForSubmodulesFilesBased( self.outDocPath, 'Tutorials.md' );

  /* write index */

  let indexPath = path.join( self.outPath, 'Tutorials.md' )
  provider.fileWrite( indexPath, index );
}

//

function performLintReports()
{
  let self = this;
  let provider =  self.provider;
  let path = provider.path;

  let index = `### Lint\n`;

  /* current */

  index += self._indexForDirectory( self.inPath, self.docPath, self.lintPath )

  /* submodules */

  if( self.includingSubmodules )
  index += self._reportsIndexForSubmodules( 'path::lint', 'doc/lint' );

  /* write index */

  let indexPath = path.join( self.outPath, 'Lint.md' )
  provider.fileWrite( indexPath, index );

}

//

function performTestingReports()
{
  let self = this;
  let provider =  self.provider;
  let path = provider.path;

  let index = `### Testing\n`;

  /* current */

  index += self._indexForDirectory( self.inPath, self.docPath, self.testingPath )

  /* submodules */

  if( self.includingSubmodules )
  index += self._reportsIndexForSubmodules( 'path::testing', 'doc/testing' );

  /* write index */

  let indexPath = path.join( self.outPath, 'Testing.md' )
  provider.fileWrite( indexPath, index );

}

//

function performDoc()
{
  let self = this;
  let provider =  self.provider;
  let path = provider.path;

  // let dstPath = path.join( self.outDocPath, path.name( self.inPath ) );

  provider.filesReflect
  ({
    reflectMap : { [ self.docPath ] : self.outDocPath },
  });

  if( !self.includingSubmodules )
  return;

  if( !self.submodules )
  return;

  self.submodules.forEach( ( sub ) =>
  {
    let inPath = sub.resolve( 'path::in' );
    let srcPath = resolveTry.call( sub, 'path::doc', 'doc' );
    srcPath = path.resolve( inPath, srcPath );
    let dstPath = path.join( self.outDocPath, path.name( inPath ) );

    provider.filesReflect
    ({
      reflectMap : { [ srcPath ] : dstPath },
    });
  })

  /* */

  function resolveTry( selector, def )
  {
    try
    {
      return this.resolve( selector );
    }
    catch( err )
    {
      return def;
    }
  }
}

//

function _indexForModule( moduleDocPathSrc, modulePath, indexPath )
{
  let self = this;
  let provider = self.provider;
  let path = provider.path;

  let moduleName = path.name( modulePath );
  let moduleDocPathDst = path.join( self.outDocPath, moduleName )
  if( !provider.fileExists( indexPath ) )
  indexPath = path.join( moduleDocPathSrc, 'README.md' );

  if( !provider.fileExists( indexPath ) )
  return '';

  indexPath = path.relative( moduleDocPathSrc, indexPath );
  let relativeDocPath = path.relative( self.outDocPath, moduleDocPathDst );
  indexPath = path.join( path.name( self.outDocPath ), relativeDocPath, indexPath );

  let result = '\n' + `* [${ moduleName }](${indexPath})` + '\n';

  return result;
}

//

function _indexForSubmodules( indexPathSelector )
{
  let self = this;
  let provider = self.provider;
  let path = provider.path;
  let index = '';

  if( !self.submodules )
  return index;

  self.submodules.forEach( ( sub ) =>
  {
    let inPath = resolveTry.call( sub, 'path::in' );
    let docPath = resolveTry.call( sub, 'path::doc', 'doc' );
    let indexPath = resolveTry.call( sub, indexPathSelector, 'doc/README.md' );

    docPath = path.resolve( inPath, docPath );
    indexPath = path.resolve( inPath, indexPath );

    index += self._indexForModule( docPath, inPath, indexPath );
  })

  return index;

  /* */

  function resolveTry( selector, def )
  {
    try
    {
      return this.resolve( selector );
    }
    catch( err )
    {
      return def;
    }
  }
}

//

function _reportsIndexForSubmodules( reportsPathSelector, defaultReportsPath )
{
  let self = this;
  let provider = self.provider;
  let path = provider.path;
  let index = '';

  if( !self.submodules )
  return index;

  self.submodules.forEach( ( sub ) =>
  {
    let inPath = resolveTry.call( sub, 'path::in' );
    let docPath = resolveTry.call( sub, 'path::doc', 'doc' );
    let reportsPath = resolveTry.call( sub, reportsPathSelector, defaultReportsPath );

    docPath = path.resolve( inPath, docPath );
    reportsPath = path.resolve( inPath, reportsPath );

    index += self._indexForDirectory( inPath, docPath, reportsPath );
  })

  return index;

  /* */

  function resolveTry( selector, def )
  {
    try
    {
      return this.resolve( selector );
    }
    catch( err )
    {
      return def;
    }
  }
}

//

function _indexForDirectory( inPath, docPath, dirPath )
{
  let self = this;
  let provider = self.provider;
  let path = provider.path;

  let index = '';

  if( !provider.fileExists( dirPath ) )
  return index;

  let files = provider.filesFind
  ({
    filePath : dirPath,
    recursive : 1,
    includingTerminals : 1,
    includingDirs : 0,
    includingStem : 0,
  });

  if( !files.length )
  return index;

  let moduleName = path.name( inPath );
  let dirPathRelative = path.relative( docPath, dirPath );

  // index += `\n#### ${moduleName}`;

  files.forEach( ( r ) =>
  {
    index += '\n';
    index += `* [${ r.name }](${ path.name( self.outDocPath ) + '/' + path.join( /* moduleName, */ dirPathRelative, r.relative )})`
    index += '\n';
  })

  return index;
}

//

function _indexForSubmodulesFilesBased( docPath, indexFile )
{
  let self = this;
  let provider = self.provider;
  let path = provider.path;

  let index = '';

  if( !provider.fileExists( docPath ) )
  return index;

  let dirs = provider.filesFind
  ({
    filePath : docPath,
    recursive : 1,
    includingTerminals : 0,
    includingDirs : 1,
    includingStem : 0,
  });

  if( !dirs.length )
  return index;

  dirs.forEach( ( r ) =>
  {
    index += forModule( r );
  })

  return index;

  /*  */

  function forModule( r )
  {
    let result = '';

    let moduleName = r.name;
    let indexPath = path.join( r.absolute, indexFile );
    if( !provider.fileExists( indexPath ) )
    indexPath = path.join( r.absolute, 'README.md' );

    if( !provider.fileExists( indexPath ) )
    return result;

    indexPath = path.relative( r.absolute, indexPath );
    let relativeDocPath = path.relative( self.outDocPath, r.absolute );
    indexPath = path.join( path.name( self.outDocPath ), relativeDocPath, indexPath );

    result = '\n' + `* [${ moduleName }](${indexPath})` + '\n';

    return result;
  }


}

//

// function _prepareManualsUsingWill( o )
// {
//   let self = this;
//   let provider = self.provider;
//   let module = self.will.moduleMake({ dirPath : self.willModulePath });

//   module.ready.deasync();

//   let submodules = module.submodulesResolve({ selector : '*' });

//   let index = `### ${o.indexTitle}\n`;

//   submodules.forEach( ( sub ) =>
//   {
//     let srcPath;
//     let moduleDirPath = sub.loadedModule.resolve( 'path::in' );

//     try
//     {
//       srcPath = sub.loadedModule.resolve( o.docPathSelector );
//     }
//     catch( err )
//     {
//       srcPath = provider.path.join( moduleDirPath, 'doc' );
//     }

//     if( !provider.fileExists( srcPath ) )
//     return;

//     let name = sub.loadedModule.resolve( 'about::name' );
//     let dstPath = provider.path.join( o.outDirPath, name );

//     let files = provider.filesReflect
//     ({
//       reflectMap : { [ srcPath ] : dstPath },
//       srcFilter :
//       {
//         ends : 'md'
//       }
//     });

//     if( !files.length )
//     return;

//     let srcIndexPath;

//     try
//     {
//       srcIndexPath = sub.loadedModule.resolve( o.indexPathSelector );
//     }
//     catch( err )
//     {
//       srcIndexPath = provider.path.join( srcPath, 'README.md' );
//     }

//     if( !provider.fileExists( srcIndexPath ) )
//     return;

//     index += '\n';
//     index += `* [${ name }](${ provider.path.name( o.outDirPath ) + '/' + provider.path.relative( o.outDirPath, srcIndexPath )})`
//     index += '\n';

//   })

//   return index;

// }

//

// function indexGenerate( srcPath, title )
// {
//   let self = this;
//   let provider = self.provider;
//   let path = provider.path;

//   let results = {};

//   if( provider.isTerminal( srcPath ) )
//   {
//     let moduleName = path.name( self.inPath );
//     results[ moduleName ] = path.join( '/', path.name( self.outDocPath ), path.relative( self.docPath, srcPath ) );
//   }
//   else
//   {
//     _.assert( provider.isDir( srcPath ) );

//     let dirs = provider.filesFind
//     ({
//       filePath : srcPath,
//       recursive : 1,
//       includingTerminals : 0,
//       includingDirs : 1,
//       includingStem : 0,
//     });

//     let indexPath = selectIndex( srcPath );

//     if( indexPath )
//     {
//       let moduleName = path.name( self.inPath );
//       results[ moduleName ] = path.join( '/', path.name( self.outDocPath ), path.relative( srcPath, indexPath ) );
//     }
//     else
//     {
//       dirs.forEach( ( f ) =>
//       {
//         let dirRelative = path.relative( srcPath, f.absolute );
//         dirRelative = _.strAppendOnce( dirRelative, '/' )
//         let moduleName = _.strIsolateLeftOrNone( path.undot( dirRelative ), '/' )[ 0 ];
//         let indexPath = selectIndex( f.absolute );
//         if( indexPath )
//         {
//           let relative = path.relative( self.docPath, indexPath );
//           results[ moduleName ] = path.join( '/', path.name( self.outDocPath ), relative );
//         }
//       })
//     }
//   }

//   /*  */

//   let index = `### ${title}\n`;

//   for( let m in results )
//   {
//     let name = m;

//     index += '\n';
//     index += `* [${ name }](${results[ m ]})`
//     index += '\n';
//   }

//   return index;

//   /*  */

//   function selectIndex( srcPath )
//   {
//     let indexPath = path.join( srcPath, title + '.md' );
//     let ReadmePath = path.join( srcPath, 'README.md' );
//     let prefixPath = path.join( '/', path.name( self.outDocPath ) );

//     if( provider.fileExists( indexPath ) )
//     {
//       return indexPath;
//     }
//     else if( provider.fileExists( ReadmePath ) )
//     {
//       return ReadmePath;
//     }
//   }
// }

//

function modulesInstall()
{
  let self = this;

  return _.shell
  ({
    execPath : 'npm i',
    currentPath : self.outPath,
    sync : 1,
    deasync : 1
  })
}

//

let commonOptionsNames =
{
  verbosity : 'verbosity',
  v : 'verbosity',
  docsify : 'docsify',
  includingConcepts : 'includingConcepts',
  includingTutorials : 'includingTutorials',
  includingLintReports : 'includingLintReports',
  includingTestingReports : 'includingTestingReports',
  includingSubmodules : 'includingSubmodules',
  submodule : 'submodule',
}

let pathOptionsNames =
{
  referencePath : 'referencePath',
  outPath : 'outPath',
  docPath : 'docPath',
  doc : 'docPath',
  out : 'outPath',
  conceptsPath : 'conceptsPath',
  concepts: 'conceptsPath',
  tutorialsPath : 'tutorialsPath',
  tutorials : 'tutorialsPath',
  lintPath : 'lintPath',
  testingPath : 'testingPath',
  readmePath : 'readmePath'
}

let optionsNamesMap = _.mapExtend( null, commonOptionsNames, pathOptionsNames );

// --
// relations
// --

let Composes =
{

  verbosity : 1,

  referencePath : 'proto',
  docPath : 'doc',
  conceptsPath : null,
  tutorialsPath : null,
  lintPath : null,
  testingPath : null,
  readmePath : null,

  // willModulePath : '.',

  inPath : '.',
  outPath : 'out/doc',

  includeAny : ".+\\.(js|ss|s)(doc)?$",
  excludeAny : "(^|\\/|\\.)(-|node_modules|3rd|external|test)",

  docsify : 1,

  includingConcepts : 1,
  includingTutorials : 1,
  includingLintReports : 1,
  includingTestingReports : 1,

  includingSubmodules : 0,
  submodule : null
}

let Associates =
{
  logger : _.define.own( new _.Logger({ output : console }) ),
  provider : null
}

let Restricts =
{
  env : null,
  appArgs : null,
  optionsFromArgs : _.define.own({}),
  templateData : _.define.own( [] ),

  outReferencePath : '{{outPath}}/Reference',
  outDocPath : '{{outPath}}/Doc',

  will : null,
  module: null,
  submodules : null,
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

  _optionsFromWillRead : _optionsFromWillRead,
  _optionsFromArgsRead : _optionsFromArgsRead,
  _optionsFromArgsApply : _optionsFromArgsApply,
  _pathsResolve : _pathsResolve,

  templateDataRead : templateDataRead,
  performDocsifyApp : performDocsifyApp,
  referenceGenerate : referenceGenerate,

  performConcepts : performConcepts,
  performTutorials : performTutorials,
  performLintReports : performLintReports,
  performTestingReports : performTestingReports,

  performDoc : performDoc,

  // indexGenerate : indexGenerate,
  _indexForModule : _indexForModule,
  _indexForSubmodules : _indexForSubmodules,
  _reportsIndexForSubmodules : _reportsIndexForSubmodules,
  _indexForSubmodulesFilesBased : _indexForSubmodulesFilesBased,
  _indexForDirectory : _indexForDirectory,
  // _prepareManualsUsingWill : _prepareManualsUsingWill,

  modulesInstall : modulesInstall,

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
