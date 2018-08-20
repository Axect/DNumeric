module dnum.stats;

import dnum.tensor;
import dnum.utils;
import std.math : sqrt;

// =============================================================================
// Basic Statistics
// =============================================================================
/++
  Summation
+/
pure double sum(Tensor t) {
  double s = 0;
  foreach (rows; t.data) {
    foreach (elem; rows) {
      s += elem;
    }
  }
  return s;
}

/++
  Parallel Sum - Effective to many row vector
+/
double psum(Tensor t) {
  import std.parallelism : taskPool;

  double s = 0;
  foreach (rows; t.data) {
    s += taskPool.reduce!"a + b"(rows);
  }
  return s;
}

/++
  Mean (Whole)
+/
pure double mean(Tensor t) {
  double s = 0;
  double l = 0;
  foreach (rows; t.data) {
    foreach (elem; rows) {
      l++;
      s += elem;
    }
  }
  return s / l;
}

/++
  Covariance (Only Single Vector)
+/
pure double cov(Tensor t1, Tensor t2) {
  // Column Vector
  if (t1.isCol && t2.isCol) {
    assert(t1.nrow == t2.nrow, "Can compare only same length tensor");
    
    auto l = t1.nrow;
    double mx = 0;
    double my = 0;
    double c = 0;

    foreach (i; 0 .. t1.nrow) {
      mx += t1[i,0];
      my += t2[i,0];
      c += t1[i, 0] * t2[i, 0];
    }
    return (c / l - (mx * my) / l^^2) * l / (l - 1);
  } else if (t1.isRow && t2.isRow) {
    assert(t1.ncol == t2.ncol, "Can compare only same length tensor");

    auto l = t1.ncol;
    double mx = 0;
    double my = 0;
    double c = 0;

    foreach (i; 0 .. t1.ncol) {
      mx += t1[0,i];
      my += t2[0,i];
      c += t1[0,i] * t2[0,i];
    }
    return (c / l - (mx * my) / l^^2) * l / (l - 1);
  } else {
    assert(false, "Can't compare matrices or different dimension vectors directly");
  }
}

/++
  Covariance Tensor
+/
Tensor cov(Tensor t, Shape byRow = Shape.Col) {
  // Default : Consider columns as data sets
  switch (byRow) with (Shape) {
    case Col:
      auto cols = t.ncol;
      auto ten = Tensor(cols, cols);

      foreach (i; 0 .. cols) {
        foreach (j; 0 .. cols) {
          ten[i, j] = cov(t.col(i), t.col(j));
        }
      }
      return ten;
    default:
      auto rows = t.nrow;
      auto ten = Tensor(rows, rows);

      foreach (i; 0 .. rows) {
        foreach (j; 0 .. rows) {
          ten[i,j] = cov(t.row(i), t.row(j));
        }
      }
      return ten;
  }
}

/++
  Variance
+/
double var(Tensor t) {
  return cov(t, t);
}

/++
  Standard Deviation
+/
double std(Tensor t) {
  return t.var.sqrt;
}

/++
  Correlation
+/
double cor(Tensor t1, Tensor t2) {
  return cov(t1, t2) / (t1.std * t2.std);
}

/++
  Generic Correlation
+/
Tensor cor(Tensor t, Shape byRow = Shape.Col) {
  switch (byRow) with (Shape) {
    case Col:
      auto cols = t.ncol;
      auto container = Tensor(cols,cols);

      foreach (i; 0 .. cols) {
        foreach (j; 0 .. cols) {
          container[i,j] = cor(t.col(i), t.col(j));
        }
      }
      return container;
    default:
      auto rows = t.nrow;
      auto container = Tensor(rows, rows);

      foreach (i; 0 .. rows) {
        foreach (j; 0 .. rows) {
          container[i, j] = cor(t.row(i), t.row(j));
        }
      }
      return container;
  }
}

// =============================================================================
// Column or Row Statistics
// =============================================================================

/++
  Column Mean
+/
Tensor cmean(Tensor t) {
  auto temp = Tensor(0, 1, t.ncol);

  foreach (rows; t.data) {
    temp = temp + Tensor(rows);
  }
  return temp / t.nrow;
}

/++
  Row Mean
+/
Tensor rmean(Tensor t) {
  auto temp = Tensor(t.nrow, 1);

  foreach (i, ref row; temp.data) {
    double s = 0;
    auto memrow = t.data[i][];
    foreach (k; 0 .. t.ncol) {
      s += memrow[k];
    }
    row[0] = s;
  }
  return temp / t.ncol;
}
