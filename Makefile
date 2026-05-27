EXPECTED_FPR := 2B930AB1228D11D5D7F6B6ACB9CF1A51FC7D3ACF
CHANNEL      := LTS
GPG_HOME     := $(CURDIR)/.gnupg
GPG          := gpg --homedir $(GPG_HOME)
YELLOW       := \033[33m
RED          := \033[1;31m
RESET        := \033[0m

.ONESHELL:
.SHELLFLAGS  := -eu -o pipefail -c
.DELETE_ON_ERROR:
.PHONY: all download install uninstall clean

all: install

dotnet-install.asc:
	@printf '$(YELLOW)Downloading the signing key...$(RESET)\n'
	curl -fsSL --proto '=https' https://dot.net/v1/dotnet-install.asc -O

.key-imported: dotnet-install.asc
	@mkdir -p $(GPG_HOME)
	chmod 700 $(GPG_HOME)
	if ! $(GPG) --show-keys --with-colons dotnet-install.asc | grep '^fpr:' | cut -d: -f10 | grep -qx '$(EXPECTED_FPR)'; then
		printf '$(RED)Bad fingerprint. Exiting$(RESET)\n' >&2
		exit 1
	fi
	printf '$(YELLOW)Signing key verified; importing to local keystore...$(RESET)\n'
	$(GPG) --import dotnet-install.asc
	touch $@

dotnet-install.sh: .key-imported
	@printf '$(YELLOW)Downloading installer script...$(RESET)\n'
	curl -fsSL --proto '=https' https://dot.net/v1/dotnet-install.sh -O

dotnet-install.sig: .key-imported
	@printf '$(YELLOW)Downloading script signature...$(RESET)\n'
	curl -fsSL --proto '=https' https://dot.net/v1/dotnet-install.sig -O

.signature-verified: dotnet-install.sh dotnet-install.sig
	@printf '$(YELLOW)Verifying script signature...$(RESET)\n'
	if ! $(GPG) --verify dotnet-install.sig dotnet-install.sh; then
		printf '$(RED)ERROR: dotnet-install.sh signature verification failed. Exiting$(RESET)\n' >&2
		exit 1
	fi
	printf '$(YELLOW)Script signature verified; marking executable...$(RESET)\n'
	chmod +x dotnet-install.sh
	touch $@

download: .signature-verified

install: .signature-verified
	@./dotnet-install.sh --channel $(CHANNEL)
	printf '$(YELLOW)dotnet installed at ~/.dotnet.$(RESET)\n'
	printf '\n'
	printf '$(YELLOW)RECOMMENDED: Update your environment with$(RESET)\n'
	printf '\n'
	printf '$(YELLOW)  echo '"'"'export PATH="$$HOME/.dotnet:$$PATH"'"'"' >> ~/.zshrc$(RESET)\n'
	printf '$(YELLOW)  echo '"'"'export DOTNET_ROOT="$$HOME/.dotnet"'"'"' >> ~/.zshrc$(RESET)\n'

uninstall:
	@rm -rf ~/.dotnet

clean:
	@rm -f dotnet-install.asc dotnet-install.sh dotnet-install.sig .key-imported .signature-verified
	rm -rf .gnupg
