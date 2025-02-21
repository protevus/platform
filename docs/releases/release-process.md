# Release Process

This document outlines the release process for our platform. Following these guidelines ensures consistent and reliable releases.

## Version Numbering

We follow [Semantic Versioning](https://semver.org/) with the following structure:
- MAJOR version for incompatible API changes
- MINOR version for backwards-compatible functionality
- PATCH version for backwards-compatible bug fixes

Development versions are suffixed with `-dev` (e.g., v1.2.3-dev).

## Release Cycle

### 1. Development Phase
- All development work happens in feature branches
- Feature branches are created from the `dmz` branch
- Branch naming convention: `feature/description-of-change`
- Regular commits should follow our commit message format:
  - `add:` for new features
  - `update:` for changes in existing functionality
  - `fix:` for bug fixes
  - `refactor:` for code changes that neither fix bugs nor add features
  - `remove:` for removed features

### 2. Pre-Release Checklist
- [ ] All tests passing
- [ ] Code review completed
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Release notes prepared
- [ ] Version numbers updated in relevant files
- [ ] Dependencies reviewed and updated
- [ ] Performance testing completed
- [ ] Security review completed

### 3. Release Preparation
1. Update version numbers:
   - CHANGELOG.md
   - pubspec.yaml files
   - Documentation references

2. Create release notes:
   - Place in `docs/release-notes/v{version}.md`
   - Include all significant changes
   - Document breaking changes
   - List known issues
   - Provide upgrade instructions

3. Update release index:
   - Add entry to `docs/releases/index.md`
   - Include key updates and changes

### 4. Release Process
1. Create release branch:
   ```bash
   git checkout dmz
   git pull origin dmz
   git checkout -b release/v{version}
   ```

2. Run final checks:
   ```bash
   dart pub get
   dart analyze
   dart test
   ```

3. Tag the release:
   ```bash
   git tag -a v{version} -m "Release v{version}"
   git push origin v{version}
   ```

4. Merge to main:
   ```bash
   git checkout main
   git merge release/v{version}
   git push origin main
   ```

### 5. Post-Release
1. Update development version:
   - Increment version number in dmz branch
   - Add `-dev` suffix

2. Create release announcement:
   - Update documentation site
   - Notify team members
   - Update relevant tracking systems

3. Monitor for issues:
   - Watch for bug reports
   - Prepare hotfix if necessary

## Hotfix Process

For critical bugs in production:

1. Create hotfix branch from main:
   ```bash
   git checkout main
   git checkout -b hotfix/description
   ```

2. Fix the issue and update version:
   - Increment PATCH version
   - Update CHANGELOG.md
   - Create release notes

3. Tag and release:
   ```bash
   git tag -a v{version} -m "Hotfix v{version}"
   git push origin v{version}
   ```

4. Merge back to both main and dmz:
   ```bash
   git checkout main
   git merge hotfix/description
   git push origin main

   git checkout dmz
   git merge hotfix/description
   git push origin dmz
   ```

## Release Artifacts

Each release should include:
1. Tagged commit in repository
2. Updated documentation
3. Release notes
4. Updated CHANGELOG.md
5. Binary artifacts (if applicable)

## Quality Gates

Before any release:

### Code Quality
- All tests must pass
- Code coverage requirements met
- Static analysis shows no issues
- Performance benchmarks within acceptable range

### Documentation
- API documentation complete
- Release notes prepared
- CHANGELOG.md updated
- Upgrade guide if necessary
- Known issues documented

### Testing
- Unit tests passing
- Integration tests passing
- End-to-end tests passing
- Manual testing completed
- Performance testing completed

## Version Control

### Branch Strategy
- `main`: Production-ready code
- `dmz`: Development branch
- `feature/*`: Feature development
- `release/*`: Release preparation
- `hotfix/*`: Emergency fixes

### Tag Strategy
- Release tags: `v{major}.{minor}.{patch}`
- Development tags: `v{major}.{minor}.{patch}-dev`

## Communication

### Internal
1. Notify team of release schedule
2. Share release notes draft
3. Conduct release retrospective
4. Document lessons learned

### External
1. Update public documentation
2. Publish release notes
3. Update version compatibility matrix
4. Notify users of breaking changes

## Rollback Procedures

If issues are discovered:

1. Assess severity and impact
2. Decide between hotfix or rollback
3. If rolling back:
   ```bash
   git revert v{version}
   git tag -a v{previous-version} -m "Rollback to v{previous-version}"
   git push origin v{previous-version}
   ```
4. Communicate with users
5. Document incident and resolution

## Continuous Improvement

After each release:

1. Conduct release retrospective
2. Document what worked and what didn't
3. Update this process document
4. Implement improvements for next release
