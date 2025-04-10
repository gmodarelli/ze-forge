const std = @import("std");
const zf = @import("ze_forge");
const graphics = zf.IGraphics;

pub fn main() !void {
    var renderer_desc = std.mem.zeroes(graphics.RendererDesc);
    var renderer: [*c]graphics.Renderer = null;
    zf.IGraphics.initRenderer("ze_forge test", &renderer_desc, &renderer);
}
