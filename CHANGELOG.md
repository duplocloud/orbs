# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

 - aws jit step
 - a base and aws executor image preinstalled with duploctl
 - fix `duplo/install` on PEP 668 systems (Ubuntu 24.04 / cimg/base:2026.x): install via `pipx` instead of system `pip`. Also fixes apt array-quoting and missing `-y` (DUPLO-42822) .
