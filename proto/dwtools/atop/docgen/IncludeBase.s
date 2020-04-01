( function _IncludeBase_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wCopyable' );
  _.include( 'wFiles' );
  _.include( 'wTemplateTreeEnvironment' );
  _.include( 'wTemplateTreeResolver' );
  _.include( 'wSelectorExtra' );
  _.include( 'wAppBasic' );
  _.include( 'wConsequence' );

  _.include( 'wCommandsAggregator' );
  _.include( 'wCommandsConfig' );

  require( 'willbe' );
}

})();
