#define INF 1000000

#include <iostream>

#include <vector>
#include <list>
#include <deque>
#include <algorithm>
#include <string>

#include "FibonacciHeap.cpp"

unsigned long long countDijkstra;

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

    ShortestPaths(int n, int src) : src(src), y(n + 1), p(n + 1) { }

    
    ShortestPath* GetPath(int dest) {
        ShortestPath* result = new ShortestPath(y[dest]);
        for(int i=dest; p[i] > -1; i = p[i]) {
            result->path.push_front(i);   
            countDijkstra++;
        }
        result->path.push_front(src);
        countDijkstra++;
        return result;
    }
    
};

struct Graph {
    std::vector<std::list<Edge> > G;
    int n;
    Graph(int n) : n(n + 1), G(n + 1) { }

    void AddEdge(int src, int dest, int cost) {
        this->G[src].push_back(Edge(dest, cost));
        countDijkstra++;
        //cout << "adicionado vertice " << src << " " << dest << ", custo: " << cost << endl;   
    }

    ShortestPaths* DijkstraHeap(int src) {
        int y[this->n], p[this->n];
        FibonacciHeap* heap = new FibonacciHeap();
        FibonacciHeapNode* nodes[this->n];

        int value = 0;        
        for(int i=0; i<this->n; i++) { 
            value = ((i==src)?0:INF);
            countDijkstra++;
            y[i] = value;
            countDijkstra++;
            p[i] = -1;
            countDijkstra++;
            nodes[i] = new FibonacciHeapNode(i, value);
            heap->insert(nodes[i]);
        }
        
        while(heap->nNodes>0) {
            //temp = countHeap;
            FibonacciHeapNode* node = heap->removeMin();
            countDijkstra++;

            //countOp1 += countHeap - temp;

            countDijkstra++;
            for(std::list<Edge>::iterator j = this->G[node->data].begin(); j != this->G[node->data].end(); j++) {
                int aux = y[node->data] + j->cost;
                countDijkstra++;
                if (aux < y[j->dest]) {
                    countDijkstra++;
                    y[j->dest] = aux;
                    countDijkstra++;

              //      temp = countHeap;
                    heap->decreaseKey(nodes[j->dest], aux);
              //      countOp2 += countHeap - temp;

                    p[j->dest] = node->data;
                    countDijkstra++;
                }
            }
            countDijkstra++;

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

    ShortestPaths* Dijkstra(int src) {
        int y[this->n], p[this->n];
        bool can[this->n];
        
        for(int i=0; i<this->n; i++) { 
            y[i] = INF; 
            countDijkstra++;
            p[i] = -1; 
            countDijkstra++;
            can[i] = true;
            countDijkstra++;
        }
        y[src] = 0;
        countDijkstra++;
        
        for(int i=0; i<this->n; i++) {
            countDijkstra++;

            int min = -1;
            countDijkstra++;

            for(int j=0; j<this->n; j++) {
                countHeap++;
                if (((countHeap++,min == -1) || 
                     (countHeap++,y[j] < y[min])) && 
                     (countHeap++,can[j])) {
                    min = j;
                    countHeap++;
                } 
            }
    
            can[min] = false;
            countDijkstra++;            
 
            for(list<Edge>::iterator j = this->G[min].begin(); j != this->G[min].end(); j++) {
                countDijkstra++;
                
                if (y[min] + j->cost < y[j->dest]) {
                    countDijkstra++;
                    y[j->dest] = y[min] + j->cost;
                    countDijkstra++;
                    p[j->dest] = min;   
                    countDijkstra++;
                }
            }
        }
        
        ShortestPaths* result = new ShortestPaths(this->n, src);
        for(int i=0; i<this->n; i++) {
            result->y[i] = y[i];
            result->p[i] = p[i];
        }
        
        return result;
    }


};
