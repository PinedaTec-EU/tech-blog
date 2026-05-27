---
name: tech-blog-writing
description: Use when drafting or editing articles for this MkDocs tech blog, especially the Sphere Integration Hub series. Captures the local article voice, structure, validation expectations, and version anchoring rules.
---

# Tech blog writing

## Purpose

Use this skill for articles in this repository.

The blog voice is practical, direct, and technical. It starts from a real engineering problem, shows why common fixes break down, then connects the fix to a concrete SIH capability.

## Voice

- Write public articles in English. The conversation language does not change the article language. Keep titles, descriptions, navigation labels, article cards, and social preview metadata in English.
- Open with the operational problem. No warm-up paragraph.
- Keep paragraphs short, usually 1 or 2 sentences.
- Use concrete examples, file names, command lines, version numbers, and outputs.
- Prefer plain verbs. Say "uses", "runs", "keeps", "fails", "writes".
- Avoid marketing language and inflated claims.
- Do not use em dashes.
- Do not use the pattern "not X, but Y" or similar negative reframes.
- Explain limits plainly when the tool has a limit.

## SIH article rules

- Anchor every SIH-specific article to an exact SIH version only. Do not include the commit hash in the public compatibility marker.
- Add the compatibility marker near the top of the article, before the first image or first major section:
  `Compatibility: Sphere Integration Hub `vX.Y.Z.BUILD`.`
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
  - `image`: the conceptual article header image path, relative to `docs/`. This image is also used for Open Graph and Twitter/X link previews.
  - `author`: the public author name shown on the article page
  - `author_id`: the stable internal author handle, for example `jmpineda`
  - `published`: the canonical publication date in `YYYY-MM-DD`
  - `updated`: optional last meaningful update date in `YYYY-MM-DD`
- Every article should have a conceptual header image that adds meaning to the article. Put it near the top of the article, after the compatibility marker when present and before the first major section.
- Prefer a specific image per article over the generic series image. Use the generic series image only as a temporary fallback.
- For Sphere Integration Hub articles, keep article images in `docs/assets/images/sphere-integration-hub/` and use a stable slug filename, for example `article-slug.png`.
- Keep social preview images in `docs/assets/images/<series>/` so MkDocs publishes them as stable absolute URLs.
- The MkDocs template emits Open Graph and Twitter card tags from this front matter. Verify generated HTML includes the article-specific `og:image` before publishing articles meant to be shared on LinkedIn.
- The article page should show `By <author> · Published <date>` under the `H1`. Show `Updated <date>` only when the article changed meaningfully after publication.
- Title as a concrete technical claim.
- First section: the pain.
- Middle sections: how teams usually handle it, where that fails, what SIH does.
- Include one compact code excerpt in the article and link to the full sample.
- End with a practical judgement, not a slogan.

## Social post rules

- LinkedIn posts for blog articles must include at least 3 focused hashtags.
- One LinkedIn hashtag must always be `#PinedaTecEU`.
- Use tags that describe the concrete engineering topic, not broad hype.
- When drafting LinkedIn companion posts for this repository, prefer an audience-first opener when the intended reader is specific and easy to name. Put the audience in the first line in natural language, for example `Backend developers and QA engineers testing API integrations:` or `DevOps teams troubleshooting production issues:`.
- Use the audience-first opener as a distribution heuristic, not as filler. Skip it when the audience would be vague, generic, or forced.

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
