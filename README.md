# DNumeric

D Numeric Library with R Syntax

## Import

Add next line to your dub.json

```json
"dnumeric": "~>0.6.1"
```

or dub.sdl

```sdl
dependency "dnumeric" version="~>0.6.1"
```

* Caution : After `0.6.0`, there are lots of changes.

## Usage

### 1. Matrix Declaration

```r
# R
a = matrix(c(1,2,3,4), 2, 2, T)
```

```d
// DNumeric
import dnum.matrix;

auto a = matrix([1,2,3,4], 2, 2, true);
```

### 2. Print

```r
# R
a = matrix(1:4, 2, 2, T)
print(a)
```

```d
// DNumeric
import dnum.matrix;
import std.stdio : writeln;

auto a = matrix([1,2,3,4], 2, 2, true);
a.writeln;
```