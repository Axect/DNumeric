import dnum.matrix;
import std.stdio : writeln;

unittest {
    auto a = Matrix([1,2,3,4], 2, 2, Shape.Row);
    a.writeln;
}

void main() {}