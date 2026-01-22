const std = @import("std");
const fft = @import("fft.zig");

const c = @cImport({
    @cInclude("kiss_fft.h");
});

fn measureKissFFT(nfft: comptime_int, iterations: comptime_int) !void {
    // Allocate config
    const cfg = c.kiss_fft_alloc(nfft, 0, null, null);
    if (cfg == null) return error.OutOfMemory;
    defer std.c.free(cfg);

    // Allocate buffers
    var in: [nfft]c.kiss_fft_cpx = undefined;
    var out: [nfft]c.kiss_fft_cpx = undefined;

    // Fill input
    in[0].r = 1.0;
    in[0].i = 0.0;
    for (in[1..]) |*v| {
        v.r = 0.0;
        v.i = 0.0;
    }

    // Measure
    var timer = try std.time.Timer.start();
    for (0..iterations) |_| {
        c.kiss_fft(cfg, &in, &out);
    }
    const elapsed_ns = timer.read();

    std.debug.print("[Kiss FFT] Operation took (nanoseconds): {}\n", .{elapsed_ns});
}

fn measureMyFFT(nfft: comptime_int, iterations: comptime_int) !void {
    // Allocate buffers
    var in: [nfft]std.math.Complex(f32) = undefined;
    var out: [nfft]std.math.Complex(f32) = undefined;

    // Fill input
    in[0].re = 1.0;
    in[0].im = 0.0;
    for (in[1..]) |*v| {
        v.re = 0.0;
        v.im = 0.0;
    }

    // Measure
    var timer = try std.time.Timer.start();
    for (0..iterations) |_| {
        fft.fftOutOfPlace(f32, &in, &out, false);
    }
    const elapsed_ns = timer.read();

    std.debug.print("[My FFT]   Operation took (nanoseconds): {}\n", .{elapsed_ns});
}

pub fn main() !void {
    const nfft = 2048;
    const iterations = 10000;

    std.debug.print("FFT Size: {}, iterations: {}\n", .{ nfft, iterations });
    try measureKissFFT(nfft, iterations);
    try measureMyFFT(nfft, iterations);
}

test {
    _ = @import("fft.zig");

    const nfft = 1024;

    // Allocate config
    const cfg = c.kiss_fft_alloc(nfft, 0, null, null);
    if (cfg == null) return error.OutOfMemory;
    defer std.c.free(cfg);

    // Allocate buffers
    var in: [nfft]c.kiss_fft_cpx = undefined;
    var out: [nfft]c.kiss_fft_cpx = undefined;

    // Fill input
    in[0].r = 1.0;
    in[0].i = 0.0;
    for (in[1..]) |*v| {
        v.*.r = 0.0;
        v.*.i = 0.0;
    }

    c.kiss_fft(cfg, &in, &out);

    for (out) |v| {
        try std.testing.expectApproxEqRel(1.0, v.r, 1e-5);
        try std.testing.expectApproxEqAbs(0.0, v.i, 1e-5);
    }
}
