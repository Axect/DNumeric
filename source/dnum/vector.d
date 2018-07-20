module dnum.vector;

/++
  Vector is default class for Statistics
+/
struct Vector {
  import std.math : sqrt;
  
  double[] comp;

  // ===========================================================================
  // Constructor
  // ===========================================================================
  /++
    Like iota
  +/
  this(double start, double end, double step = 1) {
    long l = cast(long)((end - start + 1) / step);
    this.comp.length = l;
    foreach(i; 0 .. l) {
      this.comp[i] = start + cast(double)i * step;
    }
  }

  /++
    Uninitialized
  +/
  this(long l) {
    this.comp.length = l;
  }

  /++
    array to Vector
  +/
  this(double[] vec) {
    this.comp = vec;
  }

  /++
    Intialize with number
  +/
  this(double num, long l) {
    this.comp.length = l;
    foreach(i; 0 .. l) {
      this.comp[i] = num;
    }
  }

  void toString(scope void delegate(const(char)[]) sink) const {
    import std.stdio : write;

    sink("Vector ");
    this.comp.write;
  }

  // ===========================================================================
  // Basic Operator
  // ===========================================================================
  pure long length() const {
    return this.comp.length;
  }
  
  // ===========================================================================
  //    Void Functions
  // ===========================================================================
  void add_void(T)(T x) {
    auto X = cast(double)x;
    foreach(i; 0 .. this.comp.length) {
      this.comp[i] += X;
    }
  }

  void sub_void(T)(T x) {
    auto X = cast(double)x;
    foreach(i; 0 .. this.comp.length) {
      this.comp[i] -= X;
    }
  }

  void mul_void(T)(T x) {
    auto X = cast(double)x;
    foreach(i; 0 .. this.comp.length) {
      this.comp[i] *= X;
    }
  }

  void div_void(T)(T x) {
    auto X = cast(double)x;
    foreach(i; 0 .. this.comp.length) {
      this.comp[i] /= X;
    }
  }

  void pow_void(T)(T x) {
    auto X = cast(double)x;
    foreach(i; 0 .. this.comp.length) {
      this.comp[i] ^^= X;
    }
  }

  void sqrt_void() {
    foreach(i; 0 .. this.comp.length) {
      this.comp[i] = sqrt(this.comp[i]);
    }
  }

  // TODO: What is it delegate
  void fmap_void(double delegate(double) f) {
    foreach(i; 0 .. this.comp.length) {
      this.comp[i] = f(this.comp[i]);
    }
  }

  // ===========================================================================
  //    Vector Function
  // ===========================================================================
  Vector fmap(double delegate(double) f) {
    Vector that = Vector(comp);
    that.fmap_void(f);
    return that;
  }

  const double mapReduce(double delegate(double) f) {
    double s = 0;
    foreach(e; this.comp) {
      s += f(e);
    }
    return s;
  }

  Vector sqrt() {
    return this.fmap(t => t.sqrt);
  }
  // ===========================================================================
  // Operator Overloading
  // ===========================================================================
  /++
    Getter
  +/
  pure double opIndex(size_t i) const {
    return this.comp[i];
  }

  /++
    Setter
  +/
  void opIndexAssign(double value, size_t i) {
    this.comp[i] = value;
  }

  /++
    Binary Operator with Scalar
  +/
  Vector opBinary(string op)(double rhs) {
    Vector temp = Vector(this.comp);
    switch(op) {
      case "+":
        temp.add_void(rhs);
        break;
      case "-":
        temp.sub_void(rhs);
        break;
      case "*":
        temp.mul_void(rhs);
        break;
      case "/":
        temp.div_void(rhs);
        break;
      case "^^":
        temp.pow_void(rhs);
        break;
      default:
        break;
    }
    return temp;
  }

  /++
    Binary Operator with Vector
  +/
  Vector opBinary(string op)(Vector rhs) {
    Vector temp = Vector(this.comp);
    switch(op) {
      case "+":
        foreach(i; 0 .. temp.length) {
          temp.comp[i] += rhs.comp[i];
        }
        break;
      case "-":
        foreach(i; 0 .. temp.length) {
          temp.comp[i] -= rhs.comp[i];
        }
        break;
      case "*":
        foreach(i; 0 .. temp.length) {
          temp.comp[i] *= rhs.comp[i];
        }
        break;
      case "/":
        foreach(i; 0 .. temp.length) {
          temp.comp[i] /= rhs.comp[i];
        }
        break;
      default:
        break;
    }
    return temp;
  }

  /++
    Inner Product
  +/
  double dot(Vector rhs) {
    double s = 0;
    foreach(i; 0 .. this.comp.length) {
      s += cast(double)this[i] * cast(double)rhs[i];
    }
    return s;
  }

  // ===========================================================================
  // Statistics Operator
  // ===========================================================================
  // pure double sum() const {
  //   double s = 0;
  //   foreach(e; this.comp) {
  //     s += e;
  //   }
  //   return s;
  // }
  
  // pure double mean() const {
  //   double s = 0;
  //   double l = 0;
  //   foreach(e; this.comp) {
  //     l++;
  //     s += e;
  //   }
  //   return s / l;
  // }

  // pure double var() const {
  //   double m = 0;
  //   double l = 0;
  //   double v = 0;
  //   foreach(e; this.comp) {
  //     l++;
  //     m += e;
  //     v += e ^^ 2;
  //   }
  //   return (v / l - (m / l)^^2) * l / (l - 1);
  // }

  // pure double std() const {
  //   return sqrt(var);
  // }
}

// =============================================================================
// Matrix
// =============================================================================
/++
  Matrix Structure
+/
struct Matrix {
  import std.array : join;
  import std.parallelism : taskPool, parallel; // Perfect Parallel!

  Vector val;
  long row;
  long col;
  bool byRow;
  double[][] data;
  
  // ===========================================================================
  // Constructor
  // ===========================================================================
  this(double[] vec, long r, long c, bool byrow = false) {
    this.val = Vector(vec);
    this.row = r;
    this.col = c;
    this.byRow = byrow;
    this.data = this.matForm; // heavy cost
  }

  /++
    Uninitialized Matrix
  +/
  this(long r, long c, bool byrow = false) {
    this.val = Vector(r*c);
    this.row = r;
    this.col = c;
    this.byRow = byrow;
    this.data = this.matForm;
  }

  this(Vector vec, long r, long c, bool byrow = false) {
    this.val = vec;
    this.row = r;
    this.col = c;
    this.byRow = byrow;
    this.data = this.matForm; // heavy cost
  }

  this(double[][] mat) {
    this.val = Vector(mat.join); // join is cheap
    this.row = mat.length;
    this.col = mat[0].length;
    this.byRow = true;
    this.data = mat; // no cost
  }

  this(Matrix mat) {
    this.val = mat.val;
    this.row = mat.row;
    this.col = mat.col;
    this.byRow = mat.byRow;
    this.data = mat.data;
  }

  this(double num, long r, long c) {
    this.val = Vector(num, r*c);
    this.row = r;
    this.col = c;
    this.byRow = false;
    this.data = this.matForm;
  }

  // ===========================================================================
  // String
  // ===========================================================================
  void toString(scope void delegate(const(char)[]) sink) const {
    import std.stdio : write;

    sink("Matrix ");
    this.data.write;
  }

  double[][] matForm() const {
    long c = this.col;
    long r = this.row;
    double[][] mat;
    mat.length = r;

    if (byRow) {
      foreach(i; 0 .. r) {
        mat[i].length = c;
        foreach(j; 0 .. c) {
          long k = c*i + j;
          mat[i][j] = this.val[k];
        }
      }
    } else {
      foreach(j; 0 .. c) {
        foreach(i; 0 .. r) {
          mat[i].length = c;
          long k = r*j + i;
          mat[i][j] = this.val[k];
        }
      }
    }
    return mat;
  }

  /++
    Reduce cost
  +/
  void refresh() {
    this.data = this.matForm;
  }
  // ===========================================================================
  // Operator Overloading
  // ===========================================================================
  /++
    Getter
  +/
  double opIndex(size_t i, size_t j) const {
    return this.data[i][j];
  }

  /++
    Setter
  +/
  void opIndexAssign(double value, size_t i, size_t j) {
    this.data[i][j] = value;
  }

  /++
    Binary Operator with Scalar
  +/
  Matrix opBinary(string op)(double rhs) {
    Matrix temp = Matrix(this.data); // No Cost
    switch(op) {
      case "+":
        temp.val.add_void(rhs);
        break;
      case "-":
        temp.val.sub_void(rhs);
        break;
      case "*":
        temp.val.mul_void(rhs);
        break;
      case "/":
        temp.val.div_void(rhs);
        break;
      case "^^":
        temp.val.pow_void(rhs);
        break;
      default:
        break;
    }
    temp.refresh;
    return temp;
  }

  /++
    Binary Operator with Matrix
  +/
  Matrix opBinary(string op)(Matrix rhs) {
    Matrix temp = Matrix(this.val, this.row, this.col, this.byRow); // Guess heavy cost but..
    switch(op) {
      case "+":
        foreach(i; 0 .. temp.val.length) {
          temp.val.comp[i] += rhs.val.comp[i];
        }
        break;
      case "-":
        foreach(i; 0 .. temp.val.length) {
          temp.val.comp[i] -= rhs.val.comp[i];
        }
        break;
      case "*":
        foreach(i; 0 .. temp.val.length) {
          temp.val.comp[i] *= rhs.val.comp[i];
        }
        break;
      case "/":
        foreach(i; 0 .. temp.val.length) {
          temp.val.comp[i] /= rhs.val.comp[i];
        }
        break;
      case "%": // Parallel Multiplication
        assert(this.col == rhs.row);
        
        auto m = this.data;
        auto n = rhs.data;
        auto l1 = this.row;
        auto l2 = rhs.col;

        auto target = initMat(l1, l2);

        foreach(i, ref rows; taskPool.parallel(target)) {
          foreach(j; 0 .. l2) {
            double s = 0;
            foreach(k; 0 .. this.col) {
              s += m[i][k] * n[k][j];
            }
            rows[j] = s;
          }
        }
        temp = Matrix(target);
        break;
      default:
        break;
    }
    temp.refresh;
    return temp;
  }

  // ===========================================================================
  // Matrix Utils
  // ===========================================================================
  /++
    True -> False
  +/
  Matrix makeFalse() {
    assert(this.byRow);
    double[] v_ref = this.val.comp; // Double array
    auto r = this.row;
    auto c = this.col;
    auto l = r * c - 1;
    
    double[] v_con;
    v_con.length = l + 1;

    foreach(i; 0 .. l) {
      auto s = (i * c) % l;
      v_con[i] = v_ref[s];
    }
    v_con[l] = v_ref[l];

    return Matrix(v_con, r, c);
  }

  /++
    Transpose
  +/
  Matrix transpose() { // Parallel
    auto l1 = this.row;
    auto l2 = this.col;
    auto m = this.data;
    Matrix temp;
    auto target = initMat(l2, l1);
    foreach(i, ref rows; taskPool.parallel(target)) {
      foreach(j; 0 .. l1) {
        rows[j] = m[j][i];
      }
    }
    temp = Matrix(target);
    return temp;
  }

  /++
    Check Square Matrix
  +/
  bool isSquare() {
    return this.row == this.col;
  }

  import std.typecons : tuple;

  /++
    LU Decomposition
  +/
  auto lu() {
    auto n = this.row;
    assert(this.isSquare);

    double[][] m = this.data;
    double[][] u = zerosMat(n,n);
    double[][] l = eyeMat(n);
    u[0] = m[0];

    foreach(i; 0 .. n) {
      foreach(k; i .. n) {
        double s = 0;
        foreach(j; 0 .. i) {
          s += l[i][j] * u[j][k];
        }
        u[i][k] = m[i][k] - s;
      }

      foreach(k; i+1 .. n) {
        double s = 0;
        foreach(j; 0 .. i) {
          s += l[k][j] * u[j][i];
        }
        l[k][i] = (m[k][i] - s) / u[i][i];
      }
    }
    Matrix L = Matrix(l);
    Matrix U = Matrix(u);
    return tuple(L, U);
  }

  /++
    Determinant (Using LU Decomposition)
  +/
  double det() { // Use LU Decomposition
    auto res = this.lu;
    Matrix U = res[1];
    
    double u = 1;

    foreach(i; 0 .. U.row) {
      u *= U[i,i];
    }
    return u;
  }

  /++
    Inverse
  +/
  Matrix inv() {
    auto res = this.lu();
    Matrix L = res[0];
    Matrix U = res[1];

    Matrix Uinv = U.invU;
    Matrix Linv = L.invL;

    return Uinv % Linv; 
  }

  Matrix invL() {
    if (this.row == 1) {
      return this;
    } else if (this.row == 2) {
      auto m = this.data;
      m[1][0] = -this.data[1][0];
      return Matrix(m);
    } else {
      auto l1 = this.block(1);
      auto l2 = this.block(2);
      auto l3 = this.block(3);
      auto l4 = this.block(4);

      auto m1 = l1.invL;
      auto m2 = l2;
      auto m4 = l4.invL;
      auto m3 = (m4 % l3 % m1) * (-1);

      return combine(m1, m2, m3, m4);
    }
  }

  Matrix invU() {
    if (this.row == 1) {
      auto m = this.data;
      m[0][0] = 1 / this.data[0][0];
      return Matrix(m);
    } else if (this.row == 2) {
      auto m = this.data;
      auto a = m[0][0];
      auto b = m[0][1];
      auto c = m[1][1];
      auto d = a * c;

      m[0][0] = 1 / a;
      m[0][1] = - b / d;
      m[1][1] = 1 / c;

      return Matrix(m);
    } else {
      auto u1 = this.block(1);
      auto u2 = this.block(2);
      auto u3 = this.block(3);
      auto u4 = this.block(4);

      auto m1 = u1.invU;
      auto m3 = u3;
      auto m4 = u4.invU;
      auto m2 = (m1 % u2 % m4) * (-1);

      return combine(m1, m2, m3, m4);
    }
  }

  /++
    Partitioning matrix
  +/
  Matrix block(int quad) {
    auto r = this.row;
    assert(this.isSquare);

    auto l = r / 2;
    auto m = this.data;

    Matrix target;
    
    switch(quad) {
      case 1:
        double[][] temp = initMat(l,l);
        foreach(i; 0 .. l) {
          foreach(j; 0 .. l) {
            temp[i][j] = m[i][j];
          }
        }
        target = Matrix(temp);
        break;
      case 2:
        double[][] temp = initMat(l,r - l);
        foreach(i; 0 .. l) {
          foreach(j; l .. r) {
            temp[i][j - l] = m[i][j];
          }
        }
        target = Matrix(temp);
        break;
      case 3:
        double[][] temp = initMat(r-l, l);
        foreach(i; l .. r) {
          foreach(j; 0 .. l) {
            temp[i - l][j] = m[i][j];
          }
        }
        target = Matrix(temp);
        break;
      case 4:
        double[][] temp = initMat(r-l, r-l);
        foreach(i; l .. r) {
          foreach(j; l .. r) {
            temp[i - l][j - l] = m[i][j];
          }
        }
        target = Matrix(temp);
        break;
      default:
        break;
    }
    return target;
  }
}

// =============================================================================
// Functions of vector or matrices
// =============================================================================
/++
  Concate two Vectors to Vector
+/
Vector cbind(Vector m, Vector n) {
  import std.array : join;

  Vector container;

  container.comp = join([m.comp, n.comp]);
  return container;
}

/++
  Concate two Vectors to Matrix
+/
Matrix rbind(Vector m, Vector n) {
  assert(m.length == n.length);
  Vector v = cbind(m, n);

  return Matrix(v, 2, m.length, true);
}

/++
  Insert Vector to Matrix
+/
Matrix rbind(Matrix m, Vector v) {
  assert(m.col == v.length);
  Matrix n = Matrix(v, 1, v.length, true);

  return rbind(m, n);
}

/++
  Concate two Matrix to Matrix with col direction
+/
Matrix cbind(Matrix m, Matrix n) {
  assert(m.row == n.row);
  Matrix container;
  container.row = m.row;
  container.col = m.col + n.col;
  
  if (m.byRow && n.byRow) {
    m = m.makeFalse;
    n = n.makeFalse;
  } else if (n.byRow) {
    n = n.makeFalse;
  } else if (m.byRow) {
    m = m.makeFalse;
  }

  container.val = cbind(m.val, n.val);
  container.refresh;
  return container;
}

/++
  Concate to Matrix to Matrix with row direction
+/
Matrix rbind(Matrix m, Matrix n) {
  assert(m.col == n.col);  
  
  import std.array : join;

  auto mat = join([m.data, n.data]);

  return Matrix(mat);
}


// =============================================================================
// Array of Array Utils
// =============================================================================

double[][] initMat(long r, long c) {
  double[][] m;
  m.length = r;
  foreach(i; 0 .. r) {
    m[i].length = c;
  }
  return m;
}

double[][] eyeMat(long l) {
  double[][] m = zerosMat(l, l);
  foreach(i; 0 .. l) {
    m[i][i] = 1;
  }
  return m;
}

double[][] zerosMat(long r, long c) {
  double[][] m = initMat(r, c);
  foreach(i, ref rows; m) {
    foreach(j; 0 .. c) {
      rows[j] = 0;
    }
  }
  return m;
}

/++
  Combine
+/
Matrix combine(Matrix p, Matrix q, Matrix r, Matrix s) {
  auto a = p.data;
  auto b = q.data;
  auto c = r.data;
  auto d = s.data;
  
  auto x1 = a[0].length;
  auto x2 = b[0].length;
  auto y1 = a.length;
  auto y2 = c.length;

  auto lx = x1 + x2;
  auto ly = y1 + y2;

  double[][] m;
  m.length = ly;

  foreach(i; 0 .. y1) {
    m[i].length = lx;
    foreach(j; 0 .. x1) {
      m[i][j] = a[i][j];
    }
    foreach(j; x1 .. lx) {
      m[i][j] = b[i][j - x1];
    }
  }

  foreach(i; y1 .. ly) {
    m[i].length = lx;
    foreach(j; 0 .. x1) {
      m[i][j] = c[i - y1][j];
    }
    foreach(j; x1 .. lx) {
      m[i][j] = d[i - y1][j - x1];
    }
  }

  return Matrix(m);
}