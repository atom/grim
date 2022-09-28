##### Atom and all repositories under Atom will be archived on December 15, 2022. Learn more in our [official announcement](https://github.blog/2022-06-08-sunsetting-atom/)
 # Grim
[![CI](https://github.com/atom/grim/actions/workflows/ci.yml/badge.svg)](https://github.com/atom/grim/actions/workflows/ci.yml)

Log deprecate calls

## Installing

```sh
npm install grim
```

## Usage

```javascript
Grim = require('grim')

function someOldMethod() {
  Grim.deprecate("Use theNewMethod instead.")
}
```

To view all calls to deprecated methods use `Grim.logDeprecations()` or get direct access to the deprecated calls by using `Grim.getDeprecations()`
