( function _IncludeBase_s_( )
{

'use strict';

if( typeof module !== 'undefined' )
{

  const _ = require( 'Tools' );

  _.include( 'wCopyable' );
  _.include( 'wFiles' );
  _.include( 'wTemplateTreeEnvironment' );
  _.include( 'wTemplateTreeResolver' );
  _.include( 'wSelectorExtra' );
  _.include( 'wProcess' );
  _.include( 'wConsequence' );

  _.include( 'wCommandsAggregator' );
  _.include( 'wCommandsConfig' );
  _.include( 'wCommandsConfig' );
  _.include( 'wDocParser' );
  _.include( 'wTranspile' );

  require( 'willbe' );
}

})();
