extern "C" __global__ void matmul_kernel(const int *a, const int *b, int *c, int n)
{
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index >= n * n) return;
    int row = index / n;
    int column = index % n;
    int sum = 0;
    for (int k = 0; k < n; ++k)
        sum += a[row * n + k] * b[k * n + column];
    c[index] = sum;
}

#ifndef __CUDACC_RTC__
#include <musa_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <vector>

#define MUSA_CHECK(call) do { \
    musaError_t error = (call); \
    if (error != musaSuccess) { \
        std::fprintf(stderr, "%s\n", musaGetErrorString(error)); \
        std::exit(1); \
    } \
} while (0)

int main(int argc, char **argv)
{
    int n = argc > 1 ? std::atoi(argv[1]) : 3;
    if (n != 3 && n != 256) return 1;
    std::vector<int> a(n * n), b(n * n), c(n * n), expected(n * n, 0);
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j) {
            a[i * n + j] = n == 3 ? i * n + j + 1 : (i * 3 + j) % 7 - 3;
            b[i * n + j] = n == 3 ? 9 - i * n - j : (i + j * 2) % 5 - 2;
        }
    for (int i = 0; i < n; ++i)
        for (int j = 0; j < n; ++j)
            for (int k = 0; k < n; ++k)
                expected[i * n + j] += a[i * n + k] * b[k * n + j];

    size_t bytes = n * n * sizeof(int);
    int *device_a, *device_b, *device_c;
    MUSA_CHECK(musaMalloc((void **)&device_a, bytes));
    MUSA_CHECK(musaMalloc((void **)&device_b, bytes));
    MUSA_CHECK(musaMalloc((void **)&device_c, bytes));
    MUSA_CHECK(musaMemcpy(device_a, a.data(), bytes, musaMemcpyHostToDevice));
    MUSA_CHECK(musaMemcpy(device_b, b.data(), bytes, musaMemcpyHostToDevice));
    int threads = 32;
    int blocks = (n * n + threads - 1) / threads;
    matmul_kernel<<<blocks, threads>>>(device_a, device_b, device_c, n);
    MUSA_CHECK(musaGetLastError());
    MUSA_CHECK(musaDeviceSynchronize());
    MUSA_CHECK(musaMemcpy(c.data(), device_c, bytes, musaMemcpyDeviceToHost));
    std::printf("MUSA N=%d blocks=%d threads/block=%d\n", n, blocks, threads);
    if (n == 3)
        for (int i = 0; i < n; ++i)
            std::printf("%d %d %d\n", c[i * n], c[i * n + 1], c[i * n + 2]);
    bool correct = c == expected;
    std::printf("check: %s\n", correct ? "PASS" : "FAIL");
    MUSA_CHECK(musaFree(device_a));
    MUSA_CHECK(musaFree(device_b));
    MUSA_CHECK(musaFree(device_c));
    return correct ? 0 : 1;
}
#endif
