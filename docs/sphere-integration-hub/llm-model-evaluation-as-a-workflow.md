# LLM model evaluation as a workflow

Choosing a small model is easy when the prompt is simple.

It gets harder when the prompt set looks like your real work: policy summaries, incident handoffs, JSON extraction, support replies, classification tasks, and all the strange phrasing users send at 17:58 on a Friday.

A single benchmark score does not tell you enough.

You need to know:

- which model gave the better answer for your prompts
- how many tokens it spent
- how long each call took
- whether the answer shape is safe enough to feed into the next step
- whether the test can run again next week without becoming a spreadsheet exercise

That is a workflow problem.

Compatibility: Sphere Integration Hub `v1.7.20.278`, commit `c99028ab931c2b213573377382dc7855715af3ec`. Sample validation: `--dry-run` and `--mocked` passed against that version.

![LLM model evaluation workflow](../assets/images/sphere-integration-hub/llm-model-evaluation.svg)

## The pain

A lot of model selection still happens like this:

1. paste 3 prompts into a chat UI
2. compare the answers manually
3. check pricing in another tab
4. forget to save the exact prompt
5. repeat the same test a month later with slightly different inputs

That process feels fast, until a team starts making decisions from it.

For production work, "which answer do I like?" is too small a question.

The better question is:

> Which model gives good enough answers for this task, at the cost and latency we can accept?

That needs evidence.

## What SIH can measure

The OpenAI stage in SIH normalizes the provider response into workflow output.

For each LLM call, you can capture:

- `inputTokens`
- `outputTokens`
- `totalTokens`
- `cachedInputTokens`
- `reasoningTokens`
- `durationMs`
- `finishReason`
- `requestId`
- `model`

That matters because quality without usage is incomplete.

A model that wins by 2% on answer quality and costs 8x more may still be the wrong default. A smaller model that answers 90% of the prompt set correctly might be the right first pass, with a stronger model reserved for retries, escalations, or judgment.

## The workflow shape

The useful pattern has 3 phases.

```text
input.prompts[]
  -> candidate-a forEach prompt
  -> candidate-b forEach prompt
  -> judge compares both result arrays
  -> output keeps answers, token usage, duration, and winner
```

The same prompt array goes through both candidates.

Then the judge model sees:

- the original prompts
- Candidate A answers
- Candidate A token and duration data
- Candidate B answers
- Candidate B token and duration data

The judge should evaluate quality. It should not decide price policy by itself. Cost policy belongs to you.

## The runnable sample

The full sample lives here:

[llm-model-evaluation.workflow](../assets/samples/sphere-integration-hub/llm-model-evaluation/llm-model-evaluation.workflow)

It comes with:

- [api.catalog](../assets/samples/sphere-integration-hub/llm-model-evaluation/api.catalog)
- [workflows.config](../assets/samples/sphere-integration-hub/llm-model-evaluation/workflows.config)
- [llm-model-evaluation.wfvars](../assets/samples/sphere-integration-hub/llm-model-evaluation/llm-model-evaluation.wfvars)

The first candidate stage runs one model over every prompt:

```yaml
- name: candidate-a
  kind: LLM
  expectedStatus: 200
  forEach: "{{input.prompts}}"
  itemName: prompt
  indexName: promptIndex
  config:
    connectionRef: openai-main
    model: gpt-5.4-mini
    prompts:
      system:
        text: |
          You answer technical and support prompts with concise, usable output.
          Return only JSON. No markdown fences.
      input:
        text: |
          Prompt id: {{context:prompt.id}}
          Prompt:
          {{context:prompt.text}}
    generation:
      temperature: 0.2
      responseFormat: schema
```

Candidate B uses the same prompt array and the same schema, but a different model:

```yaml
config:
  connectionRef: openai-main
  model: gpt-5.4
```

The exact model IDs are part of the workflow. If you want to compare 3 candidates, copy the candidate stage, change the model, and include that third result array in the judge prompt.

## Strict output keeps the test usable

Both candidate stages return a small JSON object:

```json
{
  "promptId": "incident-note",
  "answer": "..."
}
```

The schema is strict because the answer becomes machine input for the judge stage.

```yaml
output:
  schemaName: candidate_answer
  schemaStrict: true
  schema:
    type: object
    required:
      - promptId
      - answer
    properties:
      promptId:
        type: string
      answer:
        type: string
```

Loose text is fine for a demo. It is painful for repeatable evaluation.

## The judge stage

The judge receives both result arrays.

```yaml
input:
  text: |
    Evaluate both candidate sets for the same prompts.

    Prompts:
    {{input.prompts}}

    Candidate A results:
    {{stage:candidate-a.output.foreach_items}}

    Candidate B results:
    {{stage:candidate-b.output.foreach_items}}

    For each prompt, choose the better answer. Consider correctness,
    completeness, clarity, and operational usefulness.
```

The judge returns structured output:

```json
{
  "evaluations": [
    {
      "promptId": "refund-policy",
      "winner": "candidate-b",
      "reason": "More complete policy handling.",
      "candidateAScore": 3,
      "candidateBScore": 4
    }
  ],
  "overallWinner": "tie",
  "notes": "Quality is close; Candidate A is cheaper and faster in this run."
}
```

This is intentionally boring.

Boring is good here. You want stable fields, not an essay.

## Cost and speed

The workflow keeps token and duration evidence per prompt.

For cost, use the output artifact or JSON report and apply your current provider prices:

```text
candidate cost =
  (inputTokens / 1,000,000 * input_price_per_million)
  + (outputTokens / 1,000,000 * output_price_per_million)
```

Do this outside the judge prompt.

Model pricing changes. Your policy may also treat cached input tokens, reasoning tokens, batch discounts, or reserved capacity differently. The workflow should collect facts; the pricing layer should calculate money.

For speed, compare:

- `durationMs` per call
- total candidate phase time in the SIH execution report
- p50 and p95 across repeated runs if the prompt set is large enough

One run gives a smell. Several runs give a signal.

## Run it

From the SIH repository:

```bash
dotnet run --project src/SphereIntegrationHub.cli -- \
  --workflow /Users/jmr.pineda/Projects/GitHub/PinedaTec.eu/tech-blog/docs/assets/samples/sphere-integration-hub/llm-model-evaluation/llm-model-evaluation.workflow \
  --catalog /Users/jmr.pineda/Projects/GitHub/PinedaTec.eu/tech-blog/docs/assets/samples/sphere-integration-hub/llm-model-evaluation/api.catalog \
  --env local \
  --dry-run --verbose
```

For a local proof without calling the provider:

```bash
dotnet run --project src/SphereIntegrationHub.cli -- \
  --workflow /Users/jmr.pineda/Projects/GitHub/PinedaTec.eu/tech-blog/docs/assets/samples/sphere-integration-hub/llm-model-evaluation/llm-model-evaluation.workflow \
  --catalog /Users/jmr.pineda/Projects/GitHub/PinedaTec.eu/tech-blog/docs/assets/samples/sphere-integration-hub/llm-model-evaluation/api.catalog \
  --env local \
  --mocked \
  --report-format both \
  --capture-http bodies
```

The validated mocked run produced:

```text
candidate-a completed
candidate-b completed
judge completed
overallWinner: tie
judgeTotalTokens: 900
judgeDurationMs: 1800
```

The real run needs a real API key in `llm-model-evaluation.wfvars`.

## The current limit

In this SIH version, the sample keeps per-prompt token and duration data in the workflow output and execution report.

It does not sum candidate totals inside the workflow. That calculation is better handled by CI, `jq`, a small report parser, or a later SIH aggregation stage if one is added.

You will also see `foreach_items: "[]"` declared in each candidate output block. That is a small compatibility marker for the current preflight validator. At runtime, SIH replaces it with the real aggregate array from the `forEach` stage.

That is still enough to make a model decision from evidence:

- quality score by prompt
- winner by prompt
- overall judge result
- token usage by model call
- duration by model call
- full JSON and HTML execution report

## Where this fits

Use this pattern when you are choosing a model for a defined task:

- support reply drafting
- policy summarization
- incident handoff rewriting
- classification
- JSON extraction
- test data generation
- moderation pre-review

Use it for task-bound decisions.

The useful answer depends on the task, the prompt distribution, the quality bar, the latency budget, and the cost policy.

That belongs in a workflow.
