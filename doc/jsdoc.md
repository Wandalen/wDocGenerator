## Examples of jdoc annotations that produce good markdown

### How specify a class:

Tags used:

* [@class](http://usejsdoc.org/tags-class.html)
* [@classdesc](http://usejsdoc.org/tags-classdesc.html)

``` javascript
/**
 * Description of class constructor
 * @classdesc Description of class as single entity
 * @class TestClass
 */
function TestClass()
{
}
```

---

### How to specify a class member:

Tags used:

* [@memberof](http://usejsdoc.org/tags-memberof.html)
* [@function](http://usejsdoc.org/tags-function.html)

``` javascript
/**
 * Description of a function
 * @function testFunc
 * @memberof TestClass
 */

function testFunc(){}
```

---

### How to specify a element as an instance member of its parent:

Tags used:

* [@memberof](http://usejsdoc.org/tags-memberof.html)
* [@instance](http://usejsdoc.org/tags-instance.html)
* [@function](http://usejsdoc.org/tags-function.html)

``` javascript
/**
 * Description of a function
 * @function testFunc
 * @memberof TestClass
 * @instance
 */

function testFunc(){}
```

Other tags that specify membership:
* [@global](http://usejsdoc.org/tags-global.html)
* [@inner](http://usejsdoc.org/tags-inner.html)
* [@static](http://usejsdoc.org/tags-static.html)

---

### Other way to define a membership using only memberof:

Tags used:

* [@memberof](http://usejsdoc.org/tags-memberof.html)
* [@function](http://usejsdoc.org/tags-function.html)

``` javascript
/**
 * Description of a function as instance member
 * @function testFunc1
 * @memberof TestClass#
 */

function testFunc1(){}

```

``` javascript
/**
 * Description of a function as static member
 * @function testFunc2
 * @memberof TestClass
 */

function testFunc2(){}
```

``` javascript
/**
 * Description of a function as inner member
 * @function testFunc3
 * @memberof TestClass~
 */

function testFunc3(){}
```

---

### How to refer to another symbol:

In this case function `testFunc2` refers to instance member function `testFunc1`.

[More information about namepaths](http://usejsdoc.org/about-namepaths.html).

Tags used:

* [@memberof](http://usejsdoc.org/tags-memberof.html)
* [@function](http://usejsdoc.org/tags-function.html)
* [@link](http://usejsdoc.org/tags-link.html)

``` javascript
/**
 * Description of a function as instance member
 * @function testFunc1
 * @memberof TestClass#
 */

function testFunc1(){}

/**
 * This function is like {@link TestClass#testFunc1}, but...
 * @function testFunc2
 * @memberof TestClass#
 */

function testFunc2(){}
```

---

### How to specify arguments and return type:

Tags used:

* [@function](http://usejsdoc.org/tags-function.html)
* [@param](http://usejsdoc.org/tags-param.html)
* [@returns](http://usejsdoc.org/tags-returns.html)

``` javascript
/**
 * Description of a function
 * @param {Type} src Description of argument
 * @param {Type} dst Description of argument
 * @returns {Type} What function returns
 * @function testFunc
 */

function testFunc( src, dst ){}

```

---

### How to define options map as argument:

Tags used:

* [@function](http://usejsdoc.org/tags-function.html)
* [@param](http://usejsdoc.org/tags-param.html)

``` javascript
/**
 * Description of a function
 * @param {Object} o Options map
 * @param {Type} o.src Description of option
 * @param {Type} o.dst Description of option
 * @param {Type} [o.optional=defaultValue] Description of option with default value
 * @returns {Type} What function returns
 * @function testFunc
 */

function testFunc( o ){}

```

---

### How to define a module

Tags used:

* [@module](http://usejsdoc.org/tags-module.html)

``` javascript

/**
 * Description of test module
 * @module TestModule
 */

```

---

### How to define a class as member of a module

Tags used:

* [@module](http://usejsdoc.org/tags-module.html)
* [@class](http://usejsdoc.org/tags-class.html)
* [@classdesc](http://usejsdoc.org/tags-classdesc.html)
* [@memberof](http://usejsdoc.org/tags-memberof.html)

``` javascript

/**
 * Description of test module
 * @module TestModule
 */

 /**
 * Description of class constructor
 * @classdesc Description of class as single entity
 * @class TestClass
 * @memberof module:TestModule
 */
function TestClass(){}

```

---

### How to define a class with members as part of a module

Tags used:

* [@module](http://usejsdoc.org/tags-module.html)
* [@class](http://usejsdoc.org/tags-class.html)
* [@classdesc](http://usejsdoc.org/tags-classdesc.html)
* [@function](http://usejsdoc.org/tags-classdesc.html)
* [@memberof](http://usejsdoc.org/tags-memberof.html)

``` javascript

/**
 * Description of test module
 * @module TestModule
 */

 /**
 * Description of class constructor
 * @classdesc Description of class as single entity
 * @class TestClass
 * @memberof module:TestModule
 */
function TestClass(){}

/**
 * Description of a function as instance member of a class
 * @function TestFunc
 * @memberof module:TestModule.TestClass#
 */
function TestFunc(){}

```
