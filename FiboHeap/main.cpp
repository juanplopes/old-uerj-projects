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



int main() {
    int n, m, a, b, c;
    n = m = a = b = c = 0;
    double inicio , fim;
    char arquivo[500];

    cout << "Digite o nome do arquivo com os dados do grafo." << endl;
    cin >> arquivo;
    
    ifstream fin(arquivo , ios::binary);
    
    fin >> n >> m;
    cout << n << " " << m << endl;
    Graph* graph = new Graph(n);
        
    for(int i=0; i<m; i++) {
        fin >> a >> b >> c;
        graph->AddEdge(a, b, c);
    }
    cout << "Todos os vertices foram adicionados" << endl << endl;
        
    cout << "Digite s (saida) e t (destino). 0 0 para sair" << endl;
    while(cin >> a >> b, a||b) {
        inicio = ftime();
        ShortestPaths* allPaths = graph->Dijkstra(a);
        ShortestPath* onePath = allPaths->GetPath(b);
                
        cout << "Custo: " << onePath->cost << endl;
        cout << "Caminho: "; 
        onePath->Print(cout, 0); 
        cout << endl;
        delete(allPaths);
        delete(onePath);
                
        fim = ftime();
        cout << inicio << " " << fim << endl;
        cout << "Tempo gasto para execucao: " << (fim - inicio) * 1000 << " milisegundos" << endl;
        cout << "Numero de operacoes elementares = " << countHeap + countDjikstra << endl;
        
        countHeap = 0;
        countDjikstra = 0;
        cout << "Digite s (saida) e t (destino). 0 0 para sair." << endl;
    }
        
    delete(graph);
    system("pause");
}
