#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <time.h>
#include <ctime>

using namespace std;
double fRand();
vector<double> VecM();


int main() {

	VecM("nlr.mtx");


}

vector<double> VecM(string infile) {

	srand(time(NULL));
	int M, N, nz;

	cout << "Using " << infile<<endl;

	// open input filestream
	ifstream fin;
	fin.open(infile);


	// Ignore headers and comments:
	while (fin.peek() == '%') fin.ignore(2048, '\n');

	// Read defining parameters:
	fin >> M >> N >> nz;
	
	// Create your matrix (using a vector to store data)
	cout << "Creating blank Matrix\n";
	vector<double> smatrix(nz * 3);
	//for (long i = 0; i < nz * 3; i++) {
	//	smatrix.push_back(0);
	//}
	cout << "DONE\n";

	cout << "Storing data from file in Matrix\n";
	for (long l = 0; l < nz * 3;) {
		int m, n;
		double data = fRand();
		fin >> m >> n;
		smatrix[l] = m;
		smatrix[l + 1] = n;
		smatrix[l + 2] = data;
		l += 3;
	}
	cout << "DONE\n";

	fin.close();

	cout << "Creating Dense Vector with " << N << " values\n";
	//create Dense Vector and fill with random values
	vector<double> DenseVector;
	for (int i = 0; i < N; i++) {
		double val = fRand();
		DenseVector.push_back(val);
	}
	cout << "DONE\n";

	cout << "Creating Blank Resulting Vector\n";
	//create resulting vector and fill with 0
	vector<double> Vec(M);
	//for (int i = 0; i < M; i++) {
	//	VecM.push_back(0);
	//}
	cout << "DONE\n";

	cout << "Doing Matrix Vector Multiplication: Start Time\n";

	clock_t t;
	t = clock();


	for (long l = 0; l < nz * 3;) {
		int m = smatrix[l];
		int n = smatrix[l + 1];
		double data = smatrix[l + 2];
		Vec[m - 1] += data * DenseVector[n - 1];
		l += 3;
	}

	t = clock() - t;

	cout << "DONE: End Time\n";
	cout << "Total Time(sec): " << ((float)t) / CLOCKS_PER_SEC << " Seconds" << endl;

	return Vec;



}

double fRand() {
	double fMin = .1;
	double fMax = 4.9;
	double f = (double)rand() / (double)RAND_MAX;
	return fMin + f * (fMax - fMin);
}

vector<double> VecM()
{
	return vector<double>();
}

