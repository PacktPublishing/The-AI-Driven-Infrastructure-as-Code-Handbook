# tool-shims.sh -- sourced by every lab script that runs checkov.
#
# Why this exists. On Windows, pip puts a `checkov` launcher script on PATH whose `#!`
# line names a Windows Python path. PowerShell never reads that line (it runs
# checkov.exe), but Git Bash does, and cannot execute it:
#
#   checkov: cannot execute: required file not found
#
# so every script that calls `checkov` directly dies at its first scan. The module itself
# is installed fine, which is why `python -m checkov.main` works from the same shell.
#
# Usage, from a script:
#   . "$(dirname "${BASH_SOURCE[0]}")/../../../labs/shared/tool-shims.sh"
#   CHECKOV=$(checkov_cmd) || fail "checkov not found; see Appendix A"
#   $CHECKOV -d module --compact --quiet      # unquoted so "python -m checkov.main" splits
#
# labs/shared/tool-shims.test.sh reproduces the Windows failure on any machine and
# asserts this file routes around it.

# Resolve a checkov command that also works from Git Bash on Windows, where pip's
# launcher script on PATH cannot be executed by bash. Prints the command to use on
# stdout. When it has to fall back, it says so once on stderr, so a reader sees which
# command actually ran. Returns 1 when no working checkov can be found.
checkov_cmd() {
  if command -v checkov >/dev/null 2>&1 && checkov --version >/dev/null 2>&1; then
    echo checkov
    return 0
  fi
  local py
  for py in python3 python py; do
    if command -v "$py" >/dev/null 2>&1 && "$py" -m checkov.main --version >/dev/null 2>&1; then
      echo "tool-shims: bash cannot run the 'checkov' launcher on PATH; using '$py -m checkov.main' instead" >&2
      echo "$py -m checkov.main"
      return 0
    fi
  done
  return 1
}
