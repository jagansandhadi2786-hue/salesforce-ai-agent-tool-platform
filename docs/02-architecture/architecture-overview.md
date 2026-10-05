# Salesforce AI Agent & Tool-Calling Platform — Architecture Overview

## 1. Purpose

This document describes the architecture of the **Salesforce AI Agent & Tool-Calling Platform**.

The platform provides an enterprise-style customer-service AI agent that can understand natural-language requests, select approved tools, validate tool arguments, enforce authorization, execute Salesforce or external operations, retrieve grounded knowledge, and maintain an auditable execution trail.

The architecture is designed around a fundamental security principle:

> **The LLM recommends actions; Salesforce-controlled application logic determines whether those actions are authorized and executed.**

The LLM is therefore **not treated as the security boundary**.

---

# 2. Architecture Diagram

The high-level architecture is:

```text
                       CUSTOMER SERVICE USER
                                |
                                v
                    +-------------------------+
                    | Salesforce LWC          |
                    | AI Agent Console        |
                    +------------+------------+
                                 |
                                 v
                    +-------------------------+
                    | Agent Controller        |
                    | AI_AgentController      |
                    +------------+------------+
                                 |
                                 v
                    +-------------------------+
                    | Agent Orchestrator      |
                    | AI_AgentOrchestrator    |
                    +------------+------------+
                                 |
                    +------------+-------------+
                    |                          |
                    v                          v
          +-------------------+      +----------------------+
          | Azure OpenAI      |      | Session / Audit      |
          | Tool Calling      |      | Salesforce           |
          +---------+---------+      +----------------------+
                    |
                    v
          +-------------------------+
          | LLM Tool Validator      |
          | Contract / Argument     |
          | Validation              |
          +------------+------------+
                       |
                       v
          +-------------------------+
          | Tool Registry            |
          | Contract + Schema        |
          +------------+------------+
                       |
                       v
          +-------------------------+
          | Authorization            |
          | Approval                 |
          +------------+------------+
                       |
                       v
          +-------------------------+
          | AI Tool Executor         |
          +------------+------------+
                       |
              +--------+--------+----------------+
              |                 |                |
              v                 v                v
      +---------------+  +---------------+  +---------------+
      | Salesforce    |  | Azure AI      |  | External      |
      | Services      |  | Search        |  | REST API      |
      +-------+-------+  +-------+-------+  +-------+-------+
              |                  |                  |
              v                  v                  v
      +---------------+  +---------------+  +---------------+
      | Salesforce    |  | RAG /         |  | Orders /      |
      | Data          |  | Knowledge     |  | CRM           |
      +---------------+  +---------------+  +

# 3. sequence-diagram.png
User → LWC → Apex → AI Orchestrator → Tool Registry → Salesforce/External API/RAG → AI Response → User

# 4. tool-calling-flow.png
User request → Intent detection → Tool selection → Contract validation → Authorization → Risk/confirmation → Tool execution → Result validation → AI response

# 5. deployment-architecture.png
Developer → GitHub → CI/CD → Salesforce DEV → UAT → Production, including security scanning, Apex/LWC tests, AI/RAG evaluation, approvals, and monitoring.     