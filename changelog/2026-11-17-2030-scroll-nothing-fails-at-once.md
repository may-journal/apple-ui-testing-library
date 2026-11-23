### 2026.11.17.2030

> A scroll on a screen with nothing to scroll fails at once instead of at the five-second deadline.

- Fix: `scrolls` reads the settled screen once and fails at once when nothing on it scrolls
- Test: requirement 0004.6 proves the scroll fails well before the deadline on both hosted platforms
- Docs: the usage guide and the user journey say a scroll does not wait for something to scroll
