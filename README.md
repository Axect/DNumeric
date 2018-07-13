# DNumeric

D Numeric Library with R Syntax

## Import

Add next line to your dub.json

```json
"dnumeric": "~>0.1.0"
```

or dub.sdl

```sdl
dependency "dnumeric" version="~>0.1.0"
```

## Usage

```d
// Vector Declaration
auto a = Vector(1,10) // Vector [1,2,3,4,5,6,7,8,9,10]
auto b = Vector(1,10,2) // Vector [1,3,5,7,9]
auto c = Vector([1,2,3,5,8])

// Operation with Vector
b.dot(a) // Inner product
b + c // Addition (also subtraction)
b * c // Multiplication (also division)

// Matrix Declartion
auto m = Matrix([1,2,3,4], 2, 2) // Matrix [[1,3],[2,4]]
auto n = Matrix([1,2,3,4], 2, 2, false) // Matrix [[1,2],[3,4]]
auto o = Matrix([[1,2],[3,4]])
auto p = Matrix(Vector([1,2,3,4]), 2, 2, false)

// Utils
m.det // Determinant
auto res = m.lu // lu decomposition
res[0] // l matrix
res[1] // u matrix
```