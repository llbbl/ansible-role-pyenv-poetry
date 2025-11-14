# Testing Guide for ansible-role-pyenv-poetry

This document describes how to test the `ansible-role-pyenv-poetry` role using Molecule.

## Overview

This role uses [Molecule](https://molecule.readthedocs.io/) for automated testing. Molecule allows us to test the role against multiple operating systems and scenarios to ensure it works correctly in different environments.

## Prerequisites

### System Requirements

- Docker (for running test containers)
- Python 3.12 or later
- Poetry (Python dependency manager)
- Git

### Install Docker

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y docker.io
sudo usermod -aG docker $USER
# Log out and log back in for group changes to take effect
```

**macOS:**
```bash
brew install docker
```

### Install Poetry

**Ubuntu/Debian:**
```bash
curl -sSL https://install.python-poetry.org | python3 -
```

**macOS:**
```bash
brew install poetry
```

### Install Python Dependencies

Install the required Python packages for testing using Poetry:

```bash
poetry install
```

This will install all dev dependencies including:
- `molecule` - The testing framework
- `molecule-docker` - Docker driver for Molecule
- `ansible-core` - Ansible itself
- `ansible-lint` - Linting tool for Ansible
- `yamllint` - YAML linting tool
- `pytest` and `pytest-testinfra` - Testing utilities

The `poetry.lock` file ensures all developers and CI use the exact same dependency versions.

### Install Ansible Collections

Install the required Ansible collections:

```bash
poetry run ansible-galaxy collection install -r requirements.yml
```

This installs the `community.docker` collection required by molecule-docker.

## Test Scenarios

This role includes two test scenarios:

### 1. Default Scenario

Tests the role with **root user**:
- Ubuntu 22.04

**Location:** `molecule/default/`

**What it tests:**
- Installation of pyenv, Python, pipx, and Poetry as root
- Shell configuration in `/root/.bashrc`
- Proper PATH configuration
- All verification checks

### 2. Non-Root User Scenario

Tests the role with a **non-root user** (`testuser`):
- Ubuntu 22.04

**Location:** `molecule/non-root-user/`

**What it tests:**
- Installation for a regular user account
- Proper file ownership and permissions
- Shell configuration in user's home directory
- All verification checks for the non-root user

## Running Tests

### Run All Tests (All Scenarios)

To run all test scenarios:

```bash
poetry run molecule test --all
```

### Run Specific Scenario

To run a specific scenario:

```bash
# Test with root user on all platforms
poetry run molecule test --scenario-name default

# Test with non-root user
poetry run molecule test --scenario-name non-root-user
```

### Test Workflow Steps

The full test sequence includes:

1. **Dependency** - Install role dependencies
2. **Cleanup** - Remove any existing test containers
3. **Destroy** - Destroy test infrastructure
4. **Syntax** - Check playbook syntax
5. **Create** - Create test infrastructure (Docker containers)
6. **Prepare** - Prepare the test environment (e.g., create test user)
7. **Converge** - Run the role against the test environment
8. **Idempotence** - Run the role again and verify no changes are made
9. **Verify** - Run verification tests
10. **Cleanup** - Clean up test containers
11. **Destroy** - Final cleanup

### Run Individual Test Steps

You can run individual steps of the test workflow:

```bash
# Create test containers
poetry run molecule create

# Run the role (converge)
poetry run molecule converge

# Run verification tests only
poetry run molecule verify

# Test idempotence (should make no changes on second run)
poetry run molecule idempotence

# Clean up
poetry run molecule destroy
```

### Interactive Testing

For interactive testing and debugging:

```bash
# Create and converge (but don't destroy)
poetry run molecule converge --scenario-name default

# Log into the test container
poetry run molecule login --scenario-name default --host ubuntu-22.04

# Inside the container, you can manually test commands
# Exit when done
exit

# Clean up when finished
poetry run molecule destroy
```

## Verification Tests

The verify playbooks (`molecule/*/verify.yml`) check that:

### Default Scenario Checks

- ✅ pyenv directory exists and is executable
- ✅ pyenv version is correct
- ✅ Python 3.13.9 is installed
- ✅ Global Python version is set correctly
- ✅ Shell configuration files contain proper PATH and init commands
- ✅ pipx is installed and functional
- ✅ Poetry is installed and functional
- ✅ Python can be executed successfully

### Non-Root User Scenario Checks

All of the above, plus:
- ✅ Files are owned by the correct user
- ✅ Installations are in the user's home directory
- ✅ User can execute all tools without root privileges

## Linting

### Run YAML Lint

Check YAML syntax and style:

```bash
yamllint .
```

### Run Ansible Lint

Check Ansible best practices:

```bash
ansible-lint
```

### Configuration Files

- `.yamllint` - yamllint configuration
- `.ansible-lint` - ansible-lint configuration (if present)

## Continuous Integration

This role uses GitHub Actions for continuous integration. The CI workflow:

1. Runs linting checks (yamllint, ansible-lint)
2. Runs Molecule tests for each scenario
3. Runs full platform matrix tests

See `.github/workflows/ci.yml` for the complete CI configuration.

### CI Status

Check the Actions tab in the GitHub repository to see test results.

## Troubleshooting

### Docker Permission Denied

If you get permission errors with Docker:

```bash
sudo usermod -aG docker $USER
# Log out and log back in
```

### Container Creation Fails

If containers fail to create:

```bash
# Clean up any existing containers
poetry run molecule destroy --all

# Try again
poetry run molecule test
```

### Verify Failures

If verification tests fail:

```bash
# Run converge to set up the environment
poetry run molecule converge

# Log into the container to investigate
poetry run molecule login

# Inside the container, manually check the state
ls -la /root/.pyenv
pyenv --version
python --version
poetry --version

# Exit and destroy when done
exit
poetry run molecule destroy
```

### Python Build Failures

Python installation may take several minutes as it compiles from source. If it times out or fails:

1. Check the container has internet access
2. Ensure all build dependencies are installed
3. Try with a different Python version

### Idempotence Failures

If the idempotence test fails (role makes changes on second run):

```bash
# Run converge twice manually to see what changes
poetry run molecule converge
poetry run molecule converge

# Check the diff to see what's changing
```

## Writing New Tests

To add new test scenarios:

1. Create a new directory in `molecule/`
2. Add `molecule.yml`, `converge.yml`, and `verify.yml`
3. Optionally add `prepare.yml` for setup tasks
4. Run tests: `molecule test --scenario-name your-scenario`

Example:

```bash
mkdir -p molecule/zsh-shell
# Create your test files
poetry run molecule test --scenario-name zsh-shell
```

## Additional Resources

- [Molecule Documentation](https://molecule.readthedocs.io/)
- [Ansible Testing Strategies](https://docs.ansible.com/ansible/latest/reference_appendices/test_strategies.html)
- [Docker Documentation](https://docs.docker.com/)
- [Ansible Lint Documentation](https://ansible-lint.readthedocs.io/)

## Quick Reference

```bash
# Install dependencies
poetry install
poetry run ansible-galaxy collection install -r requirements.yml

# Run all tests
poetry run molecule test --all

# Run specific scenario
poetry run molecule test --scenario-name default

# Interactive testing
poetry run molecule converge
poetry run molecule login
poetry run molecule destroy

# Linting
poetry run yamllint .
poetry run ansible-lint

# Clean up everything
poetry run molecule destroy --all
```
