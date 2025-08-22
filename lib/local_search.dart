import 'dart:math';
import 'dart:io';

import 'model/generate_random_graph.dart';
import 'model/graph.dart';

class LocalSearchMVC {
  final Graph graph;
  final Random rng;

  // uncovered edges set (by key "u-v" with u < v)
  final Set<String> uncovered = {};
  // current cover
  final Set<int> cover = {};
  // best found
  Set<int> bestCover = {};
  int bestSize = 1 << 30;

  // configuration checking: allow a vertex to change only if a neighbor changed recently
  late List<bool> confChange;

  LocalSearchMVC(this.graph, {int? seed})
    : rng = Random(seed ?? DateTime.now().millisecondsSinceEpoch) {
    confChange = List<bool>.filled(graph.n, true);
  }

  // ---- Utilities ----
  String _ek(int a, int b) {
    final u = a < b ? a : b;
    final v = a < b ? b : a;
    return '$u-$v';
  }

  void _recomputeUncovered() {
    uncovered.clear();
    for (int u = 0; u < graph.n; u++) {
      for (final v in graph.adj[u]) {
        if (u < v) {
          if (!(cover.contains(u) || cover.contains(v))) {
            uncovered.add(_ek(u, v));
          }
        }
      }
    }
  }

  // initial cover: greedy by edges (pair-add)
  void _buildInitialCover() {
    cover.clear();
    _recomputeUncovered();
    while (uncovered.isNotEmpty) {
      final e = uncovered.elementAt(rng.nextInt(uncovered.length));
      final parts = e.split('-');
      final u = int.parse(parts[0]);
      final v = int.parse(parts[1]);
      cover.add(u);
      cover.add(v);
      confChange[u] = false;
      confChange[v] = false;
      for (final w in graph.adj[u]) confChange[w] = true;
      for (final w in graph.adj[v]) confChange[w] = true;
      _recomputeUncovered();
    }
    _tryRemoveRedundant();
    bestCover = Set<int>.from(cover);
    bestSize = bestCover.length;
  }

  // objective f(C) = |C| + |uncovered|
  int _objective() {
    return cover.length + uncovered.length;
  }

  // dscore: change in objective if we flip membership of v
  int _dscore(int v) {
    int delta = 0;
    if (cover.contains(v)) {
      // remove v
      delta -= 1;
      for (final u in graph.adj[v]) {
        if (!cover.contains(u)) {
          delta += 1; // uncovered edge penalty
        }
      }
    } else {
      // add v
      delta += 1;
      for (final u in graph.adj[v]) {
        if (!cover.contains(u)) {
          if (uncovered.contains(_ek(v, u))) delta -= 1;
        }
      }
    }
    return delta; // more negative = better
  }

  // remove redundant vertices while still covering all edges
  void _tryRemoveRedundant() {
    bool changed = true;
    while (changed) {
      changed = false;
      for (final v in List<int>.from(cover)) {
        bool ok = true;
        for (final u in graph.adj[v]) {
          if (!cover.contains(u)) {
            ok = false;
            break;
          }
        }
        if (ok) {
          cover.remove(v);
          confChange[v] = false;
          for (final w in graph.adj[v]) confChange[w] = true;
          changed = true;
        }
      }
    }
    _recomputeUncovered();
  }

  int? _pickRemoval() {
    int? bestV;
    int bestDelta = 1 << 30;
    for (final v in cover) {
      if (!confChange[v]) continue;
      final d = _dscore(v);
      if (d < bestDelta) {
        bestDelta = d;
        bestV = v;
      }
    }
    return bestV;
  }

  int? _pickAdditionOnUncovered() {
    if (uncovered.isEmpty) return null;
    final chosen = uncovered.elementAt(rng.nextInt(uncovered.length));
    final parts = chosen.split('-');
    final u = int.parse(parts[0]);
    final v = int.parse(parts[1]);

    final du = _dscore(u);
    final dv = _dscore(v);
    if (confChange[u] && (!confChange[v] || du <= dv)) return u;
    if (confChange[v]) return v;
    return du <= dv ? u : v;
  }

  void _applyFlip(int v) {
    if (cover.contains(v)) {
      cover.remove(v);
    } else {
      cover.add(v);
    }
    confChange[v] = false;
    for (final u in graph.adj[v]) confChange[u] = true;
    _recomputeUncovered();
  }

  Set<int> solve({int maxSteps = 300000, Duration? timeLimit}) {
    final start = DateTime.now();
    _buildInitialCover();

    for (int step = 0; step < maxSteps; step++) {
      if (timeLimit != null && DateTime.now().difference(start) >= timeLimit) {
        break;
      }

      if (uncovered.isEmpty) {
        _tryRemoveRedundant();
        if (cover.length < bestSize) {
          bestSize = cover.length;
          bestCover = Set<int>.from(cover);
        }
        final r = _pickRemoval();
        if (r != null) {
          _applyFlip(r);
        } else {
          _applyFlip(cover.elementAt(rng.nextInt(cover.length)));
        }
      } else {
        final addV = _pickAdditionOnUncovered();
        if (addV != null) {
          if (!cover.contains(addV)) {
            _applyFlip(addV);
          } else {
            final e = uncovered.first;
            final p = e.split('-').map(int.parse).toList();
            final cand = !cover.contains(p[0]) ? p[0] : p[1];
            _applyFlip(cand);
          }
        }
      }
    }

    cover
      ..clear()
      ..addAll(bestCover);
    _tryRemoveRedundant();
    return Set<int>.from(cover);
  }
}

// save to file
void saveCoverToFile(Set<int> cover, {String path = 'output.txt'}) {
  final file = File(path);
  file.writeAsStringSync(cover.map((v) => v.toString()).join('\n'));
}

void main() {
  Stopwatch stopwatch = Stopwatch()..start();
  final graph = generateRandomGraph(650, 1500, 0);

  print("Graph generated:");
  graph.show();

  // الگوریتم Local Search
  final solver = LocalSearchMVC(graph, seed: 42);
  final cover = solver.solve(maxSteps: 10000);

  print("\nFound Vertex Cover (size = ${cover.length}):");
  print(cover);

  // ذخیره خروجی در فایل
  // saveCoverToFile(cover, path: 'output.txt');
  print("\nResult saved to output.txt");
  print("Execution Time: ${stopwatch.elapsedMilliseconds} ms");
}
