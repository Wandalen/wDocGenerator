( function _Ext_test_s_( )
{

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );
  _.include( 'wTesting' );

  require( './../docgen/MainTop.s' );

}

let _ = _global_.wTools;

// --
// context
// --

function onSuiteBegin()
{
  let self = this;
  let path = _.fileProvider.path;

  self.suiteTempPath = path.tempOpen( path.join( __dirname, '../..' ), 'DocGenerator' );
  self.assetsOriginalPath = path.join( __dirname, '_asset' );
  self.appJsPath = path.resolve( __dirname, '../docgen/Exec' );
}

//

function onSuiteEnd()
{
  let self = this;
  let path = _.fileProvider.path;
  _.assert( _.strHas( self.suiteTempPath, '/DocGenerator-' ) )
  path.tempClose( self.suiteTempPath );
}

//

function assetFor( test, name )
{
  let context = this;
  if( !name )
  name = test.name;
  let a = test.assetFor( name );

  return a;
}

// --
// complex
// --


function coverageReport( test )
{
  let context = this;
  let a = test.assetFor( 'coverage' );
  a.reflect();

  a.ready.then( () => 
  {
    test.case = 'coverage report for single file';
    return null;
  })

  /* */

  a.appStart( `.generate.coverage.report ${a.abs( 'File1.js' )}` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '│coverageReport/File1.js        3 / 3           100%   │' ), 1 );
    test.identical( _.strCount( op.output, '│         Total                 3 / 3           100%   │' ), 1 );
    return null;
  })

  /* */

  a.appStart( `.generate.coverage.report inPath:${a.abs( '.' )} referencePath : File1.js` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '│coverageReport/File1.js        3 / 3           100%   │' ), 1 );
    test.identical( _.strCount( op.output, '│         Total                 3 / 3           100%   │' ), 1 );
    return null;
  })

  /* */

  a.appStart( `.generate.coverage.report inPath:${a.abs( '.' )} referencePath : [ File1.js ]` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '│coverageReport/File1.js        3 / 3           100%   │' ), 1 );
    test.identical( _.strCount( op.output, '│         Total                 3 / 3           100%   │' ), 1 );
    return null;
  })

  /* */

  a.ready.then( () => 
  {
    test.case = 'coverage report for directory';
    return null;
  })

  a.appStart( `.generate.coverage.report ${a.abs( '.' )}` )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '│coverageReport/File1.js        3 / 3           100%   │' ), 1 );
    test.identical( _.strCount( op.output, '│         Total                 3 / 3           100%   │' ), 1 );
    return null;
  })

  /* */

  return a.ready;
}

coverageReport.timeOut = 30000;

//

function coverageReportThrowing( test )
{
  let context = this;
  let a = test.assetFor( 'coverage' );
  a.reflect();

  /* */

  a.ready.then( () => 
  {
    test.case = 'missing file';
    return null;
  })

  a.appStartNonThrowing( `.generate.coverage.report ${a.abs( 'FileX.js' )}` )
  .then( ( op ) =>
  {
    test.notIdentical( op.exitCode, 0 );
    return null;
  })

  /* */

  return a.ready;
}

coverageReportThrowing.timeOut = 30000;

// --
// proto
// --

let Self =
{

  name : 'Tools.DocGenerator.Ext',
  silencing : 1,
  enabled : 1,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    suiteTempPath : null,
    assetsOriginalPath : null,
    appJsPath : null,

    assetFor

  },

  tests :
  {

    /* basic */

    coverageReport,
    coverageReportThrowing

  },

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
