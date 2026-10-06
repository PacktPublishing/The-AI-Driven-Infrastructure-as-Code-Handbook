#!/usr/bin/env bash
# check-book-contract.sh — the gate that keeps this repository's promise to the book.
#
# The book prints 176 commands and names a set of paths. Every one of them has to be real
# here, on main, which is what the chapters cite. This is the public half of check 9 in the
# private authoring repo: that one asserts the manuscript matches the labs, this one
# asserts the labs still match the manuscript.
#
#   ./tools/check-book-contract.sh            check every chapter
#   ./tools/check-book-contract.sh 09         check chapter 9 only
#   ./tools/check-book-contract.sh --quiet    exit code only
#
# Exits 0 when every printed command appears verbatim in the lab corpus and every named
# path resolves. Three paths are absent by design and listed as such in the script; they
# are things the reader's own agent writes during the lab.
#
# The book cites paths on main, so main is what this checks. Anything that moves main away
# from what a chapter prints is a broken promise, and this is what catches it.

set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
CONTRACT="$HERE/printed-contract.json"

QUIET=0
CHAPTER=""
while [ $# -gt 0 ]; do
  case "$1" in
    --quiet) QUIET=1; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) CHAPTER="$1"; shift ;;
  esac
done

[ -f "$CONTRACT" ] || { echo "check-book-contract: $CONTRACT missing" >&2; exit 2; }

python3 - "$REPO" "$CONTRACT" "$CHAPTER" "$QUIET" <<'PY'
import glob, json, os, sys

repo, contract_path, only, quiet = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4] == "1"
C = json.load(open(contract_path))

# The corpus is every file a printed command can legitimately live in. It mirrors the
# private repo's check 9 corpus exactly, so the two gates cannot disagree about where a
# command counts as real.
GLOBS = ["modules/*/LAB.md", "capstone/README.md", "capstone/lab/*/*.sh", "capstone/lab/*/*.md"]
corpus = ""
corpus_files = []
for g in GLOBS:
    for f in sorted(glob.glob(os.path.join(repo, g))):
        corpus_files.append(os.path.relpath(f, repo))
        corpus += open(f).read()

# Chapter N's own tree. Chapter 13 is the capstone, not a module, which is the one place
# the chapter-to-directory mapping is not arithmetic.
base = {}
for d in sorted(glob.glob(os.path.join(repo, "modules/module-*"))):
    base[os.path.basename(d)[7:9]] = d
base["13"] = os.path.join(repo, "capstone")

# Absent by design: the reader's agent writes these during the lab, and one is a URL
# fragment the extractor cannot tell apart from a path. Each is justified, not waived.
BY_DESIGN = {
    ("10", "lab/requests/analytics-xr.yaml"):
        "written by the agent in the chapter's acceptEdits run; lab/requests/ ships empty",
    ("12", "lab/solution/work"):
        "created by loop.sh at runtime; the printed command before it is rm -rf on this path",
    ("11", "book/pull/2"):
        "the tail of this repository's pull-request URL, not a path in the tree",
}

def resolves(ch, p):
    # A printed path is relative to wherever the chapter's commands are run from, and
    # chapters differ: most run from the module root (lab/solution/xr.yaml), Chapter 6
    # runs from inside lab/ (module/main.tf), and a few are repo-relative
    # (labs/shared/floci-spike). Try all three roots.
    q = p.rstrip(".").rstrip("*").rstrip("/")
    b = base.get(ch, repo)
    for c in (os.path.join(repo, q), os.path.join(b, q), os.path.join(b, "lab", q)):
        if os.path.exists(c):
            return True
    return False

def resolves_name(ch, name):
    # A bare filename in the contract means "this file exists somewhere in the chapter's
    # tree". os.walk, not glob: glob will not descend into .claude, and three of the
    # named files live inside it.
    for root in (base.get(ch, repo), repo):
        for dp, dn, fn in os.walk(root):
            if name in fn:
                return True
    return False

chapters = [only.zfill(2)] if only else sorted(C)
fails = []
n_cmd = n_path = 0

for ch in chapters:
    if ch not in C:
        print("check-book-contract: no chapter %s in the contract" % ch, file=sys.stderr)
        sys.exit(2)
    for cmd in C[ch]["cmds"]:
        n_cmd += 1
        if cmd not in corpus:
            fails.append((ch, "command not in any lab file", cmd))
    for p in C[ch]["paths"]:
        n_path += 1
        if resolves(ch, p):
            continue
        if (ch, p) in BY_DESIGN:
            if not quiet:
                print("  ch%s by design: %s\n      %s" % (ch, p, BY_DESIGN[(ch, p)]))
            continue
        fails.append((ch, "path does not resolve", p))
    for f in C[ch]["files"]:
        n_path += 1
        if not resolves_name(ch, f):
            fails.append((ch, "named file not found", f))

if not quiet:
    print("corpus: %d files" % len(corpus_files))
    print("checked: %d printed commands, %d named paths and files" % (n_cmd, n_path))

if fails:
    if not quiet:
        print("\nFAIL: %d unmet promise(s)" % len(fails))
        for ch, why, what in fails:
            print("  ch%s  %s: %s" % (ch, why, what[:120]))
        print("\nAn unmet promise is one of two things. Either this tree drifted and needs")
        print("fixing, or the book text is wrong. The book is printed. Report it, do not")
        print("quietly patch the tree to hide it.")
    sys.exit(1)

if not quiet:
    print("\nOK: every printed command and every named path is real in this tree")
PY
