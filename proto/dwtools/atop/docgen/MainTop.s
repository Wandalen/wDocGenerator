( function _MainBase_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './MainBase.s' );

}

//

let _ = wTools;
let Parent = null;
let Self = _.DocGenerator;

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

  let appArgs = _.appArgs();
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

  self.templateDataRead();

  if( self.docsify )
  self.docsifyAppBaseCopy();

  self.markdownGenerate();

  if( self.includingManuals )
  self.prepareManuals();

  if( self.includingTutorials )
  self.prepareTutorials();
}

//

function commandGenerateMarkdown( e )
{
  let self = this;

  self.form( e );
  self.templateDataRead();
  self.markdownGenerate();
}

//

function commandsMake()
{
  let self = this;

  _.assert( _.instanceIs( self ) );
  _.assert( arguments.length === 0 );

  let commands =
  {

    'help' :                    { e : _.routineJoin( self, self.commandHelp ),                  h : 'Get help.' },
    // 'set' :                  { e : _.routineJoin( self, self.commandSet ),                   h : 'Command set.' },
    'generate' :                { e : _.routineJoin( self, self.commandGenerate ),              h : 'Generates markdown files and docsify.' },
    'generate markdown' :       { e : _.routineJoin( self, self.commandGenerateMarkdown ),      h : 'Generates only markdown files.' },
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
  commandGenerateMarkdown : commandGenerateMarkdown,

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
