# Yusr Assistant: Complete Overview and How It Works

## 1. What Yusr Assistant Is
Yusr Assistant is an in-app AI assistant designed to help users manage reminders and religious routines through natural chat.

It does not only answer text questions; it can also execute real reminder operations against the database (create, update, delete, and read) with reliable validation.

## 2. Main Goal
The assistant's goal is to provide a natural Arabic-first conversational experience while keeping backend execution accurate, safe, and auditable.

## 3. Core Architecture
Yusr Assistant is built from four connected layers:

1. Flutter App (Client)
- Chat interface for user interaction.
- State management with Cubit.
- Data layer that sends requests to n8n webhook and parses responses robustly.

2. n8n Workflow (Orchestration)
- Receives incoming chat payloads.
- Sends prompts to the LLM.
- Parses and normalizes model output.
- Routes requests by intent type.
- Executes Supabase operations when needed.
- Returns a final structured response to Flutter.

3. Supabase (Data Layer)
- Stores user reminders.
- Handles reminder CRUD operations.
- Enforces user scoping through user_id in every operation.

4. LLM (Reasoning Layer)
- Understands user intent from natural language.
- Produces structured JSON responses using a strict contract.

## 4. Response Contract (Structured Output Types)
The assistant uses strict response types so Flutter and n8n can behave predictably:

1. answer
- Used when the assistant only needs to reply with information.
- No database execution is required.

2. ask_for_missing_info
- Used when required fields are missing.
- The assistant asks targeted follow-up questions before any action.

3. action_proposal
- Used when the assistant proposes an action and may need user confirmation.

4. action_ready
- Used after action execution attempt.
- Includes execution result (`executed: true/false`) and user-facing message.

## 5. End-to-End Workflow
1. User sends a message in Flutter chat.
2. Flutter sends payload (including user_id and text) to n8n webhook.
3. n8n passes context to the LLM for intent understanding.
4. LLM returns structured JSON.
5. n8n parses output and routes it to the correct branch.
6. If action is needed, n8n runs Supabase node(s).
7. n8n validates database result:
- Success only if matching/affected rows exist.
- Failure if nothing matched or an error occurred.
8. n8n returns final normalized response to Flutter.
9. Flutter displays the final message in the chat UI.

## 6. Reminder Action Logic
### Create Reminder
- Requires enough data (for example title and time).
- Inserts a new reminder row for the current user.

### Update Reminder
Supports two matching strategies:

1. By id (preferred)
- If a valid reminder id exists, update by id + user_id.

2. By fallback criteria (when id is missing)
- Match using user_id and current reminder attributes (for example title + current_hour + current_minute).
- Then apply new values (for example new_hour/new_minute/new_title).

Validation notes:
- Literal invalid id values (such as "undefined" or "null") are rejected as ids.
- The workflow avoids sending invalid UUID filters to Supabase.

### Delete Reminder
Uses the same safe strategy:

1. Delete by id + user_id if id is valid.
2. Otherwise, fallback match by current reminder attributes.

### Read/List Reminders
- Reads reminders filtered by user_id.
- Returns user-specific rows only.

## 7. Reliability and Safety Mechanisms
1. Strict JSON contract between LLM and workflow.
2. Robust parsing in Flutter and n8n for different LLM output shapes.
3. User isolation enforced by user_id in all DB operations.
4. No false success responses:
- "Updated" and "Deleted" are returned only when rows are truly affected.
5. Graceful fallback when id is not available.
6. Defensive filtering to prevent UUID syntax errors.

## 8. Typical Examples
1. "Remind me tomorrow at 7:30 to read Surah Al-Kahf."
- Assistant creates reminder and confirms success.

2. "Change my wird reminder from 8:00 to 9:00."
- Assistant updates via id if available.
- If id is unavailable, it matches current values and applies new values.

3. "Delete my water reminder at 10:00."
- Assistant deletes by id or fallback match.
- Returns success only if a row was actually deleted.

4. "What is the best time for morning adhkar?"
- Informational answer only, no DB action.

## 9. Why This Design Works
1. Natural conversation for users.
2. Deterministic backend behavior for developers.
3. Reduced runtime errors through defensive logic.
4. Honest execution reporting (no fake success).
5. Easy to extend with new tools and action types.

## 10. Extension Opportunities
1. Add prayer-time aware reminder suggestions.
2. Add multi-step plans (for example, morning routine bundles).
3. Add personalization from user history.
4. Add analytics for action success/failure patterns.

---
If needed, this document can be split into:
- Product version (non-technical).
- Engineering version (node-by-node n8n mapping).
- QA checklist version (test scenarios and expected outputs).
