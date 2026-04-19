# End-to-End Example

## Workflow files
1. `n8n/yusr-assistant-basic-chain.json`
  - Compact version with one shared execution path for add/update/delete.
2. `n8n/yusr-assistant-basic-chain-split-actions.json`
  - Recommended when you want clearer maintenance and observability.
  - Each operation has dedicated nodes:
    - Execute Add Reminder -> Finalize Add Response
    - Execute Update Reminder -> Finalize Update Response
    - Execute Delete Reminder -> Finalize Delete Response

## User scenario
User: "ضيفلي أذكار الصباح عالتذكيرات"

## Full flow
1. Flutter Chat UI sends payload to n8n webhook with:
   - user_id
   - message
   - conversation_id
   - history
2. n8n prepares prompt input and calls LLM.
3. LLM returns JSON type ask_for_missing_info because time/repeat are missing.
4. Flutter shows assistant question.
5. User replies: "خليها 7 الصبح يوميًا".
6. n8n calls LLM again with history.
7. LLM returns action_proposal with normalized data.
8. Flutter shows confirmation proposal.
9. User replies: "نعم".
10. LLM returns action_ready.
11. n8n executes Supabase INSERT into public.reminders.
12. n8n responds with executed=true and success message.
13. Flutter appends assistant success bubble.

## Example payload from Flutter
{
  "user_id": "3dca7f2f-4cb4-4c22-9e7e-62f50c3be990",
  "message": "ضيفلي أذكار الصباح عالتذكيرات",
  "conversation_id": "conv_1744531001",
  "locale": "ar",
  "timezone": "Asia/Riyadh",
  "history": []
}

## Example success response to Flutter
{
  "type": "action_ready",
  "reply_text": "تمت إضافة تذكير أذكار الصباح الساعة 07:00 يوميًا.",
  "intent": "add_reminder",
  "action": {
    "name": "add_reminder",
    "requires_confirmation": true,
    "data": {
      "title": "أذكار الصباح",
      "type": "adhkar",
      "hour": 7,
      "minute": 0,
      "repeat": "daily",
      "enabled": true
    }
  },
  "executed": true,
  "conversation_id": "conv_1744531001"
}
