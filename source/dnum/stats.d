module dnum.stats;

import dnum.tensor;
import dnum.utils;

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
  if (t1.ncol == 1 && t2.ncol == 1) {
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
  } else if (t1.nrow == 1 && t2.nrow == 1) {
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
Tensor cov(Tensor t, bool byRow=false) {
  // Default : Consider columns as data sets
  if (!byRow) {
    auto cols = t.ncol;
    auto ten = Tensor(cols, cols);

    foreach (i; 0 .. cols) {
      foreach (j; 0 .. cols) {
        ten[i, j] = cov(t.col(i), t.col(j));
      }
    }
    return ten;
  } else {
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

// =============================================================================
// R Functions
// =============================================================================
/++
    runif - generate uniform random seq
+/
Tensor runif(int n, double a, double b, bool byRow = true) {
  import std.random : Random, unpredictableSeed, uniform;

  auto rnd = Random(unpredictableSeed);

  double[] w;
  w.length = n;

  foreach (i; 0 .. n) {
    w[i] = uniform!"()"(a, b, rnd);
  }

  return Tensor(w, byRow);
}
