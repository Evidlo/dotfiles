# Mnemo Project Memory

## Description
Automatically loads project history and context from past AI coding sessions using mnemo.

## Keywords
- project
- context
- history
- remember
- previous
- last time
- earlier
- before

## Instructions

You have access to the project's AI coding history through mnemo. Before exploring the codebase fresh, check if relevant context exists from past sessions.

### Available Commands

Run these via terminal to access project memory:

```bash
# Search past sessions for relevant context
mnemo search "<keywords>"

# Get context summary for current project
mnemo context "$(basename $(pwd))"

# List recent sessions
mnemo recent

# Re-index if sessions seem missing
mnemo index
```

### When to Use

1. **Starting a new session**: Run `mnemo context` to see what was discussed before
2. **Debugging issues**: Search for past discussions about the error/component
3. **Continuing work**: Find where you left off with `mnemo search`
4. **Architecture questions**: Check if decisions were already made

### Important Notes

- Mnemo indexes Claude Code, OpenCode, and other AI tool sessions
- Search uses SQLite FTS5 with BM25 ranking
- Results show highlighted snippets with context
- Use `mnemo index --force` to rebuild if data seems stale
