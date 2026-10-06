# M08 Reference Card: Harness Engineering

## The superpowers pattern, three disciplines

| Discipline | What it means | What gets skipped without it |
|---|---|---|
| Test-first | A failing test before any production code | A test written to match what the code already does |
| Verify before claiming | Real command output before saying something works | A confident-sounding guess |
| Root-cause debugging | Fix the cause, not the symptom | A patch that hides the error and lets it reappear elsewhere |

## The verification-hook contract

- **Checks:** does the response contain a completion-claim phrase (checkov passes, tests pass,
  it works, is clean)?
- **If no claim:** pass, nothing to verify
- **If claim + real evidence nearby** (real command output, a real pass/fail count): pass
- **If claim + no evidence:** block, non-zero exit

## The test-first cycle, run for real in this lab

1. **RED**: write the test, run it against the unfixed module, confirm it fails for the real
   reason (`CKV_AWS_145` actually missing), not a typo
2. **GREEN**: write the minimal fix, rerun the same test, confirm it passes
3. **REFACTOR**: clean up only if there's real duplication or a real naming problem, skip
   honestly when there isn't

## The 3-Fix Rule, run for real in this lab

Three failed fix attempts on the same symptom is the signal to stop, not to try a fourth guess.

| Attempt | Hypothesis | Result |
|---|---|---|
| 1 | Provider version mismatch, pin exact version | Same error |
| 2 | Stale `.terraform` cache, wipe and reinit | Same error |
| 3 | Argument is just misnamed, guess `endpoints_url` | Same kind of error, still wrong |
| Stop | Compare against a known-working example instead of a 4th guess | Root cause found: `endpoint_url` was never valid AWS-provider syntax |

## Harness vs context vs loop, in one line each

| Layer | Symptom | Fixed in |
|---|---|---|
| Context | Can't get one task right at all | M03 |
| Harness | Ignores our standards | M04 to M08, this chapter assembles it |
| Loop | I have to babysit every run | M12 |

## Harness before loop

Never add a loop on top of a broken harness. A loop just repeats a broken harness's mistakes
faster. Module 12's step 5 (supervised autonomy) only works once this chapter's harness is real.
