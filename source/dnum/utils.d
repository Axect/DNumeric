module dnum.utils;

import dnum.tensor;

/++
    Column Bind (Like R Syntax)
+/
Tensor cbind(Tensor t1, Tensor t2) {
    auto container = Tensor(t1.nrow, t1.ncol + t2.ncol);

    foreach(i, ref rows; container.data) {
        rows = t1.data[i][] ~ t2.data[i][];
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
  Vectorize Function
+/
auto vectorize(double delegate(double) f) {
    return (Tensor t) => t.fmap(f);
}