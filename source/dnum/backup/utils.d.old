module dnum.utils;

import dnum.tensor;

/++
  Extract Row
+/
Tensor row(Tensor t, ulong i) {
  assert(i <= t.nrow, "No valid row");

  auto container = Tensor(t.data[i][], true);
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
