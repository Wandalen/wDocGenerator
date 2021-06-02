( function _Ext_test_s_( )
{

'use strict';

if( typeof module !== 'undefined' )
{

  const _ = require( 'Tools' );
  _.include( 'wTesting' );

  require( './../docgen/MainTop.s' );

}

const _ = _global_.wTools;

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

  a.find = a.fileProvider.filesFinder
  ({
    withTerminals : 1,
    withDirs : 1,
    withStem : 1,
    allowingMissed : 1,
    maskPreset : 0,
    outputFormat : 'relative',
    filter :
    {
      recursive : 2,
      maskAll :
      {
        excludeAny : [ /(^|\/)\.git($|\/)/, /(^|\/)\+/ ],
      },
      maskTransientAll :
      {
        excludeAny : [ /(^|\/)\.git($|\/)/, /(^|\/)\+/ ],
      },
    },
  });

  return a;
}

// --
// complex
// --

function generateReferenceTrivial( test )
{
  let context = this;
  let a = context.assetFor( test, 'generate-reference' );
  a.reflect();

  a.ready.then( () =>
  {
    test.case = 'generate reference for a single file';
    return null;
  });

  /* */

  a.appStart( `.generate.reference ${a.abs( 'File1.js' )}` );
  a.ready.then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );

    let files = a.find
    ({
      filePath : a.abs( '.' ),
      withStem : 0
    });

    let expectedFiles =
    [
      './File1.js',
      './out',
      './out/doc',
      './out/doc/Reference.md',
      './out/doc/reference',
      './out/doc/reference/namespace',
      './out/doc/reference/namespace/file1.md'
    ];

    test.identical( files, expectedFiles );

    return null;
  });

  /* - */

  return a.ready;
}

generateReferenceTrivial.timeOut = 30000;

//

function coverageReport( test )
{
  let context = this;
  let a = context.assetFor( test, 'coverage' );
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
  let a = context.assetFor( test, 'coverage' );
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

const Proto =
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

    generateReferenceTrivial,
    coverageReport,
    coverageReportThrowing

  },

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
