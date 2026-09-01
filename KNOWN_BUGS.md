# Known Bugs

No known open bugs as of 2026-09-02. The prototype boots headless without script errors and the full automated suite passes 148/148.

## Limitations

| ID | Status | Description | Impact | Resolution |
| --- | --- | --- | --- | --- |
| LIM-001 | Resolved | Original concept PDF was not supplied. | Phase 0 analysis was temporarily blocked. | PDF reviewed on 2026-08-09. |
| LIM-002 | Resolved | `tests/integration/test_gameplay_coordinator.gd` assumed the legacy fixed 120-second level, so 3 checks failed after the stage-progression model shortened stage 1 to 65 seconds. | Suite reported false failures. | Test rewritten for the stage model on 2026-08-30; suite green. |
| LIM-003 | Open | No Android export preset or APK exists yet; only the desktop/headless prototype runs. | Milestone APKs cannot be produced. | Planned for Phase 6 (Android Build). |
