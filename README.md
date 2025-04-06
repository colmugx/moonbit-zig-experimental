# MoonBit and Zig

[简体中文](README-zh.md) | [日本語](README-ja.md)

> This is an experimental project exploring interoperability between MoonBit and modern systems programming languages.

## Project Goals

This project started as an effort to implement an HTTP client in MoonBit. Instead of relying on traditional `libcurl`-based solutions, this project takes a more exploratory approach with the following goals:

1. Achieve complete independence from `libcurl`.
2. Implement the HTTP client using Zig's standard library.
3. Explore integration patterns between MoonBit and C/Zig.

## Rationale for Technical Choices

Zig was chosen over C for the underlying implementation due to several advantages:

1. **Dependency Management**
  * The C ecosystem often involves complex dependency management.
  * This typically requires manual configuration of compilers (like GCC), library paths, and linking.
  * In contrast, Zig offers a modern build system and a comprehensive standard library.

2. **Standard Library Capabilities**
  * Zig's standard library includes a built-in HTTP client implementation.
  * This eliminates the need for external dependencies for core HTTP functionality.

3. **Interoperability**
  * Currently, interoperability is achieved via the C ABI (Phase 1).
  * The plan is to enable direct MoonBit - Zig interoperability in the future (Phase 2).

## Architecture Evolution

The key components are:

* **MoonBit:** The primary language for application development.
* **Zig:** Implements the underlying HTTP client logic.
* **C:** Acts as the intermediate bridge ~~(in Phase 1)~~ (Implemented).

### Past Architecture (Phase 1)

[#21e56bb](/tree/21e56bb8ed27bd0aee0389d5417cf8a58068f46f)

```
MoonBit -> C ABI -> Zig
```

### Current Architecture (Phase 2)

```
MoonBit -> Zig
```

## Usage Example

```moonbit
fn main {
  // GET request
  println(@http.curl_get("https://api.example.com"))
  
  // POST request
  println(@http.curl_post("https://api.example.com", "{'data': 'test'}"))
}
```

### CLI

```bash
> ./zig-out/bin/moonbit_zig
 No request url.

 Usage:
  moonbit_zig <url>

> ./zig-out/bin/moonbit_zig https://jsonplaceholder.typicode.com/todos/1
It Works! You've requested: https://jsonplaceholder.typicode.com/todos/1
HTTP request returned non-OK status: http.Status.bad_request
<html>
<head><title>400 Bad Request</title></head>
<body>
<center><h1>400 Bad Request</h1></center>
<hr><center>cloudflare</center>
</body>
</html>
```

## Build

The project uses Zig build system, controlled by `moon` command:

```bash
moon build --target native
```

## Notes

1. Requires Zig 0.11.0 or higher
2. Ensure MoonBit runtime environment is properly set up
3. Currently supports macOS/aarch64 platform only
