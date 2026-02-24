# Nox

The package manager for the [Novus](https://github.com/MJDaws0n/Novus) programming language.

```
  _   _  _____  __  __
 | \ | |/ _ \ \/ /
 |  \| | | | \  /
 | |\  | |_| /  \
 |_| \_|\___/_/\_\

 the novus package manager
```

## Quick Start

```bash
# Download and build
git clone https://github.com/MJDaws0n/Nox.git
cd Nox
# Download the Novus compiler (macOS Apple Silicon)
curl -L -o novus https://raw.githubusercontent.com/MJDaws0n/Novus/main/novus
chmod +x novus
./build.sh

# Install globally (optional)
./install.sh
```

## Usage

```bash
# Initialise a new Novus project (auto-installs novus-std)
nox init

# Pull a package by name from the registry
nox pull maths

# Pull a specific version
nox pull maths -v 1.0.0

# Pull a package from a GitHub URL
nox pull https://github.com/MJDaws0n/GolemMC

# Pull a specific branch and commit
nox pull https://github.com/MJDaws0n/GolemMC -b main -c abc123

# List available packages
nox list

# Check installed packages for updates
nox check

# Remove a package
nox remove maths

# Show help
nox help
```

## How It Works

Nox pulls packages from GitHub repositories into a `lib/` directory in your project. Each package gets its own folder using the **library name** (registry name), not the repository name.

Installed packages are tracked in `libraries.conf` with version, branch, commit, and version constraint information.

### `nox init`

Creates a new project with `main.nov`, `lib/`, and `libraries.conf`. Automatically pulls the `novus-std` standard library. If run in an existing project, installs any missing packages listed in `libraries.conf` (like `npm install`).

```
my_project/
├── main.nov
├── libraries.conf        ← tracks installed packages
├── lib/
│   ├── novus-std/         ← auto-installed standard library
│   ├── maths/             ← pulled with: nox pull maths
│   └── ...
└── novus
```

You can then import from pulled packages in your Novus code:

```novus
import lib/novus-std/lib/standard_lib;
import lib/novus-std/lib/standard_lib_macos_silicon;
import lib/maths/main;
```

## Library Structure

Nox's bundled libraries use a folder-based structure with platform-specific implementations:

```
lib/
├── std/                              ← standard library
│   ├── main.nov                      ← loader (imports core + platform files)
│   ├── core.nov                      ← cross-platform: len, str_to_i32, bool_to_str, etc.
│   ├── strings.nov                   ← cross-platform: str_replace, str_upper, etc.
│   ├── darwin_arm64.nov              ← macOS ARM64: print, exit, fork, etc.
│   ├── memory_darwin_arm64.nov       ← macOS ARM64: buffers, store8, argv, cstr
│   ├── windows_amd64.nov             ← Windows x64: print, exit, input via Win API
│   ├── memory_windows_amd64.nov      ← Windows x64: buffers via RtlMoveMemory
│   ├── windows_x86.nov              ← Windows x86: 32-bit Win API variants
│   └── memory_windows_x86.nov       ← Windows x86: 32-bit memory ops
├── file_io/
│   ├── main.nov                      ← loader
│   ├── darwin_arm64.nov              ← macOS ARM64: file ops, paths, dirs, mmap
│   ├── windows_amd64.nov             ← Windows x64: CreateFileA, ReadFile, WriteFile
│   └── windows_x86.nov              ← Windows x86: 32-bit file ops
├── process/
│   ├── main.nov                      ← loader
│   ├── darwin_arm64.nov              ← macOS ARM64: fork, run_cmd, capture_output
│   ├── windows_amd64.nov             ← Windows x64: CreateProcessA, cmd.exe
│   └── windows_x86.nov              ← Windows x86: 32-bit process ops
├── maths/
│   ├── main.nov                      ← loader
│   └── core.nov                      ← cross-platform: abs, min, max, pow, gcd, lcm
├── net/
│   ├── main.nov                      ← loader
│   ├── darwin_arm64.nov              ← macOS ARM64: BSD sockets
│   ├── windows_amd64.nov             ← Windows x64: Winsock2
│   └── windows_x86.nov              ← Windows x86: Winsock2 (32-bit)
├── window/
│   ├── main.nov                      ← loader
│   ├── darwin_arm64.nov              ← macOS ARM64: WebKit window manager
│   └── window_manager                ← macOS ARM64 binary (C helper)
├── time/
│   ├── main.nov                      ← loader
│   ├── darwin_arm64.nov              ← macOS ARM64: sleep, timers
│   ├── windows_amd64.nov             ← Windows x64: Sleep, GetTickCount64
│   └── windows_x86.nov              ← Windows x86: 32-bit time ops
└── env/
    ├── main.nov                      ← loader
    ├── darwin_arm64.nov              ← macOS ARM64: getcwd, getpid, getenv
    ├── windows_amd64.nov             ← Windows x64: Win API environment
    └── windows_x86.nov              ← Windows x86: 32-bit env ops
```

### Platform Support

| Library | macOS ARM64 | Windows x64 | Windows x86 |
|---------|:-----------:|:-----------:|:-----------:|
| std     | ✅          | ✅          | ✅          |
| file_io | ✅          | ✅          | ✅          |
| process | ✅          | ✅          | ✅          |
| maths   | ✅ (cross-platform) | ✅ (cross-platform) | ✅ (cross-platform) |
| net     | ✅          | ✅          | ✅          |
| time    | ✅          | ✅          | ✅          |
| env     | ✅          | ✅          | ✅          |
| window  | ✅          | —           | —           |

**To use on Windows:** Edit the `main.nov` loader in each library folder to import the Windows variant instead of `darwin_arm64`. For example, in `lib/std/main.nov`, change `import darwin_arm64;` to `import windows_amd64;`.

> **Note:** Due to a Novus compiler limitation (#if blocks in imported files don't export functions), platform selection requires manually changing the import in each loader. This will be automated once the compiler supports conditional exports.

### Bundled Library Reference

<details>
<summary><strong>std</strong> — standard library (core types, strings, memory)</summary>

**core.nov** (cross-platform)
- `len(s) → i32`, `str_repeat(s, n) → str`, `char_eq(s, idx, ch) → bool`
- `str_to_i32(s) → i32`, `str_to_i64(s) → i64`, `int_to_str(n) → str`, `i32_to_str(n) → str`, `i64_to_str(n) → str`
- `u64_to_i32(n) → i32`, `bool_to_str(b) → str`, `str_to_bool(s) → bool`, `to_u8(v) → i32`

**strings.nov** (cross-platform)
- `starts_with`, `ends_with`, `str_contains`, `str_find`, `str_last_find`
- `substr`, `substr_len`, `str_count`, `str_replace`, `str_replace_first`
- `str_trim`, `str_trim_left`, `str_trim_right`, `str_upper`, `str_lower`, `str_reverse`
- `str_pad_left`, `str_pad_right`, `str_equals`, `str_split_first`, `str_split_rest`
- `str_is_empty`, `str_is_blank`, `int_to_hex`
- `is_digit`, `is_alpha`, `is_alnum`, `is_space`, `is_upper`, `is_lower`

**memory_darwin_arm64.nov** / **memory_windows_amd64.nov** / **memory_windows_x86.nov**
- `make_buffer`, `copy_bytes_raw`, `copy_bytes`, `cstr_to_str`, `byte_at`, `argv_get`
- `store8`, `store32`, `memset`
</details>

<details>
<summary><strong>file_io</strong> — file system operations</summary>

- `file_open`, `file_open_read`, `file_open_write`, `file_close`
- `file_read`, `file_write`, `file_write_str`, `file_seek`, `file_size`
- `file_mmap_read`, `file_munmap`
- `read_file`, `write_file`, `file_append`, `file_copy`
- `file_exists`, `file_delete`, `file_rename`, `file_chdir`
- `pipe_create`, `dup2`, `sys_mkdir`, `sys_chmod`, `mkdirp`, `dir_exists`
- `path_ext`, `path_stem`, `path_dir`, `path_basename`, `path_insert_suffix`, `path_ext_no_dot`, `path_join`
</details>

<details>
<summary><strong>process</strong> — process & subprocess management</summary>

- `wait_pid`, `capture_output`, `capture_output_full`, `run_cmd`
- `shell_exec(cmd) → i32` — run a shell command via `/bin/sh -c`
- `shell_output(cmd, max_len) → str` — run a shell command and capture output
- `pick_file_dialog(file_type) → str` — macOS file picker via osascript
- `pick_folder_dialog() → str` — macOS folder picker via osascript
</details>

<details>
<summary><strong>maths</strong> — mathematical functions (cross-platform)</summary>

- `is_even`, `is_odd`, `is_prime`
- `abs`, `abs64`, `max`, `min`, `max64`, `min64`
- `clamp`, `clamp64`, `sign`, `sign64`
- `pow_i32`, `pow_i64`, `factorial`, `fibonacci`
- `gcd`, `lcm`, `div_ceil`, `wrap`, `map_range`
- `isqrt`, `digit_sum`, `digit_count`, `lerp`
</details>

<details>
<summary><strong>net</strong> — TCP networking (macOS ARM64)</summary>

- `net_socket`, `net_close`, `net_shutdown`
- `net_set_reuse`, `net_set_nosigpipe`, `net_set_nonblock`, `net_set_keepalive`
- `net_bind`, `net_listen`, `net_accept` — server-side
- `net_connect`, `net_connect_local` — client-side
- `net_read`, `net_read_safe`, `net_write`, `net_write_str`, `net_write_line`
- `net_poll_read`, `net_bytes_available`, `net_ignore_sigpipe`
- `net_listen_on(port, backlog)` — high-level: create, bind, listen in one call
- `net_read_line`, `net_read_all`
- `make_sockaddr_in`, `make_sockaddr_in_addr`, `net_make_buf`
</details>

<details>
<summary><strong>window</strong> — macOS window manager (WebKit via UNIX socket)</summary>

- `wm_open(title, exe_path, sock_path)`, `wm_open_default(title)`
- `wm_title`, `wm_show`, `wm_hide`, `wm_resize`, `wm_ping`, `wm_quit`
- `wm_serve(fd, root_dir)`, `wm_navigate(fd, url)`, `wm_jseval(fd, code)`
- `wm_send_to_js`, `wm_recv_js_msg`, `wm_parse_port`
- `wm_open_serve(title, root_dir, index_path)` — convenience: open + serve + navigate
- `wm_escape_arg`, `wm_unescape_arg`, `wm_escape_js`
</details>

<details>
<summary><strong>time</strong> — time and sleep utilities (macOS ARM64)</summary>

- `sleep_ms(ms)`, `sleep_s(seconds)`
- `get_time_ms()`, `get_time_us()`, `get_time_s()`
- `elapsed_ms(start_ns, end_ns)`, `elapsed_us(start_ns, end_ns)`
- `timer_start()`, `timer_elapsed_ms(start)`, `timer_elapsed_us(start)`, `timer_elapsed_s(start)`
- `format_duration_ms(ms) → str`
</details>

<details>
<summary><strong>env</strong> — environment & system info (macOS ARM64)</summary>

- `getcwd()`, `getpid()`, `getppid()`, `getuid()`, `geteuid()`
- `getenv(name)`, `gethostname()`
- `get_home_dir()`, `get_username()`, `get_os_name()`, `get_os_version()`, `get_arch()`
</details>

## libraries.conf

When you pull packages, Nox automatically creates and maintains a `libraries.conf` file that tracks:

- **Package name, URL, version, branch, and commit** — for reproducible builds
- **Min/max version constraints** — for dependency compatibility

```conf
# libraries.conf - Nox package manifest
# Auto-generated by nox

installed=novus-std,maths

pkg:novus-std:url=https://github.com/MJDaws0n/Novus
pkg:novus-std:version=0.1.1
pkg:novus-std:branch=main
pkg:novus-std:commit=4dbd69c...
pkg:novus-std:min=*
pkg:novus-std:max=*

pkg:maths:url=https://github.com/MJDaws0n/novus-maths
pkg:maths:version=1.0.0
pkg:maths:branch=main
pkg:maths:commit=aeb0d9f...
pkg:maths:min=*
pkg:maths:max=*
```

When you pull a package that has its own `libraries.conf`, Nox automatically pulls all of its dependencies too. Nox scans nested `libraries.conf` files throughout the package tree. If there are version conflicts, Nox will warn you.

## Package Registry

Packages can be pulled by name (e.g. `nox pull maths`) using the built-in registry. The registry maps short names to GitHub URLs and is hosted in this repo at [`registry.txt`](registry.txt).

The registry supports versioned entries so you can pull specific versions:

```
# Base entry (latest)
maths=https://github.com/MJDaws0n/novus-maths
# Version info
maths:latest=1.0.0
# Specific version with branch and commit
maths@1.0.0=https://github.com/MJDaws0n/novus-maths|main|
```

### Available Packages

| Name | Repository |
|------|------------|
| `novus-std` | [MJDaws0n/Novus](https://github.com/MJDaws0n/Novus) - Novus language & standard libraries |
| `maths` | [MJDaws0n/novus-maths](https://github.com/MJDaws0n/novus-maths) - Mathematical functions |

### Adding a Package

To add your package to the registry, submit a PR editing `registry.txt` with:

```
your-package=https://github.com/your-username/your-repo
your-package:latest=1.0.0
your-package@1.0.0=https://github.com/your-username/your-repo|main|<commit>
```

## Flags

| Flag | Description |
|------|-------------|
| `--no-depth` | Clone full git history instead of shallow (default: `--depth 1`) |
| `-v <version>` | Pull a specific version from the registry |
| `-b <branch>` | Clone from a specific branch |
| `-c <commit>` | Checkout a specific commit after cloning |

## Requirements

- macOS Apple Silicon (ARM64)
- Git (installed via Xcode Command Line Tools)
- Internet connection (for pulling packages and fetching registry)

## Built With

Nox is written entirely in [Novus](https://github.com/MJDaws0n/Novus), the language it serves. It uses a folder-based library structure with cross-platform core modules and platform-specific implementations, and shells out to `git` for cloning and `curl` for fetching the registry.

## License

Same as [Novus](https://github.com/MJDaws0n/Novus).
