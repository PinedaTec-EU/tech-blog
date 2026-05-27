# Bug Registry

| Bug code | Discovery date | Status | Short description | Reproduction steps |
| --- | --- | --- | --- | --- |
| BUG-002 | 2026-05-28 | Fixed | The deterministic API workflow engine article opened with rendered metadata text and did not show its header image near the top of the article. | 1. Open `docs/sphere-integration-hub/deterministic-api-workflow-engine.md` on the published site. 2. Observe `title`, `description`, and `image` metadata rendered before the article heading. 3. Verify the article body does not show the `SIH.png` header image near the opening section. |
| BUG-001 | 2026-05-28 | Fixed | Article author and publication metadata were not stored canonically in article front matter, which could cause the article page and homepage metadata to drift. | 1. Open an article page such as `docs/sphere-integration-hub/deterministic-api-workflow-engine.md`. 2. Verify the article front matter has no author or publication date. 3. Compare with `docs/index.md`, where publication dates were maintained separately in card metadata lines. |
