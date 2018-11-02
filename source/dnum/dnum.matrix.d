module dnum.matrix;

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
    uint row;

    /++
        Column
    +/
    uint col;

    /++
        Shape
    +/
    Shape shape;

    /++
        Default Constructor
    +/
    this(double[] vec, uint row, uint col, Shape shape) {
        this.data = vec;
        this.row = row;
        this.col = col;
        this.shape = shape;
    }

    /++
        Initialize with single number
    +/
    this(double val, uint row, uint col, Shape shape) {
        this.data.length = row * col;
        this.row = row;
        this.col = col;
        this.shape = shape;
        foreach(i; 0 .. row * col) {
            this.data[i] = val;
        }
    }

    void toString(scope void delegate(const(char)[]) sink) const {
        import std.stdio : write;

        sink("Matrix ");
        this.data.write;
    }

    // =========================================================================
    // Operator Overloading
    // =========================================================================
    /++
        Getter
    +/
    pure double opIndex(uint i, uint j) const {
        switch(this.shape) with(Shape) {
            case Row:
                const uint idx_row = i * this.col + j;
                return this.data[idx_row];
            default:
                const uint idx_col = i + j * this.row;
                return this.data[idx_col];
        }
    }

    /++
        Setter
    +/
    void opIndexAssign(double value, uint i, uint j) {
        switch(this.shape) with(Shape) {
            case Row:
                const uint idx_row = i * this.col + j;
                this.data[idx_row] = value;
                break;
            default:
                const uint idx_col = i + this.row * j;
                this.data[idx_col] = value;
                break;
        }
    }
}