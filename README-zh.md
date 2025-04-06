# MoonBit and Zig

> 这是一个实验性项目，目标是探索 MoonBit 与现代系统编程语言的互操作性

## 项目目标

这个项目最初源于在 MoonBit 中实现 HTTP 客户端的需求。与传统的使用 `libcurl` 方案不同，本项目选择了一条更具探索性的路径：

1. 完全脱离 libcurl 依赖
2. 使用 Zig 标准库实现 HTTP 客户端
3. 探索 MoonBit 与 C/Zig 的集成方案

## 技术选型动机

选择 Zig 而不是 C 作为底层实现的原因：

1. **依赖管理**
   - C 语言生态系统的依赖管理相对复杂
   - 需要处理 gcc/库路径/链接等繁琐配置
   - Zig 提供了现代化的构建系统和标准库

2. **标准库能力**
   - Zig 标准库内置了 HTTP Client 实现
   - 无需引入外部依赖即可实现核心功能

3. **互操作性**
   - 目前通过 C ABI 作为桥接（第一阶段）
   - 计划直接实现 MoonBit - Zig 互操作 ~~（第二阶段）~~ （已实现）

## 架构演进

- MoonBit：目标编程语言
- Zig：用于实现底层 HTTP 客户端
- ~~C：作为 MoonBit 和 Zig 之间的桥接层~~

### 过去架构 (第一阶段) 

[#21e56bb](/tree/21e56bb8ed27bd0aee0389d5417cf8a58068f46f)

```
MoonBit -> C ABI -> Zig
```

### 当前架构 (第二阶段)
```
MoonBit -> Zig
```

## 使用示例

```moonbit
fn main {
  // 发起 GET 请求
  println(@http.curl_get("https://api.example.com"))
  
  // 发起 POST 请求
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

## 构建

项目使用 Zig 构建系统，但由 `moon` 命令控制：

```bash
moon build --target native
```

## 注意事项

1. 需要安装 Zig 0.11.0 或更高版本
2. 确保已正确设置 MoonBit 运行时环境
3. 代码仅支持 macOS/aarch64 平台
