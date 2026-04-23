# Scope report — task 0042: POST /sessions endpoint

## Deferred

- Per-IP rate limiting on `POST /sessions` (criterion 4): deferred to task 0051.

## Stubbed

- Error-code taxonomy in `errors/session_errors.py`: codes are defined as constants but all paths raise the generic `SessionError`; no subclass routing.

## Handled differently

- Session expiry (criterion 2): spec said 24h sliding window; shipped 24h absolute.
