# Active Webhook URLs

## ottomatik.ai Webhooks

| Webhook Name | URL | Purpose | Status |
|--------------|-----|---------|--------|
| ottomatik-contact | `http://your-n8n-instance/webhook/ottomatik-contact` | Process contact emails | Active |
| ottomatik-support | `http://your-n8n-instance/webhook/ottomatik-support` | Process support emails | Active |

## Client Webhooks

| Client | Webhook Name | URL | Purpose | Status |
|--------|--------------|-----|---------|--------|
| Client A | client-a-contact | `http://your-n8n-instance/webhook/client-a-contact` | Process client A emails | Active |
| Client B | client-b-contact | `http://your-n8n-instance/webhook/client-b-contact` | Process client B emails | Active |

## Webhook Management

### Adding New Webhook
1. Create webhook in n8n
2. Add entry to this table
3. Update `/webhooks/n8n-webhooks.json`
4. Configure in IMAP API

### Removing Webhook
1. Disable in IMAP API
2. Remove from n8n workflow
3. Remove entry from this table
4. Update `/webhooks/n8n-webhooks.json`

## Notes
- Replace `your-n8n-instance` with actual n8n URL
- Update status when webhooks are added/removed
- Keep this file synchronized with actual webhook configurations








