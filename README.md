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
