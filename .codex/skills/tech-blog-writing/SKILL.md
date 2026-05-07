---
name: tech-blog-writing
description: Use when drafting or editing articles for this MkDocs tech blog, especially the Sphere Integration Hub series. Captures the local article voice, structure, validation expectations, and version anchoring rules.
---

# Tech blog writing

## Purpose

Use this skill for articles in this repository.

The blog voice is practical, direct, and technical. It starts from a real engineering problem, shows why common fixes break down, then connects the fix to a concrete SIH capability.

## Voice

- Write in English unless the user asks otherwise.
- Open with the operational problem. No warm-up paragraph.
- Keep paragraphs short, usually 1 or 2 sentences.
- Use concrete examples, file names, command lines, version numbers, and outputs.
- Prefer plain verbs. Say "uses", "runs", "keeps", "fails", "writes".
- Avoid marketing language and inflated claims.
- Do not use em dashes.
- Do not use the pattern "not X, but Y" or similar negative reframes.
- Explain limits plainly when the tool has a limit.

## SIH article rules

- Anchor every SIH-specific article to an exact SIH version and, when available, the commit hash used for validation.
- Add the compatibility marker near the top of the article, before the first image or first major section:
  `Compatibility: Sphere Integration Hub `vX.Y.Z.BUILD`, commit `abcdef...`.`
- If the article has a runnable sample, add the validation state in the same paragraph:
  `Sample validation: `--dry-run` and `--mocked` passed against that version.`
- If the article is conceptual and has no runnable sample, keep the compatibility marker but do not claim workflow validation.
- If the article includes workflow YAML, validate it against the referenced SIH version.
- Prefer a runnable sample under `docs/assets/samples/sphere-integration-hub/<article-slug>/`.
- Include `workflow`, `api.catalog`, `workflows.config`, and `.wfvars` files when a sample needs them.
- Use `--dry-run` for preflight validation and `--mocked` when the sample includes mocks.
- Mention provider pricing as a formula or process unless exact prices were checked during the same work session.

## Article shape

- Add front matter to every public page and article with:
  - `title`: the social/link-preview title
  - `description`: a compact summary for search and social previews
  - `image`: the social preview image path, relative to `docs/`
- For Sphere Integration Hub articles, use `image: assets/images/sphere-integration-hub/SIH.png` unless the user explicitly asks for a different preview image.
- Keep social preview images in `docs/assets/images/<series>/` so MkDocs publishes them as stable absolute URLs.
- The MkDocs template emits Open Graph and Twitter card tags from this front matter. Verify generated HTML includes `og:image` before publishing articles meant to be shared on LinkedIn.
- Title as a concrete technical claim.
- First section: the pain.
- Middle sections: how teams usually handle it, where that fails, what SIH does.
- Include one compact code excerpt in the article and link to the full sample.
- End with a practical judgement, not a slogan.

## Social post rules

- LinkedIn posts for blog articles must include at least 3 focused hashtags.
- One LinkedIn hashtag must always be `#PinedaTecEU`.
- Use tags that describe the concrete engineering topic, not broad hype.

## Index card rules

- In the `Sphere Integration Hub Saga` block in `docs/index.md`, list articles newest first.
- Every article card must include a visible publication date in the metadata line.
- Use this format: `Published Month D, YYYY · Topic · Subtopic`.
- If multiple articles share the same date and the saga order is known, keep newest saga entries first.

## Local validation commands

For SIH samples, validate from the SIH repository:

```bash
dotnet run --project src/SphereIntegrationHub.cli -- \
  --workflow <workflow-path> \
  --catalog <catalog-path> \
  --env local \
  --dry-run --verbose
```

Then run mocks when present:

```bash
dotnet run --project src/SphereIntegrationHub.cli -- \
  --workflow <workflow-path> \
  --catalog <catalog-path> \
  --env local \
  --mocked \
  --report-format both \
  --capture-http bodies
```
