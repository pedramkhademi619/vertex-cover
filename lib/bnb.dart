import 'dart:io';

import 'model/graph.dart';
import 'model/generate_random_graph.dart';

// Defines the vertex cover solver class
class VertexCoverSolver {
  final Graph graph;
  int bestSize = 1 << 30; // Very large initial value for the optimal cover size
  Set<int>? bestCover; // The best vertex cover set found

  // Cache for memoization
  final Map<String, int> lbCache = {};

  VertexCoverSolver(this.graph);

  // Checks if all edges are covered by the given set
  bool isCovered(Set<int> cover) {
    for (int vertex = 0; vertex < graph.n; vertex++) {
      for (int neighbor in graph.adj[vertex]) {
        if (vertex < neighbor &&
            !cover.contains(vertex) &&
            !cover.contains(neighbor)) {
          return false; // Found an uncovered edge
        }
      }
    }
    return true; // All edges are covered
  }

  // Computes the lower bound using memoization
  int lowerBound(Set<int> currentCover, int startVertex) {
    // Create a unique key for caching
    final key = '$startVertex:${currentCover.toList()..sort()}';
    if (lbCache.containsKey(key)) return lbCache[key]!; // Return cached result

    int remainingEdges = 0; // Number of uncovered edges
    int maxDegree = 0; // Maximum degree among remaining vertices

    // Count uncovered edges
    for (int v = startVertex; v < graph.n; v++) {
      for (int u in graph.adj[v]) {
        if (v < u && !currentCover.contains(v) && !currentCover.contains(u)) {
          remainingEdges++; // Increment uncovered edge count
        }
      }
    }

    // Find the maximum degree among remaining vertices
    for (int v = startVertex; v < graph.n; v++) {
      if (!currentCover.contains(v)) {
        int deg = graph.adj[v].where((u) => !currentCover.contains(u)).length;
        if (deg > maxDegree) maxDegree = deg;
      }
    }

    int result;
    if (maxDegree == 0) {
      result = currentCover.length; // All edges are covered
    } else {
      int extraNeeded = (remainingEdges + maxDegree - 1) ~/ maxDegree;
      result = currentCover.length + extraNeeded;
    }

    lbCache[key] = result; // Cache the result
    return result;
  }

  // Branch and Bound algorithm
  void branchAndBound(Set<int> currentCover, int vertex) {
    // Prune if current cover size is not better than the best found
    if (currentCover.length >= bestSize) return;

    // Prune using lower bound
    if (lowerBound(currentCover, vertex) >= bestSize) return;

    // If all vertices have been processed
    if (vertex == graph.n) {
      if (isCovered(currentCover)) {
        bestSize = currentCover.length;
        bestCover = Set.from(currentCover);
      }
      return;
    }

    // Case 1: Include the current vertex
    currentCover.add(vertex);
    branchAndBound(currentCover, vertex + 1);
    currentCover.remove(vertex);

    // Case 2: Exclude the current vertex but include its neighbors
    List<int> addedNeighbors = [];
    for (int neighbor in graph.adj[vertex]) {
      if (!currentCover.contains(neighbor)) {
        currentCover.add(neighbor);
        addedNeighbors.add(neighbor);
      }
    }
    branchAndBound(currentCover, vertex + 1);

    // Undo changes
    for (int n in addedNeighbors) {
      currentCover.remove(n);
    }
  }

  // Solves the vertex cover problem
  Set<int>? solve() {
    branchAndBound(<int>{}, 0);
    return bestCover;
  }
}

void main() async {
  Stopwatch stopwatch = Stopwatch()..start();
  // Graph graph = Graph(0);
  // graph = await graph.readGraphFromInputFile();
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
  Graph graph = generateRandomGraph(65, 150, 0);

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
  print(Directory.current.path);

  graph.saveCoverToFile(cover!);
  print('Execution time: ${stopwatch.elapsedMilliseconds} ms');
}
