( function _MainBase_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './MainBase.s' );

}

//

let _ = wTools;
let Parent = null;
let Self = _.docgen.DocGenerator;

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

  let appArgs = _.process.args();
  let ca = self.commandsMake();

  return ca.appArgsPerform({ appArgs : appArgs });
}

//

function commandHelp( e )
{
  let self = this;
  let ca = e.ca;

  ca._commandHelp( e );

  if( !e.subject )
  {
    _.assert( 0 );
  }

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

commandGenerate.commandProperties =
{
  docPath : 'Path to directory that contains documentation. It can be directory with documentation of single or multiple modules. In second case docs of each module should be located in subdirectry with name of that module. Default: "doc" ',
  tutorialsPath : 'Path to tutorials index file or directory that contains tutorials and index file. Default: "out/doc/Doc"',
  conceptsPath : 'Path to concepts index file or directory that contains tutorials and index file. Default: "out/doc/Doc"',
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  outPath : 'Path where to save result of generation. Default : "out/doc"',
  readmePath : 'Path to README.md file that will used as homepage.',
  includingSubmodules: 'Uses will file to generate tutorials/concepts for submodules of current module. Ignores tutorialsPath,conceptsPath, docPath from options, because takes this values from will files. Default : false.',
  // willModulePath : 'Path to root of the module. Is used by generator when `useWillForManuals` is enabled.',
  includingConcepts : 'Generates concepts and index file if enabled. Default : 1.',
  includingTutorials : 'Generates tutorials and index file if enabled. Default : 1.',
  docsify : 'Prepares docsify app if enabled. Default : 1',
  v : 'Verbosity level. Default:1.'
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

commandGenerateReference.commandProperties =
{
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  referencePath : 'Path to directory with jsdoc annotated source code. Default : "proto"',
  outPath : 'Path where to generate reference. Default : out/doc',
  v : 'Verbosity level. Default:1.'
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

commandGenerateDocsify.commandProperties =
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

  if( e.argument && !e.propertiesMap.tutorialsPath )
  self.tutorialsPath = path.resolve( path.current(), self.inPath, e.argument );

  let ready = new _.Consequence().take( null );

  ready.then( () => self.performDoc() );
  ready.then( () => self.performTutorials() );

  return ready;
}

commandGenerateTutorials.commandProperties =
{
  docPath : 'Path to directory that contains documentation. It can be directory with documentation of single or multiple modules. In second case docs of each module should be located in subdirectry with name of that module. Default: "doc" ',
  tutorialsPath : 'Path to tutorials index file or directory that contains tutorials and index file. Default: "out/doc/Doc"',
  readmePath : 'Path to README.md file that will used as homepage.',
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  outPath : 'Path where to save result of generation. Default : "out/doc"',
  includingSubmodules: 'Uses will file to generate tutorials/concepts for submodules of current module. Ignores tutorialsPath,conceptsPath, docPath from options, because takes this values from will files. Default : false.',
  // willModulePath : 'Path to root of the module. Is used by generator when `useWillForManuals` is enabled.',
  v : 'Verbosity level. Default:1.'
}

//

function commandGenerateConcepts( e )
{
  let self = this;
  let path = self.provider.path;

  self.form( e );

  if( e.argument && !e.propertiesMap.conceptsPath )
  self.conceptsPath = path.resolve( path.current(), self.inPath, e.argument );

  let ready = new _.Consequence().take( null );

  ready.then( () => self.performDoc() );
  ready.then( () => self.performConcepts() );

  return ready;
}

commandGenerateConcepts.commandProperties =
{
  docPath : 'Path to directory that contains documentation. It can be directory with documentation of single or multiple modules. In second case docs of each module should be located in subdirectry with name of that module. Default: "doc" ',
  conceptsPath : 'Path to concepts index file or directory that contains tutorials and index file. Default: "out/doc/Doc"',
  readmePath : 'Path to README.md file that will used as homepage.',
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  outPath : 'Path where to save result of generation. Default : "out/doc"',
  includingSubmodules: 'Uses will file to generate tutorials/concepts for submodules of current module. Ignores tutorialsPath,conceptsPath, docPath from options, because takes this values from will files. Default : false.',
  // willModulePath : 'Path to root of the module. Is used by generator when `useWillForManuals` is enabled.',
  v : 'Verbosity level. Default:1.'
}

function commandGenerateLintReports( e )
{
  let self = this;
  let path = self.provider.path;

  self.form( e );

  if( e.argument && !e.propertiesMap.lintPath )
  self.lintPath = path.resolve( path.current(), self.inPath, e.argument );

  let ready = new _.Consequence().take( null );

  ready.then( () => self.performDoc() );
  ready.then( () => self.performLintReports() );

  return ready;
}

commandGenerateLintReports.commandProperties =
{
  docPath : 'Path to directory that contains documentation. It can be directory with documentation of single or multiple modules. In second case docs of each module should be located in subdirectry with name of that module. Default: "doc" ',
  readmePath : 'Path to README.md file that will used as homepage.',
  lintPath : 'Path to directory with eslint reports. Default: "doc/lint"',
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  outPath : 'Path where to save result of generation. Default : "out/doc"',
  includingSubmodules: 'Uses will file to generate tutorials/concepts for submodules of current module. Ignores tutorialsPath,conceptsPath, docPath from options, because takes this values from will files. Default : false.',
  // willModulePath : 'Path to root of the module. Is used by generator when `useWillForManuals` is enabled.',
  v : 'Verbosity level. Default:1.'
}

function commandGenerateTestingReports( e )
{
  let self = this;
  let path = self.provider.path;

  self.form( e );

  if( e.argument && !e.propertiesMap.testingPath )
  self.testingPath = path.resolve( path.current(), self.inPath, e.argument );

  let ready = new _.Consequence().take( null );

  ready.then( () => self.performDoc() );
  ready.then( () => self.performTestingReports() );

  return ready;
}

commandGenerateLintReports.commandProperties =
{
  docPath : 'Path to directory that contains documentation. It can be directory with documentation of single or multiple modules. In second case docs of each module should be located in subdirectry with name of that module. Default: "doc" ',
  testingPath : 'Path to directory with testing reports. Default: "doc/testing"',
  readmePath : 'Path to README.md file that will used as homepage.',
  inPath : 'Prefix path. This path is prepended to each *path option. Default : "."',
  outPath : 'Path where to save result of generation. Default : "out/doc"',
  includingSubmodules: 'Uses will file to generate tutorials/concepts for submodules of current module. Ignores tutorialsPath,conceptsPath, docPath from options, because takes this values from will files. Default : false.',
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

  if( e.argument && !e.propertiesMap.outPath )
  self.outPath = path.resolve( path.current(), self.inPath, e.argument );

  let serverScriptPath = path.join( self.outPath, 'staticserver.ss' );

  _.sure( provider.fileExists( serverScriptPath ), 'Server script does not exist at:', serverScriptPath );

  _.shellNode( serverScriptPath );

}

commandView.commandProperties =
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

    'help' :                    { e : _.routineJoin( self, self.commandHelp ),                h : 'Get help.' },
    'generate' :                { e : _.routineJoin( self, self.commandGenerate ),            h : 'Generates markdown files and docsify.' },
    'generate docsify' :        { e : _.routineJoin( self, self.commandGenerateDocsify ),     h : 'Copies built docsify app into root of `outPath` directory.' },
    'generate reference' :      { e : _.routineJoin( self, self.commandGenerateReference ),    h : 'Generates *.md files from jsdoc annotated js files.' },
    'generate tutorials' :      { e : _.routineJoin( self, self.commandGenerateTutorials ),   h : 'Aggregates tutorials and creates index file.' },
    'generate concepts' :       { e : _.routineJoin( self, self.commandGenerateConcepts ),    h : 'Aggregates concepts and creates index file.' },
    'generate lint' :       { e : _.routineJoin( self, self.commandGenerateLintReports ),    h : 'Aggregates eslint reports and creates index file.' },
    'generate testing' :       { e : _.routineJoin( self, self.commandGenerateTestingReports ),    h : 'Aggregates testing reports and creates index file.' },
    'view' :                    { e : _.routineJoin( self, self.commandView ),    h : 'Launches the doc.' },
  }

  let ca = _.CommandsAggregator
  ({
    basePath : self.provider.path.current(),
    commands : commands,
    commandPrefix : 'node ',
    logger : self.logger,
  })

  _.assert( ca.logger === self.logger );
  _.assert( ca.verbosity === self.verbosity );

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
  Exec : Exec
}

let Forbids =
{
}

// --
// declare
// --

let Extend =
{

  Exec : Exec,
  exec : exec,

  commandHelp : commandHelp,

  commandGenerate : commandGenerate,
  commandGenerateReference : commandGenerateReference,
  commandGenerateDocsify: commandGenerateDocsify,
  commandGenerateTutorials: commandGenerateTutorials,
  commandGenerateConcepts: commandGenerateConcepts,
  commandGenerateLintReports: commandGenerateLintReports,
  commandGenerateTestingReports: commandGenerateTestingReports,
  commandView : commandView,

  commandsMake : commandsMake,

  // relation

  Composes : Composes,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Forbids : Forbids,

}

//

_.classExtend
({
  cls : Self,
  extend : Extend,
});

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;
wTools[ Self.shortName ] = Self;

if( !module.parent )
Self.Exec();

})();
