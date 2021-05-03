ARCH ?= amd64
OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:'])
CURL ?= curl --fail -sSL
XARGS ?= xargs -I {}
BIN_DIR ?= ${HOME}/bin
TMP ?= /tmp

PATH := $(BIN_DIR):${PATH}

MAKEFLAGS += --no-print-directory
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

.PHONY: guard/% %/install %/lint

# Macro to return the download url for a github release
# For latest release, use version=latest
# To pin a release, use version=tags/<tag>
# $(call parse_github_download_url,owner,repo,version,asset select query)
parse_github_download_url = $(CURL) https://api.github.com/repos/$(1)/$(2)/releases/$(3)?access_token=$(GITHUB_ACCESS_TOKEN) | jq --raw-output  '.assets[] | select($(4)) | .browser_download_url'

# Macro to download a github binary release
# $(call download_github_release,file,owner,repo,version,asset select query)
download_github_release = $(CURL) -o $(1) $(shell $(call parse_github_download_url,$(2),$(3),$(4),$(5)))

guard/env/%:
	@ _="$(or $($*),$(error Make/environment variable '$*' not present))"

guard/program/%:
	@ which $* > /dev/null || $(MAKE) $*/install

$(BIN_DIR):
	@ echo "[make]: Creating directory '$@'..."
	mkdir -p $@

install/gh-release/%: guard/env/FILENAME guard/env/OWNER guard/env/REPO guard/env/VERSION guard/env/QUERY
install/gh-release/%:
	@ echo "[$@]: Installing $*..."
	$(call download_github_release,$(FILENAME),$(OWNER),$(REPO),$(VERSION),$(QUERY))
	chmod +x $(FILENAME)
	$* --version
	@ echo "[$@]: Completed successfully!"

install/pip/%: PYTHON ?= python
install/pip/%: | guard/env/PYPI_PKG_NAME
	@ echo "[$@]: Installing $*..."
	$(PYTHON) -m pip install --user $(PYPI_PKG_NAME)
	ln -sf ~/.local/bin/$* $(BIN_DIR)/$*
	$* --version
	@ echo "[$@]: Completed successfully!"

salt-lint/install:
	@ $(MAKE) install/pip/$(@D) PYPI_PKG_NAME=$(@D)

jq/install: JQ_VERSION ?= latest
jq/install: | $(BIN_DIR)
	@ $(MAKE) install/gh-release/$(@D) FILENAME="$(BIN_DIR)/$(@D)" OWNER=stedolan REPO=$(@D) VERSION=$(JQ_VERSION) QUERY='.name | endswith("$(OS)64")'

shellcheck/install: SHELLCHECK_VERSION ?= latest
shellcheck/install: SHELLCHECK_URL ?= https://storage.googleapis.com/shellcheck/shellcheck-${SHELLCHECK_VERSION}.linux.x86_64.tar.xz
shellcheck/install: $(BIN_DIR) guard/program/xz
	$(CURL) $(SHELLCHECK_URL) | tar -xJv
	mv $(@D)-*/$(@D) $(BIN_DIR)
	rm -rf $(@D)-*
	$(@D) --version

sh/%: FIND_SH := find . -name '*.sh' -type f -print0
sh/lint: | guard/program/shellcheck
	@ echo "[$@]: Linting shell scripts..."
	$(FIND_SH) | $(XARGS) shellcheck {} -e SC1088
	@ echo "[$@]: Shell scripts PASSED lint test!"

json/%: FIND_JSON := find . -name '*.json' -type f
json/lint: | guard/program/jq
	@ echo "[$@]: Linting JSON files..."
	$(FIND_JSON) | $(XARGS) bash -c 'cmp {} <(jq --indent 4 -S . {}) || (echo "[{}]: Failed JSON Lint Test"; exit 1)'
	@ echo "[$@]: JSON files PASSED lint test!"

json/format: | guard/program/jq
	@ echo "[$@]: Formatting JSON files..."
	$(FIND_JSON) | $(XARGS) bash -c 'echo "$$(jq --indent 4 -S . "{}")" > "{}"'
	@ echo "[$@]: Successfully formatted JSON files!"

salt/%: FIND_SLS := find . -name '*.sls' -type f
salt/lint: | guard/program/salt-lint
	@ echo "[$@]: Linting Salt files..."
	$(FIND_SLS) | $(XARGS) salt-lint -R {}
	@ echo "[$@]: Successfully formatted Salt files!"

#salt/install: SALTSTACK_URL ?= https://bootstrap.saltstack.com
#salt/install: $(BIN_DIR)
#  $(CURL) https://bootstrap.saltstack.com -o bootstrap_salt.sh
#  mv bootstrap_salt.sh $(BIN_DIR)
#  $(BIN_DIR)/bootstrap_salt.sh

#test: | guard/program/salt-call
#  salt-call --local state.sls pwm --state-output=mixed test=True
