#include <iostream>
#include <fstream>
#include <time.h>
#include <windows.h>
#include "Dijkstra.cpp"

using namespace std;

double ftime() 
{
	double velocidade, valor;
	
    QueryPerformanceFrequency((LARGE_INTEGER *) &velocidade);
	QueryPerformanceCounter((LARGE_INTEGER *) &valor);
	
    return valor/velocidade;  
}

void miolo(bool semHeap, Graph* graph, int a, int b) {
    cout << "*** DIJKSTRA " << (semHeap?"NORMAL":"COM HEAP") << " ***" << endl;

    double inicio = ftime();
    countHeap = 0; countOp1 = 0; countOp2 = 0;
    countDijkstra = 0;

    ShortestPaths* allPaths = (semHeap?graph->Dijkstra(a):graph->DijkstraHeap(a));
    ShortestPath* onePath = allPaths->GetPath(b);
            
    cout << "Custo: " << onePath->cost << endl;
    cout << "Caminho: "; 
    onePath->Print(cout, 0); 
    cout << endl;
    delete(allPaths);
    delete(onePath);
            
    double fim = ftime();
    
    cout << "Tempo gasto para execucao: " << (fim - inicio) * 1000 << " milisegundos" << endl;
    cout << "Numero de operacoes elementares (D+H) = " << countDijkstra << " + " << countHeap << " = " << countDijkstra + countHeap << endl;
    cout << endl;
}


int main() {
    int n, m, a, b, c;
    n = m = a = b = c = 0;
    double inicio , fim;
    char arquivo[500];

    cout << "Digite o nome do arquivo com os dados do grafo." << endl;
    cin >> arquivo;
    
    ifstream fin(arquivo , ios::binary);
    
    fin >> n >> m;
    Graph* graph = new Graph(n);
        
    for(int i=0; i<m; i++) {
        fin >> a >> b >> c;
        graph->AddEdge(a, b, c);
    }
    cout << "Todos os vertices foram adicionados" << endl;
    cout << " n=" << n << ", m=" << m << endl << endl;        

    while(true) {
        cout << "Digite s (saida) e t (destino). 0 0 para sair" << endl;
        cin >> a >> b; if (!a && !b) break;
        miolo(true, graph, a, b);
        miolo(false, graph, a, b);
    }
        
    delete(graph);
}
