#include <iostream>
#include <math.h>
#include <vector>
#define ONE_OVER_LOG_PHI 4.78497196678f

using namespace std;

unsigned long long countHeap;

class FibonacciHeapNode{
    public:
        int data;
        FibonacciHeapNode *child;
        FibonacciHeapNode *left;
        FibonacciHeapNode *parent;
        FibonacciHeapNode *right;
        bool mark;
        int key;
        int degree;

        FibonacciHeapNode(int d, int k): data(d),key(k),degree(0),child(NULL),parent(NULL){
            right = this;
            countHeap++;
            left = this;
            countHeap++;
        }

        FibonacciHeapNode(){}

        int getKey(){ return key; }

        int getData(){ return data; }
};

class FibonacciHeap{
    public:
        FibonacciHeapNode *minNode;
        int nNodes;
        
        FibonacciHeap(): minNode(NULL), nNodes(0){}

        bool isEmpty(){ return (minNode == NULL); }

        void insert(FibonacciHeapNode *node/*, int key*/){
            ////node->key = key;

            // concatenate node into min list
            if (minNode != NULL) {
                countHeap++;
                node->left = minNode;
                countHeap++;
                node->right = minNode->right;
                countHeap++;
                minNode->right = node;
                countHeap++;
                node->right->left = node;
                countHeap++;

                if ( node->key < minNode->key){
                     minNode = node;
                     countHeap++;
                }
            } else {
                minNode = node;
                countHeap++;
                minNode->left = minNode;
                countHeap++;
                minNode->right = minNode;
                countHeap++;
            }
            nNodes++;
            countHeap++;
            //cout << "inserido no com chave " << node->key << " valor = " << node->data << " na heap" << endl;
        }

        FibonacciHeapNode* removeMin(){
            FibonacciHeapNode* z = minNode;
            countHeap++;
            if (z != NULL) {
                countHeap++;
                int numKids = z->degree;
                countHeap++;
                FibonacciHeapNode *x = z->child;
                countHeap++;
        		FibonacciHeapNode *tempRight;

                // get children of z to root lost
        
                if ( numKids > 0) {
                    countHeap++;
                    tempRight = z->right;
                    countHeap++;
                    x->left->right = tempRight;
                    countHeap++;
                    tempRight->left = x->left;
                    countHeap++;
                    x->left = z;
                    countHeap++;
                    z->right = x;
                    countHeap++;
                }

                // for each child of z do...
                while (numKids > 0) {
                    //tempRight = x->right;

                    // remove x from child list
                    //x->left->right = x->right;
                    //x->right->left = x->left;

                    // add x to root list of heap
                    //x->left = minNode;
                    //x->right = minNode->right;
                    //minNode->right = x;
                    //x->right->left = x;

                    // set parent[x] to NULL
                    x->parent = NULL;
                    countHeap++;
                    //x = tempRight;
                    x = x->right;
                    countHeap++;
                    numKids--;
                    countHeap++;
                }

                // remove z from root list of heap
                z->left->right = z->right;
                countHeap++;
                z->right->left = z->left;
                countHeap++;

                if (z == z->right){
                      minNode = NULL;
                      countHeap++;
                }
                else {
                    minNode = z->right;
                    countHeap++;
    
                    consolidate();

                }

                // decrement size of heap
                nNodes--;
                countHeap++;
            }
            //cout << "chave minimo valor = " << z->key << " noh = " << z->data << endl;
            //cout << "minNode agora eh " << (minNode!=NULL?minNode->data:-1) << "(con)" <<endl;
            return z;
        }
    
    
        void link(FibonacciHeapNode* y, FibonacciHeapNode* x){
            // remove y from root list of heap
            y->left->right = y->right;
            countHeap++;
            y->right->left = y->left;
            countHeap++;

            // make y a child of x
            y->parent = x;
            countHeap++;

			if (x->child == NULL){
               x->child = y->right = y->left = y;
               countHeap++;   
            }
			else {
                y->left = x->child;
                countHeap++;
                y->right = x->child->right;
                countHeap++;
                x->child->right = y->right->left = y;
                countHeap++;
            }

            // increase degree[x]
            x->degree++;
            countHeap++;

            // set mark[y] false
            y->mark = false;
            countHeap++;
         }
    
        void cut(FibonacciHeapNode* x, FibonacciHeapNode* y){
            //cout << "cortando noh " << x->data << " de " << y->data<< endl;
            
            // remove x from childlist of y and decrement degree[y]
            x->left->right = x->right;
            countHeap++;
            x->right->left = x->left;
            countHeap++;
            y->degree--;
            countHeap++;

            // reset y.child if necessary
            if (y->child == x){
               countHeap++;
               y->child = x->right;
               countHeap++;
            }
            if (y->degree == 0){
               countHeap++;
               y->child = NULL;
               countHeap++;
            }

            // add x to root list of heap
            x->left = minNode;
            countHeap++;
            x->right = minNode->right;
            countHeap++;
            minNode->right = x;
            countHeap++;
            x->right->left = x;
            countHeap++;

            // set parent[x] to nil
            x->parent = NULL;
            countHeap++;

            // set mark[x] to false
            x->mark = false;
            countHeap++;
        }
    
        void consolidate(){

  //        int arraySize = nNodes;
            
           int arraySize =
                ((int) floor(log(nNodes) * ONE_OVER_LOG_PHI)) + 1;

            
            countHeap++;
            vector<FibonacciHeapNode*> array(arraySize);
            countHeap++;
            // Initialize degree array

            // Find the number of root nodes.

            int numRoots = 0;
            countHeap++;
            FibonacciHeapNode *x = minNode;
            countHeap++;
            if (x != NULL) {
                countHeap++;
                numRoots++;
                countHeap++;
                x = x->right;
                countHeap++;
                while (x != minNode) {
                    countHeap++;
                    numRoots++;
                    countHeap++;
                    x = x->right;
                    countHeap++;
                }
            }
            

            // For each node in root list do...
            while (numRoots > 0) {
                countHeap++;
                // Access this node's degree..
                int d = x->degree;
                countHeap++;
                FibonacciHeapNode *next = x->right;
                countHeap++;
                // ..and see if there's another of the same degree.

                for (;;) {
                    FibonacciHeapNode *y = array[d];
                    countHeap++;
                    if (y == NULL){
                          countHeap++;
                          break;
                    } // Nope.
                    // There is, make one of the nodes a child of the other.
                    // Do this based on the key value.
                    if (x->key > y->key) {
                        swap(x, y);
                        countHeap++;
                    }
                    // FibonacciHeapNode y disappears from root list.
                    link(y, x);
                    // We've handled this degree, go to next one.
                    array[d] = NULL;
                    countHeap++;
                    d++;
                    countHeap++;
                }
                

                // Save this node for later when we might encounter another of the same degree.
                array[d] = x;
                countHeap++;
                // Move forward through list.
                x = next;
                countHeap++;
                numRoots--;
                countHeap++;
            }

           
            // Set min to NULL (effectively losing the root list) and
            // reconstruct the root list from the array entries in array[].
            minNode = NULL;
            countHeap++;
            for (int i = 0; i < arraySize; i++) {
                countHeap++;
                FibonacciHeapNode *y = array[i];
                countHeap++;
                if (y == NULL){
                      countHeap++;
                      continue;
                }                      
                // We've got a live one, add it to root list.
                if (minNode != NULL) {
                    countHeap++;
                    // First remove node from root list.
                    y->left->right = y->right;
                    countHeap++;
                    y->right->left = y->left;
                    countHeap++;
                    // Now add to root list, again.
                    y->left = minNode;
                    countHeap++;
                    y->right = minNode->right;
                    countHeap++;
                    minNode->right = y;
                    countHeap++;
                    y->right->left = y;
                    countHeap++;
                    // Check if this is a new min.
                    if (y->key < minNode->key){
                       minNode = y;
                       countHeap++;
                       }
                } else{
                       minNode = y;
                       countHeap++;
                       }
            }
            
        }

        void cascadingCut(FibonacciHeapNode* x){
            FibonacciHeapNode *y= x->parent;
            countHeap++;
            if(y!=NULL){
                countHeap++;
                if(y->mark==false){
                     countHeap++;
                     y->mark=true;
                     countHeap++;
                }
                else{
                    cut(x,y);
                    cascadingCut(y);
                }
            }
        }

        void decreaseKey(FibonacciHeapNode *x, int k){
            //cout << "decrementando key do noh " << x->data << " de " << x->key << " para " << k << endl;
            if ( k >= x->key ){
                 countHeap++;
                 return;
            }
            x->key=k;
            countHeap++;
            FibonacciHeapNode *y= x->parent;
            countHeap++;
    
            //cout << " dec pai " << (y!=NULL?y->data:-1) << endl;

            if ( y!= NULL && x->key < y->key ){
                countHeap++;
                cut(x,y);
                cascadingCut(y);
            }
        }
 }; 
