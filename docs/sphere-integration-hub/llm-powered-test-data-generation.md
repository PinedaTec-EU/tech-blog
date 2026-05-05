# LLM-Powered Test Data Generation: Stop Writing Scripts, Start Generating Reality

Random test data is often technically valid and still useless for testing real features.

If a recommendation engine, a search feature, a moderation flow, or an analytics dashboard depends on realistic user behavior, random strings do not help. They pass schema validation, but they do not behave like production data.

This article shows how Sphere Integration Hub can use an inline LLM stage to generate contextually realistic test data, validate it with a strict schema, and feed it directly into API workflows.

![LLM-powered test data generation](../assets/images/sphere-integration-hub/llm-test-data-generation.svg)

## The Pain

Imagine an e-commerce platform in staging. The backend team proudly has 1,000 test users.

QA opens the recommendation engine tests and sees this:

```json
{
  "userId": "a3f2b5c8-e4d1-4f9a-b2c7-8e5f3a1d9c6b",
  "name": "Kdjfhaksld Mxnvbqwo",
  "email": "hgkdjfla@test.com",
  "bio": "Dfkjghkdfhgkljsdhfgkljshdfglkjhsdflgkjhsdfg",
  "interests": ["Qwerty", "Asdfgh", "Zxcvbn"]
}
```

The recommendation algorithm needs real interests like `hiking`, `photography`, or `cooking`.

It cannot match `Qwerty` to hiking boots. It cannot infer that `Asdfgh` means camera lenses. It cannot produce meaningful recommendations from data that has no semantic content.

The problem is simple:

> Random data is technically valid, but functionally useless for testing real features.

## What Random Data Breaks

Random data breaks the parts of the system that depend on meaning.

1. Recommendation engines
   The algorithm needs semantic relationships between user interests and products.

2. Search and filtering
   A query like `Find users interested in photography` returns nothing if every interest is random text.

3. Content personalization
   Generated emails and profile cards look broken because names, bios, and interests are nonsense.

4. UI and UX validation
   Designers cannot validate layout, wrapping, truncation, or profile cards with random strings.

5. Analytics and reporting
   Dashboards become meaningless when the top interests are `Dfkjgh`, `Qwerty`, and `Asdfgh`.

The result is a coverage gap. Schema validation passes, but 30-40% of semantic features are not really tested.

## What Teams Usually Do

Teams usually try four approaches.

### Manual Test Data

QA creates a small set of golden users in a spreadsheet and imports them into staging.

Pros:

- realistic data
- full control

Cons:

- does not scale
- brittle when schemas change
- not CI/CD friendly
- creates a team bottleneck

Verdict: good for edge cases, bad for volume.

### Random Generators

```yaml
body: |
  {
    "id": "{{rand:guid()}}",
    "name": "{{rand:text(10, alpha)}}",
    "email": "{{rand:text(8, alnum)}}@test.com",
    "bio": "{{rand:text(100, alpha)}}",
    "age": {{rand:number(18, 65)}}
  }
```

Pros:

- fast
- scalable
- inline
- schema-valid

Cons:

- semantically useless
- unrealistic
- breaks personalization, search, and recommendations

Verdict: perfect for IDs and timestamps, terrible for content.

### Python and Faker

```python
from faker import Faker
import json

fake = Faker()
users = []

for _ in range(1000):
    users.append({
        "id": fake.uuid4(),
        "name": fake.name(),
        "email": fake.email(),
        "bio": fake.text(max_nb_chars=100),
        "age": fake.random_int(18, 65),
        "interests": [fake.word() for _ in range(3)]
    })

with open("users.json", "w") as f:
    json.dump(users, f)
```

This is better than random strings, but it still produces content like generic bios and unrelated interest words.

It also introduces a separate workflow:

- generate data
- export JSON or CSV
- import into staging
- maintain the script when schemas change

Verdict: better than random strings, still not realistic enough.

### Production Data Anonymization

Production data is realistic, but it brings serious tradeoffs:

- privacy risk
- GDPR and data residency concerns
- large exports and imports
- stale staging data
- repeatability problems
- production access concerns

Verdict: realistic, but risky and hard to maintain.

## What We Need

A useful approach should be:

- realistic
- scalable
- inline in workflows
- low maintenance
- CI/CD native

That is where an LLM stage becomes useful.

## The LLM Solution

Use an LLM stage inside the workflow to generate realistic structured data, then pass that output directly into API stages.

```text
Workflow
  Stage 1: LLM generates realistic user profile
  Stage 2: API creates user
  Stage 3: API verifies user creation
```

This works because the LLM understands semantic relationships. It can produce a user profile where the name, bio, interests, and behavior make sense together.

## Generate One Realistic User

```yaml
version: "3.11"
name: "generate-realistic-user"

stages:
  - name: "generate-profile"
    kind: "LLM"
    config:
      connectionRef: "openai-main"
      prompts:
        system: "You generate realistic user profiles for an e-commerce platform"
        input:
          text: |
            Generate a realistic user profile with:
            - Full name
            - Email address
            - Bio, 50-100 words, with realistic hobbies and interests
            - Age, between 18 and 65
            - 3-5 realistic interests
      output:
        schemaName: "user_profile"
        schemaStrict: true
        schema:
          type: object
          required: [name, email, bio, age, interests]
          properties:
            name:
              type: string
            email:
              type: string
            bio:
              type: string
            age:
              type: integer
            interests:
              type: array
              items:
                type: string
      limits:
        maxOutputTokens: 500

  - name: "create-user"
    kind: "Endpoint"
    endpoint: "/api/users"
    httpVerb: "POST"
    body: |
      {
        "id": "{{rand:guid()}}",
        "name": "{{stage:generate-profile.output.name}}",
        "email": "{{stage:generate-profile.output.email}}",
        "bio": "{{stage:generate-profile.output.bio}}",
        "age": {{stage:generate-profile.output.age}},
        "interests": {{stage:generate-profile.output.interests}}
      }
```

Example output:

```json
{
  "id": "a3f2b5c8-e4d1-4f9a-b2c7-8e5f3a1d9c6b",
  "name": "Sarah Chen",
  "email": "sarah.chen.1991@gmail.com",
  "bio": "Marketing professional passionate about sustainable fashion and mindful living. Weekends you'll find me at yoga class or exploring local farmers markets. Currently learning pottery and always planning my next travel adventure.",
  "age": 32,
  "interests": ["sustainable fashion", "yoga", "pottery", "travel", "farmers markets"]
}
```

Now QA can test recommendations, search, personalization, and UI layout with data that behaves like real data.

## Generate Users in Bulk

Combine LLM stages with `forEach` for bulk generation.

```yaml
version: "3.11"
name: "bulk-generate-users"

input:
  - name: "userCount"
    type: "Number"
    required: true

stages:
  - name: "generate-profiles"
    kind: "LLM"
    forEach: "{{input.userCount}}"
    config:
      connectionRef: "openai-main"
      prompts:
        system: "Generate diverse, realistic user profiles"
        input:
          text: |
            Create a unique user profile.
            Vary demographics, interests, and backgrounds.
      output:
        schemaName: "user_profile"
        schemaStrict: true
        schema:
          type: object
          required: [name, email, bio, age, interests]
          properties:
            name: { type: string }
            email: { type: string }
            bio: { type: string }
            age: { type: integer }
            interests:
              type: array
              items: { type: string }

  - name: "create-users"
    kind: "Endpoint"
    endpoint: "/api/users"
    httpVerb: "POST"
    forEach: "{{stage:generate-profiles.output.items}}"
    body: |
      {
        "id": "{{rand:guid()}}",
        "name": "{{context:item.name}}",
        "email": "{{context:item.email}}",
        "bio": "{{context:item.bio}}",
        "age": {{context:item.age}},
        "interests": {{context:item.interests}}
      }
    ensure:
      mode: "CreateIfMissing"
```

Run it:

```bash
sih --workflow bulk-generate-users.workflow \
  --env staging \
  --input userCount=1000
```

The output is 1,000 unique realistic profiles, generated inline and created through the API.

## Cost Model

For a lightweight model such as GPT-4o mini:

- input: about 100 tokens per user
- output: about 150 tokens per user
- total: about 250 tokens per user

For 1,000 users:

- input: about 100,000 tokens
- output: about 150,000 tokens
- estimated cost: around $0.10-$0.15, depending on model pricing

The alternative is developer time:

- write and maintain a Faker script
- maintain taxonomies and domain-specific dictionaries
- update scripts when schemas change
- move files between generation and execution steps

The LLM approach is not free, but it is often cheaper than maintaining custom test-data tooling.

## Implementation Deep Dive

### Enable Plugins

```yaml
plugins:
  - http
  - openai
```

### Configure the OpenAI Connection

```yaml
- version: "3.11"
  plugins:
    - id: openai
      contractVersion: "1.0"
      runtimeVersion: "1.0"
  connections:
    - name: "openai-main"
      type: llm
      provider: openai
      baseUrl:
        local: https://api.openai.com/v1
      apiKeySecret: "{{env:OPENAI_API_KEY}}"
      config:
        model: "gpt-4o-mini"
```

### Set the API Key

```bash
export OPENAI_API_KEY="sk-..."
```

### Use Strict Output Schemas

Always prefer `schemaStrict: true` when the LLM output becomes API input.

```yaml
output:
  schemaName: "user_profile"
  schemaStrict: true
  schema:
    type: object
    required: [name, email, bio, age, interests]
    properties:
      name:
        type: string
      email:
        type: string
      bio:
        type: string
      age:
        type: integer
        minimum: 18
        maximum: 65
      interests:
        type: array
        minItems: 3
        maxItems: 5
        items:
          type: string
```

Benefits:

- schema compliance before the API call
- type safety
- better failure messages
- repeatable workflow behavior

## Prompt Design

Good prompts are specific and constrained:

```yaml
prompts:
  system: "Generate realistic user profiles for an e-commerce platform"
  input:
    text: |
      Create a unique user profile with:
      - Full name from a diverse background
      - Professional email
      - Bio of 50-100 words about hobbies, profession, and interests
      - Age between 18 and 65
      - 3-5 realistic interests

      Vary demographics, professions, and interests.
```

Bad prompts are vague:

```yaml
prompts:
  system: "Generate user data"
  input:
    text: "Create a user"
```

The vague version may produce inconsistent structures, missing fields, or unrealistic content.

## Advanced Patterns

### Context-Aware Generation

Use previous API responses as prompt context.

```yaml
stages:
  - name: "get-product-categories"
    kind: "Endpoint"
    endpoint: "/api/categories"
    output:
      categories: "{{response.body}}"

  - name: "generate-user-with-relevant-interests"
    kind: "LLM"
    config:
      prompts:
        input:
          text: |
            Generate a user profile with interests related to these product categories:
            {{stage:get-product-categories.output.categories}}

            Ensure interests are realistic hobbies that align with the categories.
```

Generated users now match the product catalog instead of generic internet hobbies.

### Conditional Generation

Generate different profiles based on workflow input.

```yaml
input:
  - name: "userType"
    type: "Text"

stages:
  - name: "generate-profile"
    kind: "LLM"
    config:
      prompts:
        input:
          text: |
            Generate a {{input.userType}} user profile.

            If the user is premium:
            - professional background
            - age range 35-55
            - premium interests

            Otherwise:
            - varied backgrounds
            - age range 18-65
            - diverse interests
```

### Batch Generation

Generate batches of profiles when cost and throughput matter.

```yaml
- name: "generate-diverse-users"
  kind: "LLM"
  forEach: "10"
  config:
    prompts:
      input:
        text: |
          Generate 10 diverse user profiles:
          - vary age, profession, location, and interests
          - include sports, arts, tech, outdoor, and creative hobbies
          - ensure no two profiles are too similar
```

Generating 10 profiles in one call is often cheaper than 10 individual calls.

## Real-World Use Cases

### E-Commerce Recommendations

Generate shoppers with realistic interests:

```yaml
- name: "generate-shoppers"
  kind: "LLM"
  forEach: "500"
  config:
    prompts:
      system: "Generate realistic online shopper profiles"
      input:
        text: |
          Create a diverse shopper profile with:
          - realistic shopping interests
          - age and demographic information
          - shopping behavior hints in the bio
```

Now recommendations can match `running`, `fitness tech`, and `outdoor gear` to real products.

### Content Moderation

Generate labeled posts:

```yaml
- name: "generate-test-posts"
  kind: "LLM"
  forEach: "1000"
  config:
    prompts:
      system: "Generate realistic social media posts"
      input:
        text: |
          Create a diverse social media post:
          - 80% normal posts
          - 15% borderline content
          - 5% clearly violating content
          Label each post as normal, borderline, or violating.
```

This creates realistic ground truth for moderation tests.

### Customer Support Chatbots

Generate customer queries with urgency, category, and emotional tone.

```json
{
  "query": "Where is my order? I ordered 5 days ago and tracking still says pending. I need it by Friday.",
  "category": "shipping",
  "urgency": "high"
}
```

### Analytics Dashboards

Generate demographic distributions that make charts meaningful:

- age distribution
- geography
- realistic interests
- shopping behavior
- segmentation data

This lets product and design teams validate dashboards with data that looks plausible.

## When to Use LLM-Generated Test Data

Use it when semantic realism matters:

- recommendation engines
- search and filtering
- personalization
- content moderation
- support chatbots
- analytics dashboards
- UI validation with realistic text
- integration tests where context flows across services

## When Not to Use It

Do not use LLM-generated data when random or fixed data is enough.

Use `rand:*` helpers for:

- IDs
- timestamps
- counters
- simple schema validation
- high-volume low-value fields

Use fixed fixtures for:

- exact regression cases
- edge case validation
- null or empty values
- maximum length tests
- deterministic assertions

Use cached or pre-generated data when seeding must complete in under one second.

## Hybrid Approach

The best approach is usually hybrid.

```yaml
body: |
  {
    "id": "{{rand:guid()}}",
    "createdAt": "{{system:datetime.utcnow}}",
    "name": "{{context:llm.name}}",
    "email": "{{context:llm.email}}",
    "bio": "{{context:llm.bio}}",
    "interests": {{context:llm.interests}}
  }
```

Use random and system tokens for mechanical fields. Use the LLM only where meaning matters.

## Getting Started

Install Sphere Integration Hub:

```bash
npm install -g @pinedatec.eu/sphere-integration-hub
sih --version
```

Or install it as a .NET tool:

```bash
dotnet tool install -g SphereIntegrationHub.Tool
sih --version
```

Create a workflow, configure the OpenAI plugin, and execute:

```bash
sih --workflow generate-user.workflow \
  --env local \
  --report-format both
```

Example execution output:

```text
Preflight checks:
  API: my-api (https://localhost:5000) - Ready
  Connection: openai-main (https://api.openai.com/v1) - Ready

Executing workflow: generate-realistic-user
  [1/2] generate-profile (LLM) ... 2.3s [Ok]
        Tokens: 120 input, 180 output
  [2/2] create-user ............... 95ms [Ok]

Final output:
  userId: "a3f2b5c8-e4d1-4f9a-b2c7-8e5f3a1d9c6b"
```

## Conclusion

The shift is simple.

From:

```yaml
"name": "{{rand:text(10, alpha)}}"
```

To:

```yaml
"name": "{{stage:generate-profile.output.name}}"
```

Random data is useful for mechanical fields. LLM-generated data is useful for semantic fields.

Stop writing test data scripts. Start generating data that behaves like reality.

## Resources

- GitHub: `github.com/PinedaTec-EU/SphereIntegrationHub`
- NPM: `@pinedatec.eu/sphere-integration-hub`
- NuGet: `SphereIntegrationHub.Tool`
