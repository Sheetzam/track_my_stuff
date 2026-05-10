# Mac Mini Sync Rule

When running commands on the Mac Mini via SSH that depend on local file changes (Maestro flows, scripts, source code), you MUST commit and `git push macdev main` BEFORE executing the remote command. The Mac Mini runs code from its git working tree — local edits on Ubuntu are not visible there until pushed.

Checklist before any `ssh macdev.local` command that uses project files:
1. `git add` the relevant changes
2. `git commit`
3. `git push macdev main` (clean Mac working tree first if needed)
4. THEN run the SSH command

This applies to: Maestro flows, verify_ios.sh, Ruby scripts, Flutter source code, pubspec.yaml — anything the Mac reads from disk.
