
Step 1: git -C {DIR} diff
Step 2: Review the diff output. Determine the commit type and message.
        - Types: feat | fix | refactor | docs | test | chore
        - Format: <type>: <short description>
        - NEVER stage .env, credentials, or secret files
Step 3: git -C {DIR} add -A
Step 4: git -C {DIR} commit -m "<your commit message>"
Step 5: git -C {DIR} push

