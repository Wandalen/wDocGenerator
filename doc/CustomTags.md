## Custom tags

Unsupported custom tags will be displayed in doc as regular tags without any adjustments.

List of custom tags that are supported by this module:

* @namespaces - allows to define several namespaces with common properties
* @memberof - allows to define entity as membe of several other entities

### Define multiple namespaces with same description and other tags

Values of `namespaces` tag should be separeted by a comma, values can be quoted.

```
/**
 *@summary Collection of functions for vector math
  @namespaces "wTools.avector","wTools.vectorAdapter"
  @memberof module:Tools/math/Vector
*/
```

### Define entity that is member of several entities

Values of `memberofs` tag should be separeted by a comma, values can be quoted.

```
/**
 * Routine assign() assigns the values of second argument to the vector {-dst-}.
 * @function assign
 * @memberofs module:Tools/math/Vector.wTools.avector,module:Tools/math/Vector.wTools.vectorAdapter
*/
```
