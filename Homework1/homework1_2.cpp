/*
	Parallel Computing 2018
	Assignment 1-2
	N Queens
	Vinh Le
	
	The N queens problem asks you to place N non-attacking queens on an N*N chessboard. No
	two queens can be in the same row, in the same column, or on the diagonal. You should
	write a parallel program in CilkPlus to solve the N queens problem by brute force search.
	Note that you should NOT prune any search space.
	Used Tesjui solver:https://www.daniweb.com/programming/software-development/threads/126961/n-queens-w-recursion-help-c 
	
	Input:
	A positive integer N that represents the number of queens.
	
	Output:
	The number of possible solutions.
*/

#include <iostream>
#include <stdlib.h>
#include <cilk/cilk.h>

using namespace std;

int solutions = 0;

bool Test(int board[], int col){
	
	for (int i=0; i<col;i++){ 
		if ((board[i]==board[col])||((board[i]-board[col])==(col-i))||((board[col]-board[i])==(col-i))) {
			return 0;
		}
	}
	return 1;
}

void NQueens(int n, int board[], int col=0){
	if (col==n){ 
		
		++solutions;
	}
	else
	{ 
		for(int i=0; i<n; i++){
			board[col]=i; 
			if(Test(board, col)) {
				 NQueens(n, board, col+1);
			}
			
		}
		
	}
}

int main(int argc, char *argv[]){ 
	int n = atoi(argv[1]);
	int *board = new int[n];
	
	cilk_spawn NQueens(n, board);
	cilk_sync;
	cout<< "There are " << solutions << " for " << n <<  " Queens."<<endl;
	
	return 0;
}					