#include <iostream>
#include "Dijkstra.cpp"

using namespace std;

int main() {
    int n, m;
    cin >> n >> m;
    
    Graph* graph = new Graph(n, m);
    
    int a, b, c;
    for(int i=0; i<m; i++) {
        cin >> a >> b >> c;
        graph->AddEdge(a-1, b-1, c);
    }
    
    while(true) {
        cin >> a >> b;
        if (a==0 && b==0) break;
        
        ShortestPath* path = graph->Dijkstra(a-1)->GetPath(b-1);
        
        cout << "Custo: " << path->cost << endl;
        cout << "Caminho:";
            path->Print(cout, +1);
            cout << endl;
    }

   
}
