# Subagent Workflow

This document guides the main agent through spawning and managing subagents for tasks.

**The main agent's role**: Planner, monitor, reviewer, integrator - NOT a programmer. Spawn subagents even for single tasks.

---

## Mental Model

### Why Delegate Everything

**Context is a finite resource.** Your context window is your working memory. Every file you read, every error you debug, every implementation detail you work through - these consume context that could be used for orchestration, planning, and user communication.

**The sunk cost trap:** Once you invest effort building context on a task ("I've already read these files, I understand the patterns..."), you become biased toward completing it yourself. "I'll just finish this one" leads to doing all the work yourself and losing the orchestrator perspective. **Avoid this by delegating from the start.**

**Even without parallelism benefits:** Spawning a subagent for a single blocking task keeps your context clean, establishes the delegation pattern, and prevents the sunk cost trap from ever forming.

### Your Job

1. **Task design**: Decompose work into tasks with clean, small, verifiable boundaries
2. **Boundary control**: Define interfaces and contracts, not implementations
3. **Lightweight verification**: Check that outputs meet contracts
4. **Orchestration**: Manage multiple subagents, handle issues, communicate with user

Your job is NOT: reading implementation code, debugging test failures, writing feature code.

### Task Design Principles

Good task decomposition determines how reviewable the output is:

- **Small scope**: One clear objective per task
- **Clean boundaries**: Well-defined inputs and outputs
- **Explicit contracts**: "Function X should return Y", "File Z should export A, B, C"
- **Verifiable criteria**: Can be checked without reading implementation details

Example of good task spec:
```
Create tl/internal/qc/gen_ident.mbt with:
- pub fn gen_lower_ident() -> @qc.Gen[String]  // [a-z][a-z0-9_]*
- pub fn gen_upper_ident() -> @qc.Gen[String]  // [A-Z][a-zA-Z0-9_]*
- pub fn gen_namespace() -> @qc.Gen[String?]

Acceptance: moon check passes, functions have correct signatures
```

### Verification Principle

**Control the boundary, trust the interior.**

Verify:
- Compiles (`moon check`)
- Tests pass (`moon test`)
- API matches spec (function signatures, exports)
- Follows stated patterns

Don't:
- Read every line of implementation
- Debug failing tests yourself (send back to subagent)
- Second-guess implementation choices that meet the spec

If verification fails, resume the subagent with specific feedback rather than fixing it yourself.

---

## Quick Reference

### Essential Commands

```bash
# Create worktree
git worktree add ./worktrees/<name> -b feature/<id>-<name>

# Verify quality
moon check && moon test && moon fmt

# Merge
git merge feature/<id>-<name> --no-ff -m "Merge <name>: <desc>"

# Cleanup
git worktree remove ./worktrees/<name>
git branch -d feature/<id>-<name>
```

### Subagent Types

| Type | Use Case |
|------|----------|
| `general-purpose` | Implementation tasks, bug fixes, features |
| `Explore` | Understanding codebase, finding patterns |
| `Plan` | Designing implementation approach |
| `Bash` | Git operations, running commands |

---

## Main Agent Workflow

### 1. Find & Claim Work

**Checklist before spawning:**

- [ ] No blocking dependencies
- [ ] Scope is specific (not "improve X" but "implement Y in X")
- [ ] Acceptance criteria are clear
- [ ] Boundary/contract is defined (what inputs, what outputs)
- [ ] **You are NOT tempted to "just do it yourself"** (if you are, that's the sunk cost trap)

**Parallel spawning:** When multiple tasks have no dependencies on each other, spawn them all in a single message. Don't wait for one to complete before spawning the next.

### 2. Create Worktree

**CRITICAL**: Commit local changes first - worktrees are created from HEAD.

```bash
git status                            # Check for uncommitted changes
git add <files> && git commit -m "chore: prepare for subagent work"

mkdir -p worktrees
git worktree add ./worktrees/<name> -b feature/<id>-<name>
```

### 3. Spawn Subagent

Use the Task tool with `run_in_background=true` and this prompt structure:

```
You are working in: /path/to/worktree

## Task
<paste task description>

## Context
- MoonBit project: use `moon check` frequently, `moon test` before done
- Reference files: <list key files to read>
- Patterns to follow: <list similar modules>

## Acceptance Criteria
- [ ] <Specific criterion 1>
- [ ] <Specific criterion 2>
- [ ] `moon check` passes
- [ ] `moon test` passes
- [ ] Code follows existing patterns

## When Done
Single commit: `<type>(<scope>): <description>`
Types: feat, fix, refactor, test, docs
```

**Context to include:**

- Worktree path (always)
- Issue ID and description
- Specific files to modify
- Related modules for patterns
- Error messages if fixing a bug

### 4. Monitor Progress

```bash
tail -50 /path/to/output-file         # Check recent output
```

**Let it complete when:** Making steady progress, errors being addressed

**Intervene when:**

- Stuck in loop on same error (3+ attempts)
- Wrong architectural approach
- Adding unnecessary complexity
- Duplicating existing functionality

**Intervention options:**

1. Resume with guidance (Task tool `resume` parameter) - **preferred**
2. Abort and restart with refined prompt
3. Take over manually - **avoid this; it pulls you back into implementer role**

**Productive waiting:**

- Update documentation (commit promptly)
- Clean up completed worktrees
- Spawn additional parallel subagents
- Plan next batch of work

### 5. Review & Merge

**Verify in worktree:**

```bash
cd ./worktrees/<name>
moon check && moon test && moon fmt
git diff  # Should be empty after fmt
```

**Code review checklist:**

- [ ] Implementation matches issue requirements
- [ ] Adequate tests with edge cases
- [ ] Follows existing codebase patterns
- [ ] No unnecessary abstractions
- [ ] No debug prints, commented code, unused imports
- [ ] Single commit with Co-Authored-By

**Merge from main repository:**

```bash
cd /Users/haoxiang/Workspace/moonbit/mosh
git merge feature/<id>-<name> --no-ff -m "Merge <name>: <description>"
moon check && moon test             # Post-merge verification
```

For conflicts, see [MERGE-CONFLICTS.md](./MERGE-CONFLICTS.md).

### 6. Cleanup

**Immediately after successful merge:**

```bash
git worktree remove ./worktrees/<name>
git branch -d feature/<id>-<name>
```

---

## Subagent Instructions

*Pass this section to subagents.*

### Your Environment

You are in a **git worktree** - an isolated copy on a feature branch.

```bash
pwd            # Verify: worktrees/<name>
git branch     # Verify: your feature branch
git status     # Should be clean initially
```

### Development Cycle

1. **Read existing code first** - understand patterns before modifying
2. Make changes
3. Run `moon check` - fix errors
4. Repeat until clean
5. Run `moon test` before committing

See [MOONBIT.md](./MOONBIT.md) for build commands and code conventions.

### Completion Checklist

**Code Quality:**

- [ ] `moon check` passes
- [ ] `moon test` passes
- [ ] `moon fmt` applied
- [ ] No debug prints or commented code

**Implementation:**

- [ ] Follows existing code patterns
- [ ] Error handling uses appropriate variants
- [ ] Public functions have doc comments (`///|`)

**Git:**

- [ ] All changes staged
- [ ] Single commit with descriptive message
- [ ] Co-Authored-By line included
- [ ] Working tree clean after commit

**Commit format:**

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<body explaining what and why>

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

**Types**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

### Anti-Patterns

**Over-engineering:**

- Abstractions for single-use code
- Helper functions called once
- Unrequested configurability

**Under-testing:**

- Happy path only
- Skipping error cases
- "It compiles so it works"

**Scope creep:**

- Fixing unrelated issues
- Refactoring outside task scope
- Adding unrequested features

**Git hygiene:**

- Uncommitted changes
- Multiple commits
- Files outside task scope

---

## Troubleshooting

| Problem | Cause | Resolution |
|---------|-------|------------|
| Subagent loops on same error | Missing context | Resume with specific guidance |
| Tests fail after merge | Isolated testing | Run full suite before merge |
| Worktree conflicts | Branch diverged | Rebase feature branch |
| Wrong architecture | Vague prompt | Be specific about patterns |
| Too many commits | Didn't squash | Use `git merge --squash` |

### When to Abort

Abort when:

- 3+ attempts without progress
- Fundamental task misunderstanding
- Creates immediate technical debt

**To restart:**

```bash
git worktree remove ./worktrees/<name> --force
git worktree add ./worktrees/<name> -b feature/<id>-<name>
# Spawn new subagent with refined prompt
```
