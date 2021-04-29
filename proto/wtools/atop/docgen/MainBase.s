( function _MainBase_s_()
{

'use strict';

/**
 * Utility to generate documentation from jsdoc annotated source code.
  @module Tools/top/DocGenerator
*/

/**
 *  */

if( typeof module !== 'undefined' )
{
  require( './IncludeBase.s' );
}

//

const _ = _global_.wTools;
const Parent = null;
_.docgen = _.docgen || Object.create( null );

const Self = wDocGenerator;
function wDocGenerator( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'DocGenerator';

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

function form( e )
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  self.will = new _.Will({ verbosity : self.verbosity });

  self._optionsFromArgsRead();
  // self._optionsFromWillRead();//xxx
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
    self.module = self.will.moduleMake({ willfilesPath : _.strAppendOnce( path.current(), '/' ) });
    self.module.openedModule.ready.deasync();
    if( self.submodule )
    self.submodule = self.module.openedModule.submodulesResolve({ selector : self.submodule });
    else
    self.submodules = self.module.openedModule.submodulesResolve({ selector : '*' });
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
  let module = _.object.isBasic( self.submodule ) ? self.submodule : self.module;

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

  _.props.extend( self, readOptions );

}

//

function _optionsFromArgsRead( e )
{
  let self = this;

  if( !e )
  {
    self.appArgs = _.process.input();
  }
  else
  {
    self.appArgs =
    {
      subject : e.instructionArgument,
      map : e.propertiesMap
    }
  }

  let appArgs = self.appArgs;

  if( appArgs.scriptArgs[ 1 ] && !appArgs.map.referencePath )
  self.referencePath = appArgs.scriptArgs[ 1 ];

  _.map.assertHasOnly( self.appArgs.map, optionsNamesMap );
}

//

function _optionsFromArgsApply( e )
{
  let self = this;

  _.process.inputReadTo
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
  self.referencePath = path.s.resolve( path.current(), self.inPath, self.referencePath );

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

function sourceFilesParse()
{
  let self = this;
  return ready;
}

//

function markdownGenerate()
{
  let self = this;

  let jsParser = new _.docgen.ParserJsdoc
  ({
    inPath : self.referencePath,
    inacurate : self.inacurate
  })

  jsParser.form();

  let ready = jsParser.parse();

  ready.then( ( got ) =>
  {
    self.product = got;

    let mdGenerator = new _.docgen.MarkdownGenerator
    ({
      product : self.product,
      outPath : self.outPath,
      outReferencePath : self.outReferencePath,
      logger : self.logger,
      provider : self.provider,
      verbosity : self.verbosity
    })

    mdGenerator.form();
    return mdGenerator.render();
  })

  return ready;
}

//

function performDocsifyApp()
{
  let self = this;
  let path = self.provider.path;

  _.assert( arguments.length === 0 );

  let docsifyAppPath = path.join( __dirname, 'l4/docsify-app' );

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
  return null;

  if( !self.submodules )
  return null;

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

  return null;

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

function performConcepts()
{
  let self = this;
  let provider =  self.provider;
  let path = provider.path;

  let index = `### Concepts\n`;

  /* current */

  debugger

  index += self._indexForModule( self.docPath, self.inPath, self.conceptsPath );

  /* submodules */

  if( self.includingSubmodules )
  index += self._indexForSubmodules( 'path::concepts' );
  else
  index += self._indexForSubmodulesFilesBased( self.outDocPath, 'Concepts.md' );

  /* write index */

  let indexPath = path.join( self.outPath, 'Concepts.md' )
  provider.fileWrite( indexPath, index );

  return null;
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

  return null;
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

  return null;
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

  return null;
}

//

function performCoverageReport()
{
  let self = this;
  let provider =  self.provider;
  let path = provider.path;

  let resultMap = Object.create( null );
  resultMap.perFileMap = Object.create( null );
  resultMap.documentedCount = 0;
  resultMap.totalCount = 0;

  let ready = self._performCoverageNumbersDocumented( resultMap );

  ready.then( () => self._performCoverageNumbersTotal( resultMap ) );

  ready.then( () => 
  {
    let o = 
    {
      data : [],
      topHead : [ 'filePath', ' nDocumented / nTotal', '  Coverage' ],
      bottomHead : [ 'Total', `${resultMap.documentedCount} / ${resultMap.totalCount}`, Math.ceil( resultMap.documentedCount / resultMap.totalCount * 100 ) + '%' ],
      dim : [ 0, 3 ],
      style : 'border'
    }

    self.parsedFiles.forEach( ( filePath ) => 
    {
      let resultsForFile = resultMap.perFileMap[ filePath ];

      if( !resultsForFile.documented && !resultsForFile.total )
      return;

      let relativePath = path.relative( path.join( filePath, '../..' ), filePath );
      o.data.push
      ( 
        relativePath,
        `${resultsForFile.documented} / ${resultsForFile.total}`,
        Math.ceil( resultsForFile.documented / resultsForFile.total * 100 ) + '%'
      )
      o.dim[ 0 ] += 1;
    });

    self.logger.log( `\nReference path(s):${_.ct.format( _.entity.exportJs( path.s.relative( self.inPath, self.referencePath ) ), 'path' )}` )

    self.logger.log( _.strTable( o ).result );

    return null;
  })

  return ready;

}

//

function _performCoverageNumbersDocumented( resultMap )
{
  let self = this;
  let provider =  self.provider;
  let path = provider.path;

  let jsParser = new _.docgen.ParserJsdoc
  ({
    inPath : self.referencePath,
    inacurate : true,
  })

  jsParser.form();

  let ready = jsParser.parse();

  ready.then( ( got ) =>
  {
    self.product = got;
    self.parsedFiles = jsParser.files;

    self.parsedFiles.forEach( ( filePath ) =>
    {
      let currentFileMap = resultMap.perFileMap[ filePath ] = Object.create( null );
      currentFileMap.documented = 0;
      currentFileMap.total = 0;
    })

    self.product.entities.forEach( onEachEntity );
    return null;
  })

  return ready;

  function onEachEntity( entity )
  {
    if( entity.typeGet() !== 'function' )
    return;

    resultMap.perFileMap[ entity.filePath ].documented += 1;
    resultMap.documentedCount += 1;
  }
}

//

function _performCoverageNumbersTotal( resultMap )
{
  let self = this;
  let provider =  self.provider;
  let path = provider.path;

  let sys = _.introspector.System
  ({ 
    defaultParserClass : _.introspector.Parser.JsTreeSitter 
  });
    
  let allowedParentTypesOfAnonymousFunction = 
  [ 
    'assignment_expression', /* var a = function ... */
    'variable_declarator', /* a.b = function ... */
    'pair' /* { b : function ... } */,
    'member_expression'
  ];

  _.assert( _.argumentsArray.like( self.parsedFiles ) );

  let cons = self.parsedFiles.map( onEachFile );
  let done = _.Consequence.AndKeep( ... cons );
  return done;

  //

  function onEachFile( filePath )
  {
    return provider.fileRead({ filePath, sync : 0 })
    .then( ( sourceCode ) => 
    {
      let file = _.introspector.File({ data : sourceCode, sys });
      file.refine();
      let routines = file.product.byType.gRoutine;

      if( !routines )
      return null;
      if( !routines.length )
      return null;

      file.product.byType.gRoutine.each( ( node ) => onEachRoutine( node, filePath ) );

      return null;
    })
  }

  //

  function onEachRoutine( node, filePath )
  {
    if( node.parent ) 
    {
      /* if function is an argument */
      if( node.parent.type === 'arguments' )
      return;

      /* if function is self invoking */
      if( node.parent.type === 'parenthesized_expression' )
      if( node.parent.parent.type === 'call_expression' )
      return;
    }

    /* if function is anonymous */
    if( !node.nameNode )
    {
      if( !node.parent )
      return;

      if( node.type === 'arrow_function' )
      return;

      if( !_.longHas( allowedParentTypesOfAnonymousFunction, node.parent.type ) )
      return;
    }

    /* if function is an argument */
    let argumentsNode = node.closest( 'arguments' );
    if( argumentsNode && argumentsNode.startIndex < node.startIndex  )
    return;

    resultMap.perFileMap[ filePath ].total += 1;
    resultMap.totalCount += 1;
  }
}

//

function modulesInstall()
{
  let self = this;

  return _.process.start
  ({
    execPath : 'npm i',
    currentPath : self.outPath,
    sync : 1,
    deasync : 1
  })
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
    filter : { recursive : 2 },
    withTerminals : 1,
    withDirs : 0,
    withStem : 0,
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
    filter : { recursive : 1 },
    withTerminals : 0,
    withDirs : 1,
    withStem : 0,
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

let commonOptionsNames =
{
  verbosity : 'verbosity',
  v : 'verbosity',
  inacurate : 'inacurate',
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
  inPath : 'inPath',
  outPath : 'outPath',
  docPath : 'docPath',
  doc : 'docPath',
  out : 'outPath',
  conceptsPath : 'conceptsPath',
  concepts : 'conceptsPath',
  tutorialsPath : 'tutorialsPath',
  tutorials : 'tutorialsPath',
  lintPath : 'lintPath',
  testingPath : 'testingPath',
  readmePath : 'readmePath'
}

let optionsNamesMap = _.props.extend( null, commonOptionsNames, pathOptionsNames );

// --
// relations
// --

let Composes =
{

  verbosity : 1,

  inacurate : 0,

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

  includeAny : '.+\\.(js|ss|s)(doc)?$',
  excludeAny : '(^|\\/|\\.)(-|node_modules|3rd|external|test)',

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
  templateData : _.define.own( {} ),

  sourceFiles : _.define.own({}),
  parsedFiles : null,

  outReferencePath : '{{outPath}}/reference',
  outDocPath : '{{outPath}}/doc',

  will : null,
  module : null,
  submodules : null,

  //

  product : null
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

  form,

  _optionsFromWillRead,
  _optionsFromArgsRead,
  _optionsFromArgsApply,
  _pathsResolve,

  //

  sourceFilesParse,
  markdownGenerate,

  //

  performDocsifyApp,
  performDoc,
  performConcepts,
  performTutorials,
  performLintReports,
  performTestingReports,
  performCoverageReport,
  _performCoverageNumbersDocumented,
  _performCoverageNumbersTotal,

  modulesInstall,

  //

  _indexForModule,
  _indexForSubmodules,
  _reportsIndexForSubmodules,
  _indexForSubmodulesFilesBased,
  _indexForDirectory,

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
_.Verbal.mixin( Self );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;
_.docgen[ Self.shortName ] = Self;

if( typeof module !== 'undefined' )
require( './IncludeMid.s' );

})();
