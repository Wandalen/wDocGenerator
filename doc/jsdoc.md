## Examples of jdoc annotations that produce good markdown

### Class

``` javascript

/**
 * Description of class constructor
 * @classdesc Description of class as single entity
 * @class TestClass
 * @param {Object} o - Options map
 */
function TestClass( o )
{
}

/**
 * Instance method of TestClass
 * @function routine
 * @memberof TestClass
 * @param {Object} o - Options map
 */

function routine( o )
{
}

```

### Module with class

When class is a part of a module:

* @memberof tag for a class as part of a module should contain name of a module in format: `module:name_of_a_module`.

* @memberof tag for a member as part of a class should contain both names of a module and a class in format: `module:module_name.class_name`.

  For example, `module:TestModule.TestClassA#` where :

  * `TestModule` in a name of module;
  * `TestClassA` in a name of class;
  * "." means that `TestClassA` is a static member of a module `TestModule`;
  * "#" at the end says that current member of class `TestClassA` is a instance member;

  [More info about namepaths in jsdoc](http://usejsdoc.org/about-namepaths.html#namepaths-in-jsdoc-3)

``` javascript
/**
 * Description of test module
 * @module TestModule
 */

/**
 * Description of class constructor
 * @classdesc Description of class as member of the module
 * @class TestClassA
 * @memberof module:TestModule
 * @param {object} o - Options map
 */
function TestClassA( o )
{
}

/**
 * Description of a routine
 * @function a
 * @memberof module:TestModule.TestClassA#
 * @param {Object} o - Options map
 */
function a( o )
{
}

```