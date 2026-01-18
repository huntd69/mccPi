<!--
Sync Impact Report

- Version change: 1.0.0 → 2026.01.18
- Modified principles: principles for mccPi
- Added sections: Project Constraints, Development Workflow
- Removed sections: None
- Templates requiring updates:
	- 5 Updated: .specify/templates/plan-template.md
	- 5 Updated: .specify/templates/spec-template.md
	- 5 Updated: .specify/templates/tasks-template.md
	- 20 Pending: None
- Deferred TODOs:
	- None
-->

# mccPi (Mobile Command Center) Constitution

## Core Principles

### I. Modular Modules (Enable/Disable)
mccPi MUST be composed of modules that can be enabled or disabled independently.

- Each module MUST declare its purpose, dependencies, and on/off state.
- A module MUST be installable/uninstallable without breaking other enabled modules.
- Module installs MUST be idempotent (safe to run repeatedly).
- Adding a new capability (e.g., ADS-B, AX.25, APRS, BBS, ATAK, field logging, offline docs) MUST be implemented as a module.

### II. Golden-Path Deployment via deploy.sh
All validation and testing MUST start from the same deploy path used by users:

- The first step MUST be fetching `deploy.sh` from GitHub via `curl`.
- `deploy.sh` MUST clone the repo into `/opt` and run the deployment.
- `deploy.sh` MUST support fresh installs and upgrades (idempotent, repeatable).
- `deploy.sh` MUST be safe when run as root (the expected workflow is SSH → `sudo su`).
- `deploy.sh` MUST provide clear, human-readable progress and failure messages.

### III. Web UI First (Port 80, Responsive)
mccPi MUST provide a web interface on port 80 intended for phones and laptops.

- The UI MUST be responsive and usable on small screens.
- Graphics and front-end complexity MUST be minimal; prioritize reliability and clarity.
- The web UI MUST expose module enable/disable controls and show module status.

### IV. Raspberry Pi Zero W2 + Bash/Python Standard
The primary target platform is Raspberry Pi Zero W2.

- Bash and Python MUST be the primary implementation languages.
- Solutions MUST be lightweight (favor system packages and simple scripts over heavy stacks).
- Long-running behaviors (daemons) SHOULD be managed by systemd when applicable.

### V. Ham-Safe Transmit Controls + TX Logging
mccPi is for licensed ham radio operators; transmit-capable features MUST be guarded.

- Users MUST enter a callsign in configuration before enabling any transmit features.
- Users MUST accept a simple disclaimer before enabling any transmit features.
- Any transmit activity MUST be logged to a separate TX activity log file.
- Logs MUST be plain text and also be available via system logs (journalctl) where applicable.

Rationale: The tool may include transmit-capable modules; this ensures explicit consent and auditability.

## Project Constraints

- Root workflow: Operational testing is performed over SSH and typically elevates to root via `sudo su`.
- Port 80: Services binding to port 80 MUST do so safely; if privilege dropping is used, it MUST be explicit and documented.
- Module toggles MUST be persisted in config so reboots/redeploys preserve intent.
- Avoid unnecessary internet dependencies at runtime; prefer local/offline operation once deployed.

## Development Workflow

- Any change MUST be validated by running the golden-path deploy on a Raspberry Pi via SSH.
	- Canonical connection: `ssh radio@mccpi.local` → `sudo su` → run the deploy ritual.
- At minimum, validation MUST include a smoke check that:
	- `deploy.sh` completes successfully,
	- the web UI responds on port 80, and
	- module enable/disable works for the touched module(s).
- When changes affect transmit-capable features, validation MUST also confirm:
	- callsign + disclaimer gates are enforced, and
	- TX activity is written to the separate TX log.

## Governance
<!-- Example: Constitution supersedes all other practices; Amendments require documentation, approval, migration plan -->

- This constitution is the highest-level project rule; all plans/specs/tasks MUST comply.
- Any PR that changes deployment behavior, module boundaries, port 80 web UI, or transmit gating MUST explicitly state compliance.
- Amendments MUST be made by editing this file and updating the Sync Impact Report at the top.
- Versioning policy:
	- This constitution uses date-based versions: `YYYY.MM.DD`.
	- Amendments update **Last Amended** and set **Version** to the amendment date.
	- Multiple amendments on the same day SHOULD append a sequence suffix: `YYYY.MM.DD.N`.
	- The mccPi repository release/version policy is also date-based.

**Version**: 2026.01.18 | **Ratified**: 2026-01-18 | **Last Amended**: 2026-01-18
