module dnum.utils;

import dnum.tensor;

/++
  Create Single Tensor
+/
Tensor seq(int start, int end, int step = 1) {
  auto r = Range(start, end, step);
  return Tensor(r);
}

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
  Check Single
+/
pure bool isSingle(Tensor t) {
  return isCol(t) || isRow(t);
}

// =============================================================================
// Python Functions
// =============================================================================
/++
  where - Like numpy.where
+/

// =============================================================================
// R Functions
// =============================================================================
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

/++
  runif - D version
+/
Tensor runif(int n, Range r, Shape byRow = Shape.Row) {
  import std.random : Random, unpredictableSeed, uniform;

  auto rnd = Random(unpredictableSeed);

  double[] w;
  w.length = n;

  foreach (i; 0 .. n) {
    w[i] = uniform!"()"(r.start, r.end, rnd);
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
  rand - D version
+/
Tensor rand(int n, Range r, Shape byRow = Shape.Row) {
  return runif(n, r, byRow);
}

/++
  rand tensor version
+/
Tensor rand(int m, int n) {
  import std.random : Random, unpredictableSeed, uniform;

  auto rnd = Random(unpredictableSeed);

  auto container = Tensor(m, n);

  foreach(ref rows; container.data) {
    foreach(ref elem; rows) {
      elem = uniform!"()"(0., 1., rnd);
    }
  }

  return container;
}

/++
  rand tensor version - D version
+/
Tensor rand(Size s, Range r) {
  import std.random : Random, unpredictableSeed, uniform;

  auto rnd = Random(unpredictableSeed);

  auto container = Tensor(s.row, s.col);

  foreach(ref rows; container.data) {
    foreach(ref elem; rows) {
      elem = uniform!"()"(r.start, r.end, rnd);
    }
  }

  return container;
}

// =============================================================================
// Functional Programming Tools - Unstable
// =============================================================================
/++
  take - take the number of components of tensor
+/
Tensor take(Tensor t, int n) {
  assert(t.isSingle, "Use Range to extract components for not single tensors (see tensor.d - opIndex)");
  if (t.isRow) {
    return t[Range(0,0), Range(0, n-1)];
  } else {
    return t[Range(0, n-1), Range(0,0)];
  }
}

/++
  takeWhile
+/
Tensor takeWhile(Tensor t, bool delegate(double) f) {
  assert(t.isSingle, "You can't use take while for not single tensors");
  if (t.isRow) {
    int n = 0;
    double[] container;
    while (f(t[0, n])) {
      container ~= t[0,n];
      n++;
    }
    return Tensor(container, Shape.Row);
  } else {
    int n = 0;
    double[] container;
    while (f(t[n,0])) {
      container ~= t[n,0];
      n++; 
    }
    return Tensor(container, Shape.Col);
  }
}

alias DFunc = double delegate(double, double);
alias Func = double delegate(double);

/++
  Currying
+/
Func currying(DFunc f, double x) {
  return t => f(x,t);
}

/++
  zipWith - zip two Tensor with operation to one tensor
+/
Tensor zipWith(double delegate(double, double) op, Tensor t1, Tensor t2) {
  assert(t1.isSingle && t2.isSingle, "zipWith for not single tensor is not yet implemented");
  import std.algorithm.comparison : min;
  if (t1.isCol && t2.isCol) {
    auto n = min(t1.nrow, t2.nrow);
    auto result = Tensor(n, 1);
    foreach(i; 0 .. n) {
      result[i, 0] = op(t1[i,0], t2[i,0]);
    }
    return result;
  } else if (t1.isRow && t2.isRow) {
    auto n = min(t1.ncol, t2.ncol);
    auto result = Tensor(1, n);
    foreach(i; 0 .. n) {
      result[0, i] = op(t1[0,i], t2[0,i]);
    }
    return result;
  } else {
    assert(false, "Both tensors should be same form! (Row vs Row or Col vs Col)");
  }
}