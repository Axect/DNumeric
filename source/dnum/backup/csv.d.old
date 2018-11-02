module dnum.csv;

import dnum.tensor;

import std.file : readText, write;
import std.array : split, join;
import std.conv : to;
import std.string : chop;
import std.algorithm : map;

alias Header = string[];

/++
  DataFrame - readcsv or writecsv structure
+/
struct DataFrame {
  Header header;
  Tensor data;

  this(Header h, Tensor t) {
    this.header = h;
    this.data = t;
  }

  this(Tensor t) {
    this.data = t;

    Header h;
    h.length = t.ncol;
    foreach (i, ref head; h) {
      head = to!string(i);
    }
    this.header = h;
  }

  // TODO : Implement Print
  // TODO : Override Index (with Header)
}

/++
  readcsv - Read CSV file to DataFrame
+/
DataFrame readcsv(string filename, bool header = false) {
  auto file = readText(filename).chop;
  auto temp = file.split("\n");

  Header head;

  if (header) {
    head = temp[0].split(",");
    temp = temp[1 .. $][];
  }

  double[][] container;
  container.length = temp.length;
  
  foreach (i; 0.. temp.length) {
    auto values = temp[i].split(",");
    auto l = values.length;
    container[i].length = l;
    foreach (j; 0 .. l) {
      container[i][j] = values[j].to!double;
    }
  }
  if (header) {
    return DataFrame(head, Tensor(container));
  } else {
    return DataFrame(Tensor(container));
  }
}

/++
  writecsv - Write DataFrame to CSV file
+/
void writecsv(string filename, DataFrame df, bool header = false) {
  Header head = [ df.header.join(",") ];
  double[][] target = df.data.data;

  string[] container;
  container.length = target.length;

  foreach (i; 0 .. target.length) {
    container[i] = target[i].map!(to!string).join(",");
  }
  
  if (!header) {
    string toWrite = container.join("\n");
    write(filename, toWrite);
  } else {
    string[] forWrite = join([head, container]);
    string toWrite = forWrite.join("\n");
    write(filename, toWrite);
  }
}
