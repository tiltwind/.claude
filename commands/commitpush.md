# Commit and Push

Commit all staged and unstaged changes, then push to remote repository.

## Workflow

1. Run `git status` to see all changes
2. Run `git diff` to review changes
3. Run `git log --oneline -3` to check recent commit style
4. Stage all relevant files (avoid sensitive files like `.env`)
5. Create a descriptive commit message summarizing the changes
6. Push to the remote repository
7. Report the result

## Commit Message Format

```
<type>: <short description>

<optional body with details>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

## Rules

- Never commit files containing secrets (`.env`, credentials, API keys)
- Never use `--force` push unless explicitly requested
- Never skip git hooks unless explicitly requested
- Use HEREDOC for commit messages to preserve formatting

## Example

```bash
git add file1.go file2.go
git commit -m "$(cat <<'EOF'
feat: Add user authentication service

- Implement JWT token generation
- Add password hashing with bcrypt
- Create login and register handlers
EOF
)"
git push
```

---

**Tools**: Bash
