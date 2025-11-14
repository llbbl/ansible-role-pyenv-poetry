# CLAUDE.md - AI Assistant Guide

## Project Overview

This is an Ansible Galaxy role named `llbbl.pyenv-poetry` that automates the installation and configuration of:
- **pyenv**: A Python version management tool
- **Python**: A specific version of Python (configurable)
- **pipx**: A tool to install and run Python applications in isolated environments
- **Poetry**: A modern Python dependency management and packaging tool

**Author**: Logan Land (llbbl.com)
**Minimum Ansible Version**: 2.9
**Target Platforms**: Ubuntu and Debian systems
**Current Version**: 0.8

## Repository Structure

```
ansible-role-pyenv-poetry/
├── defaults/          # Default variables with lowest precedence
│   └── main.yml      # Default configuration values
├── handlers/          # Event handlers (currently empty)
│   └── main.yml
├── meta/             # Role metadata for Ansible Galaxy
│   └── main.yml      # Author info, dependencies, tags
├── tasks/            # Main task definitions
│   └── main.yml      # All installation and configuration tasks
├── tests/            # Testing playbooks
│   ├── inventory     # Test inventory file
│   └── test.yml      # Test playbook
├── vars/             # Role variables (higher precedence than defaults)
│   └── main.yml      # Computed variables (pyenv paths)
├── .gitignore        # Git ignore patterns
└── README.md         # User-facing documentation
```

## Key Files and Their Purposes

### defaults/main.yml
Contains configurable default values that users can override:
- `user_home_dir`: Home directory path (default: `/root`)
- `pyenv_version`: Version of pyenv to install (default: `v2.4.0`)
- `python_version`: Python version to install via pyenv (default: `3.10.14`)
- `install_poetry`: Whether to install Poetry (default: `true`)

### vars/main.yml
Contains computed variables derived from defaults:
- `pyenv_root`: Calculated as `{{ user_home_dir }}/.pyenv`
- `pyenv_executable`: Path to pyenv binary `{{ pyenv_root }}/bin/pyenv`

### tasks/main.yml
The main execution flow with 15 tasks organized in sections:

**Section 1: System Dependencies** (Lines 4-24)
- Installs all required build dependencies for compiling Python

**Section 2: Pyenv Installation** (Lines 26-48)
- Clones pyenv repository
- Configures .zshrc with PATH and initialization commands

**Section 3: Python Installation** (Lines 50-84)
- Checks if requested Python version exists
- Installs Python via pyenv if needed
- Sets global Python version

**Section 4: Poetry Installation** (Lines 86-138)
- Checks and installs pipx
- Checks and installs Poetry via pipx
- Upgrades Poetry if already installed

### meta/main.yml
Galaxy metadata including author, description, license, and tags.

## Critical Variables

### Required Variables (Must be set by user)
These are referenced but not defined in defaults - users MUST provide them:
- `primary_user_account`: The system username to run commands as

### Default Variables (Can be overridden)
- `user_home_dir`: `/root`
- `pyenv_version`: `v2.4.0`
- `python_version`: `3.10.14`
- `install_poetry`: `true`

### Computed Variables (Do not override)
- `pyenv_root`: Derived from `user_home_dir`
- `pyenv_executable`: Derived from `pyenv_root`

## Task Execution Flow

1. **Dependency Installation**: Installs build-essential and Python build dependencies via apt
2. **Pyenv Setup**: Clones pyenv repo to `~/.pyenv` at specified version
3. **Shell Configuration**: Adds pyenv initialization to `.zshrc` (Note: assumes zsh shell)
4. **Python Version Check**: Runs `pyenv versions --bare` to check installed versions
5. **Python Installation**: Conditionally installs Python if not present
6. **Global Python Setting**: Sets the global Python version via pyenv
7. **Pipx Installation**: Installs pipx using pip from pyenv's Python
8. **Poetry Management**: Installs or upgrades Poetry using pipx

## Development Workflows

### Making Changes to Tasks

When modifying `tasks/main.yml`:
1. Read the entire file first to understand the task sequence
2. Respect the existing task organization (dependencies → pyenv → python → poetry)
3. Maintain idempotency - tasks should be safe to run multiple times
4. Use `noqa` comments to suppress ansible-lint warnings only when justified
5. Include `changed_when` for shell/command tasks to properly report changes
6. Use `become: true` and `become_user` for tasks requiring privilege escalation

### Adding New Variables

1. **For user-configurable values**: Add to `defaults/main.yml`
2. **For computed/derived values**: Add to `vars/main.yml`
3. **Update README.md**: Document new variables in the "Role Variables" section

### Version Updates

To update component versions:
- Edit `defaults/main.yml` for `pyenv_version` or `python_version`
- Test with the test playbook before committing

## Key Conventions

### Shell Configuration
- **Assumes zsh shell**: All PATH modifications target `.zshrc`
- If supporting bash, would need to modify `.bashrc` or `.bash_profile`

### User Context
- Tasks use `become_user: "{{ primary_user_account }}"` to run as the target user
- Installation happens in the user's home directory, not system-wide

### PATH Management
Multiple tasks set environment PATH explicitly:
```yaml
environment:
  PATH: "{{ user_home_dir }}/.pyenv/bin:/root/.pyenv/shims:{{ ansible_env.PATH }}:{{ user_home_dir }}/.local/bin"
```
This ensures pyenv, Python shims, and pipx binaries are available.

### Idempotency Patterns
- **Check before install**: Version checks prevent reinstallation
- **Conditional execution**: `when` clauses skip unnecessary tasks
- **Upgrade vs Install**: Separate tasks for upgrading existing installations

### ansible-lint Compliance
Uses `noqa` comments for justified rule exceptions:
- `# noqa command-instead-of-shell`: For pyenv commands requiring shell features
- `# noqa no-changed-when`: For upgrade tasks where change detection is complex

## Testing

### Test Playbook
Location: `tests/test.yml`

Basic test structure:
```yaml
- hosts: localhost
  remote_user: root
  roles:
    - pyenv-poetry
```

### Running Tests Locally
```bash
ansible-playbook tests/test.yml -i tests/inventory
```

### Required Test Variables
When testing, provide all required variables:
```yaml
- hosts: localhost
  roles:
    - role: pyenv-poetry
      vars:
        primary_user_account: your_username
        user_home_dir: /home/your_username
```

## Common Operations for AI Assistants

### Adding a New Dependency Package
1. Edit `tasks/main.yml` lines 4-24
2. Add package name to the `name:` list under "Install required dependencies"
3. Keep list alphabetically sorted

### Changing Python or Pyenv Versions
1. Edit `defaults/main.yml`
2. Update `pyenv_version` or `python_version`
3. Update README.md example if changing defaults

### Adding Bash Support
1. Duplicate `.zshrc` tasks in `tasks/main.yml` (lines 32-48)
2. Create parallel tasks targeting `.bashrc`
3. Consider using a variable for shell config file path

### Debugging Task Failures
Key areas to check:
1. **PATH issues**: Ensure pyenv binaries are in PATH (check environment blocks)
2. **Permission issues**: Verify `become_user` is set correctly
3. **Version conflicts**: Check if requested versions are available upstream
4. **Shell initialization**: Confirm .zshrc modifications are correct

### Adding New Poetry Configuration
1. Add tasks after line 138 in `tasks/main.yml`
2. Use the same environment PATH setup as existing Poetry tasks
3. Run as `become_user: "{{ primary_user_account }}"`

## Important Notes

### Shell Assumption
This role currently ONLY supports zsh. Users with bash/fish/other shells will need modifications.

### Root vs User Installation
- Default configuration installs to `/root`
- For non-root users, MUST override `user_home_dir` and set `primary_user_account`

### Network Requirements
- Requires internet access to:
  - Clone pyenv from GitHub
  - Download Python source from python.org
  - Install pipx and Poetry from PyPI

### Hardcoded Paths
Be aware of hardcoded `/root` in PATH environment variables (line 99):
```yaml
PATH: "{{ user_home_dir }}/.pyenv/bin:/root/.pyenv/shims:{{ ansible_env.PATH }}"
```
This should likely use `{{ user_home_dir }}` instead.

## Git Workflow

### Branch Naming
- Feature branches should start with `claude/` prefix
- Branch names include session identifiers

### Commit Guidelines
- Use clear, descriptive commit messages
- Reference what was changed and why
- Follow conventional commit format when possible

### Before Pushing
1. Ensure all tasks are idempotent
2. Test with `ansible-playbook tests/test.yml`
3. Run `ansible-lint` if available
4. Verify README.md is up-to-date with any variable changes

## Known Issues and TODOs

1. **Hardcoded shell**: Only supports zsh, should support bash
2. **Hardcoded path in environment**: Line 99 uses `/root` instead of variable
3. **No handlers**: Handlers file is empty, could add handlers for shell reload
4. **Single shell config**: Could use `.profile` for shell-agnostic configuration
5. **No version pinning for pipx**: Could add a variable for pipx version
6. **No Poetry version control**: Always installs latest, could pin version

## Quick Reference Commands

### Test the role locally
```bash
ansible-playbook tests/test.yml -i tests/inventory -e "primary_user_account=$(whoami)" -e "user_home_dir=$HOME"
```

### Install role from Galaxy
```bash
ansible-galaxy role install llbbl.pyenv-poetry,0.8 -p roles/ --force
```

### Run ansible-lint
```bash
ansible-lint tasks/main.yml
```

### Check role structure
```bash
ansible-galaxy role init --offline pyenv-poetry
```

## For AI Assistants: Best Practices

1. **Always read the full task file** before making changes to understand dependencies
2. **Maintain task order** - later tasks depend on earlier ones
3. **Test variable changes** by checking all references across files
4. **Document breaking changes** in commit messages
5. **Preserve idempotency** - tasks must be safe to run multiple times
6. **Consider user context** - installations are user-specific, not system-wide
7. **Update README.md** when changing variables or behavior
8. **Use consistent formatting** - follow existing YAML style (2-space indents)
9. **Add `changed_when`** to shell/command tasks for proper change reporting
10. **Set appropriate `become_user`** for each task based on what it does
