# distill

**dist**ribute + **install** - A single-file Bash CLI that generates a self-contained 'install.sh' for any CLI tool.

Every CLI tool deserves a proper installer: one that handles fresh installs,
idempotent upgrades with semver comparison, interactive and non-interactive
modes, and clean uninstalls. Writing that from scratch every time is tedious
and leads to drift between projects. distill solves this by generating a
complete, standalone `install.sh` from a short set of parameters.

The generated file is intentionally self-contained — no runtime dependency on
distill. Copy it into your repo, commit it, and ship it.

## Install distill

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/milvasic/distill/refs/heads/main/install.sh)"
```

Non-interactive (CI):

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/milvasic/distill/refs/heads/main/install.sh)" -- --yes
```

Uninstall:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/milvasic/distill/refs/heads/main/install.sh)" -- --uninstall
```

## Usage

```
distill <command> [flags]
distill [generate flags]   # 'generate' is the default command
```

### Commands

| Command                  | Description                             |
| ------------------------ | --------------------------------------- |
| `generate`               | Generate an `install.sh` for a CLI tool |
| `update`                 | Update distill to the latest version    |
| `version, --version, -v` | Print version                           |
| `help, --help, -h`       | Show help                               |

`generate` is the default — if the first argument starts with `--` (or there
are no arguments), distill behaves as if you typed `distill generate`.

### Interactive wizard

Running `distill generate` (or just `distill`) with no flags starts an
interactive prompt for each parameter:

```
$ distill generate

=== distill v0.3.1 ===
Press Enter to accept the value shown in [brackets].

Binary name: mytool
Asset URL: https://raw.githubusercontent.com/you/mytool/refs/heads/main/mytool
Installer URL: https://raw.githubusercontent.com/you/mytool/refs/heads/main/install.sh
Install directory [/usr/local/bin]:
Asset type (script/binary) [script]:
```

The command generates `install.sh` in the current directory:

```sh
distill generate
```

### Non-interactive (flags)

```sh
distill generate \
  --name mytool \
  --asset-url https://raw.githubusercontent.com/you/mytool/refs/heads/main/mytool \
  --installer-url https://raw.githubusercontent.com/you/mytool/refs/heads/main/install.sh
```

### Self-update

```sh
distill update
```

### Generate flags

| Flag                  | Description                               | Default                 |
| --------------------- | ----------------------------------------- | ----------------------- |
| `--name NAME`         | Binary name                               | _(required)_            |
| `--asset-url URL`     | Direct URL to the downloadable asset      | _(required)_            |
| `--installer-url URL` | URL to the generated `install.sh`         | _(required)_            |
| `--install-dir DIR`   | Installation directory                    | `/usr/local/bin`        |
| `--asset-type TYPE`   | `script` or `binary`                      | `script`                |
| `--version-url URL`   | Plain-text version endpoint (binary only) | _(required for binary)_ |

## What gets generated

The `distill generate` command creates two files:

**`install.sh`** — a single Bash script with two clearly delimited sections:

- **CONFIG** — the 5–6 variables you provided. Edit this block directly or regenerate with distill if parameters change.
- **ENGINE** — a copy-paste-stable block that handles all install logic: sudo detection, curl/wget fallback, semver comparison, interactive upgrade prompts, and config directory cleanup on uninstall. Never edit this block manually.

**`install-regen.sh`** — a helper script that regenerates `install.sh` using the exact parameters you provided, so you never need to remember them.

The regenerate command is documented in `install-regen.sh`, which you can commit alongside `install.sh`:

```sh
# Run this to regenerate install.sh:
bash install-regen.sh
```

## Asset types

### `script` (default)

The asset is a shell script with `VERSION="x.y.z"` near the top. The engine
extracts the version by grepping the downloaded file — no separate version
endpoint needed.

### `binary`

The asset is a compiled binary. The engine fetches the version from a
separate plain-text `VERSION_URL` endpoint, then substitutes `{VERSION}` in
`ASSET_URL` to build the final download URL. The installed version is
extracted from `binary --version` output.

Example `ASSET_URL` for a binary with per-release download URLs:

```
https://github.com/you/mytool/releases/download/v{VERSION}/mytool-linux-amd64
```

## Updating the engine

When distill ships an improved engine, regenerate any existing `install.sh`
files with the command printed in their CONFIG comment. Because the CONFIG
block is preserved and only the ENGINE block is replaced, the update is safe
and mechanical.

distill dogfoods itself: `install.sh` in this repo was generated by distill.

## License

MIT
