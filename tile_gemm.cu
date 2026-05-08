#include <cuda_runtime.h>

constexpr int TILE_SIZE = 16;

__global__ void tile_gemm(float *A, float *B, float *C, int M, int K, int N)
{
    int colStart = blockIdx.x * blockDim.x;
    int rowStart = blockIdx.y * blockDim.y;

    __shared__ float ATile[TILE_SIZE][TILE_SIZE];
    __shared__ float BTile[TILE_SIZE][TILE_SIZE];
    __shared__ float CTile[TILE_SIZE][TILE_SIZE];
    int tileNum = K / TILE_SIZE;
    for (int i = 0; i < tileNum; i++)
    {
        ATile[threadIdx.y][threadIdx.x] = A[K * (rowStart + threadIdx.y) + tileNum * TILE_SIZE + threadIdx.x];
        BTile[threadIdx.y][threadIdx.x] = B[(tileNum * TILE_SIZE + threadIdx.y) * N + colStart + threadIdx.x];
        __syncthreads();
        float result = 0;
        for (int j = 0; j < K; j++)
        {
            result += ATile[threadIdx.y][j] * BTile[j][threadIdx.x];
        }
        CTile[threadIdx.y][threadIdx.x] += result;
    }
    C[(threadIdx.y + rowStart) * N + +colStart + threadIdx.x] = CTile[threadIdx.y][threadIdx.x];
}

int main(int argc, char *argv[])
{
}
