# modulator
Modulator is an package manager for bash


# TODO: Build and Implement the "Modulator" Project

## 1. Install Module
### 1.0 Base utils setup 
- [ ] Get something like logger
    - [x] Log info 
    - [x] Log warnings 
    - [x] Log errors with additional info ?
### 1.1. Clone Repositories
- [ ] Add functionality to clone repositories:
  - [x] Just clone a repository
  - [ ] If it's already there then try to update it
  - [ ] Clone by **branch**.
  - [ ] Clone by **tag**.
  - [ ] Clone by **release** (fetch latest or specific).
  - [ ] Nest this cloning logic into version based cloning ?
  - [ ] Validate the source repository URL (e.g., check if it's reachable).

### 1.2. Read Configuration File
- [ ] Decide on the configuration file format (e.g., `TOML`, `YAML`, or `JSON`):
  - [ ] Write a sample `imports.toml` file:
    ```toml
    logger = { url = "https://github.com/andranikas/bash-logger", version = "1.0.0" }
    utils = { url = "https://github.com/example/utils", branch = "main" }
    ```
  - [ ] Implement logic to parse the configuration file:
    - [ ] Handle missing fields (e.g., default to the `main` branch).
    - [ ] Validate configuration file syntax.

### 1.3. Put Cloned Files in the Right Place
- [ ] Define a structured directory for storing modules:
  - Example directory layout:
    ```
    .modules/
    ├── logger/
    │   ├── 1.0.0/
    │   │   └── logger.sh
    │   └── current -> 1.0.0
    ├── utils/
    │   ├── main/
    │   │   └── utils.sh
    │   └── current -> main
    ```
- [ ] Create a symbolic link (`current`) pointing to the active version.

---

## 2. Manage Versions
### 2.1. Version Control
- [ ] Implement logic to:
  - [ ] Download and store specific versions based on configuration.
  - [ ] Create or update `current` symlinks to point to active versions.

### 2.2. Handle Conflicts
- [ ] Handle cases where:
  - [ ] Multiple versions of the same module are requested.
  - [ ] A module version conflicts with another.

---

## 3. Load Modules
### 3.1. Source Modules
- [ ] Implement logic to source modules dynamically:
  - [ ] Load modules from the `current` symlink.
  - [ ] Ensure dependencies are resolved before sourcing.

### 3.2. Validate Imports
- [ ] Ensure all required modules are present before running the script.
- [ ] Display meaningful error messages for missing or invalid modules.

---

## 4. Command-Line Interface
### 4.1. CLI Features
- [ ] Implement basic commands:
  - [ ] `install` - Install modules based on a configuration file.
  - [ ] `update` - Update modules to a specific version.
  - [ ] `list` - List all installed modules and their active versions.
  - [ ] `remove` - Remove a module or specific version.

### 4.2. CLI Enhancements
- [ ] Add flags for commands:
  - `--refresh`: Force re-download of all modules.
  - `--version`: Display the current version of the tool.
  - `--help`: Display help documentation.

---

## 5. Error Handling
- [ ] Gracefully handle:
  - [ ] Invalid URLs or unreachable repositories.
  - [ ] Configuration file parsing errors.
  - [ ] Failed downloads or incomplete clones.

---

## 6. Testing
### 6.1. Write Test Cases
- [ ] Test module installation:
  - [ ] Install by branch, tag, and release.
- [ ] Test version management:
  - [ ] Activate specific versions.
  - [ ] Update to a new version.
- [ ] Test loading modules:
  - [ ] Verify sourced modules work as expected.
- [ ] Test CLI commands:
  - [ ] Test all commands (`install`, `update`, `list`, `remove`).

### 6.2. Automated Testing
- [ ] Set up automated testing using:
  - [ ] Bash unit testing frameworks (e.g., [Bats](https://github.com/bats-core/bats-core)).
  - [ ] Mock repositories for testing.

---

## 7. Documentation
### 7.1. Write Documentation
- [ ] Document the configuration file format with examples.
- [ ] Document directory structure and how modules are managed.
- [ ] Provide usage instructions for CLI commands.

### 7.2. Create a README File
- [ ] Include:
  - [ ] Project description and purpose.
  - [ ] Installation instructions.
  - [ ] Example usage.
  - [ ] Contribution guidelines.

---
