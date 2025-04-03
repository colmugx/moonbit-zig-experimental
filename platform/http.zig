const std = @import("std");
const mem = std.mem;
const http = std.http;

// 定义一个错误类型，便于内部出错时返回
const Error = error{ResponseConversionFailed};

pub const c_allocator = std.heap.c_allocator;

/// 将 C 字符串转换为 Zig slice（直到遇到 0 结束）
fn cStrToSlice(c_str: [*:0]const u8) []const u8 {
    return std.mem.sliceTo(c_str, 0);
}

/// 将 Zig slice 转换为 C 字符串，分配的内存由 c_allocator 提供，调用者负责释放
fn sliceToCStr(allocator: std.mem.Allocator, slice: []const u8) ?[*]u8 {
    const c_str = allocator.alloc(u8, slice.len + 1) catch return null;
    @memcpy(c_str[0..slice.len], slice);
    c_str[slice.len] = 0;
    return c_str.ptr;
}

/// 发起 HTTP 请求，并将响应内容以字节 slice 返回（内部使用 c_allocator）
fn makeRequest(method: http.Method, url: []const u8, body: ?[]const u8) ![]u8 {
    const allocator = c_allocator;
    var client = http.Client{
        .allocator = allocator,
    };
    defer client.deinit();

    // 空的 headers 数组
    const headers: []http.Header = &[_]http.Header{};

    var response_body = std.ArrayList(u8).init(allocator);
    defer response_body.deinit();

    const response = try client.fetch(.{
        .method = method,
        .location = .{ .url = url },
        .extra_headers = headers,
        .payload = body,
        .response_storage = .{ .dynamic = &response_body },
    });

    if (response.status != .ok) {
        std.debug.print("HTTP request returned non-OK status: {}\n", .{response.status});
    }

    const result = response_body.toOwnedSliceSentinel(0) catch |err| {
        std.debug.print("Failed to convert response to string: {}\n", .{err});
        return Error.ResponseConversionFailed;
    };

    return result;
}

/// 供 C 调用的 HTTP GET 接口，出错时返回 null
pub export fn zig_http_get(url: [*:0]const u8) ?[*]u8 {
    const url_slice = cStrToSlice(url);
    const response = makeRequest(.GET, url_slice, null) catch return null;
    return sliceToCStr(c_allocator, response);
}

/// 供 C 调用的 HTTP POST 接口，出错时返回 null
pub export fn zig_http_post(url: [*:0]const u8, body: [*:0]const u8) ?[*]u8 {
    const url_slice = cStrToSlice(url);
    const body_slice = cStrToSlice(body);
    const response = makeRequest(.POST, url_slice, body_slice) catch return null;
    return sliceToCStr(c_allocator, response);
}

/// 供 C 调用的 HTTP PUT 接口，出错时返回 null
pub export fn zig_http_put(url: [*:0]const u8, body: [*:0]const u8) ?[*]u8 {
    const url_slice = cStrToSlice(url);
    const body_slice = cStrToSlice(body);
    const response = makeRequest(.PUT, url_slice, body_slice) catch return null;
    return sliceToCStr(c_allocator, response);
}

/// 供 C 调用的 HTTP DELETE 接口，出错时返回 null
pub export fn zig_http_delete(url: [*:0]const u8) ?[*]u8 {
    const url_slice = cStrToSlice(url);
    const response = makeRequest(.DELETE, url_slice, null) catch return null;
    return sliceToCStr(c_allocator, response);
}
