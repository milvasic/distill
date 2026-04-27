#!/usr/bin/env bash
# Regenerate install.sh with distill

distill generate \
	--name "distill" \
	--asset-url "https://raw.githubusercontent.com/milvasic/distill/refs/heads/main/distill" \
	--installer-url "https://raw.githubusercontent.com/milvasic/distill/refs/heads/main/install.sh" \
	--install-dir "/usr/local/bin" \
	--asset-type "script" \
	--output install.sh
