# Zig FFT

Radix-2 Cooley-Tukey FFT algorithm written in Zig.

Everything you need is in the `src/fft.zig` file, the other source files are for benchmarking/testing.

This is far from the fastest implementation, but it works!

## Benchmarks

Comparing on my machine, it seems that this FFT is usually ~30% slower than the Kiss FFT library (written in C).