const std = @import("std");
const fs = std.fs;
const tobytes = @import("bytes.zig").intToBytes;

const MIDDLE_C = 256.00;

pub const Wavhead = struct {
    riff: [4]u8, // "RIFF" chunk descriptor
    flength: u32, // File length in bytes
    wave: [4]u8, // "WAVE" format
    fmt: [4]u8, // "fmt " subchunk identifier
    chunk_size: u32, // Size of the fmt chunk (16 for PCM)
    format_tag: u16, // Format type (1 for PCM)
    num_chans: u16, // Number of channels (1 for mono, 2 for stereo)
    srate: u32, // Sample rate
    bytes_per_sec: u32, // Bytes per second
    bytes_per_samp: u16, // Bytes per sample (block align)
    bits_per_samp: u16, // Bits per sample
    data: [4]u8, // "data" subchunk identifier
    dlength: u32, // Data length in bytes

    pub fn New(sample_rate: u32, dlength: u32, header_length: u32) Wavhead {
        return .{
            .riff = [4]u8{ 'R', 'I', 'F', 'F' },
            .wave = [4]u8{ 'W', 'A', 'V', 'E' },
            .fmt = [4]u8{ 'f', 'm', 't', ' ' },
            .chunk_size = 16,
            .data = [4]u8{ 'd', 'a', 't', 'a' },
            .num_chans = 1,
            .format_tag = 1,
            .bits_per_samp = 16,
            .srate = sample_rate,
            .bytes_per_sec = sample_rate / 8 * 1, //  is num_chans
            .bytes_per_samp = 16 / 8, // bits per samp
            .dlength = dlength,
            .flength = dlength + header_length,
        };
    }
    pub fn Serialize(self: Wavhead, allocator: std.mem.Allocator) ![]u8 {
        var buffer = try allocator.alloc(u8, @sizeOf(Wavhead));

        // Copying non-integer fields with @memcpy
        @memcpy(buffer[0..4], &self.riff);

        // Convert integers to byte arrays and copy them
        const flength_b = tobytes(u32, self.flength);
        @memcpy(buffer[4..8], flength_b);

        @memcpy(buffer[8..12], &self.wave);
        @memcpy(buffer[12..16], &self.fmt);

        const chunksize_b = tobytes(u32, self.chunk_size);
        @memcpy(buffer[16..20], chunksize_b);

        const format_tag_b = tobytes(u16, self.format_tag);
        @memcpy(buffer[20..22], format_tag_b);

        const num_chans_b = tobytes(u16, self.num_chans);
        @memcpy(buffer[22..24], num_chans_b);

        const srate_b = tobytes(u32, self.srate);
        @memcpy(buffer[24..28], srate_b);

        const bytes_per_sec_b = tobytes(u32, self.bytes_per_sec);
        @memcpy(buffer[28..32], bytes_per_sec_b);

        const bytes_per_samp_b = tobytes(u16, self.bytes_per_samp);
        @memcpy(buffer[32..34], bytes_per_samp_b);

        const bits_per_samp_b = tobytes(u16, self.bits_per_samp);
        @memcpy(buffer[34..36], bits_per_samp_b);

        @memcpy(buffer[36..40], &self.data);

        const dlength_b = tobytes(u32, self.dlength);
        @memcpy(buffer[40..44], dlength_b);

        return buffer[0..];
    }
};

pub fn CreateWavFile(sample_rate: u32, sec_length: u32, filename: []const u8) !void {
    const data_length = 2 * sample_rate * sec_length;
    var header = Wavhead.New(4000, data_length, 44);
    var file = try fs.cwd().createFile(filename, .{});
    defer file.close();
    const allocator = std.heap.page_allocator;
    const bytes = try header.Serialize(allocator);
    _ = try file.write(bytes);
    for (0..data_length) |i| {
        // (short int)((cos((2 * M_PI * MIDDLE_C * i) / sample_rate) * 1000))
        const float_i: f32 = @floatFromInt(i);
        const float_sr: f32 = @floatFromInt(sample_rate);
        // failing
        const num: f32 = std.math.cos(2 * std.math.pi * MIDDLE_C * float_i / float_sr) * 1000;
        const truc: f32 = std.math.trunc(num);
        const intnum: isize = @intFromFloat(truc);
        std.debug.print("truc {d}", .{truc});
        const byte_num = tobytes(isize, intnum);
        _ = try file.write(byte_num);
    }
}
