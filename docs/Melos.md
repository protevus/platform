# Protevus Platform Melos Configuration Documentation

## Overview

The Protevus Platform uses Melos to manage our monorepo structure and automate various development tasks. This comprehensive guide outlines the features provided by our Melos configuration and provides detailed instructions on how to use them effectively.

## Repository Structure

- Project name: `protevus_platform`
- Repository: `https://github.com/protevus/platform`
- Package locations:
  - `packages/`: Core packages of the platform
  - `examples/`: Example applications and usage demonstrations

## Version Control Integration

- Version bump commit message format: "chore: Bump version to %v"
- Changelog: 
  - Version commits are linked in the changelog
  - A workspace-level changelog is generated
- Main versioning branch: `main`

Example of how versioning works:
```bash
# To bump the version and generate changelog
melos version --yes

# To bump a specific version
melos version 1.2.3 --yes

# To bump a prerelease version
melos version prerelease --preid beta --yes
```

## IDE Integration

- IntelliJ integration is disabled to prevent conflicts with our custom setup.

## Available Scripts

### Static Analysis and Formatting

1. **Analyze**
   - Command: `melos run analyze`
   - Description: Runs `dart analyze` on all packages to identify potential issues.
   - Usage: `melos run analyze`
   - Example output:
     ```
     Analyzing package_1...
     No issues found!
     Analyzing package_2...
     info • Unused import • lib/src/unused_file.dart:3:8 • unused_import
     ```

2. **Format**
   - Command: `melos run format`
   - Description: Formats all Dart files in the repository using `dart format`.
   - Usage: `melos run format`
   - Example:
     ```bash
     # Format and show which files were changed
     melos run format -- -o write --set-exit-if-changed
     ```

### Code Generation

3. **Generate**
   - Command: `melos run generate`
   - Description: Runs `build_runner` for code generation in all packages.
   - Usage: `melos run generate`
   - Example output:
     ```
     Running build_runner for package_1...
     [INFO] Generating build script...
     [INFO] Generating build script completed, took 304ms
     [INFO] Running build...
     [INFO] 5 outputs were generated
     [INFO] Running build completed, took 2.8s
     ```

4. **Generate Custom**
   - Command: `melos run generate:custom`
   - Description: Runs code generation for specified packages.
   - Usage: `MELOS_SCOPE="package_name1,package_name2" melos run generate:custom`
   - Example:
     ```bash
     MELOS_SCOPE="auth_package,user_package" melos run generate:custom
     ```

5. **Generate Check**
   - Command: `melos run generate:check`
   - Description: Checks if code generation is needed in specified packages.
   - Usage: `MELOS_SCOPE="package_name" melos run generate:check`
   - Example output:
     ```
     Checking auth_package...
     Package auth_package needs code generation.
     Checking user_package...
     Package user_package does not use build_runner.
     ```

6. **Generate Dummy Test**
   - Command: `melos run generate:dummy:test`
   - Description: Generates a dummy test file in specified package(s).
   - Usage: `MELOS_SCOPE="package_name" melos run generate:dummy:test`
   - Example:
     ```bash
     MELOS_SCOPE="new_feature" melos run generate:dummy:test
     # This will create a file: new_feature/test/dummy_test.dart
     ```

### Publishing

7. **Publish**
   - Command: `melos run publish`
   - Description: Publishes all packages that have changed.
   - Usage: `melos run publish`
   - Example workflow:
     ```bash
     # First, check what would be published
     melos run publish:check
     # If everything looks good, publish
     melos run publish
     ```

8. **Publish Check**
   - Command: `melos run publish:check`
   - Description: Dry run to check which packages would be published.
   - Usage: `melos run publish:check`
   - Example output:
     ```
     Would publish the following packages:
     - auth_package (1.0.0 -> 1.0.1)
     - user_package (2.1.0 -> 2.2.0)
     ```

### Documentation

9. **Generate Docs**
   - Command: `melos run docs:generate`
   - Description: Generates dartdoc documentation for all packages.
   - Usage: `melos run docs:generate`

10. **Generate Custom Docs**
    - Command: `melos run docs:generate:custom`
    - Description: Generates documentation for specified packages.
    - Usage: `MELOS_SCOPE="package_name1,package_name2" melos run docs:generate:custom`
    - Example:
      ```bash
      MELOS_SCOPE="core_package,utils_package" melos run docs:generate:custom
      ```

11. **Serve Docs**
    - Command: `melos run docs:serve`
    - Description: Serves generated documentation using `dhttpd`.
    - Usage: `melos run docs:serve`
    - After running, visit `http://localhost:8080` in your browser

12. **Serve Custom Docs**
    - Command: `melos run docs:serve:custom`
    - Description: Serves documentation for specified packages.
    - Usage: `MELOS_SCOPE="package_name" DOC_PORT=8081 melos run docs:serve:custom`
    - Example:
      ```bash
      MELOS_SCOPE="api_package" DOC_PORT=8082 melos run docs:serve:custom
      # Then visit http://localhost:8082 in your browser
      ```

### Testing

13. **Test**
    - Command: `melos run test`
    - Description: Runs tests for all packages with fail-fast option.
    - Usage: `melos run test`
    - Example output:
      ```
      Running tests for auth_package...
      00:01 +10: All tests passed!
      Running tests for user_package...
      00:02 +15: All tests passed!
      ```

14. **Test Custom**
    - Command: `melos run test:custom`
    - Description: Runs tests for specified packages.
    - Usage: `MELOS_SCOPE="package_name1,package_name2" melos run test:custom`
    - Example:
      ```bash
      MELOS_SCOPE="auth_package,user_package" melos run test:custom -- --coverage
      ```

### Dependency Management

15. **Check Dependencies**
    - Command: `melos run deps:check`
    - Description: Checks for outdated dependencies in all packages.
    - Usage: `melos run deps:check`
    - Example output:
      ```
      Checking dependencies for auth_package...
      2 dependencies are out of date
      Checking dependencies for user_package...
      All dependencies up to date
      ```

16. **Upgrade Dependencies**
    - Command: `melos run deps:upgrade`
    - Description: Upgrades all dependencies to their latest versions.
    - Usage: `melos run deps:upgrade`

17. **Upgrade Custom Dependencies**
    - Command: `melos run deps:upgrade:custom`
    - Description: Upgrades dependencies for specified packages.
    - Usage: `MELOS_SCOPE="package_name1,package_name2" melos run deps:upgrade:custom`
    - Example:
      ```bash
      MELOS_SCOPE="database_package,api_package" melos run deps:upgrade:custom
      ```

### CI/CD

18. **CI Pipeline**
    - Command: `melos run ci`
    - Description: Runs the full CI pipeline (analyze and test).
    - Usage: `melos run ci`
    - This is typically used in CI/CD environments, e.g., in a GitHub Actions workflow:
      ```yaml
      jobs:
        ci:
          runs-on: ubuntu-latest
          steps:
            - uses: actions/checkout@v2
            - uses: dart-lang/setup-dart@v1
            - run: dart pub global activate melos
            - run: melos bootstrap
            - run: melos run ci
      ```

### Debugging and Utility Scripts

19. **Debug Package Name**
    - Command: `melos run debug_pkg_name`
    - Description: Outputs the name of each package in the workspace.
    - Usage: `melos run debug_pkg_name`
    - Example output:
      ```
      Package name is auth_package
      Package name is user_package
      Package name is core_package
      ```

20. **Debug Package Path**
    - Command: `melos run debug_pkg_path`
    - Description: Outputs the path of each package in the workspace.
    - Usage: `melos run debug_pkg_path`
    - Example output:
      ```
      Package path is /home/user/protevus_platform/packages/auth_package
      Package path is /home/user/protevus_platform/packages/user_package
      ```

21. **Debug Reflectable**
    - Command: `melos run debug:reflectable`
    - Description: Finds `.reflectable.dart` files in specified packages.
    - Usage: `MELOS_SCOPE="package_name" melos run debug:reflectable`
    - Example:
      ```bash
      MELOS_SCOPE="core_package" melos run debug:reflectable
      # Output: Checking for .reflectable.dart files in core_package
      # /home/user/protevus_platform/packages/core_package/lib/src/models.reflectable.dart
      ```

22. **List Dart Files**
    - Command: `melos run list:dart:files`
    - Description: Lists all Dart files in specified package(s).
    - Usage: `MELOS_SCOPE="package_name" melos run list:dart:files`
    - Example:
      ```bash
      MELOS_SCOPE="utils_package" melos run list:dart:files
      # Output: Listing all Dart files in utils_package:
      # /home/user/protevus_platform/packages/utils_package/lib/src/string_utils.dart
      # /home/user/protevus_platform/packages/utils_package/lib/src/date_utils.dart
      ```

23. **Combine Config**
    - Command: `melos run combine_config`
    - Description: Combines Melos configuration files using a custom script.
    - Usage: `melos run combine_config`
    - This is useful for maintaining separate config files for different environments or CI/CD pipelines.

## Advanced Usage Examples

1. Running a subset of tests matching a specific pattern:
   ```bash
   MELOS_SCOPE="auth_package" melos run test:custom -- --name "login"
   ```

2. Generating documentation and immediately serving it:
   ```bash
   melos run docs:generate && melos run docs:serve
   ```

3. Checking for outdated dependencies, upgrading them, and then running tests:
   ```bash
   melos run deps:check && melos run deps:upgrade && melos run test
   ```

4. Performing a dry-run of publishing, then actually publishing if everything looks good:
   ```bash
   melos run publish:check && melos run publish
   ```

5. Running the full CI pipeline and then generating documentation if CI passes:
   ```bash
   melos run ci && melos run docs:generate
   ```

6. Upgrading dependencies for multiple packages and then running their tests:
   ```bash
   MELOS_SCOPE="auth_package,user_package,core_package" melos run deps:upgrade:custom && MELOS_SCOPE="auth_package,user_package,core_package" melos run test:custom
   ```

7. Generating code, running tests, and then checking if any files need to be formatted:
   ```bash
   melos run generate && melos run test && melos run format -- -o none --set-exit-if-changed
   ```

This documentation provides a comprehensive guide to using the Melos configuration in the Protevus Platform project. It covers all aspects of the development lifecycle and should help team members effectively manage the monorepo structure.