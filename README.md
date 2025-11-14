# Role Name: pyenv-poetry

This role installs and configures pyenv and Poetry on Ubuntu and Debian systems.

## Installation

To install the `pyenv-poetry` role, run the following command:

```
ansible-galaxy role install llbbl.pyenv-poetry,0.8 -p roles/ --force
```

The command `ansible-galaxy role install llbbl.pyenv-poetry,0.1 -p roles/ --force` is used to install an Ansible role from Galaxy, which is a public repository for sharing and distributing Ansible roles.

Let's break down the command:

- `ansible-galaxy`: This is the command-line tool provided by Ansible for managing roles and collections.

- `role`: Specifies that you want to install a role (as opposed to a collection).

- `install`: Indicates that you want to install the specified role.

- `llbbl.pyenv-poetry`: Represents the namespace and name of the role you want to install. In this case, the role is named `pyenv-poetry` and belongs to the `llbbl` namespace on Galaxy.

- `,0.1`: Specifies the version of the role you want to install. In this example, version `0.1` is being installed.

- `-p roles/`: Specifies the path where the role should be installed. The `-p` option stands for "path." In this case, the role will be installed in a directory named `roles/` relative to the current directory.

- `--force`: This flag indicates that if the role already exists locally, it should be forcefully overwritten with the version being installed. Without this flag, if the role already exists, Ansible will prompt for confirmation before overwriting it.

So, when you run this command, Ansible Galaxy will download and install version `0.1` of the `llbbl.pyenv-poetry` role from Galaxy and place it in the `roles/` directory. If a previous version of the role already exists in that directory, it will be overwritten due to the `--force` flag.

After running this command, you can use the installed role in your Ansible playbooks by referencing it with the name `llbbl.pyenv-poetry`.

For example:

```yaml
- hosts: servers
  roles:
    - llbbl.pyenv-poetry
```

This will apply the tasks and configurations defined in the `llbbl.pyenv-poetry` role to the specified hosts.

## Requirements

- Ubuntu or Debian operating system
- Ansible 2.9 or later

## Role Variables

The following variables are defined in `defaults/main.yml`:

- `pyenv_version` (default: "v2.4.0"): The version of pyenv to install.
- `python_version` (default: "3.13.9"): The version of Python to install using pyenv.
- `pipx_version` (default: "latest"): The version of pipx to install. Set to a specific version like "1.4.3" to pin.
- `poetry_version` (default: "latest"): The version of Poetry to install. Set to a specific version like "1.8.2" to pin.
- `install_poetry` (default: true): Whether to install Poetry.
- `user_home_dir` (default: "/root"): The home directory of the user for whom pyenv and Poetry will be installed.
- `shell_type` (default: "auto"): The shell to configure. Options are "auto" (detect automatically), "bash", or "zsh".

The following variables are required and should be set in your playbook or inventory:

- `primary_user_account`: The username of the primary user account on the target system.

You can override these variables in your playbook or inventory to customize the versions of pyenv and Python.

## Dependencies

None.

## Example Playbook

Here's an example playbook that uses the `pyenv-poetry` role:

```yaml
- hosts: servers
  roles:
    - role: llbbl.pyenv-poetry
      vars:
        primary_user_account: root
        user_home_dir: /root
        shell_type: auto  # auto-detect shell, or specify "bash" or "zsh"
        pyenv_version: "v2.4.0"
        python_version: "3.13.9"
        pipx_version: "latest"  # or pin to "1.4.3"
        poetry_version: "latest"  # or pin to "1.8.2"
        install_poetry: true
```

## Using Task Tags

This role supports task tags for selective execution. You can use tags to run only specific parts of the role:

### Available Tags

- `validation` - Variable validation tasks
- `setup` - Initial setup tasks (shell detection, shell config)
- `shell` - Shell configuration tasks
- `dependencies` - System package dependencies
- `packages` - Package installation tasks (pipx, Poetry)
- `pyenv` - pyenv installation and configuration
- `python` - Python installation tasks
- `poetry` - Poetry installation tasks
- `verification` - Installation verification tasks

### Examples

Run only Poetry installation:
```bash
ansible-playbook playbook.yml --tags "poetry"
```

Run only pyenv and Python installation (skip Poetry):
```bash
ansible-playbook playbook.yml --tags "pyenv,python"
```

Skip dependency installation:
```bash
ansible-playbook playbook.yml --skip-tags "dependencies"
```

Run only verification tasks:
```bash
ansible-playbook playbook.yml --tags "verification"
```

