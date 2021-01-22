( function _server_ss_()
{

'use strict';


let path = require( 'path' );
let fs = require( 'fs' );
let find = require( 'find-process' );
let port = 3333;

async function stopIfAlreadyRunning()
{
  let currentName = path.basename( process.argv[ 1 ] );
  var got = await find( 'port', port );
  var found = got.filter( ( e ) => e.cmd.indexOf( currentName ) !== -1 );
  if( found.length )
  {
    try
    {
      process.kill( found[ 0 ].pid );
    }
    catch
    {
    }
  }
}


/*  */

function serverStart()
{
  let express = require('express');
  let app = express();

  let cachedResults = Object.create( null );
  let searchIndexPath = path.join( __dirname, 'searchIndex.json' );

  let index;

  if( fs.existsSync( searchIndexPath ) )
  {
    index = fs.readFileSync( searchIndexPath );
    index = JSON.parse( index );
  }

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

stopIfAlreadyRunning()
.then( () => serverStart() )

})();
