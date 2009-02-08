#include <iostream>
#include "Dijkstra.h"

using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    
    Graph* graph = new Graph(n);
    
    int a, b, c;
    for(int i=0; i<m; i++) {
        cin >> a >> b >> c;
        graph->AddEdge(a-1, b-1, c);
    }
    
    while(true) {
        cin >> a >> b;
        if (a==0 && b==0) break;
        
        ShortestPaths* allPaths = graph->Dijkstra(a-1);
        ShortestPath* onePath = allPaths->GetPath(b-1);
        
        cout << "Custo: " << onePath->cost << endl;
        cout << "Caminho: ";
            onePath->Print(cout, +1);
            cout << endl;
            
        delete(allPaths);
        delete(onePath);
    }
    
    delete(graph);

   
}
