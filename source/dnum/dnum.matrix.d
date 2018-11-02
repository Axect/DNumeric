module dnum.matrix;

import std.algorithm.comparison : min, max;
import std.conv : to;

/++
    Lightweight R-like Matrix structire
+/
struct Matrix {
    /++
        Data container
    +/
    double[] data;

    /++
        Row
    +/
    ulong row;

    /++
        Column
    +/
    ulong col;

    /++
        Shape
    +/
    bool by_row;

    /++
        Default Constructor
    +/
    this(double[] vec, ulong row, ulong col, bool by_row) {
        this.data = vec;
        this.row = row;
        this.col = col;
        this.by_row = by_row;
    }

    /++
        Initialize with single number
    +/
    this(double val, ulong row, ulong col, bool by_row) {
        this.data.length = row * col;
        this.row = row;
        this.col = col;
        this.by_row = by_row;
        foreach(i; 0 .. row * col) {
            this.data[i] = val;
        }
    }

    void toString(scope void delegate(const(char)[]) sink) const {
        import std.stdio : write;

        this.spread.write;
    }

    Matrix change_shape() {
        assert((this.row * this.col) == this.data.length);
        auto r = this.row;
        auto c = this.col;
        auto l = r * c - 1;
        double[] vec;
        vec.length = r * c;

        switch (this.by_row) {
            case true:
                foreach(i; 0 .. l) {
                    auto s = (i * c) % l;
                    vec[i] = this.data[s];
                }
                vec[l] = this.data[l];
                return Matrix(vec, r, c, false);
            default:
                foreach(i; 0 .. l) {
                    auto s = (i * r) % l;
                    vec[i] = this.data[s];
                }
                vec[l] = this.data[l];
                return Matrix(vec, r, c, true);
        }
    }

    const string spread() {
        import std.format : format;

        assert(this.row * this.col == this.data.length);
        ulong space = 5;
        foreach(i; 0 .. this.row * this.col) {
            auto temp = this.data[i];
            ulong m = min(to!string(temp).length, format!"%.4f"(temp).length) + 1;
            if (m > space) {
                space = m;
            }
        }

        string result = "";

        result ~= tab("", 5);
        foreach(i; 0 .. this.col) {
            result ~= tab(format!"c[%d]"(i), space); // Header
        }
        result ~= '\n';

        foreach(i; 0 .. this.row) {
            result ~= tab(format!"r[%d]"(i), 5);
            foreach(j; 0 .. this.col) {
                const string st1 = format!"%.4f"(this[i, j]);
                const string st2 = to!string(this[i, j]);
                string st = (st1.length > st2.length) ? st2 : st1; // Choose smaller
                result ~= tab(st, space);
            }
            if (i == (this.row - 1)) {
                break;
            }
            result ~= '\n';
        }
        return result;
    }

    // =========================================================================
    // Operator Overloading
    // =========================================================================
    /++
        Getter
    +/
    pure double opIndex(ulong i, ulong j) const {
        switch(this.by_row) {
            case true:
                const ulong idx_row = i * this.col + j;
                return this.data[idx_row];
            default:
                const ulong idx_col = i + j * this.row;
                return this.data[idx_col];
        }
    }

    /++
        Setter
    +/
    void opIndexAssign(double value, ulong i, ulong j) {
        switch(this.by_row) {
            case true:
                const ulong idx_row = i * this.col + j;
                this.data[idx_row] = value;
                break;
            default:
                const ulong idx_col = i + this.row * j;
                this.data[idx_col] = value;
                break;
        }
    }

    /++
        Unary Ops
    +/
    Matrix opUnary(string op)() {
        double[] vec;
        vec.length = this.row * this.col;

        switch (op) {
            case "-":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = - this.data[i];
                }
                break;
            default:
                break;
        }

        return Matrix(vec, this.row, this.col, this.by_row);
    }

    /++
        Binary Ops with scalar
    +/
    Matrix opBinary(string op)(double rhs) {
        double[] vec;
        vec.length = this.row * this.col;

        switch (op) {
            case "+":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] + rhs;
                }
                break;
            case "-":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] - rhs;
                }
                break;
            case "*":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] * rhs;
                }
                break;
            case "/":
                foreach(i; 0 .. this.row / this.col) {
                    vec[i] = this.data[i] / rhs;
                }
                break;
            case "^^":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] ^^ rhs;
                }
                break;
            default:
                break;
        }
        return Matrix(vec, this.row, this.col, this.by_row);
    }

    /++
        Binary Ops (Right) with scalar
    +/
    Matrix opBinaryRight(string op)(double lhs) {
        double[] vec;
        vec.length = this.row * this.col;

        switch (op) {
            case "+":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] + lhs;
                }
                return Matrix(vec, this.row, this.col, this.by_row);
            case "-":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] - lhs;
                }
                return Matrix(vec, this.row, this.col, this.by_row);
            case "*":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] * lhs;
                }
                return Matrix(vec, this.row, this.col, this.by_row);
            case "/":
                foreach(i; 0 .. this.row / this.col) {
                    vec[i] = this.data[i] / lhs;
                }
                return Matrix(vec, this.row, this.col, this.by_row);
            case "^^":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] ^^ lhs;
                }
                return Matrix(vec, this.row, this.col, this.by_row);
            default:
                throw new Exception("No Operation!");
        }
    }

    /++
        Binary Ops with Matrix
    +/
    Matrix opBinary(string op)(Matrix rhs) {
        double[] vec;
        vec.length = this.row * this.col;

        assert(this.by_row == rhs.by_row);

        switch (op) {
            case "+":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] + rhs.data[i];
                }
                return Matrix(vec, this.row, this.col, this.by_row);
            case "-":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] - rhs.data[i];
                }
                return Matrix(vec, this.row, this.col, this.by_row);
            case "*":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] * rhs.data[i];
                }
                return Matrix(vec, this.row, this.col, this.by_row);
            case "/":
                foreach(i; 0 .. this.row * this.col) {
                    vec[i] = this.data[i] / rhs.data[i];
                }
                return Matrix(vec, this.row, this.col, this.by_row);
            case "%":
                assert(this.col == rhs.row);
                auto m = Matrix(0, this.row, rhs.col, this.by_row);
                foreach(i; 0 .. this.row) {
                    foreach(j; 0 .. rhs.col) {
                        double s = 0;
                        foreach(k; 0 .. this.col) {
                            s += this[i, k] * rhs[k, j];
                        }
                        m[i, j] = s;
                    }
                }
                return m;
            default:
                throw new Exception("No operation!");
        }
    }
}

// =============================================================================
// Back-end utils
// =============================================================================
string tab(string s, ulong space) {
    import std.array: replicate;
    const ulong l = s.length;
    const string fs = " ".replicate(space - l);
    return fs ~ s;
}