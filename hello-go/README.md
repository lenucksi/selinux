# hello-go — GPG-Signed Arch Repo PoC

A minimal Go hello-world packaged as a signed Arch Linux pacman repository.

## Quick Start

### 1. Add the repo

```ini
# /etc/pacman.conf
[go-hello-world]
SigLevel = Required DatabaseOptional
Server = https://lenucksi.github.io/selinux/go-hello-world/$arch
```

### 2. Import the signing key

```bash
curl -O https://lenucksi.github.io/selinux/go-hello-world/x86_64/public.asc
pacman-key --add public.asc
pacman-key --lsign-key A66EAD29600BEF3A2F09B945EB8AEC2BA4B6DC1F
```

### 3. Install

```bash
pacman -Sy
pacman -S hello-go
hello-go
# → Hello from the signed Arch repo!
```

## Local Build

```bash
./scripts/build-signed-repo.sh
```

Requires `go`, `base-devel`, and a GPG signing key.

## Repository Structure

```
repo/go-hello-world/x86_64/
├── hello-go-*.pkg.tar.zst
├── hello-go-*.pkg.tar.zst.sig
├── go-hello-world.db.tar.zst
├── go-hello-world.db.tar.zst.sig
├── go-hello-world.files.tar.zst
├── go-hello-world.files.tar.zst.sig
└── public.asc
```
