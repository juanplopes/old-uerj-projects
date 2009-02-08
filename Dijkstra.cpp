#define INF 1000000

#include <iostream>

#include <vector>
#include <list>
#include <deque>
#include <algorithm>
#include <string>
#include "FibonacciHeap.cpp"

struct Edge {
    int dest, cost;
    Edge(int dest, int cost) : dest(dest), cost(cost) { }
};

struct ShortestPath {
    int cost;
    std::deque<int> path;
    ShortestPath(int cost) : cost(cost) { }
    
    void Print(ostream &stream, int bias) {
        for(int i=0; i<path.size(); i++) {
            if (i>0) 
                stream << " ";
            
            stream << path[i]+bias;
        }
    }
};

struct ShortestPaths {
    int src;
    std::vector<int> y;
    std::vector<int> p;

    ShortestPaths(int n, int src) : src(src), y(n), p(n) { }
    
    ShortestPath* GetPath(int dest) {
        ShortestPath* result = new ShortestPath(y[dest]);
        for(int i=dest; p[i] > -1; i = p[i]) {
            result->path.push_front(i);   
        }
        result->path.push_front(src);
        return result;
    }
    
};

struct Graph {
    std::vector<std::list<Edge> > G;
    int n;
    Graph(int n) : n(n), G(n) { }

    void AddEdge(int src, int dest, int cost) {
        this->G[src].push_back(Edge(dest, cost));   
    }

    ShortestPaths* Graph::Dijkstra(int src) {
        int y[this->n], p[this->n];
        FibonacciHeap* heap = new FibonacciHeap();
        FibonacciHeapNode* nodes[this->n];

        int value = 0;        
        for(int i=0; i<this->n; i++) { 
            value = ((i==src)?0:INF);
            y[i] = value; 
            p[i] = -1; 
            nodes[i] = new FibonacciHeapNode(i, value);
            heap->insert(nodes[i]);
        }
        
        while(heap->nNodes>0) {
            FibonacciHeapNode* node = heap->removeMin();
            
            for(std::list<Edge>::iterator j = this->G[node->data].begin(); j != this->G[node->data].end(); j++) {
                if (y[node->data] + j->cost < y[j->dest]) {
                    cout << "atualizando " << j->dest << " com " << y[node->data] + j->cost << endl;
                    y[j->dest] = y[node->data]+j->cost;
                    heap->decreaseKey(nodes[j->dest], y[j->dest]);
                    p[j->dest] = node->data;
                }
            }
        }
        
        delete(heap);
        for(int i=0; i<this->n; i++)
            delete(nodes[i]);
        
        ShortestPaths* result = new ShortestPaths(this->n, src);
        for(int i=0; i<this->n; i++) {
            result->y[i] = y[i];
            result->p[i] = p[i];
        }
        
        return result;
    }

};
