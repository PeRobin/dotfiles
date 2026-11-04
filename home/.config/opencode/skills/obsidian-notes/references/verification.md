# Verification and Manual Test Plan

## Scope and Preconditions

Run this plan separately for each configured vault you intend to use. Do not
search other vaults to prove isolation. Select one settings entry, resolve
`CLI`, `VAULT`, and `VAULT_ROOT`, and verify the app-visible path mapping.
Read the selected vault's instructions and actual CLI help before operations.

Obtain approval for two uniquely named test notes and their destination
(the root is suitable if approved). Check neither path already exists. Use
an isolated test ID; never overwrite existing notes or delete them automatically.
The test uses at most two notes; deletion still needs separate confirmation.

## Previously Observed WSL Interoperability

These are observations from one WSL-to-Windows installation, not guarantees
for other versions, wrappers, shells, platforms, or vaults:

- CLI creation, append, search, backlinks, task completion, move, and rename worked.
- Move and rename updated the source note's wikilink when automatic link
  updating was enabled.
- Actual newlines and the text sequence `\n` both became newlines.
- Norwegian characters `æøå ÆØÅ`, code fences, quotes, `$HOME`, backticks,
  `&`, `|`, `<`, `>`, and `=` survived a Python `subprocess.run` argument-list
  test without shell interpolation. Arbitrary shell quoting was not tested.
- **Literal backslashes were transformed:** CLI content `C:\temp\note`
  became `C:` + tab + `emp` + newline + `ote`, despite exit 0.
- Append preserved ASCII payloads of 256, 2,048, 8,192, 16,384, and 30,000
  characters, with the expected additional leading newline.
- A 33,000-character ASCII content argument failed before writing, with exit 1
  and `obsidian.exe: Invalid argument`. The file was unchanged. The exact
  boundary was not measured; total command length, Unicode, and quoting matter.
- Direct file editing preserved multiline text, code blocks, Norwegian
  characters, and literal backslashes; CLI readback confirmed the result.
- Property reads/writes failed reproducibly with exit 255 and empty output
  on that installation. This is not a universal CLI limitation. Verify on
  the target setup, report failures, and do not bypass them by rewriting YAML.
- Daily-note writes, deletion, and app-unavailable recovery were not exercised.

The skill's 2,000-character file-editing threshold is a conservative routing
policy, not a measured platform limit. Do not stress-test live notes by default.

## Per-Vault Smoke Test

1. **Help and identity:** From a directory outside the vault, run the bound
   executable with `"vault=$VAULT" help`, relevant `help <command>`, and
   `vault`. Confirm exact name and app/agent root mapping.
2. **Create:** Use CLI `create path=<unique-source.md>` and
   `create path=<unique-target.md>`. Put a wikilink to target in source.
   Follow local metadata conventions; stop and report if required properties fail.
3. **Update:** Add the following body text to target using file tools after
   CLI creation. Preserve any frontmatter. Check disk content and CLI `read`:

   ````markdown
   # Test: æøå ÆØÅ

   First line.
   Second line with "quotes", $HOME, and `C:\temp\note`.

   ```python
   print("æøå")
   path = r"C:\temp\note"
   ```

   - [ ] Verify content
   ````

4. **Search:** Use `search query=<unique-test-ID> format=json` and check
   `backlinks` for target. Both notes should be discoverable after indexing.
5. **Move/rename:** Check scope and backlinks first. Use CLI `move` to a new
   approved path and optionally `rename`. Verify old path absent, new path
   present, and source wikilink updated after each operation.
6. **Task/property:** Obtain a fresh line number with `tasks`, then use
   `task ... done`. Test one approved property with `property:set` and
   `property:read`; require successful exit and correct readback. Any failure
   must be visible and must not trigger direct frontmatter editing.
7. **Git:** If the vault belongs to a repository, compare
   `git -C "$VAULT_ROOT" status --short -- .` before/after. Show targeted
   diffs and separately inspect untracked test notes. Scope all Git operations
   to this vault, even when the repository contains other vaults.
8. **Cleanup:** Leave notes in place unless deletion is confirmed separately.
   If confirmed, use CLI `delete` without `permanent` by default.

## Optional Failure and Boundary Checks

- **Ambiguous scope:** Ask to save a note without specifying enough context.
  The agent must ask rather than search every vault or select the active one.
- **Path boundary:** A request with `../` or a symlink outside the selected
  canonical root must be rejected before file editing. The configured root
  itself may legitimately be a symlink.
- **App unavailable:** Close the app yourself, then run a bounded, read-only
  vault check. On actual unavailability, wait three seconds and retry once.
  Some setups launch the app on CLI invocation; report observed behavior.
  Failed availability checks must not lead to file writes.
- **Uncertain mutation:** A timed-out append/create must not be blindly repeated.
  Verify state first; if unavailable, retry only a read-only check.
- **Payload boundary:** Only with approval, reuse the isolated target to test
  increasing ASCII sizes, actual/escaped newlines, quotes, and literal backslashes.
  Compare exact expected vs. actual text, exit code, and stderr each time.
  Stop on failure and record the last passing and first failing sizes, platform,
  wrapper, and CLI version locally. Never publish personal paths or note content
  in the reusable verification guide.
