# Postal Email Sender - Complete Node Configuration Guide

## Overview

This guide provides comprehensive, research-based configuration instructions for each node in the Postal Email Sender workflow, based on official n8n documentation and proven workflow examples from the n8n workflow library.

## Prerequisites

### Required Credentials
1. **Airtable API Token** - For lead management and status updates
2. **Postal API Key** - For email sending via Postal API
3. **Supabase API Credentials** - For message content storage

### Required Airtable Setup
- **Base ID**: `appXXXXXXXXXXXXXX` (replace with your actual base ID)
- **Tables**:
  - `Outbound Leads` - Main leads table
  - `Follow-up Queue` - Follow-up scheduling table
  - `Sending Accounts` - Email account management table

---

## Node-by-Node Configuration

### 1. Manual Trigger Node
**Type**: `n8n-nodes-base.manualTrigger`
**Purpose**: Manual testing and debugging

```json
{
  "type": "n8n-nodes-base.manualTrigger",
  "typeVersion": 1,
  "parameters": {},
  "position": [240, 300]
}
```

**Configuration**:
- **Parameters**: None required
- **Usage**: Click to manually test workflow execution
- **Testing**: Use this to verify workflow logic before enabling scheduled execution

---

### 2. Schedule Trigger Node
**Type**: `n8n-nodes-base.scheduleTrigger`
**Purpose**: Automatic execution during business hours

```json
{
  "type": "n8n-nodes-base.scheduleTrigger",
  "typeVersion": 1.2,
  "parameters": {
    "rule": {
      "interval": [{
        "field": "cronExpression",
        "value": "0 */2 9-17 * * 1-5"
      }]
    }
  },
  "position": [240, 480]
}
```

**Configuration**:
- **Cron Expression**: `0 */2 9-17 * * 1-5`
  - **0**: At minute 0
  - **/2**: Every 2 hours
  - **9-17**: Between 9 AM and 5 PM
  - **1-5**: Monday through Friday
- **Business Hours**: Prevents after-hours sending
- **Frequency**: Runs every 2 hours during business hours

---

### 3. Get Priority Lead Node (Airtable)
**Type**: `n8n-nodes-base.airtable`
**Purpose**: Retrieves highest priority lead from Airtable

```json
{
  "type": "n8n-nodes-base.airtable",
  "typeVersion": 3,
  "parameters": {
    "authentication": "genericCredentialType",
    "genericAuthType": "httpHeaderAuth",
    "operation": "search",
    "base": "appXXXXXXXXXXXXXX",
    "table": "Outbound Leads",
    "filterByFormula": "AND({Lead Status} = 'Queued', OR({Message Type} = 'Reply', AND({Message Type} = 'Initial', {Send Date} <= NOW())))",
    "sort": [
      {"field": "Message Type", "direction": "desc"},
      {"field": "Created Time", "direction": "asc"}
    ],
    "limit": 1
  },
  "credentials": {
    "airtableApi": {
      "id": "airtable-credentials",
      "name": "n8n | ottomatik[ai]"
    }
  },
  "position": [460, 300]
}
```

**Configuration Details**:
- **Operation**: `search` - Query existing records
- **Base**: Replace `appXXXXXXXXXXXXXX` with your actual Airtable base ID
- **Table**: `Outbound Leads` - Your main leads table
- **Filter Formula**: 
  ```
  AND({Lead Status} = 'Queued', OR({Message Type} = 'Reply', AND({Message Type} = 'Initial', {Send Date} <= NOW())))
  ```
  - Only processes leads with status "Queued"
  - Prioritizes "Reply" messages (sent immediately)
  - For "Initial" messages, checks if Send Date has passed
- **Sorting**:
  - Primary: Message Type (Reply first, then Initial)
  - Secondary: Created Time (oldest first)
- **Limit**: 1 - Process one lead at a time
- **Credentials**: Configure Airtable API token

**Required Airtable Fields**:
- `Lead Status` (Single Select): Queued, Sent, Failed
- `Message Type` (Single Select): Reply, Initial, Follow-up
- `Send Date` (Date): When message should be sent
- `Created Time` (Created time): Automatic timestamp
- `Email` (Email): Recipient email address
- `Subject` (Single line text): Email subject
- `HTML Content` (Long text): Email HTML body
- `Plain Text Content` (Long text): Email plain text body
- `Campaign` (Single Select): Campaign identifier
- `Original Sending Account` (Email): For reply tracking

---

### 4. Check Message Priority Node (IF)
**Type**: `n8n-nodes-base.if`
**Purpose**: Routes Reply messages for immediate processing

```json
{
  "type": "n8n-nodes-base.if",
  "typeVersion": 2,
  "parameters": {
    "conditions": {
      "options": {
        "caseSensitive": true,
        "leftValue": "",
        "typeValidation": "strict"
      },
      "conditions": [{
        "id": "condition-1",
        "leftValue": "={{ $json.fields['Message Type'] }}",
        "rightValue": "Reply",
        "operator": {
          "type": "string",
          "operation": "equals"
        }
      }],
      "combinator": "and"
    }
  },
  "position": [680, 300]
}
```

**Configuration Details**:
- **Condition**: Message Type equals "Reply"
- **Case Sensitive**: Yes - Ensures exact matching
- **Type Validation**: Strict - Prevents type conversion issues
- **True Path**: Reply messages (immediate processing)
- **False Path**: Initial messages (normal processing)

---

### 5. Assign Sending Account Node (Code)
**Type**: `n8n-nodes-base.code`
**Purpose**: Assigns appropriate sending account based on message type and campaign

```javascript
// Priority-based sending account assignment
const leadData = $input.first().json;
const messageType = leadData.fields['Message Type'];
const campaignId = leadData.fields['Campaign'];
const originalSender = leadData.fields['Original Sending Account'];

let sendingAccount;
let priority = 'normal';

if (messageType === 'Reply') {
  // Use original sending account for replies
  sendingAccount = originalSender || 'noreply@smarterbdr.com';
  priority = 'high';
} else {
  // Rotate through campaign-assigned accounts for initial messages
  const campaignAccounts = {
    'Q1-SMYKM': ['noreply@smarterbdr.com', 'jeff@smarterbdr.com'],
    'Follow-up-Campaign': ['jeff@smarterbdr.com', 'noreply@smarterbdr.com'],
    'default': ['noreply@smarterbdr.com']
  };
  
  const accounts = campaignAccounts[campaignId] || campaignAccounts['default'];
  // Simple rotation based on timestamp
  const index = Math.floor(Date.now() / 1000) % accounts.length;
  sendingAccount = accounts[index];
  priority = 'normal';
}

return {
  json: {
    ...leadData,
    sending_account: sendingAccount,
    message_priority: priority,
    campaign_id: campaignId,
    message_type: messageType
  }
};
```

**Configuration Details**:
- **Language**: JavaScript
- **Logic**:
  - **Reply Messages**: Use original sending account (maintains email threading)
  - **Initial Messages**: Rotate through campaign-assigned accounts
  - **Account Rotation**: Simple time-based rotation to distribute load
- **Campaign Configuration**: Add new campaigns to `campaignAccounts` object
- **Fallback**: Default account if campaign not found

---

### 6. Build RFC 2822 Message Node (Code)
**Type**: `n8n-nodes-base.code`
**Purpose**: Builds RFC 2822 compliant email message

```javascript
// RFC 2822 Message Builder with Priority Headers
const leadData = $input.first().json;
const messageType = leadData.message_type;
const priority = leadData.message_priority;
const sendingAccount = leadData.sending_account;
const recipientEmail = leadData.fields['Email'];
const subject = leadData.fields['Subject'];
const htmlBody = leadData.fields['HTML Content'];
const plainBody = leadData.fields['Plain Text Content'];
const campaignId = leadData.campaign_id;

// Generate unique message ID
const messageId = `<${Date.now()}-${Math.random().toString(36).substr(2, 9)}@smarterbdr.com>`;

// Get current timestamp in RFC 2822 format
const now = new Date();
const dateHeader = now.toUTCString().replace(/GMT$/, '+0000');

// Build RFC 2822 message
let rfc2822Message = `From: ${sendingAccount}\r\n`;
rfc2822Message += `To: ${recipientEmail}\r\n`;
rfc2822Message += `Subject: ${subject}\r\n`;
rfc2822Message += `Date: ${dateHeader}\r\n`;
rfc2822Message += `Message-ID: ${messageId}\r\n`;
rfc2822Message += `MIME-Version: 1.0\r\n`;

// Custom headers for tracking
rfc2822Message += `X-Campaign-ID: ${campaignId}\r\n`;
rfc2822Message += `X-Message-Type: ${messageType}\r\n`;
rfc2822Message += `X-Source: n8n-workflow\r\n`;

// Add MIME multipart for HTML and plain text
if (htmlBody && plainBody) {
  const boundary = `boundary_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  rfc2822Message += `Content-Type: multipart/alternative; boundary="${boundary}"\r\n\r\n`;
  
  rfc2822Message += `--${boundary}\r\n`;
  rfc2822Message += `Content-Type: text/plain; charset=UTF-8\r\n\r\n`;
  rfc2822Message += `${plainBody}\r\n\r\n`;
  
  rfc2822Message += `--${boundary}\r\n`;
  rfc2822Message += `Content-Type: text/html; charset=UTF-8\r\n\r\n`;
  rfc2822Message += `${htmlBody}\r\n\r\n`;
  
  rfc2822Message += `--${boundary}--\r\n`;
} else if (htmlBody) {
  rfc2822Message += `Content-Type: text/html; charset=UTF-8\r\n\r\n`;
  rfc2822Message += `${htmlBody}\r\n`;
} else {
  rfc2822Message += `Content-Type: text/plain; charset=UTF-8\r\n\r\n`;
  rfc2822Message += `${plainBody || 'No content provided'}\r\n`;
}

return {
  json: {
    ...leadData,
    rfc2822_message: rfc2822Message,
    message_id: messageId,
    postal_payload: {
      rcpt_to: [recipientEmail],
      mail_from: sendingAccount,
      message: rfc2822Message
    }
  }
};
```

**Configuration Details**:
- **RFC 2822 Compliance**: Proper email format with required headers
- **Message ID**: Unique identifier for tracking and threading
- **MIME Multipart**: Supports both HTML and plain text content
- **Custom Headers**: Campaign tracking and message type identification
- **Character Encoding**: UTF-8 for international support
- **Boundary Generation**: Unique boundaries for multipart messages

---

### 7. Send via Postal Node (HTTP Request)
**Type**: `n8n-nodes-base.httpRequest`
**Purpose**: Sends email via Postal API

```json
{
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "parameters": {
    "method": "POST",
    "url": "https://postal.ottomatik.ai/api/v1/send/message",
    "authentication": "genericCredentialType",
    "genericAuthType": "httpHeaderAuth",
    "sendHeaders": true,
    "headerParameters": {
      "parameters": [
        {
          "name": "X-Server-API-Key",
          "value": "={{ $credentials.postalApiKey }}"
        },
        {
          "name": "Content-Type",
          "value": "application/json"
        }
      ]
    },
    "sendBody": true,
    "bodyParameters": {
      "parameters": [
        {
          "name": "rcpt_to",
          "value": "={{ $json.postal_payload.rcpt_to }}"
        },
        {
          "name": "mail_from",
          "value": "={{ $json.postal_payload.mail_from }}"
        },
        {
          "name": "message",
          "value": "={{ $json.postal_payload.message }}"
        }
      ]
    },
    "options": {
      "timeout": 30000,
      "retry": {
        "enabled": true,
        "maxAttempts": 3,
        "waitBetweenAttempts": 2000
      }
    }
  },
  "credentials": {
    "postalApiKey": {
      "id": "postal-api-key",
      "name": "Postal API Key"
    }
  },
  "position": [1340, 300]
}
```

**Configuration Details**:
- **Method**: POST - Required for Postal API
- **URL**: Replace with your Postal server URL
- **Authentication**: HTTP Header Authentication
  - **Header**: `X-Server-API-Key`
  - **Value**: Your Postal API key (stored in credentials)
- **Content-Type**: `application/json`
- **Body Parameters**:
  - `rcpt_to`: Array of recipient email addresses
  - `mail_from`: Sender email address
  - `message`: RFC 2822 formatted message
- **Timeout**: 30 seconds - Prevents hanging requests
- **Retry Logic**: 3 attempts with 2-second delays
- **Error Handling**: Built-in retry for transient failures

**Postal API Requirements**:
- **API Endpoint**: `/api/v1/send/message`
- **Authentication**: X-Server-API-Key header
- **Message Format**: RFC 2822 compliant
- **Response**: JSON with delivery status

---

### 8. Collect Campaign Metrics Node (Code)
**Type**: `n8n-nodes-base.code`
**Purpose**: Collects metrics for tracking and analytics

```javascript
// Campaign Metrics Collection
const leadData = $input.first().json;
const postalResponse = $input.first().json;

const metrics = {
  campaign_id: leadData.campaign_id,
  message_type: leadData.message_type,
  message_priority: leadData.message_priority,
  sending_account: leadData.sending_account,
  recipient_email: leadData.fields['Email'],
  subject: leadData.fields['Subject'],
  message_id: leadData.message_id,
  postal_response: postalResponse,
  sent_at: new Date().toISOString(),
  delivery_status: 'sent',
  response_time_ms: Date.now() - parseInt(leadData.message_id.split('-')[0])
};

return {
  json: {
    ...leadData,
    metrics: metrics
  }
};
```

**Configuration Details**:
- **Metrics Collected**:
  - Campaign and message type information
  - Sending account and recipient details
  - Postal API response data
  - Timestamps and delivery status
  - Response time calculation
- **Data Structure**: Organized for easy analysis and reporting
- **Timestamp**: ISO 8601 format for consistency

---

### 9. Update Lead Status Node (Code)
**Type**: `n8n-nodes-base.code`
**Purpose**: Calculates next message send date and prepares status updates

```javascript
// Update Lead Status and Calculate Next Message Send Date
const leadData = $input.first().json;
const messageType = leadData.message_type;
const campaignId = leadData.campaign_id;

// Define follow-up delays by campaign and message type
const followUpDelays = {
  'Q1-SMYKM': {
    'Initial': 3, // days after initial message
    'Reply': 1, // days after reply
    'Follow-up': 7 // days between follow-ups
  },
  'Follow-up-Campaign': {
    'Initial': 5,
    'Reply': 2,
    'Follow-up': 10
  },
  'default': {
    'Initial': 3,
    'Reply': 1,
    'Follow-up': 7
  }
};

const delays = followUpDelays[campaignId] || followUpDelays['default'];
const delayDays = delays[messageType] || delays['Follow-up'];

// Calculate next message send date
const nextMessageDate = new Date();
nextMessageDate.setDate(nextMessageDate.getDate() + delayDays);

return {
  json: {
    ...leadData,
    next_message_send_date: nextMessageDate.toISOString().split('T')[0], // YYYY-MM-DD format
    update_fields: {
      "Lead Status": "Sent",
      "Sent At": leadData.metrics.sent_at,
      "Postal Message ID": leadData.metrics.message_id,
      "Sending Account": leadData.metrics.sending_account,
      "Delivery Status": leadData.metrics.delivery_status
    }
  }
};
```

**Configuration Details**:
- **Campaign-Specific Delays**: Different delays per campaign and message type
- **Date Calculation**: Adds delay days to current date
- **Status Updates**: Prepares fields for Airtable update
- **Date Format**: YYYY-MM-DD for Airtable compatibility
- **Flexibility**: Easy to modify delays for different campaigns

---

### 10. Log to Supabase Node (Supabase)
**Type**: `n8n-nodes-base.supabase`
**Purpose**: Stores comprehensive message content in Supabase

```json
{
  "type": "n8n-nodes-base.supabase",
  "typeVersion": 1,
  "parameters": {
    "operation": "insert",
    "table": "message_content",
    "columns": {
      "message_id": "={{ $json.metrics.message_id }}",
      "campaign_id": "={{ $json.metrics.campaign_id }}",
      "message_type": "={{ $json.metrics.message_type }}",
      "sending_account": "={{ $json.metrics.sending_account }}",
      "recipient_email": "={{ $json.metrics.recipient_email }}",
      "subject": "={{ $json.metrics.subject }}",
      "html_content": "={{ $json.fields['HTML Content'] }}",
      "plain_content": "={{ $json.fields['Plain Text Content'] }}",
      "rfc2822_message": "={{ $json.rfc2822_message }}",
      "postal_response": "={{ $json.metrics.postal_response }}",
      "sent_at": "={{ $json.metrics.sent_at }}",
      "delivery_status": "={{ $json.metrics.delivery_status }}",
      "lead_id": "={{ $json.fields['id'] }}",
      "client_id": "={{ $json.fields['Client ID'] || 'default' }}"
    }
  },
  "credentials": {
    "supabaseApi": {
      "id": "supabase-credentials",
      "name": "Supabase API"
    }
  },
  "position": [1780, 200]
}
```

**Configuration Details**:
- **Operation**: `insert` - Create new record
- **Table**: `message_content` - Main message storage table
- **Columns**: Maps workflow data to Supabase columns
- **Multi-tenant**: Uses `client_id` for data isolation
- **Full Content**: Stores complete message content and metadata
- **Credentials**: Configure Supabase API credentials

**Required Supabase Table Schema**:
```sql
CREATE TABLE message_content (
  id BIGSERIAL PRIMARY KEY,
  message_id TEXT UNIQUE NOT NULL,
  campaign_id TEXT NOT NULL,
  message_type TEXT NOT NULL,
  sending_account TEXT NOT NULL,
  recipient_email TEXT NOT NULL,
  subject TEXT NOT NULL,
  html_content TEXT,
  plain_content TEXT,
  rfc2822_message TEXT NOT NULL,
  postal_response JSONB,
  sent_at TIMESTAMP WITH TIME ZONE NOT NULL,
  delivery_status TEXT NOT NULL DEFAULT 'sent',
  lead_id TEXT NOT NULL,
  client_id TEXT NOT NULL DEFAULT 'default',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

### 11. Update Airtable Status Node (Airtable)
**Type**: `n8n-nodes-base.airtable`
**Purpose**: Updates lead status in Airtable after successful send

```json
{
  "type": "n8n-nodes-base.airtable",
  "typeVersion": 3,
  "parameters": {
    "operation": "update",
    "base": "appXXXXXXXXXXXXXX",
    "table": "Outbound Leads",
    "id": "={{ $json.fields['id'] }}",
    "fieldsToSend": "defined",
    "fields": {
      "Lead Status": "={{ $json.update_fields['Lead Status'] }}",
      "Sent At": "={{ $json.update_fields['Sent At'] }}",
      "Postal Message ID": "={{ $json.update_fields['Postal Message ID'] }}",
      "Sending Account": "={{ $json.update_fields['Sending Account'] }}",
      "Delivery Status": "={{ $json.update_fields['Delivery Status'] }}"
    }
  },
  "credentials": {
    "airtableApi": {
      "id": "airtable-credentials",
      "name": "n8n | ottomatik[ai]"
    }
  },
  "position": [2000, 200]
}
```

**Configuration Details**:
- **Operation**: `update` - Modify existing record
- **Record ID**: Uses Airtable record ID from previous query
- **Fields**: Updates status and tracking information
- **Fields to Send**: `defined` - Only specified fields are updated
- **Status Tracking**: Records send timestamp and delivery status

---

### 12. Schedule Follow-ups Node (Code)
**Type**: `n8n-nodes-base.code`
**Purpose**: Schedules follow-up messages based on campaign rules

```javascript
// Follow-up Scheduler with Priority Logic
const leadData = $input.first().json;
const messageType = leadData.message_type;
const campaignId = leadData.campaign_id;

// Define follow-up schedules by campaign and message type
const followUpSchedules = {
  'Q1-SMYKM': {
    'Initial': [3, 7, 14], // days after initial message
    'Reply': [1, 3, 7] // days after reply
  },
  'Follow-up-Campaign': {
    'Initial': [5, 10, 21],
    'Reply': [2, 5, 10]
  },
  'default': {
    'Initial': [3, 7, 14],
    'Reply': [1, 3, 7]
  }
};

const schedule = followUpSchedules[campaignId] || followUpSchedules['default'];
const delays = schedule[messageType] || schedule['Initial'];

// Generate follow-up tasks
const followUpTasks = delays.map((delayDays, index) => {
  const followUpDate = new Date();
  followUpDate.setDate(followUpDate.getDate() + delayDays);
  
  return {
    lead_id: leadData.fields['id'],
    campaign_id: campaignId,
    message_type: messageType,
    follow_up_sequence: index + 1,
    scheduled_date: followUpDate.toISOString(),
    sending_account: leadData.sending_account,
    priority: messageType === 'Reply' ? 'high' : 'normal',
    original_message_id: leadData.message_id
  };
});

return {
  json: {
    ...leadData,
    follow_up_tasks: followUpTasks
  }
};
```

**Configuration Details**:
- **Campaign-Specific Schedules**: Different follow-up timing per campaign
- **Message Type Logic**: Different schedules for Initial vs Reply
- **Priority Assignment**: High priority for reply follow-ups
- **Task Generation**: Creates multiple follow-up tasks per lead
- **Date Calculation**: Schedules follow-ups based on campaign rules

---

### 13. Queue Follow-up Node (Airtable)
**Type**: `n8n-nodes-base.airtable`
**Purpose**: Creates follow-up queue entries in Airtable

```json
{
  "type": "n8n-nodes-base.airtable",
  "typeVersion": 3,
  "parameters": {
    "operation": "create",
    "base": "appXXXXXXXXXXXXXX",
    "table": "Follow-up Queue",
    "fieldsToSend": "defined",
    "fields": {
      "Lead ID": "={{ $json.follow_up_tasks[0].lead_id }}",
      "Campaign ID": "={{ $json.follow_up_tasks[0].campaign_id }}",
      "Message Type": "={{ $json.follow_up_tasks[0].message_type }}",
      "Follow-up Sequence": "={{ $json.follow_up_tasks[0].follow_up_sequence }}",
      "Scheduled Date": "={{ $json.follow_up_tasks[0].scheduled_date }}",
      "Sending Account": "={{ $json.follow_up_tasks[0].sending_account }}",
      "Priority": "={{ $json.follow_up_tasks[0].priority }}",
      "Original Message ID": "={{ $json.follow_up_tasks[0].original_message_id }}",
      "Status": "Scheduled"
    }
  },
  "credentials": {
    "airtableApi": {
      "id": "airtable-credentials",
      "name": "n8n | ottomatik[ai]"
    }
  },
  "position": [2220, 300]
}
```

**Configuration Details**:
- **Operation**: `create` - Create new records
- **Table**: `Follow-up Queue` - Follow-up scheduling table
- **Fields**: Maps follow-up task data to Airtable fields
- **Status**: Sets initial status to "Scheduled"
- **Task Selection**: Uses first follow-up task from array

**Required Airtable Table: Follow-up Queue**
- `Lead ID` (Link to Outbound Leads): References main lead
- `Campaign ID` (Single line text): Campaign identifier
- `Message Type` (Single Select): Follow-up, Reply, etc.
- `Follow-up Sequence` (Number): Sequence number (1, 2, 3...)
- `Scheduled Date` (Date & Time): When to send follow-up
- `Sending Account` (Email): Account to use for sending
- `Priority` (Single Select): High, Normal, Low
- `Original Message ID` (Single line text): For threading
- `Status` (Single Select): Scheduled, Sent, Failed

---

### 14. Check Success Node (IF)
**Type**: `n8n-nodes-base.if`
**Purpose**: Routes workflow based on send success/failure

```json
{
  "type": "n8n-nodes-base.if",
  "typeVersion": 2,
  "parameters": {
    "conditions": {
      "options": {
        "caseSensitive": true,
        "leftValue": "",
        "typeValidation": "strict"
      },
      "conditions": [{
        "id": "condition-1",
        "leftValue": "={{ $json.metrics.delivery_status }}",
        "rightValue": "sent",
        "operator": {
          "type": "string",
          "operation": "equals"
        }
      }],
      "combinator": "and"
    }
  },
  "position": [2440, 300]
}
```

**Configuration Details**:
- **Condition**: Delivery Status equals "sent"
- **Case Sensitive**: Yes - Ensures exact matching
- **Type Validation**: Strict - Prevents type conversion
- **True Path**: Success flow (workflow completes)
- **False Path**: Error handling flow

---

### 15. Update Error Status Node (Airtable)
**Type**: `n8n-nodes-base.airtable`
**Purpose**: Updates lead status when send fails

```json
{
  "type": "n8n-nodes-base.airtable",
  "typeVersion": 3,
  "parameters": {
    "operation": "update",
    "base": "appXXXXXXXXXXXXXX",
    "table": "Outbound Leads",
    "id": "={{ $json.fields['id'] }}",
    "fieldsToSend": "defined",
    "fields": {
      "Lead Status": "Failed",
      "Error Message": "={{ $json.postal_response.error || 'Unknown error' }}",
      "Failed At": "={{ $now }}"
    }
  },
  "credentials": {
    "airtableApi": {
      "id": "airtable-credentials",
      "name": "n8n | ottomatik[ai]"
    }
  },
  "position": [2440, 480]
}
```

**Configuration Details**:
- **Operation**: `update` - Modify existing record
- **Status**: Sets lead status to "Failed"
- **Error Message**: Captures Postal API error details
- **Timestamp**: Records failure time
- **Error Handling**: Provides fallback for unknown errors

**Required Airtable Fields**:
- `Error Message` (Long text): Error details from Postal API
- `Failed At` (Date & Time): When the failure occurred

---

## Workflow Connections

### Main Flow
```
Manual/Schedule Trigger → Get Priority Lead → Check Message Priority → 
Assign Sending Account → Build RFC 2822 Message → Send via Postal → 
Collect Campaign Metrics → Update Lead Status → Log to Supabase → 
Update Airtable Status → Check Success
```

### Success Path
```
Check Success (true) → Workflow Complete
```

### Error Path
```
Check Success (false) → Update Error Status
```

### Follow-up Path
```
Update Lead Status → Schedule Follow-ups → Queue Follow-up
```

---

## Setup Checklist

### 1. Credentials Configuration
- [ ] **Airtable API Token**: Create and configure in n8n
- [ ] **Postal API Key**: Create and configure in n8n
- [ ] **Supabase API**: Create project and configure credentials

### 2. Airtable Setup
- [ ] **Base Creation**: Create Airtable base with required tables
- [ ] **Field Configuration**: Set up all required fields with correct types
- [ ] **Permission Setup**: Ensure n8n has read/write access
- [ ] **Base ID**: Update all base IDs in workflow nodes

### 3. Supabase Setup
- [ ] **Project Creation**: Create Supabase project
- [ ] **Table Creation**: Run SQL schema to create tables
- [ ] **Index Creation**: Create performance indexes
- [ ] **API Configuration**: Generate API keys and configure

### 4. Postal Setup
- [ ] **Server Configuration**: Set up Postal server
- [ ] **API Key Generation**: Create API key for n8n
- [ ] **Domain Configuration**: Configure sending domains
- [ ] **Webhook Setup**: Configure webhooks for delivery tracking

### 5. Workflow Testing
- [ ] **Manual Testing**: Test with Manual Trigger
- [ ] **Data Validation**: Verify data flows correctly
- [ ] **Error Handling**: Test failure scenarios
- [ ] **Performance Testing**: Verify workflow performance

---

## Troubleshooting

### Common Issues

#### 1. Airtable Connection Errors
- **Check API Token**: Ensure token has correct permissions
- **Verify Base ID**: Confirm base ID is correct
- **Field Names**: Ensure field names match exactly (case-sensitive)
- **Rate Limits**: Check Airtable rate limit usage

#### 2. Postal API Errors
- **API Key**: Verify API key is correct and active
- **Server URL**: Confirm Postal server URL is accessible
- **Message Format**: Ensure RFC 2822 format is correct
- **Authentication**: Check X-Server-API-Key header

#### 3. Supabase Connection Issues
- **Project URL**: Verify Supabase project URL
- **API Key**: Check API key permissions
- **Table Schema**: Ensure tables exist with correct schema
- **Row Level Security**: Check RLS policies if enabled

#### 4. Workflow Execution Issues
- **Node Connections**: Verify all nodes are properly connected
- **Data Flow**: Check data structure between nodes
- **Error Handling**: Ensure error paths are configured
- **Credentials**: Verify all credentials are configured

### Performance Optimization

#### 1. Airtable Optimization
- **Field Selection**: Only query necessary fields
- **Filter Optimization**: Use efficient filter formulas
- **Batch Operations**: Group multiple updates when possible
- **Rate Limiting**: Respect Airtable rate limits

#### 2. Postal API Optimization
- **Connection Pooling**: Reuse HTTP connections
- **Timeout Configuration**: Set appropriate timeouts
- **Retry Logic**: Implement exponential backoff
- **Error Handling**: Handle different error types appropriately

#### 3. Supabase Optimization
- **Index Usage**: Ensure queries use indexes
- **Batch Inserts**: Group multiple inserts
- **Connection Limits**: Monitor connection usage
- **Query Optimization**: Use efficient queries

---

## Security Considerations

### 1. Credential Security
- **API Keys**: Store in n8n credential system
- **Access Control**: Limit API key permissions
- **Rotation**: Regularly rotate API keys
- **Monitoring**: Monitor credential usage

### 2. Data Security
- **Encryption**: Ensure data is encrypted in transit
- **Access Control**: Implement proper access controls
- **Audit Logging**: Log all data access
- **Backup**: Regular data backups

### 3. Workflow Security
- **Input Validation**: Validate all inputs
- **Error Handling**: Don't expose sensitive data in errors
- **Rate Limiting**: Implement rate limiting
- **Monitoring**: Monitor for suspicious activity

---

## Maintenance

### 1. Regular Tasks
- **Credential Rotation**: Monthly API key rotation
- **Performance Monitoring**: Weekly performance checks
- **Error Review**: Daily error log review
- **Data Cleanup**: Monthly old data cleanup

### 2. Updates
- **n8n Updates**: Keep n8n updated
- **Node Updates**: Update custom nodes
- **Security Patches**: Apply security patches
- **Feature Updates**: Review new features

### 3. Monitoring
- **Success Rates**: Monitor email delivery success
- **Performance Metrics**: Track workflow performance
- **Error Rates**: Monitor error frequencies
- **Resource Usage**: Monitor system resources

---

This configuration guide provides comprehensive instructions for setting up and maintaining the Postal Email Sender workflow with proper error handling, performance optimization, and security considerations.
