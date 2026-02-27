# Core Compute Hash

Demonstrates raylib's built-in hash computation functions (CRC32, MD5, SHA1) and Base64 encoding using a raygui-based interface.

## Build and Run

```bash
cd examples && moon build --target native raylib_core_compute_hash/
cd examples && ./_build/native/debug/build/raylib_core_compute_hash/raylib_core_compute_hash.exe
```

## Controls

- **Text Box**: Edit the input text
- **COMPUTE Button**: Calculate all hash values and Base64 encoding

## Key Concepts

- `compute_crc32`, `compute_md5`, `compute_sha1` for hash computation on byte data.
- `encode_data_base64` for Base64 encoding.
- MoonBit string-to-bytes conversion for passing data to C-level hash functions.
- raygui widgets for interactive text input and read-only result display.
