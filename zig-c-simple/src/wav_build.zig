const std = @import("std");
const fs = std.fs;

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
};

pub fn CreateWavFile(sample_rate: u32, sec_length: u32, filename: []const u8) !void {
    const data_length = 2 * sample_rate * sec_length;
    var header = Wavhead.New(4000, data_length);
    var file = try fs.cwd().createFile(filename, .{});
    const ptr_header: []u8 = @ptrFromInt(&header);
    file.write(ptr_header);
}
