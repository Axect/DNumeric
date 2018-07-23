module dnum.linalg;

import dnum.tensor;
import std.typecons : tuple;

/++
    Identity Matrix
+/
Tensor eye(long n) {
    auto I = Tensor(0, n, n);
    foreach(i, ref rows; I.data) {
        rows[i] = 1;
    }
    return I;
}

/++
    LU Decomposition
+/
auto lu(Tensor m) {
    auto n = m.nrow;

    auto u = Tensor(0, n, n);
    auto l = eye(n);

    foreach(i, ref rows; u.data) {
        rows[i] = m[0, i];
    }

    foreach(i; 0 .. n) {
        foreach(k; i .. n) {
            double s = 0;
            foreach(j; 0 .. i) {
                s += l[i, j] * u[j, k];
            }
            u[i, k] = m[i, k] - s;
        }

        foreach(k; i+1 .. n) {
            double s = 0;
            foreach(j; 0 .. i) {
                s += l[k, j] * u[j, i];
            }
            l[k, i] = (m[k, i] - s) / u[i, i];
        }
    }
    return tuple(l, u);
}

/++
    Determinant
+/
auto det(Tensor m) {
    auto u = m.lu[1];
    double s = 1;

    foreach(i, ref rows; u.data) {
        s *= rows[i];
    }
    return s;
}

/++
    Block partitioning Matrix (Tuple(mat11, mat12, mat21 mat22))
+/
auto block(Tensor m) {
    auto r = m.nrow;
    auto l = r / 2;

    auto t1 = Tensor(l, l);
    auto t2 = Tensor(l, r-l);
    auto t3 = Tensor(r-l, l);
    auto t4 = Tensor(r-l, r-l);

    foreach(i, ref rows; m.data) {
        foreach(j, ref elem; rows) {
            if (i < l) {
                if (j < l) {
                    t1[i, j] = elem;
                } else {
                    t2[i, j - l] = elem;
                }
            } else {
                if (j < l) {
                    t3[i - l, j] = elem;
                } else {
                    t4[i - l, j - l] = elem;
                }
            }
        }
    }
    return tuple(t1, t2, t3, t4);
}

/++
    Inverse
+/
Tensor inv(Tensor m) {
    auto res = m.lu;
    auto l = res[0];
    auto u = res[1];

    auto linv = l.invL;
    auto uinv = u.invU;

    return uinv % linv;
}

// =============================================================================
// Back-End Utils
// =============================================================================

/++
    Four Matrix to one Matrix
+/
Tensor combine(Tensor a, Tensor b, Tensor c, Tensor d) {
    auto x1 = a.ncol;
    auto x2 = b.ncol;
    auto y1 = a.nrow;
    auto y2 = c.nrow;

    auto x = x1 + x2;
    auto y = y1 + y2;

    auto m = Tensor(x, y);

    foreach(i; 0 .. y1) {
        foreach(j; 0 .. x1) {
            m[i, j] = a[i, j];
        }
        foreach(j; x1 .. x) {
            m[i, j] = b[i, j - x1];
        }
    }

    foreach(i; y1 .. y) {
        foreach(j; 0 .. x1) {
            m[i, j] = c[i - y1, j];
        }
        foreach(j; x1 .. x) {
            m[i, j] = d[i - y1, j - x1];
        }
    }

    return m;
}

/++
    Inverse of Low Triangular Matrix
+/
Tensor invL(Tensor l) {
    auto r = l.nrow;
    auto m = Tensor(l);

    if (r == 1) {
        return l;
    } else if (r == 2) {
        m[1, 0] = -l[1, 0];
        return m;
    } else {
        auto ls = m.block;
        auto l1 = ls[0];
        auto l2 = ls[1];
        auto l3 = ls[2];
        auto l4 = ls[3];

        auto m1 = l1.invL;
        auto m2 = l2;
        auto m4 = l4.invL;
        auto m3 = -(m4 % l3 % m1);

        return combine(m1, m2, m3, m4);
    }
}

/++
    Inverse of Upper triangular matrix
+/
Tensor invU(Tensor u) {
    auto r = u.nrow;
    auto m = Tensor(u);

    if (r == 1) {
        m[0, 0] = 1 / u[0, 0];
        return m;
    } else if (r == 2) {
        auto a = m[0, 0];
        auto b = m[0, 1];
        auto c = m[1, 1];
        auto d = a * c;

        m[0, 0] = 1 / a;
        m[0, 1] = -b / d;
        m[1, 1] = 1 / c;

        return m;
    } else {
        auto us = u.block;
        auto u1 = us[0];
        auto u2 = us[1];
        auto u3 = us[2];
        auto u4 = us[3];

        auto m1 = u1.invU;
        auto m3 = u3;
        auto m4 = u4.invU;
        auto m2 = -(m1 % u2 % m4);

        return combine(m1, m2, m3, m4);
    }
}
