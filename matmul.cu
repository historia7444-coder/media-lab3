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
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <vector>

#define CUDA_CHECK(call) do { \
    cudaError_t error = (call); \
    if (error != cudaSuccess) { \
        std::fprintf(stderr, "%s\n", cudaGetErrorString(error)); \
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
    CUDA_CHECK(cudaMalloc((void **)&device_a, bytes));
    CUDA_CHECK(cudaMalloc((void **)&device_b, bytes));
    CUDA_CHECK(cudaMalloc((void **)&device_c, bytes));
    CUDA_CHECK(cudaMemcpy(device_a, a.data(), bytes, cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(device_b, b.data(), bytes, cudaMemcpyHostToDevice));
    int threads = 32;
    int blocks = (n * n + threads - 1) / threads;
    matmul_kernel<<<blocks, threads>>>(device_a, device_b, device_c, n);
    CUDA_CHECK(cudaGetLastError());
    CUDA_CHECK(cudaDeviceSynchronize());
    CUDA_CHECK(cudaMemcpy(c.data(), device_c, bytes, cudaMemcpyDeviceToHost));
    std::printf("CUDA N=%d blocks=%d threads/block=%d\n", n, blocks, threads);
    if (n == 3)
        for (int i = 0; i < n; ++i)
            std::printf("%d %d %d\n", c[i * n], c[i * n + 1], c[i * n + 2]);
    bool correct = c == expected;
    std::printf("check: %s\n", correct ? "PASS" : "FAIL");
    CUDA_CHECK(cudaFree(device_a));
    CUDA_CHECK(cudaFree(device_b));
    CUDA_CHECK(cudaFree(device_c));
    return correct ? 0 : 1;
}
#endif
