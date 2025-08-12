import 'dart:io';

class Graph {
  final int n;
  final List<Set<int>> adj;
  Graph(this.n) : adj = List.generate(n, (_) => <int>{});

  void addEdge(int u, int v) {
    adj[u].add(v);
    adj[v].add(u);
  }

  void show() {
    for (int i = 0; i < n; i++) {
      print('$i -> ${adj[i].join(", ")}');
    }
  }

  Future<Graph> readGraphFromInputFile() async {
    const String filePath =
        r"C:\Users\pedra\Desktop\minimum vertex cover\lib\input.txt";
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
}
