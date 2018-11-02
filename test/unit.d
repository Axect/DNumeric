import dnum.matrix;
import std.stdio : writeln;

unittest {
    // Matrix
    auto a = Matrix([1,2,3,4], 2, 2, true);
    a.writeln;
    auto b = Matrix([1,2,3,4], 2, 2, false);
    b.writeln;

    // Ops
    auto c = a + 1;
    c.writeln;

    auto d = 1 + a;
    d.writeln;

    // Ops
    auto e = c%d;
    writeln(e, e.by_row);
    auto f = e.change_shape;
    writeln(f, f.by_row);
}

void main() {}