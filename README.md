# DNumeric

D Numeric Library with R Syntax

## Import

Add next line to your dub.json

```json
"dnumeric": "~>0.3.0"
```

or dub.sdl

```sdl
dependency "dnumeric" version="~>0.3.0"
```

## Usage

```d
import dnum.tensor;
import dnum.linalg;
import dnum.utils;

// Tensor Declaration
auto a = Tensor([1,2,3,4]); // Single row tensor
auto a = Tensor([1,2,3,4], Shape.Row) // Also row tensor
auto b = Tensor([1,2,3,4], Shape.Col); // Single column tensor
auto c = Tensor([[1,2],[3,4]]); // Two Dimensional Tensor

a.nrow.writeln; // The number of rows of a
b.ncol.writeln; // The number of cols of b
assert(a.nrow == b.ncol); // Same

a.transpose.writeln; // (== b)
c.transpose.writeln; // (== Tensor([[1,3],[2,4]]))

// Operation
-b.writeln; // Negation
(b + b).writeln; // Addition
(b - b).writeln; // Subtraction
(b * b).writeln; // Multiplication (component-wise)
(b / b).writeln; // Division
(b % b).writeln; // Matrix multiplication

// Linear Algebra
b.det.writeln; // Determinant (Using LU Decomposition)
b.inv.writeln; // Inverse (Using LU Decomposition)
b.lu[0].writeln; // LU Decomposition - L
b.lu[1].writeln; // LU Decomposition - U

// Utils
cbind(b, b).writeln; // Tensor([[1,2,1,2],[3,4,3,4]])
rbind(b, b).writeln; // Tensor([[1,2],[3,4],[1,2],[3,4]])
c.col(0).writeln; // Tensor([[1], [3]])
c.row(0).writeln; // Tensor([[1, 2]])
```
