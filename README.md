[# Vertex Cover Algorithms in Dart

This repository contains multiple implementations of the **Vertex Cover** problem, including approximation, exact, and metaheuristic algorithms.  
It is intended as a learning resource and a practical toolkit for experimenting with small and large graphs.

---

## 📌 Table of Contents
1. [Problem Definition](#problem-definition)  
2. [Repository Structure](#repository-structure)  
3. [Algorithms Implemented](#algorithms-implemented)  
   - [2-Approximation](#1-2-approximation-algorithm)  
   - [Exact Branch-and-Bound](#2-exact-branch-and-bound)  
   - [Local Search (Metaheuristic)](#3-local-search-metaheuristic)  
4. [Graph Model](#graph-model)  
5. [Random Graph Generator](#random-graph-generator)  
6. [Running the Project](#running-the-project)  
7. [Complexity Summary](#complexity-summary)  
8. [Known Issues & Improvements](#known-issues--possible-improvements)  
9. [License](#license)

---

## Problem Definition

A **vertex cover** of an undirected graph  
\[
G = (V, E)
\]  
is a set  
\[
C \subseteq V
\]  
such that every edge \((u,v) \in E\) has at least one endpoint in \(C\).

The goal of **Minimum Vertex Cover (MVC)** is:

> Find the smallest possible set \(C\) that covers all edges.

### 🔹 Key facts
- MVC is **NP-hard**.  
- For bipartite graphs, MVC equals the size of the **maximum matching** (Kőnig’s theorem).  
- Approximations, exact algorithms, and heuristics are common in practice.

---

## Repository Structure

lib/
│
├─ model/
│ ├─ graph.dart # Graph data structure (adj list, edges)
│ ├─ generate_random_graph.dart # Random graph generator
│
├─ two_approx.dart # 2-approximation algorithm
├─ exact_solver.dart # Exact branch & bound solver
├─ local_search.dart # Local search / metaheuristic solver
│
├─ main_two_approx.dart # Example: run 2-approx
├─ main_exact.dart # Example: run exact solver
├─ main_local_search.dart # Example: run local search solver

---

## Algorithms Implemented

---

# 1. **2-Approximation Algorithm**

### 📘 Theory

This classic greedy algorithm repeatedly:

1. Picks an uncovered edge \((u, v)\)  
2. Adds **both** endpoints to the vertex cover  
3. Removes all edges incident to either vertex  

This ensures:

\[
|C| \le 2 \cdot OPT
\]

Because selected edges form a matching, and every matching edge requires at least one vertex in any optimal solution.

### ⏱ Complexity  
**O(E)** (linear time)

### 🧩 Code Snippet

```dart
Set<int> twoApprox(Graph.Graph graph) {
  Set<int> C = {};
  List<List<int>> edges =
      graph.edges.map((e) => [e[0], e[1]]).toList(); // deep copy

  while (edges.isNotEmpty) {
    var edge = edges.first;
    int u = edge[0], v = edge[1];

    C.add(u);
    C.add(v);

    edges.removeWhere((e) => e.contains(u) || e.contains(v));
  }

  return C;
}
2. Exact Branch-and-Bound

An exponential-time exact algorithm with heavy pruning.

📘 Theory

Uses:

Recursive branching:

Include vertex v

Exclude v → add all neighbors

Lower bound:

𝐿
𝐵
=
∣
𝐶
∣
+
⌈
𝑟
𝑒
𝑚
𝑎
𝑖
𝑛
𝑖
𝑛
𝑔
𝐸
𝑑
𝑔
𝑒
𝑠
𝑚
𝑎
𝑥
𝐷
𝑒
𝑔
𝑟
𝑒
𝑒
⌉
LB=∣C∣+⌈
maxDegree
remainingEdges
	​

⌉

Memoization of lower bound states.

✔ When pruning occurs?

If current cover ≥ best found

If lower bound ≥ best found

If all vertices processed and solution is valid

⏱ Complexity

Worst-case O(2ⁿ), but fast for small graphs.

🧩 Code Snippet (simplified)
void branchAndBound(Set<int> currentCover, int v) {
  if (currentCover.length >= bestSize) return;
  if (lowerBound(currentCover, v) >= bestSize) return;

  if (v == graph.n) {
    if (isCovered(currentCover)) {
      bestSize = currentCover.length;
      bestCover = {...currentCover};
    }
    return;
  }

  // include v
  currentCover.add(v);
  branchAndBound(currentCover, v + 1);
  currentCover.remove(v);

  // exclude v -> add neighbors
  List<int> added = [];
  for (int u in graph.adj[v]) {
    if (!currentCover.contains(u)) {
      currentCover.add(u);
      added.add(u);
    }
  }

  branchAndBound(currentCover, v + 1);

  for (int u in added) currentCover.remove(u);
}
3. Local Search (Metaheuristic)

Inspired by modern MVC solvers such as NuMVC and FastVC.

📘 Theory (high-level)

Start with an initial cover (using a greedy method).

Reduce solution by flipping vertices:

Remove a vertex if its removal doesn’t uncover edges.

If edges become uncovered, add a vertex from the edge with the best score.

Maintain:

dscore(v): change in objective when flipping v

confChange(v): configuration checking to avoid cycles

uncovered: tracked incrementally

🎯 Objective function:
𝑓
=
∣
𝐶
∣
+
∣
𝑢
𝑛
𝑐
𝑜
𝑣
𝑒
𝑟
𝑒
𝑑
𝐸
𝑑
𝑔
𝑒
𝑠
∣
f=∣C∣+∣uncoveredEdges∣
🧩 Properties

Very fast for large graphs

No optimality guarantee

Often finds near-optimal solutions

Incremental update cost: O(deg(v))

🧩 Code Snippet (core part)
void _applyFlip(int v) {
  if (cover.contains(v)) {
    cover.remove(v);
    for (int u in graph.adj[v]) {
      if (!cover.contains(u)) uncovered.add("$v-$u");
      confChange[u] = true;
    }
  } else {
    cover.add(v);
    uncovered.removeWhere((e) {
      var parts = e.split('-');
      int a = int.parse(parts[0]), b = int.parse(parts[1]);
      return a == v || b == v;
    });
    for (int u in graph.adj[v]) confChange[u] = true;
  }
  confChange[v] = false;
}
Random Graph Generator

File: generate_random_graph.dart

Features

Generate graph with n nodes and m edges

Optional random seed

Ensures no self-loops or parallel edges

Example
Graph g = generateRandomGraph(50, 120, 42);

Running the Project

Run any solver from command line:

# 2-approximation
dart run lib/main_two_approx.dart

# Exact solver
dart run lib/main_exact.dart

# Local search solver
dart run lib/main_local_search.dart


Example inside main_local_search.dart:

void main() {
  var g = generateRandomGraph(65, 150, 0);
  var solver = LocalSearchMVC(g, seed: 0);
  var cover = solver.solve(maxSteps: 10000);

  print("Cover size = ${cover.length}");
  print(cover.toList()..sort());
}

Complexity Summary
Algorithm	Guarantee	Typical Complexity	Notes
2-Approx	≤ 2×OPT	O(E)	Fast & deterministic
Exact BnB	Optimal	Exponential	Good for small graphs
Local Search	No guarantee	User-controlled (steps)	Great for large graphs
Known Issues & Possible Improvements
✔ two_approx edge copy

Use deep copy to avoid mutating the real graph.

✔ Lower bound is basic

Could be improved with:

Maximum matching lower bound

Crown rule reductions

Kernelization

✔ Memoization uses large string keys

Bitmask representation would be faster and smaller.

✔ Local search uncovered set uses "u-v" strings

Better representation:

Pair struct

Integer encoding

Direct adjacency flags

✔ Move heuristics to separate strategy classes

To allow:

WalkSAT-like behavior

Probabilistic diversification

Multiple initial covers

License

MIT License
You are free to use and modify the code.

If you want, I can also generate:

✅ A PDF documentation
✅ UML diagrams
✅ Graph visualizations
✅ Benchmarks chart
✅ Example input/output files
✅ Code cleanup + refactor
](https://github.com/pedramkhademi619/vertex-cover)
