# Contributing to the Protevus Platform

Welcome to the Protevus Platform project! We appreciate your interest in contributing to our open-source application server platform. This document outlines the guidelines and best practices for contributing to the project.

## Code of Conduct

By participating in this project, you are expected to uphold our [Code of Conduct](CODE_OF_CONDUCT.md). Please review it to understand the behavior standards expected of all contributors.

## Ways to Contribute

There are many ways to contribute to the Protevus Platform project, including:

- Reporting bugs or issues
- Suggesting new features or improvements
- Submitting pull requests with bug fixes or new features
- Improving documentation
- Participating in discussions and providing feedback

## Getting Started

1. Fork the repository and create a new branch for your contribution.
2. Follow the project's coding standards and conventions.
3. Write clear and descriptive commit messages.
4. Test your changes locally before submitting a pull request.
5. Submit a pull request with a detailed description of your changes.

## Branching Conventions

When creating a new branch for your contribution, please follow these naming conventions:

topic names.
```
docs/<description>
fix/<username>-<description>
feature/<username>-<description>
refactor/<username>-<description>
```

If the scope of the issue changes for any reason, please create a new branch with the appropriate naming convention.

## Local Testing

While we provide CI/CD through GitHub Actions, it is recommended to set up your local testing environment to run tests before pushing commits. Follow the instructions in the project's documentation or the CI configuration files to set up your local testing environment.

### Running Tests

Currently, there are three sets of tests that need to be run:

```bash
melos test-unit
# These two need to be run inside packages/conduit
dart test -j1 test/* # use dart test -j1 for Windows and macOS
dart tool/generated_test_runner.dart
```
The first command will run all the unit tests in the Conduit package and its dependencies. The last two commands test CLI components and string-compiled code, respectively.

## Pull Request Requirements

Document the intent and purpose of the pull request.
All non-documentation pull requests must include automated tests that cover the new code, including failure cases.
If tests work locally but not on the CI, please mention @j4qfrost on the pull request or reach out on the Discord server.

## Commits and Versioning

The project uses melos for tooling, which provides autoversioning based on conventional commits. Commits to the master branch will usually be squashed from pull requests, so ensure that the pull request title uses conventional commits to trigger versioning and publishing CI. You do not need to use conventional commits on each commit to your branch.

## Licensing

Protevus Platform is released under the [MIT License](LICENSE).

Thank you for your interest in contributing to the Protevus Platform project! We look forward to your contributions and appreciate your efforts to make this project better.