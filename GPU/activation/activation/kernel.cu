
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <math.h>
#include <stdio.h>

__global__ void sigmoidActivation(float *z_matrix, float *activation_matrix) {
    int index = threadIdx.x;
    activation_matrix[index] = 1.0 / (1.0 + exp(-z_matrix[index]));
}


int main()
{
    const int arraySize = 5;

    // Initialize arrays on the cpu 
    float host_z_values[arraySize] = { 1.0, 2.0, 3.0, 4.0, 5.0 };
    float host_activations[arraySize] = { 0.0 };

    // Caculate the number of bytes required to store the arrays on gpu
    const size_t bytes_z_values = arraySize * sizeof(float);
    const size_t bytes_activations = arraySize * sizeof(float);

    // Declare pointers for gpu based params
    float *device_z_values;
    float *device_activations;

    // Allocate memory on the gpu
    cudaMalloc(&device_z_values, bytes_z_values);
    cudaMalloc(&device_activations, bytes_activations);

    // Copy the arrays from cpu to gpu
    cudaMemcpy(device_z_values, host_z_values, bytes_z_values, cudaMemcpyHostToDevice);

    //Call the kernel, with 1 block and arraySize threads
    sigmoidActivation << <1, arraySize >> > (device_z_values, device_activations);

    // Copy the results from gpu to cpu
    cudaMemcpy(host_activations, device_activations, bytes_activations, cudaMemcpyDeviceToHost);

    printf("sigmoid({1,2,3,4,5}) = {%f, %f, %f, %f, %f}\n",
		host_activations[0],
		host_activations[1],
		host_activations[2],
		host_activations[3],
        host_activations[4]);
    //getchar();

    // Free the memory on gpu
    cudaFree(device_z_values);
    cudaFree(device_activations);


    return 0;
}
