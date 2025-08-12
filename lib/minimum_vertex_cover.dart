import 'graph.dart';

class VertexCoverSolver {
  final Graph graph;
  int bestSize = 1 << 30; // بزرگ فرض می‌کنیم
  Set<int>? bestCover;

  VertexCoverSolver(this.graph);

  // چک کن همه لبه‌ها توسط set پوشش داده شده؟
  bool isCovered(Set<int> cover) {
    for (int vertex = 0; vertex < graph.n; vertex++) {
      for (int neighbor in graph.adj[vertex]) {
        if (vertex < neighbor &&
            !cover.contains(vertex) &&
            !cover.contains(neighbor)) {
          return false;
        }
      }
    }
    return true;
  }

  void branchAndBound(Set<int> currentCover, int vertex) {
    // اگر اندازه راه حل فعلی از بهترین بزرگتر است، قطع کن
    if (currentCover.length >= bestSize) return;

    // اگر همه رئوس بررسی شدند
    if (vertex == graph.n) {
      if (isCovered(currentCover)) {
        bestSize = currentCover.length;
        bestCover = Set.from(currentCover);
      }
      return;
    }

    // حالت 1: رأس current را در مجموعه قرار بده
    currentCover.add(vertex);
    branchAndBound(currentCover, vertex + 1);
    currentCover.remove(vertex);

    // حالت 2: رأس current را نگذار
    // اما باید همه ی لبه‌هایی که از vertex شروع می‌شوند پوشش داده شوند
    // یعنی باید همسایگان vertex را در مجموعه قرار دهیم
    // اگر همسایگان از قبل در مجموعه نبودند اضافه می‌کنیم و بعد حذف می‌کنیم

    // ذخیره همسایگان اضافه شده
    List<int> addedNeighbors = [];
    for (int neighbor in graph.adj[vertex]) {
      if (!currentCover.contains(neighbor)) {
        currentCover.add(neighbor);
        addedNeighbors.add(neighbor);
      }
    }

    branchAndBound(currentCover, vertex + 1);

    // حذف همسایگان اضافه شده بعد از بازگشت
    for (int n in addedNeighbors) {
      currentCover.remove(n);
    }
  }

  Set<int>? solve() {
    branchAndBound(<int>{}, 0);
    return bestCover;
  }
}

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

  graph.show();

  // اجرای الگوریتم branch and bound یا هر الگوریتم دیگه
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
  print('Execution time: ${stopwatch.elapsedMilliseconds} ms');
}
