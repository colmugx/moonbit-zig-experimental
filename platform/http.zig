const std = @import("std");
const mem = std.mem;
const http = std.http;

const moonbit = @cImport({
    @cInclude("moonbit.h");
});

// 定义一个错误类型，便于内部出错时返回
const Error = error{
    NullPointer,
    AllocationFailure,
    ResponseConversionFailed,
};

const c_allocator = std.heap.c_allocator;

/// 发起 HTTP 请求，并将响应内容以字节 slice 返回（内部使用 c_allocator）
fn makeRequest(method: http.Method, url: ?[]const u8, body: ?[]const u8) ![]u8 {
    if (url == null) return Error.NullPointer;

    const allocator = c_allocator;
    var client = http.Client{
        .allocator = allocator,
    };
    defer client.deinit();

    // 空的 headers 数组
    const headers = &[_]http.Header{};
    const url_slice = url.?;

    var response_body = std.ArrayList(u8).init(allocator);
    defer response_body.deinit();

    const response = try client.fetch(.{
        .method = method,
        .location = .{ .url = url_slice },
        .extra_headers = headers,
        .payload = body,
        .response_storage = .{ .dynamic = &response_body },
    });

    if (response.status != .ok) {
        std.debug.print("HTTP request returned non-OK status: {}\n", .{response.status});
        return Error.ResponseConversionFailed;
    }

    const result = response_body.toOwnedSliceSentinel(0) catch |err| {
        std.debug.print("Failed to convert response to string: {}\n", .{err});
        return Error.ResponseConversionFailed;
    };

    return result;
}

pub fn moonbitStringToCStr(allocator: std.mem.Allocator, str: ?moonbit.moonbit_string_t) ?[]const u8 {
    if (str == null) return null;
    // 解包实际的字符串指针
    const actualStr = str.?;
    const len: usize = @intCast(moonbit.Moonbit_array_length(actualStr));
    if (len == 0) return null;

    var result = allocator.alloc(u8, len + 1) catch return null;
    const s = actualStr[0..len];
    for (s, 0..) |ch, i| {
        result[i] = @truncate(ch);
    }
    result[len] = '0';
    return result;
}

pub fn cStrToMoonbitString(cstr: ?[]u8) !moonbit.moonbit_string_t {
    if (cstr == null) return Error.ResponseConversionFailed;
    const s = cstr.?;
    const len = s.len;
    var result = moonbit.moonbit_make_string(@intCast(len), 0);
    if (result == null) return Error.AllocationFailure;
    const out = result[0..len];
    for (s[0..len], 0..) |ch, i| {
        out[i] = @intCast(ch);
    }
    return result;
}

/// 供 C 调用的 HTTP GET 接口，出错时返回 null
pub export fn zig_http_get(url: moonbit.moonbit_string_t) moonbit.moonbit_string_t {
    const url_slice = moonbitStringToCStr(c_allocator, url);
    const response = makeRequest(.GET, url_slice, null) catch return null;
    const moonbit_str = cStrToMoonbitString(response) catch return null;
    c_allocator.free(response);
    return moonbit_str;
}

/// 供 C 调用的 HTTP POST 接口，出错时返回 null
pub export fn zig_http_post(url: moonbit.moonbit_string_t, body: moonbit.moonbit_string_t) moonbit.moonbit_string_t {
    const url_slice = moonbitStringToCStr(c_allocator, url);
    const body_slice = moonbitStringToCStr(c_allocator, body);
    const response = makeRequest(.POST, url_slice, body_slice) catch return null;
    const moonbit_str = cStrToMoonbitString(response) catch return null;
    c_allocator.free(response);
    return moonbit_str;
}

/// 供 C 调用的 HTTP PUT 接口，出错时返回 null
pub export fn zig_http_put(url: moonbit.moonbit_string_t, body: moonbit.moonbit_string_t) moonbit.moonbit_string_t {
    const url_slice = moonbitStringToCStr(c_allocator, url);
    const body_slice = moonbitStringToCStr(c_allocator, body);
    const response = makeRequest(.PUT, url_slice, body_slice) catch return null;
    const moonbit_str = cStrToMoonbitString(response) catch return null;
    c_allocator.free(response);
    return moonbit_str;
}
/// 供 C 调用的 HTTP DELETE 接口，出错时返回 null
pub export fn zig_http_delete(url: moonbit.moonbit_string_t) moonbit.moonbit_string_t {
    const url_slice = moonbitStringToCStr(c_allocator, url);
    const response = makeRequest(.DELETE, url_slice, null) catch return null;
    const moonbit_str = cStrToMoonbitString(response) catch return null;
    c_allocator.free(response);
    return moonbit_str;
}
