module dnum.stats;

import dnum.tensor;

// =============================================================================
// Basic Statistics
// =============================================================================
/++
    Summation
+/
pure double sum(Tensor t) {
    double s = 0;
    foreach(rows; t.data) {
        foreach(elem; rows) {
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
    foreach(rows; t.data) {
        foreach(elem; rows) {
            l++;
            s += elem;
        }
    }
    return s / l;
}

/++
    Column Mean
+/
Tensor cmean(Tensor t) {
    auto temp = Tensor(0, 1, t.ncol);

    foreach(rows; t.data) {
        temp = temp + Tensor(rows);
    }
    return temp;
}

/++
    Row Mean
+/
Tensor rmean(Tensor t) {
    auto temp = Tensor(t.nrow, 1);

    foreach(i, ref row; temp.data) {
        double s = 0;
        auto memrow = t.data[i][];
        foreach(k; 0 .. t.ncol) {
            s += memrow[k];
        }
        row[0] = s;
    }
    return temp;
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

    foreach(i; 0 .. n) {
        w[i] = uniform!"()"(a, b, rnd);
    }

    return Tensor(w, byRow);
}