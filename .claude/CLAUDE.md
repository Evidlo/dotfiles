# Code Style

In scientific Python code, prefer to avoid conditionals where possible.  
Instead write code that handles multiple conditions simultaneously (e.g. cast numpy array to known type unconditionally)

Avoid adding comments which read as responses to issues raised in a session.  Comments should stand on their own in context.

# Tooling

When making commits/commit messages, be sure to check `git diff` output to see what has actually been committed already.  The user may have already committed some of your changes.

When testing code, do not generate long inline commands which require repeated permission from the user.  Instead write to a file in /tmp/claude_XXX.(py|sh|...) which can be granted write/exec permission once.

# Output

Use unicode characters instead of Latex when talking directly to the user.  e.g.  σ₁ instead of $\sigma_1$

When rendering LaTeX for a web viewer: inline $…$ only renders if the body has a TeX marker (\, ^, _, {}) and is ≤59 chars — append ^{} to plain bodies (e.g. $ab^{}$) and use $$…$$ for longer expressions.
