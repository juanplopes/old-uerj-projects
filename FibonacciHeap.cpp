#include <cstdlib>
#include <iostream>
#include <math.h>
#include <vector>
#define ONE_OVER_LOG_PHI 1.0 / log((1.0 + sqrt(5.0)) / 2.0)

using namespace std;

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
            left = this;
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
                node->left = minNode;
                node->right = minNode->right;
                minNode->right = node;
                node->right->left = node;

                if ( node->key < minNode->key) minNode = node;
            } else {
                minNode = node;
                minNode->left = minNode;
                minNode->right = minNode;
            }
            nNodes++;
            cout << "inserido no com chave " << node->key << " valor = " << node->data << " na heap" << endl;
        }

        FibonacciHeapNode* removeMin(){
            FibonacciHeapNode* z = minNode;
            if (z != NULL) {
                int numKids = z->degree;
                FibonacciHeapNode *x;
				FibonacciHeapNode *tempRight;
                // for each child of z do...
                while (numKids > 0) {
                    x = z->child;
                    tempRight = x->right;

                    // remove x from child list
                    x->left->right = x->right;
                    x->right->left = x->left;

                    // add x to root list of heap
                    x->left = minNode;
                    x->right = minNode->right;
                    minNode->right = x;
                    x->right->left = x;

                    // set parent[x] to NULL
                    x->parent = NULL;
                    x = tempRight;
                    numKids--;
                }

                // remove z from root list of heap
                z->left->right = z->right;
                z->right->left = z->left;

                if (z == z->right) minNode = NULL;
                else {
                    minNode = z->right;
                    consolidate();
                }

                // decrement size of heap
                nNodes--;
            }
            cout << "chave minimo " << z->key << " valor = " << z->data << endl;
            return z;
        }
    
    
        void link(FibonacciHeapNode* y, FibonacciHeapNode* x){
            // remove y from root list of heap
            y->left->right = y->right;
            y->right->left = y->left;

            // make y a child of x
            y->parent = x;

			if (x->child == NULL) x->child = y->right = y->left = y;
			else {
                y->left = x->child;
                y->right = x->child->right;
                x->child->right = y->right->left = y;
            }

            // increase degree[x]
            x->degree++;

            // set mark[y] false
            y->mark = false;
         }
    
        void cut(FibonacciHeapNode* x, FibonacciHeapNode* y){
            // remove x from childlist of y and decrement degree[y]
            x->left->right = x->right;
            x->right->left = x->left;
            y->degree--;

            // reset y.child if necessary
            if (y->child == x) y->child = x->right;
            if (y->degree == 0) y->child = NULL;

            // add x to root list of heap
            x->left = minNode;
            x->right = minNode->right;
            minNode->right = x;
            x->right->left = x;

            // set parent[x] to nil
            x->parent = NULL;

            // set mark[x] to false
            x->mark = false;
        }
    
        void consolidate(){
            int arraySize = ((int) floor(log((float)nNodes) * ONE_OVER_LOG_PHI)) + 1;
            vector<FibonacciHeapNode*> array(arraySize);
            // Initialize degree array
            for (int i = 0; i < arraySize; i++) {
                array.push_back(NULL);
            }
            // Find the number of root nodes.
            int numRoots = 0;
            FibonacciHeapNode *x = minNode;
            if (x != NULL) {
                numRoots++;
                x = x->right;
                while (x != minNode) {
                    numRoots++;
                    x = x->right;
                }
            }
            // For each node in root list do...
            while (numRoots > 0) {
                // Access this node's degree..
                int d = x->degree;
                FibonacciHeapNode *next = x->right;
                // ..and see if there's another of the same degree.
                for (;;) {
                    FibonacciHeapNode *y = array[d];
                    if (y == NULL) break; // Nope.
                    // There is, make one of the nodes a child of the other.
                    // Do this based on the key value.
                    if (x->key > y->key) {
                        FibonacciHeapNode *temp = y;
                        y = x;
                        x = temp;
                    }
                    // FibonacciHeapNode y disappears from root list.
                    link(y, x);
                    // We've handled this degree, go to next one.
                    array[d] = NULL;
                    d++;
                }
                // Save this node for later when we might encounter another of the same degree.
                array[d] = x;
                // Move forward through list.
                x = next;
                numRoots--;
            }
            // Set min to NULL (effectively losing the root list) and
            // reconstruct the root list from the array entries in array[].
            minNode = NULL;
            for (int i = 0; i < arraySize; i++) {
                FibonacciHeapNode *y = array[i];
                if (y == NULL) continue;
                // We've got a live one, add it to root list.
                if (minNode != NULL) {
                    // First remove node from root list.
                    y->left->right = y->right;
                    y->right->left = y->left;
                    // Now add to root list, again.
                    y->left = minNode;
                    y->right = minNode->right;
                    minNode->right = y;
                    y->right->left = y;
                    // Check if this is a new min.
                    if (y->key < minNode->key) minNode = y;
                } else minNode = y;
            }
        }

        void cascadingCut(FibonacciHeapNode* x){
            FibonacciHeapNode *y= x->parent;
            if(y!=NULL){
                if(y->mark==false) y->mark=true;
                else{
                    cut(x,y);
                    cascadingCut(y);
                }
            }
        }

        void decreaseKey(FibonacciHeapNode *x, int k){
            if ( k >= x->key ) return;
            x->key=k;
            FibonacciHeapNode *y= x->parent;
            if ( y!= NULL && x->key < y->key ){
                cut(x,y);
                cascadingCut(y);
            }
            if ( x-> key < minNode->key ) minNode=x;
        }
 }; 
