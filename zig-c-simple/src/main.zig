const std = @import("std");
const wav_build = @import("wav_build.zig");

const wav = @cImport({
    @cInclude("wav.c");
});

pub fn main() !void {
    try wav_build.CreateWavFile(8000, 10, "test.wav");
}
