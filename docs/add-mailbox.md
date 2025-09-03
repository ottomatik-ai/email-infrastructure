# How to Add a Mailbox

## Via IMAP API Web Interface

1. **Access IMAP API**: Go to `http://98.81.118.238:3000`
2. **Click "Add Account"** or "New Mailbox"
3. **Enter Mailbox Details**:
   - **Server**: `imap.migadu.com`
   - **Port**: `993`
   - **Username**: `your-email@yourdomain.com`
   - **Password**: `your-email-password`
   - **Security**: `SSL/TLS`
4. **Click "Add"** or "Save"

## Via API (Bulk Import)

```bash
curl -X POST http://98.81.118.238:3000/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "name": "mailbox-name",
    "email": "email@domain.com",
    "imap": {
      "host": "imap.migadu.com",
      "port": 993,
      "secure": true,
      "auth": {
        "user": "email@domain.com",
        "pass": "password"
      }
    }
  }'
```

## Migadu IMAP Settings

- **IMAP Server**: `imap.migadu.com`
- **Port**: `993` (SSL) or `143` (STARTTLS)
- **Security**: SSL/TLS recommended
- **Authentication**: Username = full email address

## After Adding Mailbox

1. **Test connection** in IMAP API interface
2. **Configure webhook** for n8n integration
3. **Update webhook URLs** in `/webhooks/n8n-webhooks.json`
4. **Document** in client configuration file (e.g., `{slug}-mailboxes.json`)
