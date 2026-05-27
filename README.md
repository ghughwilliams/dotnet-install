# dotnet-install

Installs .NET on macOS or Linux using the official `dotnet-install.sh` script, with GPG signature verification before execution.

## Usage

```
make            # download, verify, and install (equivalent to make install)
make download   # download and verify only, without installing
make uninstall  # remove ~/.dotnet
make clean      # remove all downloaded files and stamp files
```

By default, `make install` installs the current LTS release. To install a different channel (e.g. STS, or a specific version like `9.0`), run `make download` first, then invoke the verified script directly:

```
./dotnet-install.sh --channel STS
./dotnet-install.sh --channel 9.0
```

## GPG verification

Before execution, the installer script is verified against the signing key with fingerprint:

```
2B930AB1228D11D5D7F6B6ACB9CF1A51FC7D3ACF
```

This fingerprint was confirmed against the [official Microsoft documentation](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script) and [dotnet/install-scripts#276](https://github.com/dotnet/install-scripts/issues/276) (retrieved 2026-05-27). If Microsoft rotates the signing key, the `EXPECTED_FPR` variable in the Makefile will need to be updated.

## Post-install

Add .NET to your shell environment:

```
echo 'export PATH="$HOME/.dotnet:$PATH"' >> ~/.zshrc  # or whatever your shell uses
echo 'export DOTNET_ROOT="$HOME/.dotnet"' >> ~/.zshrc
```
