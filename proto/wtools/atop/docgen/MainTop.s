( function _MainBase_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  require( './MainBase.s' );

}

//

const _ = _global_.wTools;
const Parent = null;
const Self = _.docgen.DocGenerator;

// --
// exec
// --

function Exec()
{
  let generator = new this.Self();
  return generator.exec();
}

//

function exec()
{

  _.assert( arguments.length === 0 );

  let self = this;

  let appArgs = _.process.input();
  let ca = self.commandsMake();

  return ca.programPerform({ program : appArgs.original });
  // return ca.appArgsPerform({ appArgs });
}

//

function commandHelp( e )
{
  let self = this;
  let ca = e.aggregator;

  ca._commandHelp( e );

  // if( !e.commandName )
  // {
  //   _.assert( 0 );
  // }

}

//

function commandGenerate( e )
{
  let self = this;

  self.form( e );

  let ready = new _.Consequence().take( null );

  if( self.docsify )
  ready.then( () => self.performDocsifyApp() )

  ready.then( () => self.markdownGenerate() )

  if( self.includingConcepts || self.includingTutorials )
  ready.then( () => self.performDoc() )

  if( self.includingConcepts )
  ready.then( () => self.performConcepts() )

  if( self.includingTutorials )
  ready.then( () => self.performTutorials() )

  if( self.includingLintReports )
  ready.then( () => self.performLintReports() )

  if( self.includingTestingReports )
  ready.then( () => self.performTestingReports() )

  ready.then( () => self.modulesInstall() )

  return ready;
}

var command = commandGenerate.command = Object.create( null );
command.properties =
{
  docPath : 'Path to directory that contains documentation. It can be directory with documentation of single or multiple modules. In second case docs of each module should be located in subdirectry with name of that module. Default: "doc" ',
  tutorialsPath : 'Path to tutorials index file or directory that contains tutorials and index file. Default: "out/doc/Doc"',
  conceptsPath : 'Path to concepts index file or directory that contains tutorials and index file. Default: "out/doc/Doc"',
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  outPath : 'Path where to save result of generation. Default : "out/doc"',
  readmePath : 'Path to README.md file that will used as homepage.',
  includingSubmodules : 'Uses will file to generate tutorials/concepts for submodules of current module. Ignores tutorialsPath,conceptsPath, docPath from options, because takes this values from will files. Default : false.',
  // willModulePath : 'Path to root of the module. Is used by generator when `useWillForManuals` is enabled.',
  includingConcepts : 'Generates concepts and index file if enabled. Default : 1.',
  includingTutorials : 'Generates tutorials and index file if enabled. Default : 1.',
  docsify : 'Prepares docsify app if enabled. Default : 1',
  v : 'Verbosity level. Default:1.',
  inacurate : 'Allows parser to extract doc comments using regexp. Default:0'
}

//

function commandGenerateReference( e )
{
  let self = this;

  self.form( e );

  let ready = new _.Consequence().take( null );

  ready.then( () => self.markdownGenerate() )

  return ready;
}

var command = commandGenerateReference.command = Object.create( null );
command.properties =
{
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  referencePath : 'Path to directory with jsdoc annotated source code. Default : "proto"',
  outPath : 'Path where to generate reference. Default : out/doc',
  v : 'Verbosity level. Default:1.',
  inacurate : 'Allows parser to extract doc comments using regexp. Default:0'
}


//

function commandGenerateDocsify( e )
{
  let self = this;

  self.form( e );

  let ready = new _.Consequence().take( null );

  ready.then( () => self.performDocsifyApp() );
  ready.then( () => self.modulesInstall() );

  return ready;
}

var command = commandGenerateDocsify.command = Object.create( null );
command.properties =
{
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  outPath : 'Path where to save docsify app. Default : "out/doc"',
  readmePath : 'Path to README.md file that will used as homepage.',
  v : 'Verbosity level. Default:1.'
}

//

function commandGenerateTutorials( e )
{
  let self = this;
  let path = self.provider.path;

  self.form( e );

  if( e.instructionArgument && !e.propertiesMap.tutorialsPath )
  self.tutorialsPath = path.resolve( path.current(), self.inPath, e.instructionArgument );

  let ready = new _.Consequence().take( null );

  ready.then( () => self.performDoc() );
  ready.then( () => self.performTutorials() );

  return ready;
}

var command = commandGenerateTutorials.command = Object.create( null );
command.properties =
{
  docPath : 'Path to directory that contains documentation. It can be directory with documentation of single or multiple modules. In second case docs of each module should be located in subdirectry with name of that module. Default: "doc" ',
  tutorialsPath : 'Path to tutorials index file or directory that contains tutorials and index file. Default: "out/doc/Doc"',
  readmePath : 'Path to README.md file that will used as homepage.',
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  outPath : 'Path where to save result of generation. Default : "out/doc"',
  includingSubmodules : 'Uses will file to generate tutorials/concepts for submodules of current module. Ignores tutorialsPath,conceptsPath, docPath from options, because takes this values from will files. Default : false.',
  // willModulePath : 'Path to root of the module. Is used by generator when `useWillForManuals` is enabled.',
  v : 'Verbosity level. Default:1.'
}

//

function commandGenerateConcepts( e )
{
  let self = this;
  let path = self.provider.path;

  self.form( e );

  if( e.instructionArgument && !e.propertiesMap.conceptsPath )
  self.conceptsPath = path.resolve( path.current(), self.inPath, e.instructionArgument );

  let ready = new _.Consequence().take( null );

  ready.then( () => self.performDoc() );
  ready.then( () => self.performConcepts() );

  return ready;
}

var command = commandGenerateConcepts.command = Object.create( null );
command.properties =
{
  docPath : 'Path to directory that contains documentation. It can be directory with documentation of single or multiple modules. In second case docs of each module should be located in subdirectry with name of that module. Default: "doc" ',
  conceptsPath : 'Path to concepts index file or directory that contains tutorials and index file. Default: "out/doc/Doc"',
  readmePath : 'Path to README.md file that will used as homepage.',
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  outPath : 'Path where to save result of generation. Default : "out/doc"',
  includingSubmodules : 'Uses will file to generate tutorials/concepts for submodules of current module. Ignores tutorialsPath,conceptsPath, docPath from options, because takes this values from will files. Default : false.',
  // willModulePath : 'Path to root of the module. Is used by generator when `useWillForManuals` is enabled.',
  v : 'Verbosity level. Default:1.'
}

//

function commandGenerateLintReports( e )
{
  let self = this;
  let path = self.provider.path;

  self.form( e );

  if( e.instructionArgument && !e.propertiesMap.lintPath )
  self.lintPath = path.resolve( path.current(), self.inPath, e.instructionArgument );

  let ready = new _.Consequence().take( null );

  ready.then( () => self.performDoc() );
  ready.then( () => self.performLintReports() );

  return ready;
}

var command = commandGenerateLintReports.command = Object.create( null );
command.properties =
{
  docPath : 'Path to directory that contains documentation. It can be directory with documentation of single or multiple modules. In second case docs of each module should be located in subdirectry with name of that module. Default: "doc" ',
  readmePath : 'Path to README.md file that will used as homepage.',
  lintPath : 'Path to directory with eslint reports. Default: "doc/lint"',
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  outPath : 'Path where to save result of generation. Default : "out/doc"',
  includingSubmodules : 'Uses will file to generate tutorials/concepts for submodules of current module. Ignores tutorialsPath,conceptsPath, docPath from options, because takes this values from will files. Default : false.',
  // willModulePath : 'Path to root of the module. Is used by generator when `useWillForManuals` is enabled.',
  v : 'Verbosity level. Default:1.'
}

//

function commandGenerateTestingReports( e )
{
  let self = this;
  let path = self.provider.path;

  self.form( e );

  if( e.instructionArgument && !e.propertiesMap.testingPath )
  self.testingPath = path.resolve( path.current(), self.inPath, e.instructionArgument );

  let ready = new _.Consequence().take( null );

  ready.then( () => self.performDoc() );
  ready.then( () => self.performTestingReports() );

  return ready;
}

var command = commandGenerateTestingReports.command = Object.create( null );
command.properties =
{
  docPath : 'Path to directory that contains documentation. It can be directory with documentation of single or multiple modules. In second case docs of each module should be located in subdirectry with name of that module. Default: "doc" ',
  testingPath : 'Path to directory with testing reports. Default: "doc/testing"',
  readmePath : 'Path to README.md file that will used as homepage.',
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  outPath : 'Path where to save result of generation. Default : "out/doc"',
  includingSubmodules : 'Uses will file to generate tutorials/concepts for submodules of current module. Ignores tutorialsPath,conceptsPath, docPath from options, because takes this values from will files. Default : false.',
  // willModulePath : 'Path to root of the module. Is used by generator when `useWillForManuals` is enabled.',
  v : 'Verbosity level. Default:1.'
}

//

function commandGenerateCoverageReport( e )
{
  let self = this;
  let path = self.provider.path;

  self.form( e );

  if( e.instructionArgument && !e.propertiesMap.testingPath )
  self.testingPath = path.resolve( path.current(), self.inPath, e.instructionArgument );

  let ready = new _.Consequence().take( null );

  ready.then( () => self.performCoverageReport() );

  return ready;
}

var command = commandGenerateCoverageReport.command = Object.create( null );
command.properties =
{
  referencePath : 'Path to directory with jsdoc annotated source code. Default : "proto"',
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  // willModulePath : 'Path to root of the module. Is used by generator when `useWillForManuals` is enabled.',
  v : 'Verbosity level. Default:1.'
}

//

function commandView( e )
{
  let self = this;
  let provider = self.provider;
  let path = provider.path;

  self.form( e );

  if( e.instructionArgument && !e.propertiesMap.outPath )
  self.outPath = path.resolve( path.current(), self.inPath, e.instructionArgument );

  let serverScriptPath = path.join( self.outPath, 'server.ss' );

  _.sure( provider.fileExists( serverScriptPath ), 'Server script does not exist at:', serverScriptPath );

  _.process.startNjs( serverScriptPath );

}

var command = commandView.command = Object.create( null );
command.properties =
{
  outPath : 'Path to directory with generated documentation. Default : "out/doc"',
}

//

function commandsMake()
{
  let self = this;

  _.assert( _.instanceIs( self ) );
  _.assert( arguments.length === 0 );

  let commands =
  {

    'help' :                      { ro : _.routineJoin( self, self.commandHelp ),                h : 'Get help.' },
    'generate' :                  { ro : _.routineJoin( self, self.commandGenerate ),            h : 'Generates markdown files and docsify.' },
    'generate docsify' :          { ro : _.routineJoin( self, self.commandGenerateDocsify ),     h : 'Copies built docsify app into root of `outPath` directory.' },
    'generate reference' :        { ro : _.routineJoin( self, self.commandGenerateReference ),    h : 'Generates *.md files from jsdoc annotated js files.' },
    'generate tutorials' :        { ro : _.routineJoin( self, self.commandGenerateTutorials ),   h : 'Aggregates tutorials and creates index file.' },
    'generate concepts' :         { ro : _.routineJoin( self, self.commandGenerateConcepts ),    h : 'Aggregates concepts and creates index file.' },
    'generate lint' :             { ro : _.routineJoin( self, self.commandGenerateLintReports ),    h : 'Aggregates eslint reports and creates index file.' },
    'generate testing' :          { ro : _.routineJoin( self, self.commandGenerateTestingReports ),    h : 'Aggregates testing reports and creates index file.' },
    'generate coverage report' :  { ro : _.routineJoin( self, self.commandGenerateCoverageReport ),    h : 'Generates doc coverage report.' },
    'view' :                      { ro : _.routineJoin( self, self.commandView ),    h : 'Launches the doc.' },
  }

  let ca = _.CommandsAggregator
  ({
    basePath : self.provider.path.current(),
    commands,
    commandPrefix : 'node ',
    logger : self.logger,
  })

  _.assert( ca.logger === self.logger );
  // _.assert( ca.verbosity === self.verbosity );
  _.assert( ca.logger.verbosity === self.verbosity );

  ca.form();

  return ca;
}

// --
// relations
// --

let Composes =
{
}

let Aggregates =
{
}

let Associates =
{
}

let Restricts =
{
}

let Statics =
{
  Exec
}

let Forbids =
{
}

// --
// declare
// --

let Extension =
{

  Exec,
  exec,

  commandHelp,

  commandGenerate,
  commandGenerateReference,
  commandGenerateDocsify,
  commandGenerateTutorials,
  commandGenerateConcepts,
  commandGenerateLintReports,
  commandGenerateTestingReports,
  commandGenerateCoverageReport,
  commandView,

  commandsMake,

  // relation

  Composes,
  Associates,
  Restricts,
  Statics,
  Forbids,

}

//

_.classExtend
({
  cls : Self,
  extend : Extension,
});

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;
wTools[ Self.shortName ] = Self;

if( !module.parent )
Self.Exec();

})();
