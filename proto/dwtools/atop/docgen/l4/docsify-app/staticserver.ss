( function _StaticServer_ss_() {

'use strict';


if( typeof module !== 'undefined' )
{
  let _ = require( 'wFiles' );
}

let _ = _global_.wTools;
let path = _.path;
let provider = _.fileProvider;
let port = 3333;

/*  */

function stopIfAlreadyRunning()
{
  let find = require( 'find-process' );
  let currentName = _.path.fullName( process.argv[ 1 ] );
  var con = _.Consequence.From( find( 'port', port ) );
  var got = con.deasync();
  var found = got.filter( ( e ) => _.strHas( e.cmd, currentName ) );
  if( found.length )
  {
    _.assert( found.length === 1 );
    try
    {
      process.kill( found[ 0 ].pid );
    }
    catch
    {
    }
  }
}

//

function serverStart()
{
  let express = require('express');
  let app = express();

  let cachedResults = Object.create( null );
  let searchIndexPath = path.join( __dirname, 'searchIndex.json' );

  let index;

  if( provider.fileExists( searchIndexPath ) )
  index = provider.fileRead({ filePath : searchIndexPath, encoding : 'json' });

  app.use( express.static( __dirname ) );

  if( index )
  app.get( '/search', ( req, res ) =>
  {
    let result;
    let query = req.query.q;

    if( cachedResults[ query ] )
    {
      result = cachedResults[ query ];
    }
    else if( index[ query ] )
    {
      result =
      {
        results : [ index[ query ] ],
      }
    }
    else
    {
      let items = [];
      let maxItems = 10;

      var reg = new RegExp( query, 'i' );

      for( var k in index )
      {
        if( k.match( reg ) )
        {
          items.push( index[ k ] );
          if( items.length === maxItems )
          break;
        }
      }

      result =
      {
        results : items,
      }

      cachedResults[ query ] = result;
    }

    res.send( result );
  })

  app.listen( port );
  console.log( `Listening at http://localhost:${port}` );
  
}

/* */

stopIfAlreadyRunning();
serverStart();

})();