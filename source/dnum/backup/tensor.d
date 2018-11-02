module dnum.tensor;

// =============================================================================
// Enum Section
// =============================================================================
/++
  Shape Enum - Row or Col
+/
enum Shape {
  Row,
  Col
}

/++
  Range Struct - start, end
+/
struct Range {
  double start;
  double end;
  double step = 1;

  this(double x, double y) {
    this.start = x;
    this.end = y;
  }

  this(double x, double y, double step) {
    this.start = x;
    this.end = y;
    this.step = step;
  }

  Tensor toTensor(Shape byRow = Shape.Row) {
    return Tensor(this, byRow);
  }
}

/++
  Size Struct - row, col
+/
struct Size {
  int row;
  int col;

  this(int x, int y) {
    this.row = x;
    this.col = y;
  }
}

// =============================================================================
// Main Section
// =============================================================================
/++
  Tensor - Lightweight Numerical Structrue
+/
struct Tensor {
  /++
    Main Components
  +/
  double[][] data;

  /++
    Constructor of single row or column tensor
  +/
  this(double[] vec, Shape byRow = Shape.Row) {
    switch (byRow) with (Shape) {
      case Row:
        this.data.length = 1;
        this.data[0] = vec[]; // Copy
        break;
      default:
        this.data.length = vec.length;
        foreach (i, ref rows; this.data) {
          rows.length = 1;
          rows[0] = vec[i];
        }
        break;
    }
  }

  /++
    Constructor with array of array
  +/
  this(double[][] mat) {
    this.data.length = mat.length;
    foreach (i, ref rows; this.data) {
      rows = mat[i][]; // Copy, not ref
    }
  }

  /++
    Initialize with single number
  +/
  this(double val, long row, long col) {
    this.data.length = row;
    foreach (i, ref rows; this.data) {
      rows.length = col;
      foreach (j; 0 .. col) {
        rows[j] = val;
      }
    }
  }

  /++
    Empty Matrix
  +/
  this(long row, long col) {
    this.data.length = row;
    foreach (i, ref rows; this.data) {
      rows.length = col;
    }
  }

  /++
    Copy Matrix
  +/
  this(Tensor m) {
    this.data.length = m.nrow;
    foreach (i, ref rows; this.data) {
      rows.length = m.ncol;
      foreach (j, ref elem; rows) {
        elem = m[i, j];
      }
    }
  }

  /++
    Range to Tensor
  +/
  this(Range r, Shape byRow = Shape.Row) {
    auto factor = (r.end - r.start) / r.step;
    auto l = cast(int)(factor + 1);
    double[] vec;
    vec.length = l;

    foreach (i; 0 .. l) {
      vec[i] = r.start + i * r.step;
    }

    switch (byRow) with (Shape) {
      case Row:
        this.data.length = 1;
        this.data[0] = vec[]; // Copy
        break;
      default:
        this.data.length = l;
        foreach (i, ref rows; this.data) {
          rows.length = 1;
          rows[0] = vec[i];
        }
        break;
    }
  }

  /++
    Return row (Same as R)
  +/
  pure auto nrow() {
    return this.data.length;
  }

  /++
    Return col (Same as R)
  +/
  pure auto ncol() {
    return this.data[0].length;
  }

  // =========================================================================
  // Operator Overloading
  // =========================================================================
  /++
    Getter
  +/
  pure double opIndex(size_t i, size_t j) const {
    return this.data[i][j];
  }

  /++
    Setter
  +/
  void opIndexAssign(double value, size_t i, size_t j) {
    this.data[i][j] = value;
  }

  /++
    opIndex with Slice
  +/
  Tensor opIndex(Range x, Range y) {
    long idiff = cast(long)(x.end - x.start);
    long jdiff = cast(long)(y.end - y.start);
    auto result = Tensor(idiff, jdiff);
    foreach (i; 0 .. idiff) {
      foreach (j; 0 .. jdiff) {
        result[i, j] = this.data[cast(long)x.start + i][cast(long)y.start + j];
      }
    }
    return result;
  }

  /++
    opSlice
  +/
  long[2] opSlice(size_t dim)(long start, long end) {
    return [start, end];
  }

  /++
    Unary Operator
  +/
  Tensor opUnary(string op)() {
    auto temp = Tensor(this.nrow, this.ncol);

    switch (op) {
    case "-":
      foreach (i, ref rows; temp.data) {
        pure auto memrow = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = -memrow[j];
        }
      }
      break;
    default:
      break;
    }
    return temp;
  }

  /++
    Binary Operator with Scalar
  +/
  Tensor opBinary(string op)(double rhs) {
    auto temp = Tensor(this.nrow, this.ncol);

    switch (op) {
    case "+":
      foreach (i, ref rows; temp.data) {
        auto memrow = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow[j] + rhs;
        }
      }
      break;
    case "-":
      foreach (i, ref rows; temp.data) {
        pure auto memrow = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow[j] - rhs;
        }
      }
      break;
    case "*":
      foreach (i, ref rows; temp.data) {
        pure auto memrow = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow[j] * rhs;
        }
      }
      break;
    case "/":
      foreach (i, ref rows; temp.data) {
        pure auto memrow = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow[j] / rhs;
        }
      }
      break;
    case "^^":
      foreach (i, ref rows; temp.data) {
        pure auto memrow = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow[j] ^^ rhs;
        }
      }
      break;
    default:
      break;
    }
    return temp;
  }

  /++
        Binary Operator (Right) with Scalar
    +/
  Tensor opBinaryRight(string op)(double lhs) {
    auto temp = Tensor(this.nrow, this.ncol);

    switch (op) {
    case "+":
      foreach (i, ref rows; temp.data) {
        auto memrow = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow[j] + lhs;
        }
      }
      break;
    case "-":
      foreach (i, ref rows; temp.data) {
        pure auto memrow = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = lhs - memrow[j];
        }
      }
      break;
    case "*":
      foreach (i, ref rows; temp.data) {
        pure auto memrow = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow[j] * lhs;
        }
      }
      break;
    case "/":
      foreach (i, ref rows; temp.data) {
        pure auto memrow = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = lhs / memrow[j];
        }
      }
      break;
    case "^^":
      foreach (i, ref rows; temp.data) {
        pure auto memrow = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow[j] ^^ lhs;
        }
      }
      break;
    default:
      break;
    }
    return temp;
  }

  /++
        Binary Operator with Tensor
    +/
  Tensor opBinary(string op)(Tensor rhs) {
    auto temp = Tensor(this.nrow, this.ncol);

    switch (op) {
    case "+":
      foreach (i, ref rows; temp.data) {
        pure auto memrow1 = this.data[i][];
        pure auto memrow2 = rhs.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow1[j] + memrow2[j];
        }
      }
      break;
    case "-":
      foreach (i, ref rows; temp.data) {
        pure auto memrow1 = this.data[i][];
        pure auto memrow2 = rhs.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow1[j] - memrow2[j];
        }
      }
      break;
    case "*":
      foreach (i, ref rows; temp.data) {
        pure auto memrow1 = this.data[i][];
        pure auto memrow2 = rhs.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow1[j] * memrow2[j];
        }
      }
      break;
    case "/":
      foreach (i, ref rows; temp.data) {
        pure auto memrow1 = this.data[i][];
        pure auto memrow2 = rhs.data[i][];
        foreach (j, ref elem; rows) {
          elem = memrow1[j] / memrow2[j];
        }
      }
      break;
    case "%":
      temp = Tensor(this.nrow, rhs.ncol);
      foreach (i, ref rows; temp.data) {
        pure auto memrow1 = this.data[i][];
        foreach (j, ref elem; rows) {
          elem = 0;
          foreach (k; 0 .. this.ncol) {
            elem += memrow1[k] * rhs.data[k][j];
          }
        }
      }
      break;
    default:
      break;
    }
    return temp;
  }

  // =========================================================================
  // Operators (Utils)
  // =========================================================================
  /++
    Function apply whole tensor
  +/
  Tensor fmap(double delegate(double) f) {
    Tensor temp = Tensor(this.nrow, this.ncol);
    foreach (i, ref rows; temp.data) {
      pure auto memrow1 = this.data[i][];
      foreach (j, ref elem; rows) {
        elem = f(memrow1[j]);
      }
    }
    return temp;
  }

  /++
    Function apply whole tensor - parallel - choose row or column which contain many components
  +/
  Tensor pmap(double delegate(double) f, Shape byRow = Shape.Col) {
    import std.parallelism : taskPool;
    Tensor temp = Tensor(this.nrow, this.ncol);

    switch (byRow) with (Shape) {
      case Row:
        foreach (i, ref rows; taskPool.parallel(temp.data)) {
          pure auto memrow1 = this.data[i][];
          foreach (j, ref elem; rows) {
            elem = f(memrow1[j]);
          }
        }
        break;
      default:
        foreach (i, ref rows; temp.data) {
          pure auto memrow1 = this.data[i][];
          foreach (j, ref elem; taskPool.parallel(rows)) {
            elem = f(memrow1[j]);
          }
        }
        break;
    }
    return temp;
  }

  /++
    Transpose
  +/
  Tensor transpose() {
    Tensor temp = Tensor(this.ncol, this.nrow);
    foreach (i, ref rows; temp.data) {
      foreach (j, ref elem; rows) {
        elem = this.data[j][i];
      }
    }
    return temp;
  }

  /++
    Alias for Transpose
  +/
  Tensor t() {
    return this.transpose;
  }
}
