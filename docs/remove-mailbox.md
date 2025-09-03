# How to Remove a Mailbox

## Via IMAP API Web Interface

1. **Access IMAP API**: Go to `http://98.81.118.238:3000`
2. **Find the mailbox** in the accounts list
3. **Click "Delete"** or "Remove" button
4. **Confirm deletion**

## Via API

```bash
curl -X DELETE http://98.81.118.238:3000/api/accounts/{account-id}
```

## Cleanup Steps

After removing a mailbox:

1. **Remove webhook configuration** from n8n
2. **Update webhook URLs** in `/webhooks/n8n-webhooks.json`
3. **Remove from client configuration** file (e.g., `{slug}-mailboxes.json`)
4. **Update documentation**

## Important Notes

- **Data loss**: Removing a mailbox will delete all stored email data
- **Webhooks**: Disable associated webhooks before removal
- **Backup**: Consider backing up important emails before removal
