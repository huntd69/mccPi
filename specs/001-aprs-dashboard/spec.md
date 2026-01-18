# Feature Specification: APRS Dashboard MVP

**Feature Branch**: `001-aprs-dashboard`  
**Created**: 2026-01-18  
**Status**: Draft  
**Input**: User description: "MVP web dashboard with module enable/disable, persistent config folder with optional reset-configs, and APRS receive module page for listening to APRS traffic"

## User Scenarios & Testing *(mandatory)*

<!--
  mccPi note: Operational testing is performed on a Raspberry Pi over SSH and
  MUST start from the golden-path deploy workflow (curl deploy.sh from GitHub,
  clone into /opt, run deploy).
-->

### User Story 1 - Enable APRS Module (Priority: P1)

Enable and use a module from the mobile-friendly dashboard.

As a licensed ham operator, I can deploy mccPi on a Raspberry Pi, open the web UI on port 80, enable the APRS receive module, and navigate to the module page to observe APRS traffic.

**Why this priority**: This is the core "Swiss army knife" value: quick deployment plus a simple on/off control surface that works from a phone.

**Independent Test**: Can be fully tested by running the golden-path deploy, loading the dashboard in a browser, enabling the APRS module, and confirming the APRS module page is reachable and shows receive activity or a clear "waiting for traffic" state.

**Acceptance Scenarios**:

1. **Given** a freshly deployed Raspberry Pi and a browser on the same network, **When** I visit the mccPi homepage on port 80, **Then** I see a dashboard listing available modules and each module's status.
2. **Given** the APRS receive module is disabled, **When** I enable it from the dashboard, **Then** it enters a "starting" state and then a "running" or "error" state with a human-readable reason.
3. **Given** the APRS receive module is running, **When** I open its module page, **Then** I can observe received APRS traffic (or a clear message indicating no traffic has been received yet).

---

### User Story 2 - Persistent Config + Reset (Priority: P2)

Keep configuration persistent across redeploys, with an explicit reset option.

As an operator, I want all customization (project and module configuration) to live in a single folder that is retained across redeploys, unless I explicitly request a reset.

**Why this priority**: Operators will re-run `deploy.sh` to upgrade. Config must survive upgrades by default.

**Independent Test**: Can be tested by setting a recognizable config value, re-running the golden-path deploy, and confirming the value is unchanged; then re-running with the reset-configs option and confirming the value is reset.

**Acceptance Scenarios**:

1. **Given** I have customized at least one configuration value, **When** I redeploy using the golden-path deploy process, **Then** my configuration remains intact.
2. **Given** I want a clean slate, **When** I redeploy with the reset-configs option, **Then** the configuration is reset to defaults and modules return to a safe disabled state.

---

### User Story 3 - TX Safety Gates + Logging (Priority: P3)

Support safe transmit gating and provide operator-friendly logs.

As a licensed operator, I want transmit-related controls to be clearly gated behind a callsign entry and disclaimer acceptance, and I want transmit activity recorded in a dedicated TX log.

**Why this priority**: This is a safety boundary that prevents accidental transmission features from being enabled without explicit consent.

**Independent Test**: Can be tested by visiting the dashboard and verifying transmit controls are disabled until callsign+disclaimer are set, and verifying that any transmit-related activity is recorded in the dedicated TX log.

**Acceptance Scenarios**:

1. **Given** I have not entered a callsign and have not accepted the disclaimer, **When** I view any transmit-related controls, **Then** they are disabled and explain why.
2. **Given** I have entered a callsign and accepted the disclaimer, **When** transmit-related controls are available for a module, **Then** they can be enabled and any transmit-related activity is recorded in the TX activity log.

---

### Edge Cases

- No internet connectivity during routine use: the dashboard still loads and module pages still function.
- APRS module enabled but no RF traffic received: module page shows a clear "no traffic yet" state (not a blank page).
- Module start failure (misconfiguration, missing hardware, permission issues): dashboard shows "error" with an actionable message.
- Rapid enable/disable toggling: system stays consistent (no duplicate starts, no stuck "starting" state).
- Reset-configs used accidentally: system clearly indicates that configuration was reset and modules are disabled.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a responsive web dashboard on port 80 suitable for phones and laptops.
- **FR-002**: The dashboard MUST list available modules and show each module's state at minimum: disabled, starting, running, error.
- **FR-003**: Users MUST be able to enable or disable a module from the dashboard.
- **FR-004**: When a module is enabled, the system MUST start it immediately and keep it enabled across reboot.
- **FR-005**: Each module MUST have a module-specific page reachable from the dashboard.

- **FR-006**: The APRS receive module MUST allow the operator to observe received APRS traffic from its module page.
- **FR-007**: The APRS receive module MUST provide a clear indicator when it is running but has not received traffic yet.

- **FR-008**: All project/module customization MUST be stored in a single configuration folder.
- **FR-009**: Configuration MUST persist across redeploy by default.
- **FR-010**: The deploy workflow MUST support an explicit reset-configs option that resets configuration to defaults.

- **FR-011**: Transmit-related controls MUST remain disabled until a callsign is provided and a disclaimer is accepted.
- **FR-012**: Any transmit activity MUST be recorded in a dedicated TX activity log.
- **FR-013**: The dashboard MUST provide links to relevant log files and configuration views for each module.

### Key Entities *(include if feature involves data)*

- **Module**: A named capability that can be enabled/disabled; includes status, health message, and links (module page, logs, config).
- **Module Configuration**: Customization values for a module, stored in the shared configuration folder.
- **Operator Profile**: Callsign and disclaimer acceptance state used for transmit gating.
- **APRS Message**: A received APRS packet/event displayed to the operator (timestamp, source, summary text).
- **TX Activity Event**: A record of transmit-related actions captured in the dedicated TX activity log.

## Assumptions

- For this MVP, APRS functionality is receive-focused; transmit controls may exist but are gated.
- Wi-Fi configuration is out of scope.
- Hardware support is intentionally narrow for the MVP; unsupported hardware should lead to a clear error state.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a fresh Raspberry Pi, an operator can complete golden-path deploy and load the dashboard in a browser within 5 minutes.
- **SC-002**: From the dashboard, an operator can enable the APRS receive module and reach its module page within 60 seconds.
- **SC-003**: When APRS traffic is present, received messages appear on the APRS module page within 10 seconds of receipt.
- **SC-004**: Configuration persists across redeploys in 100% of upgrade tests; reset-configs reliably restores defaults when used.
- **SC-005**: Transmit controls are inaccessible without callsign+disclaimer in 100% of validation checks; TX activity is logged when transmit actions occur.
