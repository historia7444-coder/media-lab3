#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

#ifndef MATRIX_N
#define MATRIX_N 256
#endif
#define N MATRIX_N
#define MATMUL_NO_MAIN
#include "matmul.c"

static int a[N][N], b[N][N], c[N][N], reference[N][N];
static volatile long long checksum;

static double seconds(void)
{
    LARGE_INTEGER counter, frequency;
    QueryPerformanceCounter(&counter);
    QueryPerformanceFrequency(&frequency);
    return (double)counter.QuadPart / (double)frequency.QuadPart;
}

static double median_time(void (*multiply)(const int [N][N], const int [N][N], int [N][N]))
{
    const int repeats = N == 3 ? 2000000 : 20;
    double times[5];
    multiply(a, b, c);
    for (int sample = 0; sample < 5; sample++) {
        double start = seconds();
        for (int repeat = 0; repeat < repeats; repeat++) {
            multiply(a, b, c);
            checksum += c[0][0];
        }
        times[sample] = (seconds() - start) * 1000.0 / repeats;
    }
    for (int i = 0; i < 5; i++) {
        for (int j = i + 1; j < 5; j++) {
            if (times[j] < times[i]) {
                double temp = times[i];
                times[i] = times[j];
                times[j] = temp;
            }
        }
    }
    return times[2];
}

int main(int argc, char **argv)
{
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            a[i][j] = N == 3 ? i * 3 + j + 1 : (i * 3 + j) % 7 - 3;
            b[i][j] = N == 3 ? 9 - i * 3 - j : (i + j * 2) % 5 - 2;
        }
    }
    matmul_ijk(a, b, reference);
    matmul_ikj(a, b, c);
    if (memcmp(c, reference, sizeof(c)) != 0) {
        puts("FAIL: ijk and ikj disagree.");
        return 1;
    }
    printf("N=%d, all %d elements match (ijk vs ikj).\n", N, N * N);
    printf("Median of 5 batches, %d products per batch; milliseconds per product.\n",
           N == 3 ? 2000000 : 20);
    printf("ijk: %.9f ms\n", median_time(matmul_ijk));
    printf("ikj: %.9f ms\n", median_time(matmul_ikj));
    if (argc == 2) {
        FILE *out = fopen(argv[1], "wb");
        if (out == NULL) {
            perror("fopen");
            return 1;
        }
        size_t written = fwrite(reference, sizeof(int), N * N, out);
        int closed = fclose(out);
        if (written != N * N || closed != 0) {
            puts("FAIL: could not save all matrix elements.");
            return 1;
        }
    }
    return 0;
}
