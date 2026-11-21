# BandaStation

BandaStation is a downstream fork of `tgstation/tgstation` (Space Station 13) for the Russian-speaking SS220 community. Main language: BYOND Dream Maker (DM); also TGUI (TypeScript/React), SQL, maps (`.dmm`), assets. Large, old, and highly interconnected:

## Glossary

- **you** means the agent reading this file.
- **we** means the BandaStation development team.
- **user** means the person who gave you the task.
- **bug fix** means a change that restores expected behavior.
- **feature** means any change beyond a bug fix, including new mechanics, balance changes, and reworks of existing systems.
- **approval** means explicit permission from a senior BandaStation developer to implement a proposal.

## Engineering principles

In this repository we would like to see you behave acording to Karpathy Guidelines

### 1. Think Before Coding

Don't assume. Don't hide confusion. Surface tradeoffs.

Before implementing:

State your assumptions explicitly. If uncertain, ask.
If multiple interpretations exist, present them - don't pick silently.
If a simpler approach exists, say so. Push back when warranted.
If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

Minimum code that solves the problem. Nothing speculative.

No features beyond what was asked.
No abstractions for single-use code.
No "flexibility" or "configurability" that wasn't requested.
No error handling for impossible scenarios.
If you write 200 lines and it could be 50, rewrite it.
Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

Touch only what you must. Clean up only your own mess.

When editing existing code:

Don't "improve" adjacent code, comments, or formatting.
Don't refactor things that aren't broken.
Match existing style, even if you'd do it differently.
If you notice unrelated dead code, mention it - don't delete it.
When your changes create orphans:

Remove imports/variables/functions that YOUR changes made unused.
Don't remove pre-existing dead code unless asked.
The test: Every changed line should trace directly to the user's request.

## Discuss features before implementation

Discuss big feature in the [BandaStation proposals channel on Discord](https://discord.com/channels/1097181193939730453/1181261198096875670) and obtain approval before implementation. See the [contribution guide](.github/CONTRIBUTING.md).

When the user asks to implement a feature, check whether it has been approved. If approval is unconfirmed, tell the user that maintainers may close the PR without it. You can help refine the design and draft the proposal while approval is pending.

Link the discussion containing the approval in the feature PR description.

## Extending upstream with minimal changes

BandaStation is a downstream fork. Use the modular system to keep upstream changes small and reduce the cost of maintaining the fork.

If you confirm that a bug originates upstream, stop work on the local fix and tell the user that it should be fixed upstream.

Implement new BandaStation features in a modpack under `modular_bandastation/`. Keep the feature's assets, objects, systems, state, and overrides of upstream code in that modpack. Choose the smallest extension that preserves the upstream contract.

- **To configure an object**, set subtype fields or adjust the object's own state after initialization.
- **To react to an existing signal or hook**, reuse it and verify when it fires and what the handler may do.
- **To check a condition before an upstream action**, check it in a modular override before calling the parent.
- **To extend a return value**, capture the parent result with `. = ..()` and modify it according to its contract.
- **To act at a specific point inside an upstream proc**, add a narrow hook and keep implementation and state in the modpack.

Trace the `#include` chain from each new `.dm` file through its modpack and `modular_bandastation/modular_bandastation.dme` to `tgstation.dme`. The [`example` modpack](modular_bandastation/example) is a template. [`job_restrictions`](modular_bandastation/job_restrictions) shows the include chain and parent lifecycle calls in a compiled modpack.

#### Parent calls and side effects

- Use `. = ..()` when the override needs to preserve and extend the parent's result. Use `return ..()` when the parent call completes the override. Check the result type and meaning. `JOB_AVAILABLE` is `0`, so `if(!.)` also matches success. Call the parent where its contract requires it and follow the normal inheritance chain.
- Check permission or eligibility before a parent call that creates a body, grants items, or saves data. Changing the return value cannot undo those effects. If rollback is required, perform it while the objects it needs still exist.
- Copy a shared list before modifying it when the contract requires a separate value. `Copy()` is shallow. Avoid temporarily replacing global job datums or active preferences across a call that can yield. After a yield, recheck the client, ownership, and state needed for the action.
- For TGUI extensions, inspect the DM `ui_data` and `ui_act` contract and the existing component first. Add the feature at the narrowest existing composition point and reuse existing components and styles. Keep the existing interface, dispatcher, and render path for local additions.

#### Narrow upstream hooks

Use a direct upstream hook when an override or signal lacks essential local data or runs at the wrong point. For each upstream hunk, record its purpose, the owning modpack, and why existing extension points are insufficient. Place validation before the side effect it can block and account for effects that have already occurred.

```dm
	native_validate()
	// BANDASTATION EDIT START - Feature admission
	if(!module_can_continue())
		return FALSE
	// BANDASTATION EDIT END - Feature admission
	native_commit()
```

In this example, the modpack defines `module_can_continue()`. Mark upstream edits with `// BANDASTATION EDIT - <reason>` for one line or matching `// BANDASTATION EDIT START - <reason>` and `// BANDASTATION EDIT END - <reason>` markers for a block. Use the existing `ADDITION` or `REMOVAL` variants where appropriate. Use one marker form per change and reserve these markers for upstream files.

- Preserve the upstream algorithm and extend the relevant step. Do not copy the whole algorithm into a modpack, disable the original with an unconditional return or a constant predicate, bypass a required parent by calling a more distant ancestor, or restructure upstream to save hooks or shrink the diff cosmetically.
- If correctness requires replacing or removing upstream behavior outside the requested scope, show the conflict and propose the smallest exception. When replacement is in scope, remove the superseded path.

---

## 3. Repository facts

- `code/` contains upstream-derived DM code.
- `modular_bandastation/` contains the fork's modpacks.
- `tgui/` contains the frontend.
- `SQL/` contains the schema and changelog.
- `_maps/` contains maps.
- `config/` contains server configuration managed by deployments.
- `tools/` contains build tools, CI scripts, and linters.
- `icons/`, `sound/`, `strings/`, and `interface/` contain assets.

**Sources of truth, in order:** the checked-out code; `.github/guides/*` (`STANDARDS.md`, `STYLE.md`, `AUTODOC.md`, `HARDDELETES.md`, `CI.md`, `ATOMIZATION.md`, …); `.github/CONTRIBUTING.md`; `tgui/README.md` and `tgui/docs/`; `code/modules/unit_tests/README.md`; lint config (`SpacemanDMM.toml`, `__odlint.dm`). General tg/DM knowledge comes after these. Legacy code shows what exists, not what is acceptable for new code. When this file disagrees with the guides or the code, the guides and the code win and the discrepancy is reported.

**Fork conventions:**

- When drafting a PR for code written with an agent, name each model and its harness in the PR description, as required by [CONTRIBUTING](.github/CONTRIBUTING.md).
- Credit new sounds, `.dmi` files, and other image assets in the relevant commit message, the PR description, or both. Name the creator, including the model that generated an asset, and link the source of reused assets. Verify that reuse is permitted. Do not create standalone attribution files for these credits.

## Game translation

- Keep object `name` values in English. When translating a name, use one `.toml` fragment per English name in [`modular_bandastation/translations/public/ru_names/`](modular_bandastation/translations/public/ru_names/) and fill in all six Russian grammatical cases. `ru_names.toml` is generated. Edit the fragments to update it.
- Translate existing item descriptions directly in the DM `desc` field. If an item needs an original description, ask the user to write it. Translate existing or user-provided text.
- Translate player-facing action messages in chat. Keep logs in English.
- Translation is encouraged and optional.

See the translation section of [CONTRIBUTING.md](.github/CONTRIBUTING.md) for the fragment format and [`tools/translations/`](tools/translations/) for the tools.

---

## 4. Boundaries

- Before reviewing a PR, read the [code review guide](.github/guides/CODE_REVIEW.md). Use its applicable checks when implementing changes as well.
- Implementation edits only the working tree. Commit, push, PR, or deploy happen only on explicit request. The user's uncommitted edits are never overwritten.
- When creating a commit that includes your work, add a `Co-authored-by` trailer after a blank line at the end of the commit message. Use your model's name and the provider's co-author email. For example, `Co-authored-by: gpt-6.1-sol <codex@openai.com>`.
- Generated files, such as built TGUI bundles, are never edited by hand.

### Plans and work artifacts

- Keep implementation plans, research notes, temporary checklists, and agent scratch files outside the Git worktree. Share feature proposals and design decisions in the Discord discussion or the issue tracking the work.
- Attach verification evidence, such as screenshots, recordings, and relevant log excerpts, directly to the PR. Game assets and test fixtures belong with the code that uses them.

## Evidence-based PRs

When preparing a PR, fill its Testing section with a Markdown task list. Use `- [x]` for checks that ran and succeeded, and `- [ ]` for checks that remain open. For each completed check, state the scenario, observed result, and supporting evidence. Explain any open checks and omit checks that do not apply.

- **New unit tests.** Run the same new tests against the code immediately before the first PR commit and against the final PR commit. Show that they fail on the behavior under test before the change and pass after it. Record both commit SHAs, the test names, and the results.

- **Gameplay.** Add a task for each new item or entity and each changed behavior. Record what a person verified in game or which unit test covered the behavior, along with the observed result.

- **TGUI.** Embed screenshots of the same scenario before and after the change in a PR table with scenario, before, and after columns. For a new interface, include the after screenshot and leave the before cell empty.
