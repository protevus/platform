#!/usr/bin/env bash
set -e

# Change to the project root directory
cd "$(dirname "$0")/.."

# Default values
coverage=false
unit_only=false
integration_only=false
watch=false

# Print usage information
function print_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  --coverage        Generate coverage report"
  echo "  --unit           Run only unit tests"
  echo "  --integration    Run only integration tests"
  echo "  --watch          Run tests in watch mode"
  echo "  --help           Show this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --coverage)
      coverage=true
      shift
      ;;
    --unit)
      unit_only=true
      shift
      ;;
    --integration)
      integration_only=true
      shift
      ;;
    --watch)
      watch=true
      shift
      ;;
    --help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      print_usage
      exit 1
      ;;
  esac
done

# Clean up previous runs
rm -rf coverage .dart_tool/test

# Ensure dependencies are up to date
echo "Ensuring dependencies are up to date..."
dart pub get

# Run tests based on options
if [ "$unit_only" = true ]; then
  echo "Running unit tests..."
  if [ "$watch" = true ]; then
    dart test --tags unit --watch
  else
    dart test --tags unit
  fi
elif [ "$integration_only" = true ]; then
  echo "Running integration tests..."
  if [ "$watch" = true ]; then
    dart test --tags integration --watch
  else
    dart test --tags integration
  fi
else
  echo "Running all tests..."
  if [ "$coverage" = true ]; then
    echo "Collecting coverage..."
    # Ensure coverage package is activated
    dart pub global activate coverage

    # Run tests with coverage
    dart test --coverage="coverage"
    
    # Format coverage data
    dart pub global run coverage:format_coverage \
      --lcov \
      --in=coverage \
      --out=coverage/lcov.info \
      --packages=.packages \
      --report-on=lib \
      --check-ignore

    # Generate HTML report if lcov is installed
    if command -v genhtml >/dev/null 2>&1; then
      echo "Generating HTML coverage report..."
      genhtml coverage/lcov.info -o coverage/html
      echo "Coverage report generated at coverage/html/index.html"
    else
      echo "lcov not installed, skipping HTML report generation"
      echo "Install lcov for HTML reports:"
      echo "  brew install lcov     # macOS"
      echo "  apt-get install lcov  # Ubuntu"
    fi
  elif [ "$watch" = true ]; then
    dart test --watch
  else
    dart test
  fi
fi

# Print summary
echo
echo "Test execution completed"
if [ "$coverage" = true ]; then
  echo "Coverage information available in coverage/lcov.info"
fi
