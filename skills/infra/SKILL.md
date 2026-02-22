---
name: infra
description: "Design AWS SAM infrastructure for a greenfield project. Guides the user through serverless resource selection, generates specs/infrastructure.md, infra/template.yaml, and infra/samconfig.toml. Triggers on: infra, infrastructure, aws setup, sam template, cloud architecture, serverless setup."
user-invocable: true
---

# AWS Infrastructure Design (SAM)

Design serverless infrastructure for a project using AWS SAM.

---

## The Job

1. Review the project overview to understand requirements
2. Interview the user about AWS infrastructure needs
3. Select appropriate SAM resources
4. Generate infrastructure spec and SAM template
5. Write deployment configuration

**Important:** Do NOT implement application code. Only define infrastructure.

---

## Before You Start

- Read `specs/project-overview.md` for project context
- Check if `specs/infrastructure.md` already exists
- Use AWS MCP tools to validate region/service availability, look up SAM resource syntax, check for relevant SOPs, and validate the generated template

---

## Interview Steps

### Step 1: App Type & Region (2-3 questions)

Confirm the application type from the project overview and ask:
- Target AWS region?
- Expected scale: prototype, moderate, or production?

Use lettered options:
```
1. What's your target AWS region?
   A. us-east-1 (N. Virginia) - lowest latency for US East
   B. eu-west-1 (Ireland) - good for EU users
   C. ap-southeast-1 (Singapore) - good for Asia-Pacific
   D. Other: [please specify]
```

### Step 2: SAM Resources (2-4 questions per category)

Walk through relevant resource types:
- **Compute:** Lambda functions (runtime, memory, event sources)
- **API:** REST API vs HTTP API, auth method
- **Data:** DynamoDB tables, S3 buckets
- **Messaging:** SQS, SNS, EventBridge (only if relevant)
- **Auth:** Cognito (only if relevant)

### Step 3: Cross-Cutting (1-2 questions)

- Shared config via SAM Globals (runtime, memory, timeout)
- Tracing (X-Ray), logging, tags
- Use SAM policy templates for permissions

### Step 4: Deployment (1-2 questions)

- Stack naming convention
- Environment differences (dev vs prod)
- CI/CD approach

---

## Output

Generate these artifacts:

1. **`specs/infrastructure.md`** - Architecture overview, resource inventory, data flow, security, environment config
2. **`infra/template.yaml`** - Valid SAM template with Globals, Parameters, Resources (each with Description), and Outputs
3. **`infra/samconfig.toml`** - Deployment configuration
4. **`infra/deployer-policy.json`** - IAM policy document with permissions needed to deploy the stack (for the user to attach to Ralph's IAM user before running build)
5. **Update `specs/project-overview.md`** - Add Infrastructure section summary

Then suggest: "Run `./ralph/ralph.sh discover` to generate feature specs."

---

## Style

- 2-4 questions at a time
- Lettered options for quick answers
- Reflect back understanding after each answer
- Be opinionated when user is unsure - suggest SAM best practices
- Use SAM policy templates over raw IAM
- Every resource must have a Description
- Keep the template minimal - only what the project needs
