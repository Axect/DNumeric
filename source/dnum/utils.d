module dnum.utils;

import dnum.vector;

// =============================================================================
// Vectorize
// =============================================================================
/++
  Vectorize - Like R Function
+/
Vector delegate(Vector) Vectorize(double delegate(double) f) {
  return (v => v.fmap(f));
}

/++
  VectorizeM - function to Matrix function
+/
Matrix delegate(Matrix) VectorizeM(double delegate(double) f) {
  return (v => Matrix(v.val.fmap(f), v.row, v.col, v.byRow));
}