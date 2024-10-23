const std = @import("std");

const wav = @cImport({
    @cInclude("wav.c"); 
});


pub fn main() !void {
    _ = wav.create_wav(); 
}


