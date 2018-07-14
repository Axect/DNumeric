module dnum.stats;

import dnum.vector;

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
