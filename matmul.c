#include <stdio.h>

#ifndef N
#define N 3
#endif
#if N < 1 || N > 256
#error N must be between 1 and 256
#endif

void matmul_ijk(const int a[N][N], const int b[N][N], int c[N][N])
{
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            c[i][j] = 0;
            for (int k = 0; k < N; k++) {
                c[i][j] += a[i][k] * b[k][j];
            }
        }
    }
}

void matmul_ikj(const int a[N][N], const int b[N][N], int c[N][N])
{
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            c[i][j] = 0;
        }
        for (int k = 0; k < N; k++) {
            for (int j = 0; j < N; j++) {
                c[i][j] += a[i][k] * b[k][j];
            }
        }
    }
}

#ifndef MATMUL_NO_MAIN
int main(void)
{
    static int a[N][N], b[N][N], c[N][N], expected[N][N];
    const int answer3[3][3] = {{30, 24, 18}, {84, 69, 54}, {138, 114, 90}};
    int correct = 1;

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            a[i][j] = N == 3 ? i * 3 + j + 1 : (i * 3 + j) % 7 - 3;
            b[i][j] = N == 3 ? 9 - i * 3 - j : (i + j * 2) % 5 - 2;
        }
    }
    matmul_ijk(a, b, c);
    matmul_ikj(a, b, expected);
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            if (N == 3) {
                expected[i][j] = answer3[i][j];
            }
            if (c[i][j] != expected[i][j]) {
                correct = 0;
            }
        }
    }
    if (N > 3) {
        printf("N=%d; top-left 3x3:\n", N);
    }
    for (int i = 0; i < N && i < 3; i++) {
        for (int j = 0; j < N && j < 3; j++) {
            printf("%4d", c[i][j]);
        }
        putchar('\n');
    }
    printf("%s: all %d elements match.\n", correct ? "PASS" : "FAIL", N * N);
    return correct ? 0 : 1;
}
#endif
