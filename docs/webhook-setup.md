# Webhook Setup for n8n Integration

## Overview

IMAP API can send webhooks to n8n when new emails arrive, enabling automated email processing workflows.

## Setting Up Webhooks

### 1. Create n8n Webhook Node

In your n8n workflow:
1. **Add Webhook node**
2. **Set HTTP Method** to `POST`
3. **Copy the webhook URL**

### 2. Configure IMAP API Webhook

1. **Access IMAP API**: `http://98.81.118.238:3000`
2. **Go to mailbox settings**
3. **Add webhook URL**:
   ```
   http://your-n8n-instance/webhook/your-webhook-id
   ```
4. **Set webhook events**:
   - New messages
   - Message updates
   - Message deletions

### 3. Webhook Payload Structure

IMAP API sends this data to n8n:

```json
{
  "event": "newMessage",
  "account": "mailbox-name",
  "message": {
    "id": "message-id",
    "subject": "Email Subject",
    "from": "sender@domain.com",
    "to": "recipient@domain.com",
    "date": "2025-01-01T00:00:00Z",
    "body": "Email content...",
    "attachments": []
  }
}
```

## Active Webhook URLs

Track your webhook URLs in `/webhooks/n8n-webhooks.json`:

```json
{
  "name": "webhook-name",
  "url": "http://your-n8n-instance/webhook/webhook-id",
  "purpose": "Description of what this webhook does",
  "mailbox": "email@domain.com",
  "status": "active"
}
```

## Testing Webhooks

1. **Send test email** to monitored mailbox
2. **Check n8n workflow** for webhook trigger
3. **Verify payload** contains expected data
4. **Test error handling** for failed webhooks

## Troubleshooting

- **Webhook not firing**: Check IMAP API logs
- **n8n not receiving**: Verify webhook URL is correct
- **Authentication issues**: Check n8n webhook security settings








