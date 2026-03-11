---
name: release-notes-writer
description: Generates concise, user-friendly release notes by fetching work items from Azure DevOps boards. Pulls items from the "Ready for Release" column, groups them by category, and writes a markdown file to /docs. Use this when the user wants to create release notes, changelogs, or describe what is new in a release.
license: MIT
compatibility: opencode
---

## What I do

I generate release notes by pulling work items from Azure DevOps boards. The board is the single source of truth — items in the "Ready for Release" column define what goes into the release. I write short, clear release notes that non-technical users understand, with work item numbers and clickable links to Azure DevOps.

## Error handling

Run all `az boards` and `az devops` commands directly — do NOT proactively verify login, extensions, or defaults before running them.

If any `az` command fails, diagnose the error message and act:

| Error pattern                                               | Likely cause                   | Action                                                                                                                                                                   |
| ----------------------------------------------------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| "Please run 'az login'" or 401/403                          | Not logged in or token expired | Ask the user to run `az login`, or offer to run it for them                                                                                                              |
| "azure-devops extension is not installed"                   | Missing CLI extension          | Ask the user if you should run `az extension add --name azure-devops` for them                                                                                           |
| "The following defaults are not set" or missing org/project | CLI defaults not configured    | Ask the user to provide organization and project, then offer to run `az devops configure --defaults organization=https://dev.azure.com/<org> project=<project>` for them |
| Any other error                                             | Unknown                        | Show the full error message to the user and ask how to proceed                                                                                                           |

Always **ask before running** any fix-command — never silently change the user's CLI configuration.

## Process (follow this order strictly)

### Step 1 — List area paths and let user choose

Fetch available area paths:

```bash
az boards area project list --depth 5 --output table
```

Present the list to the user and **ask which area path to use**. If the user already specified an area path or product name in their prompt, match it against the list and skip the question.

Wait for the user's answer before proceeding.

### Step 2 — Fetch work items in "Ready for Release"

Query all work items in the selected board column and area path using WIQL. The default column name is `Ready for Release`, but some boards use emoji-prefixed names like `🚀 Ready for release`.

First, do a broad query to discover the actual column name:

```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.WorkItemType], [System.State], [System.AreaPath], [System.BoardColumn] FROM WorkItems WHERE [System.AreaPath] UNDER '<selected-area-path>' ORDER BY [System.Id] DESC" --output json
```

Parse the results and look at the `System.BoardColumn` values. Find items where the column name contains "Ready for Release" (case-insensitive, ignore emoji prefixes).

Once the column name is known, run a targeted query:

```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.WorkItemType], [System.State], [System.AreaPath], [System.BoardColumn] FROM WorkItems WHERE [System.AreaPath] UNDER '<selected-area-path>' AND [System.BoardColumn] = '<discovered-column-name>' ORDER BY [System.WorkItemType], [System.Id]" --output json
```

If no column matching "Ready for Release" is found, **ask the user what the column is called** and use their answer.

### Step 3 — Fetch details for each work item

For each work item found in Step 2, fetch full details:

```bash
az boards work-item show --id <id> --output json
```

Extract:

- `System.Title` — the title
- `System.WorkItemType` — type (User Story, Bugfix, Task, NFR, etc.)
- `System.State` — state
- `System.Description` — description (may be HTML, extract plain text)

Also fetch child/related items if present (check the `relations` array in the response). For child items:

```bash
az boards work-item show --id <child-id> --output json
```

### Step 4 — Group and categorize

Group work items into categories based on their `System.WorkItemType`:

| Work item type                       | Category     |
| ------------------------------------ | ------------ |
| User Story, Feature                  | **New**      |
| Improvement, NFR                     | **Improved** |
| Bugfix, Bug                          | **Fixed**    |
| Removed (or title indicates removal) | **Removed**  |

Use judgment when a work item doesn't fit neatly — read the title and description to determine the correct category. Only include categories that have items.

If multiple work items are closely related or describe the same user-facing change, **merge them into a single bullet point** with all relevant work item numbers listed. Do not repeat essentially the same information across multiple bullet points.

If the user highlights a main feature in their prompt, give it prominence — consider making it a separate section with its own heading rather than just a bullet point.

### Step 5 — Build the Azure DevOps link URL

Construct clickable links using the organization and project from the work item's own `url` field (returned in every `az boards query` and `az boards work-item show` response). Extract the organization base URL and project ID from there.

The link format is:

```
https://dev.azure.com/<org>/<project>/_workitems/edit/<id>
```

Every bullet point MUST include at least one clickable work item link.

### Step 6 — Write release notes

Write the release notes and save them to a markdown file in the project's `/docs` directory:

**Filename:** `release-notes-YYYY-MM-DD.md` (using today's date)

**Path:** `<project-root>/docs/release-notes-YYYY-MM-DD.md`

If the `/docs` directory does not exist, create it.

## Writing style rules

- Default language is **English**. Use Norwegian only if the user explicitly requests it.
- Write for **non-technical users** — explain what the user can do or experiences, not what was coded.
- Use simple, everyday language.
- Maximum 1-2 sentences per bullet point.
- Every bullet point must have work item number(s) with **clickable links** in parentheses at the end.
- Do NOT mention: file names, variable names, component names, function names, commit SHAs, or technical implementation details.
- Do NOT write about infrastructure, CI/CD, dependency upgrades, or internal refactoring unless they have a direct user-visible effect.

## Output format

```markdown
## Release — <version or date>

<1-3 sentences summarizing the release: what are the biggest news and what will users notice most.>

---

### New

- Description of the change. ([#1234](https://<org-url>/<project>/_workitems/edit/1234))
- Description of the change. ([#1235](...), [#1236](...))

### Improved

- Description. ([#1240](...))

### Fixed

- Description. ([#1250](...))

### Removed

- Description. ([#998](...))
```

Always place the **summary text first**, before the bullet list. The summary gives the reader a quick impression of the release without reading every point.

If a feature is large enough to warrant its own section (e.g., the user marked it as a main feature), use a dedicated heading:

```markdown
### Feature Name (new)

Description of the feature and what it enables. ([#1234](...), [#1235](...), [#1236](...))

- Sub-capability one ([#1237](...))
- Sub-capability two ([#1238](...))
```

## Restrictions

- Do NOT include work items that are not in the "Ready for Release" column (or the equivalent column identified in Step 2).
- Do NOT omit work item numbers or links from any bullet point — both must always be present.
- Do NOT skip the area path selection step — area path must be confirmed by the user unless they already specified it.
- Do NOT guess or fabricate work items — only use data returned by Azure DevOps.
- Do NOT include purely technical/internal items (refactoring, CI/CD, dependency bumps) unless they have a clear user-visible impact.
- Do NOT ask unnecessary questions beyond area path selection — start the analysis with what the user has given.
- Do NOT use `az boards board list` — this command does not exist. Use `az boards area project list` instead.
