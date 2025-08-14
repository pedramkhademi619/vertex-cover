import 'graph.dart';

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
