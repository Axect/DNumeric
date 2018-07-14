module dnum.stats;

import dnum.vector;
import std.random : Random, unpredictableSeed, uniform;

// =============================================================================
// Basic Statistics Tools
// =============================================================================
/++
  Sum of Vector
+/
pure double sum(Vector v) {
  double s = 0;
  foreach (e; v.comp) {
    s += e;
  }
  return s;
}

/++
  Mean of Vector
+/
pure double mean(Vector v) {
  double s = 0;
  double l = 0;
  foreach (e; v.comp) {
    l++;
    s += e;
  }
  return s / l;
}

/++
  Variance of Vector
+/
pure double var(Vector v) {
  double m = 0;
  double l = 0;
  double va = 0;
  foreach (e; v.comp) {
    l++;
    m += e;
    va += e ^^ 2;
  }
  return (va / l - (m / l) ^^ 2) * l / (l - 1);
}

/++
  Standard Deviation of Vector
+/
pure double std(Vector v) {
  import std.math : sqrt;

  return sqrt(v.var);
}

/++
  Covariance - Vector & Vector
+/
pure double cov(Vector x, Vector y) {
  assert(x.length == y.length);
  
  auto l = x.length;
  double mx = 0;
  double my = 0;
  double c = 0;

  foreach(i; 0 .. l) {
    auto xi = x[i];
    auto yi = y[i];
    mx += xi;
    my += yi;
    c += xi * yi;
  }
  return (c / l - (mx * my) / l^^2) * l / (l - 1);
}
// =============================================================================
// R Functions
// =============================================================================
/++
  runif - generate uniform random seq
+/
Matrix runif(int n, double a, double b) {
  auto rnd = Random(unpredictableSeed);

  double[] w;
  w.length = n;

  foreach(i; 0 .. n) {
    w[i] = uniform!"()"(a, b, rnd);
  }

  return Matrix(w, n, 1);
}