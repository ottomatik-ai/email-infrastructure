# Postal n8n Workflow Reference Guide

## 🎯 PURPOSE
This document serves as the single source of truth for building the Postal email automation workflows, ensuring consistent variable mapping, node naming, and Airtable schema alignment.

## 📋 TABLE OF CONTENTS
1. [Airtable Schema Reference](#airtable-schema-reference)
2. [Node Naming Convention](#node-naming-convention)
3. [Variable Mapping Reference](#variable-mapping-reference)
4. [Workflow Building Checklist](#workflow-building-checklist)
5. [Common Variable Patterns](#common-variable-patterns)
6. [Troubleshooting Guide](#troubleshooting-guide)

---

## 📊 AIRTABLE SCHEMA REFERENCE

### **Outbound Leads Table**
| Field Name | Field Type | Description | Example Value | Required |
|------------|------------|-------------|---------------|----------|
| `id` | Auto-generated | Airtable Record ID | `recXXXXXXXXXXXXXX` | ✅ |
| `Lead Status` | Single Select | Current lead status | `Queued`, `Sent to Postal`, `Delivered`, `Campaign Complete`, `Invalid Email`, `Soft Bounce` | ✅ |
| `Message Type` | Single Select | Current message type | `email1`, `email2`, `email3`, `email4`, `email5`, `Done` | ✅ |
| `Priority` | Number | Processing priority | `2` (email1), `3` (email2), `4` (email3), `5` (email4), `6` (email5), `7` (Done) | ✅ |
| `Campaign` | Single Line Text | Campaign identifier | `2024-01-15-ptc-01` | ✅ |
| `Email` | Email | Recipient email address | `john@example.com` | ✅ |
| `Subject` | Single Line Text | Email subject line | `Follow up on our conversation` | ✅ |
| `HTML Content` | Long Text | HTML email content | `<html>...</html>` | ✅ |
| `Plain Text Content` | Long Text | Plain text email content | `Plain text version` | ✅ |
| `Send Date` | Date | When message should be sent | `2024-01-15` | ✅ |
| `Message Sequence` | Number | Current message number | `1`, `2`, `3`, etc. | ✅ |
| `Total Campaign Messages` | Number | Total messages in sequence | `5` | ✅ |
| `Next Message ID` | Single Line Text | Airtable ID of next message | `recYYYYYYYYYYYYYY` | ❌ |
| `Original Sending Account` | Single Line Text | **CRITICAL** - Original sender for replies | `sender@smarterbdr.com` | ✅ |
| `Original Message ID` | Single Line Text | **CRITICAL** - email1 Message ID for threading | `<2024-01-15-ptc-01-email1-recXXXXXXXXXXXXXX@smarterbdr.com>` | ✅ |
| `Original Email` | Email | **CRITICAL** - Original email before any updates | `bob@acme.com` | ✅ |
| `Reply Content` | Long Text | Content for reply messages | `Reply message content` | ❌ |
| `Sending Account` | Single Line Text | Current sending account | `sender@smarterbdr.com` | ❌ |
| `Postal Message ID` | Single Line Text | Message ID from Postal | `<2024-01-15-ptc-01-email1-recXXXXXXXXXXXXXX@smarterbdr.com>` | ❌ |
| `Sent At` | Date | Timestamp when sent | `2024-01-15T14:30:45.123Z` | ❌ |
| `Delivery Status` | Single Select | Delivery status | `accepted_by_postal`, `delivered`, `bounced` | ❌ |
| `Bounce Type` | Single Select | Type of bounce | `soft`, `hard` | ❌ |
| `Bounce Reason` | Single Line Text | Bounce reason from Postal | `mailbox_full` | ❌ |
| `Bounce Details` | Long Text | Human-readable bounce description | `Mailbox is full` | ❌ |
| `Bounce Date` | Date | When bounce occurred | `2024-01-15T14:30:45.123Z` | ❌ |
| `Retry Count` | Number | Number of retry attempts | `0`, `1` | ❌ |
| `Retry Date` | Date | When to retry | `2024-01-17T14:30:45.123Z` | ❌ |
| `Error Message` | Single Line Text | Technical error details from Postal API | `Invalid RFC 2822 format` | ❌ |
| `Error Count` | Number | Number of consecutive failed attempts | `3` | ❌ |
| `Last Error Date` | Date | Timestamp of last error | `2024-01-15T14:30:45.123Z` | ❌ |
| `Error` | Long Text | Detailed error message (same as Pushover) - **ACCUMULATES** multiple entries | `Postal Send Failed: 422 | Lead: john@example.com | Campaign: 2024-01-15-ptc-01 | Message: email1 | Attempted: 2024-01-15 14:30:00 | Status: Delayed to tomorrow` | ❌ |
| `Campaign Completion Date` | Date | When sequence completed | `2024-01-15T14:30:45.123Z` | ❌ |
| `Last Contacted Date` | Date | When lead was last contacted | `2024-01-15T14:30:45.123Z` | ❌ |
| `email2_content` | Long Text | email2 content (empty if sequence ends after email1) | `Follow up message content` | ❌ |
| `email3_content` | Long Text | email3 content (empty if sequence ends after email2) | `Follow up message content` | ❌ |
| `email4_content` | Long Text | email4 content (empty if sequence ends after email3) | `Follow up message content` | ❌ |
| `email5_content` | Long Text | email5 content (empty if sequence ends after email4) | `Follow up message content` | ❌ |

### **Sending Accounts Table**
| Field Name | Field Type | Description | Example Value | Required |
|------------|------------|-------------|---------------|----------|
| `id` | Auto-generated | Airtable Record ID | `recAAAAAAAAAAAAAA` | ✅ |
| `Email Address` | Email | The sending email address | `sender1@smarterbdr.com` | ✅ |
| `Campaigns` | Multiple Select | Campaigns this account can send for | `2024-01-15-ptc-01`, `2024-01-15-montani-01` | ✅ |
| `Status` | Single Select | Account status | `Active`, `Paused`, `Suspended` | ✅ |
| `Daily Limit` | Number | Maximum emails per day | `50` | ✅ |
| `Sent Today` | Number | Count of emails sent today | `23` | ✅ |
| `Last Used` | Single Line Text | Precise timestamp (YYYY-MM-DD HH:MM:SS) | `2024-01-15 14:30:45` | ✅ |
| `Rotation Priority` | Number | Load balancing priority | `1` (highest), `2`, `3` | ✅ |
| `Invalid Email` | Checkbox | Invalid email flag | `false` | ❌ |
| `Campaign Status` | Single Select | Campaign status | `Active`, `Complete`, `Paused` | ❌ |
| `Completed At` | Date | When campaign completed | `2024-01-15T14:30:45.123Z` | ❌ |

---

## 🏷️ NODE NAMING CONVENTION

### **Main Workflow Nodes (22 total)**
| Node # | Node Name | Node Type | Purpose |
|--------|-----------|-----------|---------|
| 1 | `Manual Trigger` | Manual Trigger | Start workflow manually |
| 2 | `Get Priority Lead` | Airtable | Fetch highest priority lead |
| 3 | `Check Message Priority` | IF | Route Reply messages |
| 4 | `Check if Reply` | IF | Bypass daily limits for replies |
| 5 | `Check Daily Limits` | Airtable | Find available accounts |
| 6 | `Validate Account Availability` | Code | Check if accounts available |
| 7 | `Check Accounts Available` | IF | Stop if no accounts |
| 8 | `Assign Sending Account` | Airtable | Query sending accounts |
| 9 | `Merge Account Data` | Code | Determine sending account |
| 10 | `Check if Account Rotation Needed` | IF | Route based on message type |
| 11 | `Get Rotated Account` | Airtable | Get account for rotation |
| 12 | `Set Rotated Account` | Code | Assign rotated account |
| 13 | `Format Message Content` | Code | Convert raw content to RFC 2822 format |
| 14 | `Build RFC 2822 Message` | Code | Format email message |
| 15 | `Send via Postal` | HTTP Request | Submit to Postal API |
| 16 | `Collect Campaign Metrics` | Code | Track performance data |
| 17 | `Update Lead Status` | Airtable | Mark as "Sent to Postal" |
| 18 | `Update Reply Email` | Airtable | Update Email field with reply address |
| 19 | `Update Last Used Timestamp` | Airtable | Record account usage |
| 20 | `Update Sent Today Counter` | Airtable | Increment daily counter |
| 21 | `Update Last Contacted Date` | Airtable | Record contact timestamp |
| 22 | `Check if Sequence Complete` | Code | Determine if final message |
| 23 | `Route Sequence Completion` | IF | Route to completion or continue |
| 24 | `Mark Sequence Complete` | Airtable | Update to "Done" status |
| 25 | `Check Success` | IF | Verify Postal acceptance |
| 26 | `Update Error Status` | Airtable | Mark as failed on error |
| 27 | `Send Error to Error Workflow` | HTTP Request | Send error data to error workflow |
| 28 | `Stop Workflow - Daily Limits Reached` | Code | Stop when limits reached |

### **Error Workflow Nodes (8 total)**
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

### **Webhook Workflow Nodes (17 total)**
| Node # | Node Name | Node Type | Purpose |
|--------|-----------|-----------|---------|
| 1 | `Postal Webhook` | Webhook | Receive Postal events |
| 2 | `Route Event Type` | IF | Route DeliverySucceeded |
| 3 | `Route Bounce Events` | IF | Route MessageBounced |
| 4 | `Handle Delivery Success` | Code | Extract Record ID |
| 5 | `Find Lead by Message ID` | Airtable | Direct record lookup |
| 6 | `Determine Follow-up Action` | Code | Schedule next or complete |
| 7 | `Route Action` | IF | Route to schedule or complete |
| 8 | `Schedule Next Message` | Airtable | Update next message |
| 9 | `Mark Campaign Complete` | Airtable | Mark sequence complete |
| 10 | `Handle Bounce Events` | Code | Smart bounce strategy |
| 11 | `Find Bounced Lead` | Airtable | Direct record lookup |
| 12 | `Check Retry Count` | IF | Route retry vs invalid |
| 13 | `Retry Logic` | Code | Determine retry action |
| 14 | `Mark as Invalid Email` | Airtable | Mark reputation killers |
| 15 | `Schedule Retry` | Airtable | Schedule retry attempt |
| 16 | `Mark as Soft Bounce` | Airtable | Mark retry limit exceeded |
| 17 | `Webhook Response` | Respond to Webhook | Send response to Postal |

---

## 🔗 VARIABLE MAPPING REFERENCE

### **Critical Variable Patterns**

#### **Lead Data Structure**
```javascript
// Standard lead data from Airtable
const leadData = {
  fields: {
    'id': 'recXXXXXXXXXXXXXX',                    // Airtable Record ID
    'Lead Status': 'Queued',                      // Current status
    'Message Type': 'email1',                     // Current message type
    'Priority': 2,                                // Processing priority
    'Campaign': '2024-01-15-ptc-01',             // Campaign identifier
    'Email': 'john@example.com',                  // Recipient email
    'Subject': 'Follow up on our conversation',   // Email subject
    'HTML Content': '<html>...</html>',           // HTML content
    'Plain Text Content': 'Plain text version',   // Plain text content
    'Send Date': '2024-01-15',                    // Send date
    'Original Sending Account': 'sender@smarterbdr.com', // Original sender
    'email2_content': 'Follow up content',        // Next message content
    // ... other fields
  }
};
```

#### **Sending Account Data Structure**
```javascript
// Sending account data from Airtable
const sendingAccount = {
  id: 'recAAAAAAAAAAAAAA',                       // Account Record ID
  fields: {
    'Email Address': 'sender1@smarterbdr.com',   // Sending email
    'Campaigns': ['2024-01-15-ptc-01'],          // Assigned campaigns
    'Status': 'Active',                           // Account status
    'Daily Limit': 50,                            // Daily limit
    'Sent Today': 23,                             // Current count
    'Last Used': '2024-01-15 14:30:45',          // Last usage
    'Rotation Priority': 1                        // Load balancing
  }
};
```

#### **Message-ID Format**
```javascript
// Message-ID generation
const recordId = leadData.fields['id'];           // Extract Record ID
const campaignId = leadData.fields['Campaign'];   // Extract Campaign
const messageType = leadData.fields['Message Type']; // Extract Message Type
const messageId = `<${campaignId}-${messageType}-${recordId}@smarterbdr.com>`;
```

#### **Webhook Data Structure**
```javascript
// Postal webhook payload
const webhookData = {
  event: 'DeliverySucceeded',                     // Event type
  message: {
    message_id: '<2024-01-15-ptc-01-email1-recXXXXXXXXXXXXXX@smarterbdr.com>'
  },
  timestamp: '2024-01-15T14:30:45Z',             // Event timestamp
  bounce: {                                       // Only for bounce events
    type: 'soft',                                 // 'soft' or 'hard'
    reason: 'mailbox_full',                       // Bounce reason
    details: 'Mailbox is full'                    // Human readable
  }
};
```

### **Common Variable References**

#### **Airtable Field Access**
```javascript
// Always use this pattern for Airtable fields
$json.fields['Field Name']                        // Correct
$json.fields.FieldName                            // Incorrect (spaces in field names)
```

#### **Record ID Extraction**
```javascript
// Extract Record ID from Message-ID
const recordId = messageId.split('-')[4].split('@')[0];
// Message-ID: <2024-01-15-ptc-01-email1-recXXXXXXXXXXXXXX@smarterbdr.com>
// Result: recXXXXXXXXXXXXXX
```

#### **Date Formatting**
```javascript
// ISO timestamp for Airtable
const isoDate = new Date().toISOString();         // 2024-01-15T14:30:45.123Z

// Precise timestamp for Last Used
const preciseTime = new Date().toISOString().slice(0, 19).replace('T', ' '); // 2024-01-15 14:30:45

// Date only for Send Date
const dateOnly = new Date().toISOString().split('T')[0]; // 2024-01-15
```

---

## ✅ WORKFLOW BUILDING CHECKLIST

### **Phase 1: Foundation Setup**
- [ ] Import both JSON workflow files
- [ ] Set up Airtable API credentials
- [ ] Set up Postal API credentials
- [ ] Update Airtable base ID (replace `appXXXXXXXXXXXXXX`)
- [ ] Test webhook endpoint URL

### **Phase 2: Main Workflow (22 nodes)**
- [ ] Node 1: Manual Trigger
- [ ] Node 2: Get Priority Lead (Airtable query)
- [ ] Node 3: Check Daily Limits (Airtable query)
- [ ] Node 4: Validate Account Availability (Code)
- [ ] Node 5: Check Accounts Available (IF condition)
- [ ] Node 6: Assign Sending Account (Airtable query)
- [ ] Node 7: Merge Account Data (Code)
- [ ] Node 8: Format Message Content (Code)
- [ ] Node 9: Build RFC 2822 Message (Code)
- [ ] Node 10: Send via Postal (HTTP Request)
- [ ] Node 11: Collect Campaign Metrics (Code)
- [ ] Node 12: Update Lead Status (Airtable update)
- [ ] Node 13: Update Last Used Timestamp (Airtable update)
- [ ] Node 14: Update Sent Today Counter (Airtable update)
- [ ] Node 15: Update Last Contacted Date (Airtable update)
- [ ] Node 16: Check if Sequence Complete (Code)
- [ ] Node 17: Route Sequence Completion (IF condition)
- [ ] Node 18: Mark Sequence Complete (Airtable update)
- [ ] Node 19: Check Success (IF condition)
- [ ] Node 20: Update Error Status (Airtable update - delay to tomorrow)
- [ ] Node 21: Send Error to Error Workflow (HTTP Request)
- [ ] Node 22: Stop Workflow - Daily Limits Reached (Code)

### **Phase 3: Error Workflow (8 nodes)**
- [ ] Node 1: Error Webhook (Webhook trigger)
- [ ] Node 2: Route Error Source (IF condition)
- [ ] Node 3: Process Main Workflow Error (Code)
- [ ] Node 4: Process Webhook Error (Code)
- [ ] Node 5: Send Pushover Notification (Pushover)
- [ ] Node 6: Update Airtable Error Status (Airtable update)
- [ ] Node 7: Log Error Details (Code)
- [ ] Node 8: Error Response (Respond to Webhook)

### **Phase 4: Webhook Workflow (17 nodes)**
- [ ] Node 1: Postal Webhook (Webhook trigger)
- [ ] Node 2: Route Event Type (IF condition)
- [ ] Node 3: Route Bounce Events (IF condition)
- [ ] Node 4: Handle Delivery Success (Code)
- [ ] Node 5: Find Lead by Message ID (Airtable get)
- [ ] Node 6: Determine Follow-up Action (Code)
- [ ] Node 7: Route Action (IF condition)
- [ ] Node 8: Schedule Next Message (Airtable update)
- [ ] Node 9: Mark Campaign Complete (Airtable update)
- [ ] Node 10: Handle Bounce Events (Code)
- [ ] Node 11: Find Bounced Lead (Airtable get)
- [ ] Node 12: Check Retry Count (IF condition)
- [ ] Node 13: Retry Logic (Code)
- [ ] Node 14: Mark as Invalid Email (Airtable update)
- [ ] Node 15: Schedule Retry (Airtable update)
- [ ] Node 16: Mark as Soft Bounce (Airtable update)
- [ ] Node 17: Webhook Response (Respond to Webhook)

### **Phase 5: Integration & Testing**
- [ ] Connect webhook URL to Postal server
- [ ] Test with sample lead data
- [ ] Verify Airtable field updates
- [ ] Test bounce handling
- [ ] Test follow-up scheduling
- [ ] Test daily limit enforcement
- [ ] Test error handling and retry logic

---

## 🔧 COMMON VARIABLE PATTERNS

### **Airtable Query Filters**
```javascript
// Priority lead query
filterByFormula: "AND({Lead Status} = 'Queued', OR(AND({Message Type} = 'email1', {Send Date} <= NOW()), AND({Message Type} = 'email2', {Send Date} <= NOW()), AND({Message Type} = 'email3', {Send Date} <= NOW()), AND({Message Type} = 'email4', {Send Date} <= NOW()), AND({Message Type} = 'email5', {Send Date} <= NOW())))"

// Available accounts query
filterByFormula: "AND({Status} = 'Active', FIND('{{ $json.fields['Campaign'] }}', {Campaigns}), {Sent Today} < {Daily Limit})"
```

### **IF Node Conditions**
```javascript
// Check account availability
leftValue: "={{ $json.no_accounts_available }}"
rightValue: true
operator: "equal"

// Check sequence completion
leftValue: "={{ $json.is_sequence_complete }}"
rightValue: true
operator: "equal"
```

### **HTTP Request Configuration**
```javascript
// Postal API request
method: "POST"
url: "https://postal.ottomatik.ai/api/v1/send/message"
headers: {
  "X-Server-API-Key": "={{ $credentials.postalApiKey }}",
  "Content-Type": "application/json"
}
body: {
  "rcpt_to": "={{ $json.postal_payload.rcpt_to }}",
  "mail_from": "={{ $json.postal_payload.mail_from }}",
  "message": "={{ $json.postal_payload.message }}"
}
```

---

## 🚨 TROUBLESHOOTING GUIDE

### **Common Variable Issues**

#### **Field Name Mismatches**
```javascript
// ❌ Wrong - field names with spaces need brackets
$json.fields.Lead Status

// ✅ Correct - use brackets for field names with spaces
$json.fields['Lead Status']
```

#### **Record ID Access**
```javascript
// ❌ Wrong - accessing nested Airtable response
$json.id

// ✅ Correct - Airtable Record ID is in fields.id
$json.fields['id']
```

#### **Message-ID Extraction**
```javascript
// ❌ Wrong - incorrect split index
messageId.split('-')[2]

// ✅ Correct - Record ID is at index 4
messageId.split('-')[4].split('@')[0]
```

### **Airtable Connection Issues**
- Verify base ID is correct (not `appXXXXXXXXXXXXXX`)
- Check API key permissions
- Ensure field names match exactly (case-sensitive)
- Use `fieldsToSend: "defined"` for update operations

### **Postal API Issues**
- Verify API key is correct
- Check webhook URL is accessible
- Ensure Message-ID format matches expected pattern
- Verify RFC 2822 message format

### **Webhook Issues**
- Test webhook endpoint manually
- Check Postal webhook configuration
- Verify webhook response format
- Ensure proper HTTP response codes

---

## 📝 NOTES

- **Field names are case-sensitive** - always use exact Airtable field names
- **Spaces in field names** - always use bracket notation `['Field Name']`
- **Record ID extraction** - always use `split('-')[4].split('@')[0]` pattern
- **Date formatting** - use appropriate format for each field type
- **Variable consistency** - use same variable names throughout workflows
- **Test each node** - verify data flow before connecting to next node

---

**This document should be referenced throughout the workflow building process to ensure consistency and accuracy.**
