# Assistant JSON Contract

## Allowed types
- answer
- ask_for_missing_info
- action_proposal
- action_ready

## Base shape
{
  "type": "answer | ask_for_missing_info | action_proposal | action_ready",
  "reply_text": "string",
  "intent": "general_question | add_reminder | update_reminder | delete_reminder",
  "missing_fields": ["string"],
  "conversation_id": "string optional",
  "action": {
    "name": "add_reminder | update_reminder | delete_reminder",
    "requires_confirmation": true,
    "data": {
      "id": "string optional",
      "title": "string",
      "type": "string",
      "hour": 0,
      "minute": 0,
      "repeat": "daily | weekdays | weekends | once",
      "enabled": true
    }
  },
  "executed": false
}

## Example: ask_for_missing_info
{
  "type": "ask_for_missing_info",
  "reply_text": "أكيد. أي ساعة بدك تذكير أذكار الصباح؟ وهل يتكرر يوميًا؟",
  "intent": "add_reminder",
  "missing_fields": ["hour", "minute", "repeat"]
}

## Example: action_proposal
{
  "type": "action_proposal",
  "reply_text": "تمام، سأضيف تذكير أذكار الصباح الساعة 07:00 يوميًا. اكتب نعم للتأكيد.",
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
  "executed": false
}

## Example: action_ready
{
  "type": "action_ready",
  "reply_text": "تمت إضافة التذكير بنجاح.",
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
  "executed": true
}
