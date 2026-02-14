#!/usr/bin/env python3
"""Package and publish tonyfettes/raylib to mooncakes registry."""

import argparse
import glob
import os
import shutil
import subprocess
import sys

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

RAYLIB_C_SOURCES = [
    "rcore.c",
    "utils.c",
    "rshapes.c",
    "rtextures.c",
    "rtext.c",
    "rmodels.c",
    "raudio.c",
]


def validate_prerequisites():
    """Check that setup.sh has been run and all needed files exist."""
    src_dir = os.path.join(PROJECT_ROOT, "external", "raylib", "src")
    if not os.path.isdir(src_dir):
        print("Error: external/raylib/src/ not found. Run setup.sh first.", file=sys.stderr)
        sys.exit(1)

    internal = os.path.join(PROJECT_ROOT, "internal", "raylib")
    for name in RAYLIB_C_SOURCES:
        path = os.path.join(internal, name)
        if not os.path.isfile(path):
            print(f"Error: internal/raylib/{name} not found. Run setup.sh first.", file=sys.stderr)
            sys.exit(1)

    print("Prerequisites validated.")


def copy_file(src, dst, *, warn_missing=False):
    """Copy a single file, creating parent directories as needed."""
    if not os.path.isfile(src):
        if warn_missing:
            print(f"  Warning: {os.path.relpath(src, PROJECT_ROOT)} not found, skipping.")
        return
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)


def copy_tree(src, dst):
    """Copy a directory tree."""
    if not os.path.isdir(src):
        print(f"  Warning: {os.path.relpath(src, PROJECT_ROOT)} not found, skipping.")
        return
    shutil.copytree(src, dst, dirs_exist_ok=True)


def build_publish_dir():
    """Create publish/ directory with all needed files."""
    publish = os.path.join(PROJECT_ROOT, "publish")

    # Clean and recreate
    if os.path.exists(publish):
        shutil.rmtree(publish)
    os.makedirs(publish)

    print("Building publish/ directory...")

    # Top-level files
    copy_file(os.path.join(PROJECT_ROOT, "moon.mod.json"), os.path.join(publish, "moon.mod.json"))
    copy_file(os.path.join(PROJECT_ROOT, "README.md"), os.path.join(publish, "README.md"), warn_missing=True)
    copy_file(os.path.join(PROJECT_ROOT, "LICENSE"), os.path.join(publish, "LICENSE"), warn_missing=True)
    copy_file(os.path.join(PROJECT_ROOT, "moon.pkg"), os.path.join(publish, "moon.pkg"))

    # Root .mbt files (skip tests)
    for path in sorted(glob.glob(os.path.join(PROJECT_ROOT, "*.mbt"))):
        name = os.path.basename(path)
        if name.endswith("_test.mbt") or name == "windowed_smoke_test.mbt":
            continue
        copy_file(path, os.path.join(publish, name))

    # internal/raylib/ .mbt files
    internal_src = os.path.join(PROJECT_ROOT, "internal", "raylib")
    internal_dst = os.path.join(publish, "internal", "raylib")
    os.makedirs(internal_dst, exist_ok=True)

    copy_file(os.path.join(internal_src, "moon.pkg"), os.path.join(internal_dst, "moon.pkg"))

    for path in sorted(glob.glob(os.path.join(internal_src, "*.mbt"))):
        copy_file(path, os.path.join(internal_dst, os.path.basename(path)))

    # Tracked C/Obj-C glue
    copy_file(os.path.join(internal_src, "stub.c"), os.path.join(internal_dst, "stub.c"))
    copy_file(os.path.join(internal_src, "rglfw.m"), os.path.join(internal_dst, "rglfw.m"))

    # Generated raylib C sources
    for name in RAYLIB_C_SOURCES:
        copy_file(os.path.join(internal_src, name), os.path.join(internal_dst, name))

    # external/raylib/src/ (headers + external deps for -I paths)
    ext_src = os.path.join(PROJECT_ROOT, "external", "raylib", "src")
    ext_dst = os.path.join(publish, "external", "raylib", "src")
    print("  Copying external/raylib/src/ (headers)...")
    copy_tree(ext_src, ext_dst)

    # tools/
    for name in ["cc", "stub-cc", "stub-ar"]:
        src = os.path.join(PROJECT_ROOT, "tools", name)
        dst = os.path.join(publish, "tools", name)
        copy_file(src, dst)
        if os.path.isfile(dst):
            os.chmod(dst, 0o755)

    print("Done.")


def verify(publish_dir):
    """Run moon check --target native in the publish directory."""
    print("Verifying with moon check --target native...")
    result = subprocess.run(
        ["moon", "check", "--target", "native"],
        cwd=publish_dir,
    )
    if result.returncode != 0:
        print("Error: moon check failed in publish/", file=sys.stderr)
        sys.exit(1)
    print("Verification passed.")


def publish(publish_dir):
    """Run moon publish in the publish directory."""
    print("Publishing...")
    result = subprocess.run(
        ["moon", "publish"],
        cwd=publish_dir,
    )
    if result.returncode != 0:
        print("Error: moon publish failed", file=sys.stderr)
        sys.exit(1)
    print("Published successfully.")


def main():
    parser = argparse.ArgumentParser(description="Package and publish tonyfettes/raylib to mooncakes")
    parser.add_argument("--publish", action="store_true", help="Run moon publish after packaging")
    parser.add_argument("--dry-run", action="store_true", help="Only package, skip verification")
    args = parser.parse_args()

    os.chdir(PROJECT_ROOT)
    validate_prerequisites()
    build_publish_dir()

    publish_dir = os.path.join(PROJECT_ROOT, "publish")

    if not args.dry_run:
        verify(publish_dir)

    if args.publish:
        publish(publish_dir)
    else:
        print(f"\nPublish directory ready at: {publish_dir}")
        print("Run with --publish to publish, or inspect the directory first.")


if __name__ == "__main__":
    main()
