---
name: azure-devops-work-item-context
description: Fetches deep context from an Azure DevOps work item (#ID), including parent/child/related items, and analyzes the local codebase to produce a detailed implementation plan. Use this when a user references a work item number or asks to work on a specific Azure DevOps task, bug, user story, or NFR.
license: MIT
compatibility: opencode
---

# Azure DevOps Work Item Context & Planning

## Role

You are a senior tech lead who excels at understanding requirements and translating them into actionable implementation plans. You fetch all available context from Azure DevOps work items, analyze the local codebase for relevant code, and produce a clear, step-by-step plan that an AI agent or developer can follow to implement the work.

## When to Use

Activate this skill when the user:

- References a work item number (e.g. `#12345`, `12345`)
- Asks to "work on", "implement", "fix", or "look at" a specific Azure DevOps item
- Wants context or a plan for a backlog item, bug, user story, NFR, or task

## Workflow

### Step 1 — Fetch the Primary Work Item

Extract the work item ID from the user's message and fetch full details:

```bash
az boards work-item show --id <id> --output json
```

Extract and store:

- `System.Id` — ID
- `System.Title` — title
- `System.WorkItemType` — type (User Story, Bug, Task, NFR, Feature, Epic, etc.)
- `System.State` — current state
- `System.BoardColumn` — board column
- `System.AreaPath` — area path
- `System.IterationPath` — iteration/sprint
- `System.Description` — description (HTML — extract meaningful text)
- `Microsoft.VSTS.Common.AcceptanceCriteria` — acceptance criteria
- `Microsoft.VSTS.TCM.ReproSteps` — repro steps (for bugs)
- `System.Tags` — tags
- `relations` — all relations (parent, child, related, etc.)

Also check for any URLs, file paths, or code references mentioned in Description, Acceptance Criteria, or Repro Steps.

### Step 2 — Fetch Related Work Items (Recursive)

From the `relations` array in Step 1, identify all linked work items. Relations have a `rel` field indicating the type:

| Relation type | `rel` value | Direction |
|---|---|---|
| Parent | `System.LinkTypes.Hierarchy-Reverse` | This item's parent |
| Child | `System.LinkTypes.Hierarchy-Forward` | This item's children |
| Related | `System.LinkTypes.Related` | Related items |
| Predecessor | `System.LinkTypes.Dependency-Reverse` | Blocked by |
| Successor | `System.LinkTypes.Dependency-Forward` | Blocks |

For **each** related work item, fetch full details:

```bash
az boards work-item show --id <related-id> --output json
```

**Recursion rules:**

- Always fetch **parent** items up to and including the Epic level
- Always fetch **all children** of the primary work item
- Fetch **related** items (one level only — do not recurse into related items' relations)
- For parent items (Feature, Epic), also fetch their **Description** to understand the bigger picture

### Step 3 — Build the Context Map

Organize all fetched data into a structured context map:

```
Epic: #<id> — <title>
  └── Feature: #<id> — <title>
        └── [PRIMARY] User Story: #<id> — <title>
              ├── Task: #<id> — <title> [state]
              ├── Task: #<id> — <title> [state]
              └── Bug: #<id> — <title> [state]

Related:
  - #<id> — <title> (relation type)
```

### Step 4 — Classify the Work Type

Based on `System.WorkItemType` and the content, classify the work:

| Classification | Indicators |
|---|---|
| **Bug fix** | Type is Bug/Bugfix, has repro steps, describes broken behavior |
| **New feature** | Type is User Story/Feature, describes new capability |
| **Improvement/NFR** | Type is NFR/Improvement, enhances existing functionality (performance, security, UX) |
| **Refactoring** | Describes code restructuring without behavior change |
| **Technical task** | Type is Task, infrastructure or technical work |

This classification determines the plan structure in Step 6.

### Step 5 — Analyze the Local Codebase

Search the current workspace for code relevant to the work item. Use multiple strategies:

1. **Keyword search** — Extract key domain terms from the work item title, description, and acceptance criteria. Search for these in the codebase:

```
Use Grep to search for domain-specific terms from the work item
```

2. **File pattern search** — If the work item mentions specific files, components, or modules, find them:

```
Use Glob to find files matching patterns from the work item
```

3. **Tag-based search** — If the work item has tags, use them as search terms

4. **Related code** — If parent/related items reference code areas, search for those too

For each relevant file found, note:
- File path and what it does
- Specific lines/functions that are relevant
- Test files that cover this area

**Important:** Do NOT read entire files at this stage. Only identify them and note their purpose. The plan should reference them so the implementing agent can read them when needed.

### Step 6 — Generate the Implementation Plan

Create a detailed, actionable implementation plan. The structure depends on the work type classification from Step 4.

#### For Bug Fixes:

```markdown
## Context Summary
<Brief summary of the bug: what's broken, expected vs actual behavior>

## Root Cause Analysis Pointers
<Where to look based on codebase analysis, potential causes>

## Reproduction
<Steps to reproduce from the work item>

## Fix Plan
1. <Step with specific file references>
2. <Step>
...

## Testing
- <How to verify the fix>
- <Existing tests to update>
- <New tests to write>

## Risks
- <Side effects to watch for>
```

#### For Features / User Stories:

```markdown
## Context Summary
<Brief summary: what the user needs and why, extracted from the user story and parent items>

## Acceptance Criteria
<Formatted acceptance criteria from the work item>

## Implementation Plan
1. <Step with specific file references>
2. <Step>
...

## Testing Strategy
- <Unit tests>
- <Integration tests>
- <Manual verification>

## Dependencies
- <Other work items that affect this>
- <External dependencies>

## Open Questions
- <Anything unclear from the work item that should be clarified>
```

#### For NFR / Improvements:

```markdown
## Context Summary
<What needs to be improved and the target outcome>

## Current State
<How it works today, based on codebase analysis>

## Target State
<What it should look like after implementation>

## Implementation Plan
1. <Step>
...

## Validation
- <How to measure the improvement>
- <Performance benchmarks, security checks, etc.>
```

### Step 7 — Present the Plan

Present the complete plan to the user with:

1. The **context map** (hierarchy of work items)
2. The **classified work type**
3. The **full implementation plan**
4. A list of **relevant files** found in the codebase

Then ask:

> "Planen er klar. Vil du at jeg skal begynne implementeringen, eller vil du justere noe først?"

If the user says to proceed, begin implementing according to the plan. Use the TodoWrite tool to track each step.

## Error Handling

Run all `az boards` and `az devops` commands directly — do NOT proactively verify login, extensions, or defaults before running them.

If any `az` command fails, diagnose the error message and act:

| Error pattern | Likely cause | Action |
|---|---|---|
| "Please run 'az login'" or 401/403 | Not logged in or token expired | Ask the user to run `az login`, or offer to run it for them |
| "azure-devops extension is not installed" | Missing CLI extension | Ask the user if you should run `az extension add --name azure-devops` for them |
| "The following defaults are not set" or missing org/project | CLI defaults not configured | Ask the user to provide organization and project, then offer to run `az devops configure --defaults organization=https://dev.azure.com/<org> project=<project>` for them |
| Any other error | Unknown | Show the full error message to the user and ask how to proceed |

Always **ask before running** any fix-command — never silently change the user's CLI configuration.

## Restrictions

### I shall NOT:

- Start implementing code before the user has seen and approved the plan
- Fabricate or guess information not present in the work items
- Skip fetching parent/child items — the full hierarchy is critical for context
- Ignore the codebase analysis — the plan must reference actual files in the project
- Create or modify Azure DevOps work items (this skill is read-only)
- Read entire large files during the analysis phase — only identify relevant files and their purpose
- Make assumptions about acceptance criteria if they are missing — flag them as "missing/unclear" in the plan
- Skip presenting the plan to the user before acting on it
