const std = @import("std");

pub fn build(b: *std.Build) !void {
    b.release_mode = .small;

    const allocator = std.heap.page_allocator;
    const envmap = try std.process.getEnvMap(allocator);

    const home_path = envmap.get("HOME").?;

    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .aarch64,
            .os_tag = .macos,
        },
    });
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    const http_mod = b.createModule(.{
        .root_source_file = b.path("platform/http.zig"),
        .target = target,
        .optimize = optimize,
        .sanitize_c = false,
        .strip = true,
        .code_model = .small,
    });

    http_mod.addIncludePath(.{
        .cwd_relative = b.pathJoin(&.{
            home_path,
            ".moon/include",
        }),
    });

    http_mod.addCSourceFile(.{
        .file = .{
            .cwd_relative = b.pathJoin(&.{
                home_path,
                ".moon/lib/runtime.c",
            }),
        },
        .flags = &.{
            "-O3",
        },
    });

    // Add HTTP library
    const http_lib = b.addLibrary(.{
        .name = "zig_http",
        .root_module = http_mod,
        .linkage = .dynamic,
    });

    const exe = b.addExecutable(.{
        .name = "moonbit_zig",
        .target = target,
        .optimize = optimize,
        .strip = true,
        .code_model = .small,
    });

    exe.addIncludePath(.{
        .cwd_relative = b.pathJoin(&.{
            home_path,
            ".moon/include",
        }),
    });

    exe.addCSourceFile(.{
        .file = b.path("target/native/release/build/main/main.c"),
        .flags = &.{
            "-fwrapv",
            "-O3",
        },
    });

    exe.linkLibrary(http_lib);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
}
