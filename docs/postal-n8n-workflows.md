# Postal n8n Workflow System

## 🚀 Overview

This system consists of **three separate n8n workflows** that work together to send emails via Postal with reliable follow-up scheduling, smart bounce handling, and centralized error management.

## 📧 REPLY HANDLING (SEPARATE WORKFLOW)

**Important**: Reply handling is NOT handled by this workflow. Replies are processed by a separate **Inbox Management Workflow** that:

- Receives Postal webhooks when replies are detected
- Performs sentiment analysis on incoming replies  
- Generates appropriate responses using AI (FUL, R, NI, NB, AUC response types)
- Routes responses through Human-in-the-Loop (HITL) approval
- Sends approved replies back to Postal for delivery

This separation ensures:
- **Immediate reply processing** (no waiting for scheduled triggers)
- **AI-powered response generation** with sentiment analysis
- **Quality control** through HITL approval
- **Clean workflow separation** between outbound sequences and reply management

**Integration**: This main workflow focuses solely on email sequences (email1-email5), while the Inbox Management workflow handles all reply processing and response generation.

## 📋 Workflow Architecture

### **1. Main Email Sender Workflow**
**File:** `Postal_Email_Sender_Clean.json`

**Purpose:** Sends email sequences (email1-email5) to Postal with smart error handling

**Detailed Node Flow:**
1. **Manual/Schedule Trigger** → Process queued leads
2. **Get Priority Lead** → Fetch highest priority lead from Airtable (Priority asc, Created Time asc)
3. **Check Daily Limits** → Verify available accounts haven't exceeded daily limits
4. **Validate Account Availability** → Check if any accounts are available
5. **Check Accounts Available** → Stop workflow if all accounts at daily limit
6. **Assign Sending Account** → Query Sending Accounts table for available account
7. **Merge Account Data** → Determine sending account based on Message Type (email1 vs follow-ups)
8. **Format Message Content** → Process raw content for RFC 2822 plain text and HTML
9. **Build RFC 2822 Message** → Format complete email message with campaign headers and threading
10. **Send via Postal** → Submit to Postal API with 5-retry logic
11. **Collect Campaign Metrics** → Track performance data and response times
12. **Update Lead Status** → Mark as "Sent to Postal" with timestamps
13. **Update Last Used Timestamp** → Record when sending account was used
14. **Update Sent Today Counter** → Increment daily counter for sending account
15. **Update Last Contacted Date** → Record when lead was contacted
16. **Check if Sequence Complete** → Determine if this was the final message
17. **Route Sequence Completion** → Route to completion or continue
18. **Mark Sequence Complete** → Update to "Done" status if sequence finished
19. **Check Success** → Verify Postal acceptance
20. **Update Error Status** → Mark as "Retrying" with tomorrow's send date for failed sends
21. **Send Error to Error Workflow** → Notify error handler for failed sends
22. **Stop Workflow - Daily Limits Reached** → Stop when all accounts exhausted

**Key Features:**
- ✅ **Sequence-only processing** (email1-email5, no reply handling)
- ✅ **RFC 2822 compliant** message formatting with email threading
- ✅ **Campaign tracking** with custom headers
- ✅ **Smart error handling** (delay to tomorrow, stays "Queued")
- ✅ **Daily limit enforcement** with workflow stopping
- ✅ **Account rotation** for email1, original sender for follow-ups

### **2. Postal Webhook Handler Workflow**
**File:** `Postal_Webhook_Handler.json`

**Purpose:** Handles Postal webhooks and schedules follow-ups

**Detailed Node Flow:**
1. **Postal Webhook** → Receive delivery confirmations and bounce notifications
2. **Route Event Type** → Route DeliverySucceeded events to success handling
3. **Route Bounce Events** → Route MessageBounced events to bounce handling
4. **Handle Delivery Success** → Extract Record ID and prepare lead lookup
5. **Find Lead by Message ID** → Direct record lookup using Record ID
6. **Determine Follow-up Action** → Check if campaign complete or schedule next message
7. **Route Action** → Route to schedule next or mark complete
8. **Schedule Next Message** → Update next message with send date and status
9. **Mark Campaign Complete** → Update lead when sequence finished
10. **Handle Bounce Events** → Smart bounce strategy with reputation protection
11. **Find Bounced Lead** → Direct record lookup using Record ID
12. **Check Retry Count** → Route retry vs invalid based on bounce type
13. **Retry Logic** → Determine if retry allowed or mark soft bounce
14. **Mark as Invalid Email** → Mark reputation killer bounces as invalid
15. **Schedule Retry** → Schedule retry for safe bounce types
16. **Mark as Soft Bounce** → Mark retry limit exceeded bounces
17. **Webhook Response** → Send response back to Postal

**Key Features:**
- ✅ **Delivery confirmation** before scheduling follow-ups
- ✅ **Smart bounce handling** with reputation protection
- ✅ **Campaign completion** detection
- ✅ **Follow-up sequencing** with proper delays

## 🛡️ Smart Bounce Strategy

### **NEVER Retry (Reputation Killers):**
- `content_rejected` → Mark as Invalid Email
- `greylisted` → Mark as Invalid Email  
- `blocked` → Mark as Invalid Email
- **Any hard bounce** → Mark as Invalid Email

### **Safe to Retry (Limited):**
- `mailbox_full` → Retry once in 48 hours
- `temporary_failure` → Retry once in 24 hours
- `rate_limited` → Retry once in 2 hours

## 📊 Required Airtable Fields

### **Outbound Leads Table:**
- `Lead Status` - "Queued" | "Sent to Postal" | "Delivered" | "Campaign Complete" | "Invalid Email" | "Soft Bounce"
- `Message Type` - "email1" | "email2" | "email3" | "email4" | "email5" | "Done"
- `Priority` - 2 (email1) | 3 (email2) | 4 (email3) | 5 (email4) | 6 (email5) | 7 (Done)
- `Campaign` - Campaign identifier (linked to Sending Accounts table)
- `Email` - Recipient email address
- `Subject` - Email subject line
- `HTML Content` - HTML email content
- `Plain Text Content` - Plain text email content
- `Send Date` - When message should be sent (YYYY-MM-DD)
- `Message Sequence` - Current message number in campaign
- `Total Campaign Messages` - Total messages in campaign sequence
- `Next Message ID` - Airtable ID of next message in sequence
- `Original Sending Account` - **CRITICAL**: Original sender for reply/follow-up consistency (MUST be used for Replies and Follow-ups)
- `Original Message ID` - **CRITICAL**: email1 Message ID for email threading (MUST be used for email2-email5 and Replies)
- `Sending Account` - Current sending account
- `Postal Message ID` - Message ID from Postal
- `Sent At` - Timestamp when sent
- `Delivery Status` - "accepted_by_postal" | "delivered" | "bounced"
- `Bounce Type` - "soft" | "hard" | null
- `Bounce Reason` - Detailed bounce reason from Postal
- `Bounce Details` - Human-readable bounce description
- `Bounce Date` - When bounce occurred
- `Retry Count` - Number of retry attempts
- `Retry Date` - When to retry
- `Error Message` - Technical error details from Postal API
- `Error Count` - Number of consecutive failed attempts
- `Last Error Date` - Timestamp of last error
- `Error` - Detailed error message (same as Pushover notification) - **ACCUMULATES** multiple error entries with separator
- `Campaign Completion Date` - When the entire campaign sequence was completed
- `Last Contacted Date` - When the lead was last contacted (any message type)
- `email2_content` - Long text field (email2 content, empty if sequence ends after email1)
- `email3_content` - Long text field (email3 content, empty if sequence ends after email2)
- `email4_content` - Long text field (email4 content, empty if sequence ends after email3)
- `email5_content` - Long text field (email5 content, empty if sequence ends after email4)

### **Sending Accounts Table:**
- `Email Address` - The sending email address (primary field)
- `Campaigns` - Multiple select field of campaigns this account can send for
- `Status` - "Active" | "Paused" | "Suspended"
- `Daily Limit` - Maximum emails per day for this account
- `Sent Today` - Count of emails sent today (updated by workflow, resets daily at midnight)
- `Last Used` - Precise timestamp of last email sent (YYYY-MM-DD HH:MM:SS format)
- `Rotation Priority` - Number for load balancing (1 = highest priority)
- `Invalid Email` - Boolean flag for invalid emails
- `Campaign Status` - "Active" | "Complete" | "Paused"
- `Completed At` - When campaign completed

## ⚠️ CRITICAL SENDING ACCOUNT RULES

### **Follow-up Messages (email2-email5):**
- **MUST use Original Sending Account** from the lead record
- **NO rotation allowed** - maintains conversation thread consistency
- **RESPECT daily limits** - follows normal daily limit rules

### **Initial Messages:**
- **Use account rotation** from Sending Accounts table
- **Load balanced** by Rotation Priority and Last Used timestamp
- **RESPECT daily limits** - stops when daily limit reached
- **Distributes evenly** across available campaign accounts

## 👁️ AIRTABLE FIELD VISIBILITY RECOMMENDATIONS

### **🔍 OUTBOUND LEADS TABLE - HIDE THESE FIELDS:**

#### **🤖 Pure Automation Fields (Hide):**
- `Next Message ID` - Internal workflow reference only
- `Original Message ID` - Email threading automation only
- `Sending Account` - Current sending account (automation managed)
- `Postal Message ID` - Postal system reference only
- `Delivery Status` - Technical status for automation
- `Bounce Type` - Technical classification
- `Bounce Reason` - Technical error details
- `Bounce Details` - Technical error description
- `Bounce Date` - Technical timestamp
- `Retry Count` - Automation retry logic
- `Retry Date` - Automation scheduling
- `Campaign Completion Date` - Automated completion tracking
- `email2_content` - Content storage for automation
- `email3_content` - Content storage for automation
- `email4_content` - Content storage for automation
- `email5_content` - Content storage for automation

#### **📊 Analytics Fields (Consider Hiding):**
- `Sent At` - Technical timestamp (keep if you want delivery analytics)
- `Last Contacted Date` - Analytics field (keep if you want contact frequency)

#### **👁️ Keep Visible (Business Critical):**
- `Lead Status` - **ESSENTIAL** - Current lead state
- `Message Type` - **ESSENTIAL** - Which email in sequence
- `Priority` - **ESSENTIAL** - Processing priority
- `Campaign` - **ESSENTIAL** - Campaign identification
- `Email` - **ESSENTIAL** - Contact email
- `Subject` - **ESSENTIAL** - Email subject
- `HTML Content` - **ESSENTIAL** - Email content
- `Plain Text Content` - **ESSENTIAL** - Email content
- `Send Date` - **ESSENTIAL** - When to send
- `Message Sequence` - **ESSENTIAL** - Current message number
- `Total Campaign Messages` - **ESSENTIAL** - Sequence length
- `Original Sending Account` - **ESSENTIAL** - Reply consistency
- `Original Email` - **ESSENTIAL** - Email change tracking

### **📧 SENDING ACCOUNTS TABLE - HIDE THESE FIELDS:**

#### **🤖 Pure Automation Fields (Hide):**
- `Sent Today` - Daily counter for automation
- `Last Used` - Precise timestamp for rotation
- `Rotation Priority` - Load balancing automation
- `Invalid Email` - Technical flag for automation
- `Campaign Status` - Technical status for automation
- `Completed At` - Technical completion timestamp

#### **👁️ Keep Visible (Business Critical):**
- `Email Address` - **ESSENTIAL** - Sending email
- `Campaigns` - **ESSENTIAL** - Campaign assignments
- `Status` - **ESSENTIAL** - Account status
- `Daily Limit` - **ESSENTIAL** - Daily sending limit

### **📋 SUMMARY:**
- **Hide 21 Fields Total** (automation/technical only)
- **Keep 17 Fields Visible** (business critical)
- **Benefits**: Cleaner interface, reduced confusion, better focus, full automation functionality maintained

---

## 📝 MESSAGE FORMATTING STRATEGY

### **Content Processing Approach:**
- **Airtable Storage**: Raw plain text content in `email1_content`, `email2_content`, etc.
- **Processing**: Code node formats content for RFC 2822 compliance
- **Output**: Formatted plain text and HTML sent to Postal
- **Storage**: No formatted content saved back to Airtable

### **Message Formatting Code Node (Node 12.5):**
```javascript
// Message Content Formatter
const leadData = $input.first().json;
const messageType = leadData.fields['Message Type'];

// Get raw content based on message type
let rawContent = '';
switch(messageType) {
  case 'email1':
    rawContent = leadData.fields['email1_content'];
    break;
  case 'email2':
    rawContent = leadData.fields['email2_content'];
    break;
  case 'email3':
    rawContent = leadData.fields['email3_content'];
    break;
  case 'email4':
    rawContent = leadData.fields['email4_content'];
    break;
  case 'email5':
    rawContent = leadData.fields['email5_content'];
    break;
  case 'Reply':
    rawContent = leadData.fields['Reply Content'];
    break;
}

// Format for RFC 2822 plain text
function formatPlainText(text) {
  if (!text) return '';
  
  return text
    .replace(/\n\n/g, '\r\n\r\n')  // Double line breaks = paragraph breaks
    .replace(/\n/g, '\r\n')         // Single line breaks = line breaks
    .trim();
}

// Convert to HTML
function formatHTML(plainText) {
  if (!plainText) return '';
  
  let html = plainText
    .replace(/\r\n\r\n/g, '</p><p>')  // Double line breaks = paragraph breaks
    .replace(/\r\n/g, '<br>')         // Single line breaks = line breaks
    .trim();
  
  // Wrap in paragraph tags
  if (!html.startsWith('<p>')) {
    html = '<p>' + html + '</p>';
  }
  
  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Email</title>
</head>
<body>
  ${html}
</body>
</html>`;
}

// Process the content
const formattedPlainText = formatPlainText(rawContent);
const formattedHTML = formatHTML(rawContent);

// Return for RFC 2822 builder
return {
  json: {
    ...leadData,
    formatted_plain_text: formattedPlainText,
    formatted_html: formattedHTML
  }
};
```

### **Benefits:**
- ✅ **No Airtable bloat** - Only store raw content
- ✅ **Real-time processing** - Always uses latest formatting
- ✅ **Clean workflow** - Format → Send → Done
- ✅ **Flexible** - Can change formatting logic anytime

---

## 📧 EMAIL ADDRESS UPDATE STRATEGY

### **Dynamic Email Address Management:**
- **Initial Setup**: Both `Email` and `Original Email` fields contain identical values
- **Reply Processing**: Webhook automatically updates `Email` field with reply address
- **Future Emails**: Always uses current `Email` field (latest preferred address)
- **History Preservation**: `Original Email` field never changes

### **Webhook Email Update Logic:**
```javascript
// Always update Email field with reply email
const replyEmail = webhookData.message.from;

return {
  json: {
    ...leadData,
    reply_email: replyEmail
  }
};
```

### **Airtable Update (Node 18.5):**
```javascript
// Always update Email field with reply email
fields: {
  "Email": "={{ $json.reply_email }}"
}
```

### **Benefits:**
- ✅ **Automatic detection** - Works for all reply scenarios
- ✅ **No conditional logic** - Always updates
- ✅ **Handles any changes** - Works for any email address changes
- ✅ **Preserves history** - `Original Email` shows where we started
- ✅ **Dynamic updates** - Lead can change email preference multiple times

---

## 🚨 ERROR HANDLING WORKFLOW

### **Workflow Name**: "Postal Error Handler"
### **Purpose**: Centralized error processing and Pushover notifications
### **Trigger**: Webhook from main workflow and webhook workflow

### **Error Workflow Nodes (8 total):**
| Node # | Node Name | Node Type | Purpose |
|--------|-----------|-----------|---------|
| 1 | `Error Webhook` | Webhook | Receive error data from other workflows |
| 2 | `Route Error Source` | IF | Route based on error source (main/webhook) |
| 3 | `Process Main Workflow Error` | Code | Format main workflow error data |
| 4 | `Process Webhook Error` | Code | Format webhook workflow error data |
| 5 | `Send Pushover Notification` | Pushover | Send error notification |
| 6 | `Update Airtable Error Status` | Airtable | Update lead with error details |
| 7 | `Log Error Details` | Code | Log error for debugging |
| 8 | `Error Response` | Respond to Webhook | Send response back to caller |

### **Pushover Notification Format:**
```
🚨 POSTAL EMAIL ERROR

Campaign: 2024-01-15-ptc-01
Recipient: john@example.com
Message Type: email1
Error Code: 422
Error: Invalid RFC 2822 format
Source: Main Workflow

Time: 2024-01-15 14:30:45
```

### **Error Categories:**
- **Authentication (401)**: Invalid API credentials
- **Validation (422)**: Invalid RFC 2822 format, email format
- **Rate Limit (429)**: Too many requests
- **Server Error (500-503)**: Postal server issues
- **Webhook Processing**: Airtable update failures

### **Benefits:**
- ✅ **Centralized error handling** - All errors in one place
- ✅ **Immediate notifications** - Pushover alerts for all errors
- ✅ **Detailed error logging** - Complete error information
- ✅ **Error categorization** - Different handling for different error types
- ✅ **Audit trail** - All errors tracked in Airtable

---

## 📧 Message-ID Format

### **Campaign-Sequence-RecordID Format:**
```
Message-ID: <{campaign}-{message-type}-{record-id}@{domain}>
```

## 🧵 Email Threading (CRITICAL)

### **Threading Logic:**
- **email1**: Uses original subject, no threading headers
- **email2-email5**: Uses "Re: " prefix + original subject + In-Reply-To + References headers  
- **Reply**: Uses "Re: " prefix + original subject + In-Reply-To + References headers
- **Original Message ID**: Stored when email1 is sent, used for all follow-up threading

### **Threading Headers:**
```
In-Reply-To: <2024-01-15-ptc-01-email1-recXXXXXXXXXXXXXX@smarterbdr.com>
References: <2024-01-15-ptc-01-email1-recXXXXXXXXXXXXXX@smarterbdr.com>
```

### **Examples:**
```
<2024-01-15-ptc-01-email1-recXXXXXXXXXXXXXX@smarterbdr.com>
<2024-01-15-ptc-01-email2-recYYYYYYYYYYYYYY@smarterbdr.com>
<2024-01-15-montani-01-email1-recZZZZZZZZZZZZZZ@smarterbdr.com>
```

### **Benefits:**
- **Direct record lookup** - Extract Record ID directly from Message-ID for instant lead identification
- **Better performance** - No Airtable search needed, direct record access
- **Easy debugging** - See campaign, sequence, and Record ID at a glance
- **Enhanced analytics** - Group by campaign/sequence without database lookups
- **RFC 2822 compliant** - Globally unique with proper format
- **Webhook efficiency** - Webhook handler can directly access lead record using extracted Record ID

## 📊 Daily Limit Management

### **Daily Limit Enforcement:**
- **All email sequences:** Respect daily limits (stops when limit reached)
- **Automatic counter:** "Sent Today" field incremented after each successful send
- **Daily reset:** Counters reset at midnight (manual or automated process)
- **Smart error handling:** Failed sends delayed to tomorrow, lead stays "Queued"

### **Workflow Stopping Logic:**
- **When all accounts reach limits:** Workflow stops processing new leads
- **Schedule control:** Prevents wasted trigger executions
- **Logging:** Records which lead triggered the stop and why

### **Example Daily Limits:**
```
Account A: Daily Limit = 50, Sent Today = 47 → Can send 3 more
Account B: Daily Limit = 100, Sent Today = 100 → At limit, cannot send
Account C: Daily Limit = 25, Sent Today = 25 → At limit, cannot send

Result: Only Account A can send Initial/Follow-up messages
Replies: Always allowed regardless of limits
```

## 🔧 Detailed Node Configurations

### **Node 2: Get Priority Lead (Airtable)**
```json
{
  "operation": "search",
  "table": "Outbound Leads",
  "filterByFormula": "AND({Lead Status} = 'Queued', OR({Message Type} = 'Reply', AND({Message Type} = 'email1', {Send Date} <= NOW()), AND({Message Type} = 'email2', {Send Date} <= NOW()), AND({Message Type} = 'email3', {Send Date} <= NOW()), AND({Message Type} = 'email4', {Send Date} <= NOW()), AND({Message Type} = 'email5', {Send Date} <= NOW())))",
  "sort": [
    {"field": "Priority", "direction": "asc"},
    {"field": "Created Time", "direction": "asc"}
  ],
  "limit": 1
}
```

### **Node 3: Check Message Priority (IF)**
```json
{
  "conditions": {
    "conditions": [
      {
        "leftValue": "={{ $json.fields['Message Type'] }}",
        "rightValue": "Reply",
        "operator": {"type": "string", "operation": "equals"}
      }
    ]
  }
}
```

### **Node 5: Check Daily Limits (Airtable)**
```json
{
  "operation": "search",
  "table": "Sending Accounts",
  "filterByFormula": "AND({Status} = 'Active', FIND('{{ $json.fields['Campaign'] }}', {Campaigns}), {Sent Today} < {Daily Limit})",
  "sort": [
    {"field": "Rotation Priority", "direction": "asc"},
    {"field": "Last Used", "direction": "asc"}
  ],
  "limit": 1
}
```

### **Node 6: Validate Account Availability (Code)**
```javascript
// Check if any accounts are available
const accountData = $input.first().json;

// If no accounts found, it means all accounts have reached daily limits
if (!accountData.fields || Object.keys(accountData.fields).length === 0) {
  return {
    json: {
      ...accountData,
      no_accounts_available: true,
      error_message: 'All sending accounts have reached their daily limits'
    }
  };
}

return {
  json: {
    ...accountData,
    no_accounts_available: false
  }
};
```

### **Node 9: Merge Account Data (Code)**
```javascript
// Determine Sending Account Based on Message Type
const leadData = $input.first().json;
const messageType = leadData.fields['Message Type'];
const campaignId = leadData.fields['Campaign'];
const originalSender = leadData.fields['Original Sending Account'];

let assignedEmail;
let priority = 'normal';

if (messageType === 'Reply') {
  // CRITICAL: Must use original sending account for replies
  assignedEmail = originalSender;
  priority = 'high';
  
  // If no original sender found, use a fallback
  if (!assignedEmail) {
    assignedEmail = 'noreply@smarterbdr.com'; // Fallback
  }
} else if (messageType === 'email2' || messageType === 'email3' || messageType === 'email4' || messageType === 'email5') {
  // CRITICAL: Must use original sending account for follow-up emails
  assignedEmail = originalSender;
  priority = 'normal';
  
  // If no original sender found, use a fallback
  if (!assignedEmail) {
    assignedEmail = 'noreply@smarterbdr.com'; // Fallback
  }
} else {
  // For email1 (initial messages), query Sending Accounts table for rotation
  // This will be handled by a separate node after this one
  assignedEmail = null; // Will be set by next node
  priority = 'normal';
}

return {
  json: {
    ...leadData,
    sending_account: assignedEmail,
    campaign_id: campaignId,
    message_type: messageType,
    message_priority: priority,
    needs_account_rotation: messageType === 'email1'
  }
};
```

### **Node 13: Build RFC 2822 Message (Code)**
```javascript
// RFC 2822 Message Builder
const leadData = $input.first().json;
const messageType = leadData.message_type;
const priority = leadData.message_priority;
const sendingAccount = leadData.sending_account;
const recipientEmail = leadData.fields['Email'];
const subject = leadData.fields['Subject'];
const htmlBody = leadData.fields['HTML Content'];
const plainBody = leadData.fields['Plain Text Content'];
const campaignId = leadData.campaign_id;

// Generate unique message ID with campaign, sequence, and Record ID
const recordId = leadData.fields['id']; // Airtable Record ID
const messageId = `<${campaignId}-${messageType}-${recordId}@smarterbdr.com>`;

// Get current timestamp in RFC 2822 format
const now = new Date();
const dateHeader = now.toUTCString().replace(/GMT$/, '+0000');

// Build RFC 2822 message
let rfc2822Message = `From: ${sendingAccount}\\r\\n`;
rfc2822Message += `To: ${recipientEmail}\\r\\n`;
rfc2822Message += `Subject: ${subject}\\r\\n`;
rfc2822Message += `Date: ${dateHeader}\\r\\n`;
rfc2822Message += `Message-ID: ${messageId}\\r\\n`;
rfc2822Message += `MIME-Version: 1.0\\r\\n`;

// Campaign tracking headers
rfc2822Message += `X-Campaign-ID: ${campaignId}\\r\\n`;
rfc2822Message += `X-Message-Type: ${messageType}\\r\\n`;
rfc2822Message += `X-Compliance: CAN-SPAM\\r\\n`;

// Add MIME multipart for HTML and plain text
if (htmlBody && plainBody) {
  const boundary = `boundary_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  rfc2822Message += `Content-Type: multipart/alternative; boundary=\"${boundary}\"\\r\\n\\r\\n`;
  
  rfc2822Message += `--${boundary}\\r\\n`;
  rfc2822Message += `Content-Type: text/plain; charset=UTF-8\\r\\n\\r\\n`;
  rfc2822Message += `${plainBody}\\r\\n\\r\\n`;
  
  rfc2822Message += `--${boundary}\\r\\n`;
  rfc2822Message += `Content-Type: text/html; charset=UTF-8\\r\\n\\r\\n`;
  rfc2822Message += `${htmlBody}\\r\\n\\r\\n`;
  
  rfc2822Message += `--${boundary}--\\r\\n`;
} else if (htmlBody) {
  rfc2822Message += `Content-Type: text/html; charset=UTF-8\\r\\n\\r\\n`;
  rfc2822Message += `${htmlBody}\\r\\n`;
} else {
  rfc2822Message += `Content-Type: text/plain; charset=UTF-8\\r\\n\\r\\n`;
  rfc2822Message += `${plainBody || 'No content provided'}\\r\\n`;
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

### **Node 15: Update Lead Status (Airtable)**
```json
{
  "operation": "update",
  "table": "Outbound Leads",
  "id": "={{ $json.fields['id'] }}",
  "fieldsToSend": "defined",
  "fields": {
    "Lead Status": "Sent to Postal",
    "Sent At": "={{ $json.metrics.sent_at }}",
    "Postal Message ID": "={{ $json.metrics.message_id }}",
    "Sending Account": "={{ $json.metrics.sending_account }}",
    "Delivery Status": "={{ $json.metrics.delivery_status }}"
  }
}
```

### **Node 16: Update Last Used Timestamp (Airtable)**
```json
{
  "operation": "update",
  "table": "Sending Accounts",
  "id": "={{ $json.sending_account.id }}",
  "fieldsToSend": "defined",
  "fields": {
    "Last Used": "={{ new Date().toISOString().slice(0, 19).replace('T', ' ') }}"
  }
}
```

### **Node 17: Update Sent Today Counter (Airtable)**
```json
{
  "operation": "update",
  "table": "Sending Accounts",
  "id": "={{ $json.sending_account.id }}",
  "fieldsToSend": "defined",
  "fields": {
    "Sent Today": "={{ $json.sending_account.fields['Sent Today'] + 1 }}"
  }
}
```

### **Node 18: Update Last Contacted Date (Airtable)**
```json
{
  "operation": "update",
  "table": "Outbound Leads",
  "id": "={{ $json.fields['id'] }}",
  "fieldsToSend": "defined",
  "fields": {
    "Last Contacted Date": "={{ new Date().toISOString() }}"
  }
}
```

### **Node 19: Check if Sequence Complete (Code)**
```javascript
// Check if this was the final message in the sequence
const leadData = $input.first().json;
const messageType = leadData.fields['Message Type'];

let isSequenceComplete = false;

switch(messageType) {
  case 'email1':
    // Check if email2 content exists
    isSequenceComplete = !leadData.fields['email2_content'] || leadData.fields['email2_content'].trim() === '';
    break;
  case 'email2':
    // Check if email3 content exists
    isSequenceComplete = !leadData.fields['email3_content'] || leadData.fields['email3_content'].trim() === '';
    break;
  case 'email3':
    // Check if email4 content exists
    isSequenceComplete = !leadData.fields['email4_content'] || leadData.fields['email4_content'].trim() === '';
    break;
  case 'email4':
    // Check if email5 content exists
    isSequenceComplete = !leadData.fields['email5_content'] || leadData.fields['email5_content'].trim() === '';
    break;
  case 'email5':
    // email5 is always the final message
    isSequenceComplete = true;
    break;
  default:
    isSequenceComplete = false;
}

return {
  json: {
    ...leadData,
    is_sequence_complete: isSequenceComplete,
    current_message_type: messageType
  }
};
```

### **Node 21: Mark Sequence Complete (Airtable)**
```json
{
  "operation": "update",
  "table": "Outbound Leads",
  "id": "={{ $json.fields['id'] }}",
  "fieldsToSend": "defined",
  "fields": {
    "Message Type": "Done",
    "Lead Status": "Sequence Complete",
    "Campaign Completion Date": "={{ new Date().toISOString() }}"
  }
}
```

## 🔧 Webhook Workflow Node Configurations

### **Node 1: Postal Webhook (Webhook)**
```json
{
  "httpMethod": "POST",
  "path": "postal-webhook",
  "responseMode": "responseNode",
  "options": {}
}
```

### **Node 2: Route Event Type (IF)**
```json
{
  "conditions": {
    "conditions": [
      {
        "leftValue": "={{ $json.event }}",
        "rightValue": "DeliverySucceeded",
        "operator": {"type": "string", "operation": "equals"}
      }
    ]
  }
}
```

### **Node 3: Route Bounce Events (IF)**
```json
{
  "conditions": {
    "conditions": [
      {
        "leftValue": "={{ $json.event }}",
        "rightValue": "MessageBounced",
        "operator": {"type": "string", "operation": "equals"}
      }
    ]
  }
}
```

### **Node 4: Handle Delivery Success (Code)**
```javascript
// Handle Delivery Success - Schedule Follow-up
const webhookData = $input.first().json;
const messageId = webhookData.message.message_id;
const deliveryTime = webhookData.timestamp;

// Extract Record ID directly from message ID
// Format: <campaign-messageType-recordId@domain.com>
const recordId = messageId.split('-')[4].split('@')[0];

return {
  json: {
    message_id: messageId,
    delivery_time: deliveryTime,
    event_type: 'DeliverySucceeded',
    record_id: recordId
  }
};
```

### **Node 5: Find Lead by Message ID (Airtable)**
```json
{
  "operation": "get",
  "table": "Outbound Leads",
  "id": "={{ $json.record_id }}"
}
```

### **Node 6: Determine Follow-up Action (Code)**
```javascript
// Check if this is the final message in campaign
const leadData = $input.first().json;
const currentSequence = leadData.fields['Message Sequence'] || 1;
const totalMessages = leadData.fields['Total Campaign Messages'] || 1;
const campaignId = leadData.fields['Campaign'];

// Define follow-up delays by campaign
const followUpDelays = {
  'Q1-SMYKM': {
    'Initial': 3,
    'Reply': 1,
    'Follow-up': 7
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
const messageType = leadData.fields['Message Type'];
const delayDays = delays[messageType] || delays['Follow-up'];

// Check if this is the final message
const isFinalMessage = currentSequence >= totalMessages;

if (isFinalMessage) {
  // Mark campaign as complete
  return {
    json: {
      ...leadData,
      action: 'campaign_complete',
      next_message_send_date: null,
      campaign_status: 'Complete'
    }
  };
} else {
  // Schedule next message
  const nextMessageDate = new Date();
  nextMessageDate.setDate(nextMessageDate.getDate() + delayDays);
  
  return {
    json: {
      ...leadData,
      action: 'schedule_next',
      next_message_send_date: nextMessageDate.toISOString().split('T')[0],
      next_sequence: currentSequence + 1
    }
  };
}
```

### **Node 7: Route Action (IF)**
```json
{
  "conditions": {
    "conditions": [
      {
        "leftValue": "={{ $json.action }}",
        "rightValue": "schedule_next",
        "operator": {"type": "string", "operation": "equals"}
      }
    ]
  }
}
```

### **Node 8: Schedule Next Message (Airtable)**
```json
{
  "operation": "update",
  "table": "Outbound Leads",
  "id": "={{ $json.fields['Next Message ID'] }}",
  "fieldsToSend": "defined",
  "fields": {
    "Send Date": "={{ $json.next_message_send_date }}",
    "Lead Status": "Queued",
    "Message Sequence": "={{ $json.next_sequence }}"
  }
}
```

### **Node 9: Mark Campaign Complete (Airtable)**
```json
{
  "operation": "update",
  "table": "Outbound Leads",
  "id": "={{ $json.fields['id'] }}",
  "fieldsToSend": "defined",
  "fields": {
    "Lead Status": "Campaign Complete",
    "Campaign Status": "Complete",
    "Completed At": "={{ $now }}"
  }
}
```

### **Node 10: Handle Bounce Events (Code)**
```javascript
// Handle Bounce Events - Smart Bounce Strategy
const webhookData = $input.first().json;
const messageId = webhookData.message.message_id;
const bounceType = webhookData.bounce.type; // 'soft' or 'hard'
const bounceReason = webhookData.bounce.reason;
const bounceDetails = webhookData.bounce.details;
const bounceTime = webhookData.timestamp;

// Extract Record ID directly from message ID
// Format: <campaign-messageType-recordId@domain.com>
const recordId = messageId.split('-')[4].split('@')[0];

// Reputation killer bounces - NEVER retry
const reputationKillers = [
  'content_rejected',
  'greylisted', 
  'blocked'
];

// Safe to retry bounces (with limits)
const safeToRetry = [
  'mailbox_full',
  'temporary_failure',
  'rate_limited'
];

// Determine action based on bounce reason
let action;
let retryDelay = null;

if (bounceType === 'hard') {
  // Never retry hard bounces
  action = 'mark_invalid';
} else if (reputationKillers.includes(bounceReason)) {
  // Never retry reputation killers
  action = 'mark_invalid';
} else if (safeToRetry.includes(bounceReason)) {
  // Safe to retry with limits
  action = 'check_retry';
  
  // Set retry delays based on bounce reason
  switch(bounceReason) {
    case 'mailbox_full':
      retryDelay = 48; // 48 hours
      break;
    case 'temporary_failure':
      retryDelay = 24; // 24 hours
      break;
    case 'rate_limited':
      retryDelay = 2; // 2 hours
      break;
  }
} else {
  // Unknown bounce reason - be conservative
  action = 'mark_soft_bounce';
}

return {
  json: {
    message_id: messageId,
    bounce_type: bounceType,
    bounce_reason: bounceReason,
    bounce_details: bounceDetails,
    bounce_time: bounceTime,
    action: action,
    retry_delay_hours: retryDelay,
    record_id: recordId
  }
};
```

### **Node 11: Find Bounced Lead (Airtable)**
```json
{
  "operation": "get",
  "table": "Outbound Leads",
  "id": "={{ $json.record_id }}"
}
```

### **Node 12: Check Retry Count (IF)**
```json
{
  "conditions": {
    "conditions": [
      {
        "leftValue": "={{ $json.action }}",
        "rightValue": "check_retry",
        "operator": {"type": "string", "operation": "equals"}
      }
    ]
  }
}
```

### **Node 13: Retry Logic (Code)**
```javascript
// Check if we should retry or give up
const leadData = $input.first().json;
const bounceData = $input.first().json;
const retryCount = leadData.fields['Retry Count'] || 0;
const maxRetries = 1; // Only retry once

if (retryCount < maxRetries) {
  // Schedule retry
  const retryDate = new Date();
  retryDate.setHours(retryDate.getHours() + bounceData.retry_delay_hours);
  
  return {
    json: {
      ...leadData,
      ...bounceData,
      action: 'schedule_retry',
      retry_date: retryDate.toISOString(),
      new_retry_count: retryCount + 1
    }
  };
} else {
  // Too many retries - mark as soft bounce
  return {
    json: {
      ...leadData,
      ...bounceData,
      action: 'mark_soft_bounce'
    }
  };
}
```

### **Node 14: Mark as Invalid Email (Airtable)**
```json
{
  "operation": "update",
  "table": "Outbound Leads",
  "id": "={{ $json.fields['id'] }}",
  "fieldsToSend": "defined",
  "fields": {
    "Lead Status": "Invalid Email",
    "Bounce Type": "={{ $json.bounce_type }}",
    "Bounce Reason": "={{ $json.bounce_reason }}",
    "Bounce Details": "={{ $json.bounce_details }}",
    "Bounce Date": "={{ $json.bounce_time }}",
    "Invalid Email": true
  }
}
```

### **Node 15: Schedule Retry (Airtable)**
```json
{
  "operation": "update",
  "table": "Outbound Leads",
  "id": "={{ $json.fields['id'] }}",
  "fieldsToSend": "defined",
  "fields": {
    "Lead Status": "Soft Bounce",
    "Bounce Type": "={{ $json.bounce_type }}",
    "Bounce Reason": "={{ $json.bounce_reason }}",
    "Bounce Details": "={{ $json.bounce_details }}",
    "Bounce Date": "={{ $json.bounce_time }}",
    "Retry Count": "={{ $json.new_retry_count }}",
    "Retry Date": "={{ $json.retry_date }}"
  }
}
```

### **Node 16: Mark as Soft Bounce (Airtable)**
```json
{
  "operation": "update",
  "table": "Outbound Leads",
  "id": "={{ $json.fields['id'] }}",
  "fieldsToSend": "defined",
  "fields": {
    "Lead Status": "Soft Bounce",
    "Bounce Type": "={{ $json.bounce_type }}",
    "Bounce Reason": "={{ $json.bounce_reason }}",
    "Bounce Details": "={{ $json.bounce_details }}",
    "Bounce Date": "={{ $json.bounce_time }}"
  }
}
```

### **Node 17: Webhook Response (Respond to Webhook)**
```json
{
  "respondWith": "json",
  "responseBody": "={{ { \"status\": \"success\", \"message\": \"Webhook processed\" } }}"
}
```

## 🔧 Setup Instructions

### **1. Import Workflows:**
1. Import `Postal_Email_Sender_Simplified.json` into n8n
2. Import `Postal_Webhook_Handler.json` into n8n

### **2. Configure Credentials:**
- **Airtable API** - Connect to your Airtable base
- **Postal API Key** - Your Postal server API key

### **3. Update Configuration:**
- Replace `appXXXXXXXXXXXXXX` with your actual Airtable base ID
- Update Postal API URL if different from `https://postal.ottomatik.ai`

### **4. Configure Postal Webhooks:**
- Set webhook URL to your n8n webhook endpoint
- Enable `DeliverySucceeded` and `MessageBounced` events
- Use webhook path: `postal-webhook`

### **5. Test Workflows:**
1. Run main workflow manually with test lead
2. Verify webhook receives Postal confirmation
3. Check Airtable updates and follow-up scheduling

## 🎯 Workflow Benefits

### **Reliability:**
- ✅ **Delivery confirmation** before scheduling follow-ups
- ✅ **Smart bounce handling** protects sender reputation
- ✅ **Error handling** with proper status updates
- ✅ **Campaign completion** detection

### **Performance:**
- ✅ **Sequence-only processing** (focused on email campaigns)
- ✅ **Schedule-controlled pacing** (no artificial delays needed)
- ✅ **Account rotation** distributes sending load
- ✅ **Efficient queuing** with proper scheduling
- ✅ **Smart error recovery** (delay to tomorrow, automatic retry)

### **Analytics:**
- ✅ **Campaign tracking** with detailed metrics
- ✅ **Bounce analysis** with reason tracking
- ✅ **Delivery confirmation** for accurate reporting
- ✅ **Performance monitoring** with response times

## 🚨 Critical Requirements

### **MANDATORY: RFC 2822 Format Only**
- **NO individual attributes method** - Postal requires RFC 2822 format
- **Complete message formation** before sending to Postal
- **Proper line endings** - Must use `\r\n` (carriage return + line feed)
- **Header formatting** - Exact RFC 2822 specification compliance

### **MANDATORY: Documentation Compliance**
- **ALWAYS follow published documentation** - Never guess or assume
- **Postal API documentation** - https://docs.postalserver.io/developer/api
- **If documentation missing** - Inform user and ask for help finding it
- **NO EXCEPTIONS** - Follow documentation only

## 📈 Campaign Management

### **Follow-up Scheduling:**
- **Automatic sequencing** based on campaign configuration
- **Proper delays** between messages (3, 7, 14 days, etc.)
- **Campaign completion** detection and marking
- **Future campaign** preparation for completed leads

### **Priority System:**
- **Initial messages (email1)** processed on schedule (business hours)
- **Follow-up messages (email2-email5)** processed when Send Date arrives
- **Account consistency** maintained for follow-ups using original sender
- **Reply processing** handled by separate Inbox Management workflow

This system provides enterprise-grade email automation with proper deliverability, reputation protection, and campaign management capabilities.
