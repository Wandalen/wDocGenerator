(function _file1_js()
{

  /**
   * @namespace file1
  */

  /**
   * @function a
   * @namespace file1
   */
  function a(){}; //counted in total

  //

  /**
   * @function b
   * @namespace file1
  */
  let b = function (){};//counted in total

  //

  ([]).forEach( () => {} )

  //

  b({ c : () => {} })

  //

  b({ d : function d() {} })

  //

  (function(){})()

  //

  let namespace = //counted in total
  {
    /**
     * @function e
     * @namespace file1
    */
    e : function e() 
    {
    }
  }
})()