import 'model/graph.dart' as Graph;
import 'model/generate_random_graph.dart';

Set<int> twoApprox(Graph.Graph graph) {
  Set<int> C = {};
  List<List<int>> edges = List.from(graph.edges);

  while (edges.isNotEmpty) {
    List<int> edge = edges[0];
    int u = edge[0];
    int v = edge[1];

    C.add(u);
    C.add(v);

    edges.removeWhere((_edge) => _edge.contains(u) || _edge.contains(v));
  }

  return C;
}

main() {
  Stopwatch stopwatch = Stopwatch()..start();

  Graph.Graph graph = generateRandomGraph(20, 50, 0);
  graph.show();
  Set<int> C = twoApprox(graph);
  print('2-approximation Vertex Cover size: ${C.length}');
  print('Vertices in the cover:');
  for (int i in C) {
    print(i);
  }
  print('Execution time: ${stopwatch.elapsedMilliseconds} ms');
}
