# Ansible Role pyenv-poetry - Improvement Suggestions

This document tracks potential improvements for the ansible-role-pyenv-poetry project.

## Status Legend
- 🔴 **Critical** - Bugs or issues that break functionality
- 🟡 **High Priority** - Important improvements for usability/maintainability
- 🟢 **Medium Priority** - Enhancements that add value
- 🔵 **Low Priority** - Nice to have features

---

## Critical Issues (Fix First)

### 🔴 1. Hardcoded `/root` in PATH variables
**Status:** ✅ Completed (2025-11-14)
**Location:** `tasks/main.yml:99, 109, 120, 128, 137`
**Impact:** Breaks functionality for non-root users

**Problem:**
The environment PATH uses `/root/.pyenv/shims` instead of `{{ user_home_dir }}`:
```yaml
PATH: "{{ user_home_dir }}/.pyenv/bin:/root/.pyenv/shims:{{ ansible_env.PATH }}"
```

**Solution:**
```yaml
PATH: "{{ user_home_dir }}/.pyenv/bin:{{ user_home_dir }}/.pyenv/shims:{{ ansible_env.PATH }}"
```

**Files to modify:** `tasks/main.yml` (5 occurrences)

---

### 🔴 2. No shell configuration file existence check
**Status:** ✅ Completed (2025-11-14)
**Location:** `tasks/main.yml:32-60`
**Impact:** May fail silently or create unexpected files

**Problem:**
Tasks modify `.zshrc` without checking if it exists. While lineinfile will create it, it's better to be explicit.

**Solutions:**
- Option A: Add a task to ensure `.zshrc` exists before modification
- Option B: Add `create: yes` parameter to lineinfile tasks

**Example:**
```yaml
- name: Ensure shell config file exists
  ansible.builtin.file:
    path: "{{ user_home_dir }}/.zshrc"
    state: touch
    mode: '0644'
  become: true
  become_user: "{{ primary_user_account }}"
```

---

## High Priority Improvements

### 🟡 3. Shell-agnostic support
**Status:** ✅ Completed (2025-11-14)
**Location:** `defaults/main.yml:12-15`, `tasks/main.yml:20-101`
**Impact:** Currently only supports zsh users

**Problem:**
Role assumes zsh shell and only modifies `.zshrc`. Many users use bash or other shells.

**Solutions:**
- Add a `shell_config_file` variable (default: `.zshrc`)
- Support detection of user's shell via `getent passwd`
- Support multiple shells (.bashrc, .zshrc, .profile)

**Example:**
```yaml
# In defaults/main.yml
shell_type: auto  # auto, bash, zsh, fish
shell_config_file: "{{ '.zshrc' if shell_type == 'zsh' else '.bashrc' }}"
```

---

### 🟡 4. Missing required variable documentation
**Status:** ✅ Completed (2025-11-14)
**Location:** `defaults/main.yml`, `tasks/main.yml:4-18`
**Impact:** Users may not know required variables, causing failures

**Problem:**
`primary_user_account` is required but not documented in defaults.

**Solutions:**
- Add it to `defaults/main.yml` with a comment that it's required
- Add validation task to fail early with clear message if not set

**Example:**
```yaml
# In defaults/main.yml
# primary_user_account: username  # REQUIRED: Set in playbook

# In tasks/main.yml (add as first task)
- name: Validate required variables
  ansible.builtin.assert:
    that:
      - primary_user_account is defined
      - user_home_dir is defined
    fail_msg: "Required variable not set. Please define primary_user_account and user_home_dir"
```

---

### 🟡 5. Duplicate environment blocks
**Status:** ✅ Completed (2025-11-14)
**Location:** `vars/main.yml`, throughout `tasks/main.yml`
**Impact:** Harder to maintain, violates DRY principle

**Problem:**
The PATH environment is duplicated 5+ times across different tasks.

**Solution:**
Define once in `vars/main.yml` and reference it in tasks.

**Example:**
```yaml
# In vars/main.yml
pyenv_path_environment:
  PATH: "{{ user_home_dir }}/.pyenv/bin:{{ user_home_dir }}/.pyenv/shims:{{ ansible_env.PATH }}:{{ user_home_dir }}/.local/bin"

# In tasks/main.yml
- name: Install Poetry with pipx
  ansible.builtin.shell: |
    pipx install poetry
  environment: "{{ pyenv_path_environment }}"
```

---

### 🟡 6. No version pinning for Poetry/pipx
**Status:** ✅ Completed (2025-11-14)
**Location:** `defaults/main.yml:18-24`, `tasks/main.yml:128-169`
**Impact:** Unpredictable versions, harder to reproduce environments

**Problem:**
Poetry and pipx are installed without version control, always getting latest.

**Solution:**
Add version variables with option for "latest".

**Example:**
```yaml
# In defaults/main.yml
pipx_version: "1.4.3"  # or "latest"
poetry_version: "1.8.2"  # or "latest"

# In tasks/main.yml
- name: Install pipx with pip
  ansible.builtin.pip:
    name: "pipx{% if pipx_version != 'latest' %}=={{ pipx_version }}{% endif %}"
```

---

## Medium Priority Enhancements

### 🟢 7. Improved idempotency for Poetry upgrade
**Status:** 📋 Proposed
**Location:** `tasks/main.yml:131-138`
**Impact:** Currently always reports changes even when no upgrade occurs

**Problem:**
Upgrade task always runs when Poetry is installed, even if already at desired version.

**Solution:**
- Parse current version from `poetry --version`
- Only upgrade if version differs from desired `poetry_version`
- Add proper `changed_when` based on actual upgrade

**Example:**
```yaml
- name: Get current Poetry version
  ansible.builtin.shell: poetry --version | awk '{print $3}'
  register: current_poetry_version
  changed_when: false

- name: Upgrade Poetry with pipx
  ansible.builtin.shell: pipx upgrade poetry
  when: install_poetry and current_poetry_version.stdout != poetry_version
  register: poetry_upgrade
  changed_when: "'upgraded' in poetry_upgrade.stdout"
```

---

### 🟢 8. Add task tags for selective execution
**Status:** 📋 Proposed
**Location:** Throughout `tasks/main.yml`
**Impact:** Better user experience for targeted execution

**Problem:**
No way to run only specific parts of the role (e.g., only Poetry installation).

**Solution:**
Add meaningful tags to tasks.

**Example:**
```yaml
- name: Install required dependencies
  tags: [dependencies, packages, setup]
  ansible.builtin.apt:
    # ...

- name: Clone pyenv repository
  tags: [pyenv, setup]
  # ...

- name: Install Poetry with pipx
  tags: [poetry, packages]
  # ...
```

**Usage:**
```bash
ansible-playbook playbook.yml --tags "poetry"
ansible-playbook playbook.yml --skip-tags "dependencies"
```

---

### 🟢 9. Verify installations succeeded
**Status:** 📋 Proposed
**Location:** End of `tasks/main.yml`
**Impact:** Better error detection and user confidence

**Problem:**
No verification that installations completed successfully.

**Solution:**
Add verification tasks at the end.

**Example:**
```yaml
- name: Verify pyenv installation
  ansible.builtin.command: "{{ pyenv_executable }} --version"
  register: pyenv_verify
  changed_when: false
  failed_when: pyenv_version not in pyenv_verify.stdout

- name: Verify Python installation
  ansible.builtin.shell: "{{ pyenv_executable }} version-name"
  register: python_verify
  changed_when: false
  failed_when: python_verify.stdout != python_version

- name: Verify Poetry installation
  ansible.builtin.command: poetry --version
  register: poetry_verify
  changed_when: false
  when: install_poetry
```

---

### 🟢 10. Add support for pyenv update
**Status:** 📋 Proposed
**Location:** `tasks/main.yml:26-30`
**Impact:** Better handling of existing installations

**Problem:**
Git clone task doesn't handle updates to existing pyenv installations.

**Solution:**
Add `update: yes` to allow updating existing clones.

**Example:**
```yaml
- name: Clone or update pyenv repository
  ansible.builtin.git:
    repo: https://github.com/pyenv/pyenv.git
    dest: "{{ user_home_dir }}/.pyenv"
    version: "{{ pyenv_version }}"
    update: yes
```

---

## Low Priority / Nice to Have

### 🔵 11. Platform-specific dependency management
**Status:** 📋 Proposed
**Location:** `tasks/main.yml:4-24`
**Impact:** Expands platform support beyond Debian/Ubuntu

**Problem:**
Only supports apt-based systems (Debian/Ubuntu).

**Solution:**
Add conditional tasks for different OS families.

**Example:**
```yaml
- name: Install dependencies (Debian/Ubuntu)
  ansible.builtin.apt:
    name: [build-essential, libssl-dev, ...]
  when: ansible_os_family == "Debian"

- name: Install dependencies (RedHat/CentOS)
  ansible.builtin.dnf:
    name: [gcc, gcc-c++, openssl-devel, ...]
  when: ansible_os_family == "RedHat"
```

---

### 🔵 12. Add handlers for shell reload notification
**Status:** 📋 Proposed
**Location:** `handlers/main.yml` (currently empty)
**Impact:** Better user guidance

**Problem:**
Users may not know they need to reload their shell after installation.

**Solution:**
Add handler to notify user to reload shell.

**Example:**
```yaml
# In handlers/main.yml
- name: Reload shell configuration
  ansible.builtin.debug:
    msg: "Please reload your shell: source {{ user_home_dir }}/.zshrc"

# In tasks/main.yml (notify on shell config changes)
- name: Add pyenv to PATH
  ansible.builtin.lineinfile:
    dest: "{{ user_home_dir }}/.zshrc"
    line: 'export PATH="$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH"'
  notify: Reload shell configuration
```

---

### 🔵 13. Add molecule tests
**Status:** 📋 Proposed
**Location:** New `molecule/` directory
**Impact:** Automated testing and CI/CD integration

**Problem:**
No automated testing framework.

**Solution:**
Set up molecule for automated testing across different scenarios.

**Test scenarios:**
- Operating systems (Ubuntu 20.04, 22.04, Debian 11, 12)
- User contexts (root vs non-root)
- Shell types (bash vs zsh)
- Different Python versions

**Example structure:**
```
molecule/
├── default/
│   ├── converge.yml
│   ├── molecule.yml
│   └── verify.yml
└── non-root-user/
    ├── converge.yml
    ├── molecule.yml
    └── verify.yml
```

---

### 🔵 14. Conditional pyenv installation
**Status:** 📋 Proposed
**Location:** `defaults/main.yml`, `tasks/main.yml`
**Impact:** More flexibility for advanced users

**Problem:**
Role always installs pyenv, even if user wants to manage it separately.

**Solution:**
Add variable to make pyenv installation optional.

**Example:**
```yaml
# In defaults/main.yml
install_pyenv: true

# In tasks/main.yml
- name: Clone pyenv repository
  ansible.builtin.git:
    repo: https://github.com/pyenv/pyenv.git
    dest: "{{ user_home_dir }}/.pyenv"
    version: "{{ pyenv_version }}"
  when: install_pyenv
```

---

### 🔵 15. Better error messages with pre-flight validation
**Status:** 📋 Proposed
**Location:** Beginning of `tasks/main.yml`
**Impact:** Better user experience and debugging

**Problem:**
Cryptic errors when required variables are missing.

**Solution:**
Add comprehensive pre-flight validation.

**Example:**
```yaml
- name: Validate required variables
  ansible.builtin.assert:
    that:
      - primary_user_account is defined
      - primary_user_account | length > 0
      - user_home_dir is defined
      - user_home_dir is directory or user_home_dir is string
    fail_msg: |
      Required variables not properly set:
      - primary_user_account: {{ primary_user_account | default('NOT DEFINED') }}
      - user_home_dir: {{ user_home_dir | default('NOT DEFINED') }}
    success_msg: "All required variables are properly configured"

- name: Validate pyenv version format
  ansible.builtin.assert:
    that:
      - pyenv_version is match('^v[0-9]+\.[0-9]+\.[0-9]+$')
    fail_msg: "pyenv_version must be in format 'vX.Y.Z' (e.g., 'v2.4.0')"
```

---

## Implementation Priority

Recommended implementation order:

1. **Critical Issues** (#1, #2) - Fix bugs first
2. **High Priority Core** (#4, #5) - Better architecture
3. **High Priority Features** (#3, #6) - Major functionality improvements
4. **Medium Priority** (#7, #8, #9, #10) - Quality of life improvements
5. **Low Priority** (#11-15) - When time permits

---

## Notes

- Each improvement should be implemented in a separate commit for easy review
- All changes should maintain backward compatibility where possible
- Update README.md when adding new variables or changing behavior
- Update CLAUDE.md when making architectural changes
- Add tests when implementing new features (if molecule framework is in place)

---

**Last Updated:** 2025-11-14
**Document Version:** 1.0
