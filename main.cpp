#include <iostream>
#include "Dijkstra.cpp"

using namespace std;

int main() {
    int n, m, a, b, c;

    while(cin >> n >> m, n||m) {
        Graph* graph = new Graph(n);
        
        for(int i=0; i<m; i++) {
            cin >> a >> b >> c;
            graph->AddEdge(a, b, c);
        }
        
        while(cin >> a >> b, a||b) {
            ShortestPaths* allPaths = graph->Dijkstra(a);
            ShortestPath* onePath = allPaths->GetPath(b);
            
            cout << "Custo: " << onePath->cost << endl;
            cout << "Caminho: "; 
                onePath->Print(cout, 0); 
                cout << endl;
                
            delete(allPaths);
            delete(onePath);
        }
        
        delete(graph);
    }
}
