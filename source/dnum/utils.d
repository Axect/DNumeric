module dnum.utils;

import dnum.tensor;

/++
  Extract Row
+/
Tensor row(Tensor t, ulong i) {
  assert(i <= t.nrow, "No valid row");

  auto container = Tensor(t.data[i][], Shape.Row);
  return container;
}


/++
  Extract Column
+/
Tensor col(Tensor t, ulong i) {
  assert(i <= t.ncol, "No valid column");
  
  auto container = Tensor(t.nrow, 1);

  foreach (j, ref rows; t.data) {
    container[j,0] = rows[i];
  }
  return container;
}

/++
  Check Single Column
+/
pure bool isCol(Tensor t) {
  return t.ncol == 1;
}

/++
  Check Single Row
+/
pure bool isRow(Tensor t) {
  return t.nrow == 1;
}

/++
  Column Bind (Like R Syntax)
+/
Tensor cbind(Tensor t1, Tensor t2) {
  auto container = Tensor(t1.nrow, t1.ncol + t2.ncol);

  foreach (i, ref rows; container.data) {
    rows = t1.data[i][] ~ t2.data[i][];
  }

  return container;
}

/++
  Generic cbind
+/
Tensor cbind(Tensor[] t...) {
  int cols = 0;
  foreach (elem; t) {
    cols += elem.ncol;
  }

  auto container = Tensor(t[0].nrow, cols);

  foreach (i, ref rows; container.data) {
    auto initTen = t[0].data[i][];
    foreach (k; 1 .. t.length) {
      initTen ~= t[k].data[i][];
    }
    rows = initTen[];
  }
  return container;
}

/++
    Row Bind (Like R Syntax)
+/
Tensor rbind(Tensor t1, Tensor t2) {
  return Tensor(t1.data ~ t2.data);
}

/++
  Generic rbind
+/
Tensor rbind(Tensor[] t...) {
  auto initTen = Tensor(t[0]);
  foreach (k; 1 .. t.length) {
    initTen.data ~= t[k].data;
  }
  return initTen;
}

/++
  Vectorize Function
+/
auto vectorize(double delegate(double) f) {
  return (Tensor t) => t.fmap(f);
}

// =============================================================================
// R Functions
// =============================================================================
/++
    runif - generate uniform random seq
+/
Tensor runif(int n, double a, double b, Shape byRow = Shape.Row) {
  import std.random : Random, unpredictableSeed, uniform;

  auto rnd = Random(unpredictableSeed);

  double[] w;
  w.length = n;

  foreach (i; 0 .. n) {
    w[i] = uniform!"()"(a, b, rnd);
  }

  return Tensor(w, byRow);
}

// =============================================================================
// MATLAB(Julia) Functions
// =============================================================================
/++
  rand - random tensor with uniform dist (0, 1)
+/
Tensor rand(int n, Shape byRow = Shape.Row) {
  return runif(n, 0, 1, byRow);
}

/++
  rand tensor version
+/
Tensor rand(int m, int n) {
  import std.random : Random, unpredictableSeed, uniform;

  auto rnd = Random(unpredictableSeed);

  auto container = Tensor(m, n);

  foreach(rows; container.data) {
    foreach(elem; rows) {
      elem = uniform!"()"(0, 1, rnd);
    }
  }

  return container;
}
