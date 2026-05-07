version: "3.11"
id: "01JLLMMODELEVAL0000001"
name: "llm-model-evaluation"
description: |
  Compares two LLM/SLM candidates over the same prompt array, then asks a
  judge model to rank answer quality while preserving token and duration data.
  Validated against Sphere Integration Hub v1.7.20.278.
output: true

input:
  - name: openaiApiKey
    type: Text
    required: true
    secret: true
  - name: prompts
    type: Array
    required: true

stages:
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
        output:
          text: "Return JSON matching the configured schema."
      reasoning:
        effort: low
      generation:
        temperature: 0.2
        responseFormat: schema
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
      limits:
        maxInputTokens: 4000
        maxOutputTokens: 900
        maxTotalTokens: 4900
        timeoutSeconds: 60
    mock:
      status: 200
      payload: |
        {
          "output": {
            "text": "{\"promptId\":\"{{context:prompt.id}}\",\"answer\":\"Candidate A answer for {{context:prompt.id}}\"}",
            "json": {
              "promptId": "{{context:prompt.id}}",
              "answer": "Candidate A answer for {{context:prompt.id}}"
            }
          },
          "usage": {
            "inputTokens": 120,
            "outputTokens": 80,
            "totalTokens": 200,
            "cachedInputTokens": 0,
            "reasoningTokens": 8,
            "model": "gpt-5.4-mini",
            "provider": "openai"
          },
          "finishReason": "completed",
          "durationMs": 900,
          "requestId": "mock-candidate-a-{{context:promptIndex}}"
        }
    output:
      promptId: "{{response.body.output.json.promptId}}"
      answer: "{{response.body.output.json.answer}}"
      inputTokens: "{{response.body.usage.inputTokens}}"
      outputTokens: "{{response.body.usage.outputTokens}}"
      totalTokens: "{{response.body.usage.totalTokens}}"
      reasoningTokens: "{{response.body.usage.reasoningTokens}}"
      durationMs: "{{response.body.durationMs}}"
      model: "{{response.body.usage.model}}"
      finishReason: "{{response.body.finishReason}}"
      foreach_items: "[]"

  - name: candidate-b
    kind: LLM
    expectedStatus: 200
    forEach: "{{input.prompts}}"
    itemName: prompt
    indexName: promptIndex
    config:
      connectionRef: openai-main
      model: gpt-5.4
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
        output:
          text: "Return JSON matching the configured schema."
      reasoning:
        effort: low
      generation:
        temperature: 0.2
        responseFormat: schema
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
      limits:
        maxInputTokens: 4000
        maxOutputTokens: 900
        maxTotalTokens: 4900
        timeoutSeconds: 60
    mock:
      status: 200
      payload: |
        {
          "output": {
            "text": "{\"promptId\":\"{{context:prompt.id}}\",\"answer\":\"Candidate B answer for {{context:prompt.id}}\"}",
            "json": {
              "promptId": "{{context:prompt.id}}",
              "answer": "Candidate B answer for {{context:prompt.id}}"
            }
          },
          "usage": {
            "inputTokens": 140,
            "outputTokens": 95,
            "totalTokens": 235,
            "cachedInputTokens": 0,
            "reasoningTokens": 12,
            "model": "gpt-5.4",
            "provider": "openai"
          },
          "finishReason": "completed",
          "durationMs": 1350,
          "requestId": "mock-candidate-b-{{context:promptIndex}}"
        }
    output:
      promptId: "{{response.body.output.json.promptId}}"
      answer: "{{response.body.output.json.answer}}"
      inputTokens: "{{response.body.usage.inputTokens}}"
      outputTokens: "{{response.body.usage.outputTokens}}"
      totalTokens: "{{response.body.usage.totalTokens}}"
      reasoningTokens: "{{response.body.usage.reasoningTokens}}"
      durationMs: "{{response.body.durationMs}}"
      model: "{{response.body.usage.model}}"
      finishReason: "{{response.body.finishReason}}"
      foreach_items: "[]"

  - name: judge
    kind: LLM
    expectedStatus: 200
    config:
      connectionRef: openai-main
      model: gpt-5.4
      prompts:
        system:
          text: |
            You are a strict evaluator. Score answer quality without knowing
            provider cost. Return only JSON. No markdown fences.
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
        output:
          text: "Return JSON matching the configured schema."
      reasoning:
        effort: low
      generation:
        temperature: 0
        responseFormat: schema
      output:
        schemaName: model_eval_report
        schemaStrict: true
        schema:
          type: object
          required:
            - evaluations
            - overallWinner
            - notes
          properties:
            evaluations:
              type: array
              items:
                type: object
                required:
                  - promptId
                  - winner
                  - reason
                  - candidateAScore
                  - candidateBScore
                properties:
                  promptId:
                    type: string
                  winner:
                    type: string
                    enum:
                      - candidate-a
                      - candidate-b
                      - tie
                  reason:
                    type: string
                  candidateAScore:
                    type: integer
                    minimum: 1
                    maximum: 5
                  candidateBScore:
                    type: integer
                    minimum: 1
                    maximum: 5
            overallWinner:
              type: string
              enum:
                - candidate-a
                - candidate-b
                - tie
            notes:
              type: string
      limits:
        maxInputTokens: 12000
        maxOutputTokens: 1600
        maxTotalTokens: 13600
        timeoutSeconds: 90
    mock:
      status: 200
      payload: |
        {
          "output": {
            "text": "{\"evaluations\":[{\"promptId\":\"refund-policy\",\"winner\":\"candidate-b\",\"reason\":\"More complete policy handling.\",\"candidateAScore\":3,\"candidateBScore\":4},{\"promptId\":\"incident-note\",\"winner\":\"candidate-a\",\"reason\":\"Shorter handoff with enough chronology.\",\"candidateAScore\":4,\"candidateBScore\":3},{\"promptId\":\"json-extraction\",\"winner\":\"tie\",\"reason\":\"Both answers preserve the requested fields.\",\"candidateAScore\":4,\"candidateBScore\":4}],\"overallWinner\":\"tie\",\"notes\":\"Quality is close; Candidate A is cheaper and faster in this mocked run.\"}",
            "json": {
              "evaluations": [
                {
                  "promptId": "refund-policy",
                  "winner": "candidate-b",
                  "reason": "More complete policy handling.",
                  "candidateAScore": 3,
                  "candidateBScore": 4
                },
                {
                  "promptId": "incident-note",
                  "winner": "candidate-a",
                  "reason": "Shorter handoff with enough chronology.",
                  "candidateAScore": 4,
                  "candidateBScore": 3
                },
                {
                  "promptId": "json-extraction",
                  "winner": "tie",
                  "reason": "Both answers preserve the requested fields.",
                  "candidateAScore": 4,
                  "candidateBScore": 4
                }
              ],
              "overallWinner": "tie",
              "notes": "Quality is close; Candidate A is cheaper and faster in this mocked run."
            }
          },
          "usage": {
            "inputTokens": 680,
            "outputTokens": 220,
            "totalTokens": 900,
            "cachedInputTokens": 0,
            "reasoningTokens": 60,
            "model": "gpt-5.4",
            "provider": "openai"
          },
          "finishReason": "completed",
          "durationMs": 1800,
          "requestId": "mock-judge"
        }
    output:
      report: "{{response.body.output.json}}"
      overallWinner: "{{response.body.output.json.overallWinner}}"
      notes: "{{response.body.output.json.notes}}"
      inputTokens: "{{response.body.usage.inputTokens}}"
      outputTokens: "{{response.body.usage.outputTokens}}"
      totalTokens: "{{response.body.usage.totalTokens}}"
      reasoningTokens: "{{response.body.usage.reasoningTokens}}"
      durationMs: "{{response.body.durationMs}}"
      model: "{{response.body.usage.model}}"

endStage:
  output:
    candidateAItems: "{{stage:candidate-a.output.foreach_items}}"
    candidateBItems: "{{stage:candidate-b.output.foreach_items}}"
    judgeReport: "{{stage:judge.output.report}}"
    overallWinner: "{{stage:judge.output.overallWinner}}"
    candidateATokenEvidence: "{{stage:candidate-a.output.foreach_items}}"
    candidateBTokenEvidence: "{{stage:candidate-b.output.foreach_items}}"
    judgeTotalTokens: "{{stage:judge.output.totalTokens}}"
    judgeDurationMs: "{{stage:judge.output.durationMs}}"
