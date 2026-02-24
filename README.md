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
# Pull a package by name from the registry
nox pull golemmc

# Pull a package from a GitHub URL
nox pull https://github.com/MJDaws0n/GolemMC

# List available packages
nox list

# Remove a package
nox remove GolemMC

# Initialise a new Novus project
nox init

# Show help
nox help
```

## How It Works

Nox pulls packages from GitHub repositories into a `lib/` directory in your project. Each package gets its own folder matching the repository name.

```
my_project/
├── main.nov
├── lib/
│   ├── GolemMC/          ← pulled with: nox pull golemmc
│   ├── Novus/            ← pulled with: nox pull novus-std
│   └── ...
└── novus
```

You can then import from pulled packages in your Novus code:

```novus
import lib/GolemMC/lib/net;
import lib/Novus/lib/maths;
```

## Package Registry

Packages can be pulled by name (e.g. `nox pull golemmc`) using the built-in registry. The registry maps short names to GitHub URLs and is hosted in this repo at [`registry.txt`](registry.txt).

### Available Packages

| Name | Repository |
|------|------------|
| `novus-std` | [MJDaws0n/Novus](https://github.com/MJDaws0n/Novus) - Novus language & standard libraries |
| `golemmc` | [MJDaws0n/GolemMC](https://github.com/MJDaws0n/GolemMC) - Minecraft server in Novus |
| `manifold` | [MJDaws0n/Manifold-Edge-Remover-V2](https://github.com/MJDaws0n/Manifold-Edge-Remover-V2) - 3D model tool |

### Adding a Package

To add your package to the registry, submit a PR editing `registry.txt` with a new line:

```
your-package-name=https://github.com/your-username/your-repo
```

## Flags

| Flag | Description |
|------|-------------|
| `--no-depth` | Clone full git history instead of shallow (default: `--depth 1`) |

## Requirements

- macOS Apple Silicon (ARM64)
- Git (installed via Xcode Command Line Tools)
- Internet connection (for pulling packages and fetching registry)

## Built With

Nox is written entirely in [Novus](https://github.com/MJDaws0n/Novus), the language it serves. It uses the standard Novus libraries for file I/O, process execution, and string manipulation, and shells out to `git` for cloning and `curl` for fetching the registry.

## License

Same as [Novus](https://github.com/MJDaws0n/Novus).
