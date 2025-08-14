import 'dart:math';

import 'graph.dart';
import 'vertex_cover_solver.dart';

void main() async {
  Stopwatch stopwatch = Stopwatch()..start();
  Graph graph = Graph(0);
  graph = await graph.readGraphFromInputFile();
  // Graph graph = Graph(20);

  // graph.addEdge(0, 3);
  // graph.addEdge(0, 7);
  // graph.addEdge(1, 4);
  // graph.addEdge(1, 9);
  // graph.addEdge(2, 5);
  // graph.addEdge(2, 8);
  // graph.addEdge(3, 10);
  // graph.addEdge(4, 11);
  // graph.addEdge(5, 12);
  // graph.addEdge(6, 13);
  // graph.addEdge(7, 14);
  // graph.addEdge(8, 15);
  // graph.addEdge(9, 16);
  // graph.addEdge(10, 17);
  // graph.addEdge(11, 18);
  // graph.addEdge(12, 19);
  // graph.addEdge(13, 0);
  // graph.addEdge(14, 1);
  // graph.addEdge(15, 2);
  // graph.addEdge(16, 6);
  // graph.addEdge(17, 7);
  // graph.addEdge(18, 8);
  // graph.addEdge(19, 9);
  // Graph graph = generateRandomGraph(20, 150, 0);

  graph.show();

  VertexCoverSolver solver = VertexCoverSolver(graph);
  Set<int>? cover = solver.solve();

  if (cover != null) {
    print('Minimum Vertex Cover size: ${cover.length}');
    print('Vertices in the cover:');
    for (int v in cover) {
      print(v);
    }
  } else {
    print('No vertex cover found.');
  }
  graph.saveCoverToFile(cover!);
  print('Execution time: ${stopwatch.elapsedMilliseconds} ms');
}

Graph generateRandomGraph(int n, int edgeCount, int seed) {
  final graph = Graph(n);
  final rng = Random(seed);
  final edges = <String>{};

  while (edges.length < edgeCount) {
    int u = rng.nextInt(n);
    int v = rng.nextInt(n);
    if (u != v) {
      int a = u < v ? u : v;
      int b = u < v ? v : u;
      String edgeKey = '$a-$b';
      if (!edges.contains(edgeKey)) {
        edges.add(edgeKey);
        graph.addEdge(a, b);
      }
    }
  }
  return graph;
}
