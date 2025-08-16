import 'dart:io';

class Graph {
  final int n;
  final List<Set<int>> adj;
  List<List<int>> edges = [];
  Graph(this.n) : adj = List.generate(n, (_) => <int>{});

  void addEdge(int u, int v) {
    adj[u].add(v);
    adj[v].add(u);
    edges.add(u < v ? [u, v] : [v, u]);
  }

  void show() {
    for (int i = 0; i < n; i++) {
      print('$i -> ${adj[i].join(", ")}');
    }
  }

  void showEdges() {
    for (int i = 0; i < edges.length; i++) {
      print("${edges[i][0]}---${edges[i][1]}");
    }
  }

  Future<Graph> readGraphFromInputFile() async {
    const String filePath = r"io\input.txt";
    File file = File(filePath);

    var contents = await file.readAsLines();
    int n = int.parse(contents[0]);
    Graph graph = Graph(n);
    for (String line in contents.getRange(1, n - 1)) {
      var splittedLine = line.split(' ');
      int u = int.parse(splittedLine[0]);
      int v = int.parse(splittedLine[1]);

      graph.addEdge(u, v);
    }
    graph.show();
    return graph;
  }

  bool saveCoverToFile(Set<int> cover) {
    try {
      final file = File('io/output.txt');
      // Write each vertex in a new line (overwrite if file already exists)
      file.writeAsStringSync(cover.map((v) => v.toString()).join('\n'));
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
