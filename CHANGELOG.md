# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2025-03-23

### Fixed

- Fixed handling of structs that caused conversion failures
- Improved handling for struct types

## [0.1.0] - 2024-10-26

### Added

- Initial implementation with support for converting between camelCase and snake_case
- Functions for basic string and atom key conversion
- Support for converting nested maps and lists
- Preservation of atom and string key types
- Phoenix integration for automatic conversion of JSON responses
- Plug for converting incoming request parameters from camelCase to snake_case
