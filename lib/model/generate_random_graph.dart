import 'dart:math';
import 'graph.dart';

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
