#include <mpi.h>
#include <iostream>
#include <cstdlib> // Untuk rand()
#include <ctime>   // Untuk srand()

#define MATRIX_SIZE 10 // Ukuran matriks (10x10)

using namespace std; // Menggunakan namespace std untuk menghindari penggunaan std:: secara eksplisit

// Fungsi untuk mengisi matriks dengan nilai random
void fillMatrix(int matrix[MATRIX_SIZE][MATRIX_SIZE]) {
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            matrix[i][j] = rand() % 10; // Mengisi matriks dengan nilai acak 0-9
        }
    }
}

// Fungsi untuk mencetak matriks ke output
void printMatrix(int matrix[MATRIX_SIZE][MATRIX_SIZE]) {
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE; j++) {
            cout << matrix[i][j] << " "; // Menampilkan elemen matriks
        }
        cout << endl; // Pindah ke baris berikutnya setelah mencetak satu baris
    }
}

int main(int argc, char* argv[]) {
    int processRank, processCount;

    MPI_Init(&argc, &argv); // Inisialisasi lingkungan MPI
    MPI_Comm_rank(MPI_COMM_WORLD, &processRank); // Mendapatkan ID/rank proses saat ini
    MPI_Comm_size(MPI_COMM_WORLD, &processCount); // Mendapatkan jumlah total proses

    // Deklarasi matriks
    int matrixA[MATRIX_SIZE][MATRIX_SIZE], matrixB[MATRIX_SIZE][MATRIX_SIZE], matrixResult[MATRIX_SIZE][MATRIX_SIZE];
    int subMatrixA[MATRIX_SIZE][MATRIX_SIZE / processCount]; // Submatriks A untuk masing-masing proses
    int subMatrixB[MATRIX_SIZE][MATRIX_SIZE / processCount]; // Submatriks B untuk masing-masing proses
    int subMatrixResult[MATRIX_SIZE][MATRIX_SIZE / processCount]; // Hasil penjumlahan submatriks

    // Inisialisasi random seed (unik untuk setiap proses)
    srand(time(nullptr) + processRank);

    // Proses root (rank 0) mengisi matriks sumber
    if (processRank == 0) {
        fillMatrix(matrixA); // Mengisi matriks A dengan nilai acak
        fillMatrix(matrixB); // Mengisi matriks B dengan nilai acak

        // Menampilkan matriks A dan B di proses root
        cout << "Matrix A:" << endl;
        printMatrix(matrixA);

        cout << "\nMatrix B:" << endl;
        printMatrix(matrixB);
    }

    // Scatter matriks A dari proses root ke semua proses
    MPI_Scatter(matrixA, MATRIX_SIZE * (MATRIX_SIZE / processCount), MPI_INT, 
                subMatrixA, MATRIX_SIZE * (MATRIX_SIZE / processCount), MPI_INT, 0, MPI_COMM_WORLD);

    // Scatter matriks B dari proses root ke semua proses
    MPI_Scatter(matrixB, MATRIX_SIZE * (MATRIX_SIZE / processCount), MPI_INT, 
                subMatrixB, MATRIX_SIZE * (MATRIX_SIZE / processCount), MPI_INT, 0, MPI_COMM_WORLD);

    // Setiap proses menjumlahkan elemen-elemen dari submatriks A dan B yang diterima
    for (int i = 0; i < MATRIX_SIZE; i++) {
        for (int j = 0; j < MATRIX_SIZE / processCount; j++) {
            subMatrixResult[i][j] = subMatrixA[i][j] + subMatrixB[i][j]; // Menjumlahkan elemen
        }
    }

    // Mengumpulkan hasil penjumlahan submatriks dari semua proses ke proses root
    MPI_Gather(subMatrixResult, MATRIX_SIZE * (MATRIX_SIZE / processCount), MPI_INT,
               matrixResult, MATRIX_SIZE * (MATRIX_SIZE / processCount), MPI_INT, 0, MPI_COMM_WORLD);

    // Proses root (rank 0) menampilkan hasil akhir penjumlahan matriks
    if (processRank == 0) {
        cout << "\nResultant Matrix:" << endl;
        printMatrix(matrixResult); // Menampilkan matriks hasil penjumlahan
    }

    MPI_Finalize(); // Mengakhiri lingkungan MPI
    return 0;
}
