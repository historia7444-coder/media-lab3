"""用 NVRTC 编译 matmul.cu，再由 CUDA Driver API 启动同一核函数。"""

import argparse
import ctypes as ct
import json
import os
from pathlib import Path
import statistics
import time


def bind(library, name, arguments):
    function = getattr(library, name)
    function.argtypes = arguments
    function.restype = ct.c_int
    return function


def check(status):
    if status != 0:
        raise RuntimeError(f"CUDA/NVRTC error code: {status}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--nvrtc", type=Path)
    parser.add_argument("--json", type=Path)
    args = parser.parse_args()
    folder = Path(__file__).resolve().parent
    dll_path = args.nvrtc
    if dll_path is None:
        dll_path = folder.parents[1] / "过程资料/cuda/nvrtc/nvidia/cuda_nvrtc/bin/nvrtc64_120_0.dll"
    if not dll_path.is_file():
        parser.error("找不到 NVRTC。请用 --nvrtc 指定 NVIDIA NVRTC DLL 的完整路径。")
    os.environ["CUDA_CACHE_DISABLE"] = "1"
    os.environ["TEMP"] = str(folder.parents[1] / "过程资料/cuda")
    os.environ["TMP"] = os.environ["TEMP"]
    dll_directory = os.add_dll_directory(str(dll_path.parent))
    os.environ["PATH"] = str(dll_path.parent) + os.pathsep + os.environ.get("PATH", "")
    nvrtc = ct.WinDLL(str(dll_path))
    driver = ct.WinDLL("nvcuda.dll")
    pointer, integer = ct.c_void_p, ct.c_int
    integer_pointer = ct.POINTER(integer)
    device_pointer = ct.c_uint64
    api = {
        "cuInit": [ct.c_uint],
        "cuDeviceGet": [integer_pointer, integer],
        "cuDeviceGetName": [pointer, integer, integer],
        "cuDeviceGetAttribute": [integer_pointer, integer, integer],
        "cuCtxCreate_v2": [ct.POINTER(pointer), ct.c_uint, integer],
        "cuCtxDestroy_v2": [pointer],
        "cuModuleLoadData": [ct.POINTER(pointer), pointer],
        "cuModuleGetFunction": [ct.POINTER(pointer), pointer, ct.c_char_p],
        "cuMemAlloc_v2": [ct.POINTER(device_pointer), ct.c_size_t],
        "cuMemFree_v2": [device_pointer],
        "cuMemcpyHtoD_v2": [device_pointer, pointer, ct.c_size_t],
        "cuMemcpyDtoH_v2": [pointer, device_pointer, ct.c_size_t],
        "cuLaunchKernel": [pointer] + [ct.c_uint] * 7 + [pointer, pointer, pointer],
        "cuCtxSynchronize": [],
        "cuEventCreate": [ct.POINTER(pointer), ct.c_uint],
        "cuEventRecord": [pointer, pointer],
        "cuEventSynchronize": [pointer],
        "cuEventElapsedTime": [ct.POINTER(ct.c_float), pointer, pointer],
        "cuEventDestroy_v2": [pointer],
    }
    calls = {name: bind(driver, name, types) for name, types in api.items()}
    def call(name, *values):
        check(calls[name](*values))
    call("cuInit", 0)
    device, major, minor = integer(), integer(), integer()
    call("cuDeviceGet", ct.byref(device), 0)
    call("cuDeviceGetAttribute", ct.byref(major), 75, device)
    call("cuDeviceGetAttribute", ct.byref(minor), 76, device)
    name = ct.create_string_buffer(200)
    call("cuDeviceGetName", name, len(name), device)
    context = pointer()
    call("cuCtxCreate_v2", ct.byref(context), 0, device)
    program = pointer()
    create = bind(nvrtc, "nvrtcCreateProgram", [ct.POINTER(pointer), ct.c_char_p, ct.c_char_p, integer, pointer, pointer])
    compile_program = bind(nvrtc, "nvrtcCompileProgram", [pointer, integer, ct.POINTER(ct.c_char_p)])
    get_log_size = bind(nvrtc, "nvrtcGetProgramLogSize", [pointer, ct.POINTER(ct.c_size_t)])
    get_log = bind(nvrtc, "nvrtcGetProgramLog", [pointer, pointer])
    get_size = bind(nvrtc, "nvrtcGetPTXSize", [pointer, ct.POINTER(ct.c_size_t)])
    get_ptx = bind(nvrtc, "nvrtcGetPTX", [pointer, pointer])
    destroy = bind(nvrtc, "nvrtcDestroyProgram", [ct.POINTER(pointer)])
    version = bind(nvrtc, "nvrtcVersion", [integer_pointer, integer_pointer])
    vmajor, vminor = integer(), integer()
    check(version(ct.byref(vmajor), ct.byref(vminor)))
    source = (folder / "matmul.cu").read_text(encoding="utf-8-sig").encode("utf-8")
    check(create(ct.byref(program), source, b"matmul.cu", 0, None, None))
    options = (ct.c_char_p * 2)(f"--gpu-architecture=compute_{major.value}{minor.value}".encode(), b"--std=c++11")
    status = compile_program(program, 2, options)
    log_size = ct.c_size_t()
    check(get_log_size(program, ct.byref(log_size)))
    log = ct.create_string_buffer(log_size.value)
    check(get_log(program, log))
    if log.value:
        print(log.value.decode())
    check(status)
    size = ct.c_size_t()
    check(get_size(program, ct.byref(size)))
    ptx = ct.create_string_buffer(size.value)
    check(get_ptx(program, ptx))
    check(destroy(ct.byref(program)))
    module, kernel = pointer(), pointer()
    call("cuModuleLoadData", ct.byref(module), ptx)
    call("cuModuleGetFunction", ct.byref(kernel), module, b"matmul_kernel")
    print(f"GPU: {name.value.decode()}")
    print(f"NVRTC {vmajor.value}.{vminor.value}, compute_{major.value}{minor.value}")
    results = []
    for n in (3, 256):
        length = n * n
        a = [i * n + j + 1 if n == 3 else (i * 3 + j) % 7 - 3 for i in range(n) for j in range(n)]
        b = [9 - i * n - j if n == 3 else (i + j * 2) % 5 - 2 for i in range(n) for j in range(n)]
        expected = [sum(a[i * n + k] * b[k * n + j] for k in range(n)) for i in range(n) for j in range(n)]
        array = integer * length
        host_a, host_b, host_c = array(*a), array(*b), array()
        dev_a, dev_b, dev_c = device_pointer(), device_pointer(), device_pointer()
        bytes_count = ct.sizeof(host_a)
        for memory in (dev_a, dev_b, dev_c):
            call("cuMemAlloc_v2", ct.byref(memory), bytes_count)
        call("cuMemcpyHtoD_v2", dev_a, host_a, bytes_count)
        call("cuMemcpyHtoD_v2", dev_b, host_b, bytes_count)
        dim = integer(n)
        parameters = (pointer * 4)(ct.cast(ct.byref(dev_a), pointer), ct.cast(ct.byref(dev_b), pointer), ct.cast(ct.byref(dev_c), pointer), ct.cast(ct.byref(dim), pointer))
        blocks = (length + 31) // 32
        def launch():
            call("cuLaunchKernel", kernel, blocks, 1, 1, 32, 1, 1, 0, None, parameters, None)
        for _ in range(20):
            launch()
        call("cuCtxSynchronize")
        call("cuMemcpyDtoH_v2", host_c, dev_c, bytes_count)
        assert list(host_c) == expected
        print(f"CUDA N={n} blocks={blocks} threads/block=32")
        if n == 3:
            for row in range(n):
                print(*host_c[row * n:(row + 1) * n])
        print(f"check: PASS ({length} elements)")
        start, stop = pointer(), pointer()
        call("cuEventCreate", ct.byref(start), 0)
        call("cuEventCreate", ct.byref(stop), 0)
        kernel_samples = []
        for _ in range(5):
            call("cuEventRecord", start, None)
            for _ in range(100):
                launch()
            call("cuEventRecord", stop, None)
            call("cuEventSynchronize", stop)
            elapsed = ct.c_float()
            call("cuEventElapsedTime", ct.byref(elapsed), start, stop)
            kernel_samples.append(elapsed.value / 100)
        total_samples = []
        for _ in range(31):
            tick = time.perf_counter()
            call("cuMemcpyHtoD_v2", dev_a, host_a, bytes_count)
            call("cuMemcpyHtoD_v2", dev_b, host_b, bytes_count)
            launch()
            call("cuCtxSynchronize")
            call("cuMemcpyDtoH_v2", host_c, dev_c, bytes_count)
            total_samples.append((time.perf_counter() - tick) * 1000)
        measured = {
            "n": n, "blocks": blocks, "threads_per_block": 32,
            "kernel_ms": statistics.median(kernel_samples),
            "transfer_kernel_ms": statistics.median(total_samples),
            "kernel_samples_ms": kernel_samples, "sum": sum(host_c), "correct": list(host_c) == expected,
        }
        results.append(measured)
        print(f"kernel: {measured['kernel_ms']:.6f} ms; copy + kernel + copy: {measured['transfer_kernel_ms']:.6f} ms")
        for event in (start, stop):
            call("cuEventDestroy_v2", event)
        for memory in (dev_a, dev_b, dev_c):
            call("cuMemFree_v2", memory)
    call("cuCtxDestroy_v2", context)
    dll_directory.close()
    if args.json:
        args.json.write_text(json.dumps({"gpu": name.value.decode(), "nvrtc": f"{vmajor.value}.{vminor.value}", "results": results}, ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()

