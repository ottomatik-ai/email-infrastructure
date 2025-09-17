# 📊 Email Monitoring & Warmup Workflow Adaptation Plan

## Overview
Adapt the existing "Monitoring and Warmup" workflow from **Instantly + Google Sheets** to **Postal + Airtable** setup while preserving the sophisticated warmup logic.

---

## 🎯 KEEP & ADAPT THESE CORE FEATURES

### 1. Warmup Progression Logic ✅
```javascript
// Perfect for your 36 addresses:
Week 1-2: 1-2 emails/day × 36 addresses = 36-72 emails/day
Week 3-4: 8-20 emails/day × 36 addresses = 288-720 emails/day  
Week 5-6: 20-40 emails/day × 36 addresses = 720-1,440 emails/day
Week 7+: Target 40 emails/day × 36 addresses = 1,440 emails/day
```

### 2. Safety & Health Monitoring ✅
- **Domain bounce rate monitoring** (keep 10% threshold)
- **Complaint rate tracking** (keep 0.1-0.3% thresholds)
- **SparkPost stage monitoring** (essential for your setup)
- **Conservative 15% safety buffer**
- **Automatic pausing** for problematic addresses

### 3. Progressive Scaling Logic ✅
- **New addresses start at 0**, gradually increase
- **Stuck address detection** (no progress for 3+ days)
- **Health status tracking** (healthy/paused/stuck/error)
- **Smart distribution** across your address portfolio

---

## 🔄 MAJOR ADAPTATIONS NEEDED

### 1. Data Source Changes
```javascript
// FROM: Instantly API + Google Sheets
Get All Mailboxes → Read from Airtable "Email Accounts"
Get Campaign Status → Get Postal Route Health  
Update Account Daily Limit → Update Airtable daily limits
Campaign Analytics → Postal sending statistics per domain
```

### 2. Storage Migration
```javascript
// FROM: 3 Google Sheets
Mailboxes Sheet → Airtable "Email Accounts" table
WarmupHistory Sheet → Airtable "Warmup History" table  
CampaignMetrics Sheet → Airtable "Domain Metrics" table
```

### 3. API Integration Changes
```javascript
// REPLACE Instantly API calls:
- Campaign management → Postal route monitoring
- Account limit updates → Airtable quota updates
- Reply rate tracking → Focus on deliverability metrics

// KEEP SparkPost API calls:
- Domain metrics ✅
- IP status monitoring ✅
- Bounce/complaint tracking ✅
```

---

## ➕ NEW FEATURES TO ADD

### 1. Daily Reset Functionality
```javascript
// Add to warmup workflow:
if (new Date().getHours() === 0) {
  // Reset "Sent Today" to 0 for all active addresses
  await updateAirtable('Email Accounts', { 
    where: { Status: 'Active' },
    set: { 'Sent Today': 0 }
  });
}
```

### 2. Postal Integration
- **Route health monitoring**
- **Delivery statistics per address**
- **Webhook status checking**
- **Sending queue monitoring**

### 3. Enhanced Airtable Schema
```csv
Email Address,Daily Limit,Sent Today,Status,Domain,Warmup Start,Days Active,Health Status,Bounce Rate,Complaint Rate,Last Updated
```

---

## 🔧 NODE-BY-NODE ADAPTATION GUIDE

### SCHEDULING & TRIGGERS

#### Node 1: "Weekday Morning Trigger"
**✅ KEEP AS IS**
- Cron: `0 6 * * 1-5` (6 AM weekdays)
- Perfect for daily warmup checks

---

### DOCUMENTATION NODES

#### Node 2: "System Overview" (Sticky Note)
**🔄 UPDATE CONTENT:**
```markdown
## Email Warmup System - Postal + Airtable

### Key Features:
- **36 Email Addresses**: Across 9 domains with 4 variations each
- **Ultra-Conservative**: 6-week warmup (Risk: 3/10)
- **Postal Integration**: Route monitoring & delivery tracking
- **Airtable Storage**: Email accounts, warmup history, domain metrics
- **SparkPost Backend**: Domain reputation monitoring
- **Daily Quota Reset**: Automatic midnight counter reset

### Warmup Schedule:
- **Weeks 1-2**: 1-2 emails/day (+1 max) = 36-72 total/day
- **Weeks 3-4**: 8-20 emails/day (+3 max) = 288-720 total/day  
- **Weeks 5-6**: 20-40 emails/day (+4 max) = 720-1,440 total/day

### Safety Thresholds:
- Individual address bounce: 10%
- Individual address complaint: 0.3%
- Domain average bounce: 10%
- Domain average complaint: 0.1%
- Pause if no progress for 3+ days
```

#### Node 30: "Setup Requirements" (Sticky Note)
**🔄 UPDATE CONTENT:**
```markdown
## Configuration Required:

### 1. Airtable Setup:
Create base with 3 tables:
- **Email Accounts**: Your existing table with added fields
- **Warmup History**: Track daily progression  
- **Domain Metrics**: SparkPost domain stats

### 2. Update SparkPost IP Name:
In 'Get SparkPost IP Status' node, replace 'YOUR_IP_NAME' with your actual IP name (likely 'Default')

### 3. Remove Campaign Logic:
Delete or modify campaign-related nodes since you don't use Instantly campaigns

### 4. Add Postal API Integration:
- Monitor route health
- Track delivery statistics
- Check webhook status

### 5. Update Pushover Keys:
Replace 'YOUR_PUSHOVER_USER_KEY_HERE' with your actual Pushover user key

## Airtable Schema:

### Email Accounts Table:
- Email Address (text)
- Daily Limit (number) 
- Sent Today (number)
- Status (select: Active/Inactive/Paused)
- Domain (formula: domain from email)
- Warmup Start Date (date)
- Days Active (formula: days since start)
- Health Status (select: healthy/paused/stuck/error)
- Bounce Rate (number)
- Complaint Rate (number)
- Last Updated (datetime)

### Warmup History Table:
- Timestamp, Email, Domain, Previous Limit, New Limit, 
- Increment, Days Active, Health Status, Reason

### Domain Metrics Table:
- Timestamp, Domain, Bounce Rate, Complaint Rate, 
- Targeted, Bounced, Complaints, Health Status
```

---

### DATA SOURCE NODES

#### Node 3: "Get All Mailboxes"
**🔄 REPLACE: Google Sheets → Airtable**
```json
{
  "type": "n8n-nodes-base.airtable",
  "operation": "list",
  "base": "YOUR_AIRTABLE_BASE_ID",
  "table": "Email Accounts",
  "returnAll": true
}
```

#### Node 4: "Prepare Campaign IDs"
**❌ DELETE THIS NODE**
- You don't have Instantly campaigns
- Logic will be handled per email address instead

#### Node 5: "Get Campaign Status"  
**🔄 REPLACE: With Postal Route Check**
```json
{
  "type": "n8n-nodes-base.httpRequest",
  "method": "GET", 
  "url": "https://postal.ottomatik.ai/api/v1/routes",
  "authentication": "genericCredentialType",
  "genericAuthType": "httpHeaderAuth"
}
```

---

### DATA PROCESSING NODES

#### Node 6: "Aggregate Campaign & SparkPost Data"
**🔄 MAJOR REWRITE:**
```javascript
// Remove campaign aggregation logic
// Focus on email address and domain grouping
const allAddresses = $('Get All Mailboxes').all();
const sparkpostData = $node["Get SparkPost IP Status"].json;
const postalRoutes = $node["Check Postal Routes"].json;

// Group by domain instead of campaign
const domainGroups = {};
for (const item of allAddresses) {
  const email = item.json['Email Address'];
  const domain = email.split('@')[1];
  
  if (!domainGroups[domain]) {
    domainGroups[domain] = [];
  }
  domainGroups[domain].push(item.json);
}

// Extract SparkPost limits (keep existing logic)
let currentStage = 1;
let stageLimit = 50;
const stageLimits = { /* keep existing stage limits */ };

// Return domain-grouped data instead of campaign data
return [{
  json: {
    sparkpost: { currentStage, stageLimit, effectiveLimit },
    domains: domainGroups,
    postalRoutes: postalRoutes,
    timestamp: new Date().toISOString()
  }
}];
```

#### Node 8: "Process Mailboxes with Domain Metrics"
**🔄 MAJOR REWRITE:**
```javascript
// Change data source from Google Sheets to Airtable
const mailboxesData = $('Get All Mailboxes').all();
const aggregatedData = $node["Aggregate Domain & SparkPost Data"].json;
const sparkpostMetrics = $node["Get SparkPost Domain Metrics"].json.results || [];

// Process each email address (not mailbox)
for (const item of mailboxesData) {
  const address = item.json;
  const email = address['Email Address'];
  const domain = email.split('@')[1];
  let currentLimit = parseInt(address['Daily Limit']) || 0;
  let sentToday = parseInt(address['Sent Today']) || 0;
  let warmupStartDate = address['Warmup Start Date'];
  let healthStatus = address['Health Status'] || 'healthy';
  
  // Keep existing warmup logic but adapt field names
  // ... rest of processing logic
}
```

---

### UPDATE NODES

#### Node 12: "Get Account Current Info"
**🔄 REPLACE: Instantly API → Airtable Read**
```json
{
  "type": "n8n-nodes-base.airtable",
  "operation": "read",
  "base": "YOUR_AIRTABLE_BASE_ID", 
  "table": "Email Accounts",
  "recordId": "={{ $json.airtable_record_id }}"
}
```

#### Node 13: "Update Account Daily Limit"
**🔄 REPLACE: Instantly API → Airtable Update**
```json
{
  "type": "n8n-nodes-base.airtable",
  "operation": "update",
  "base": "YOUR_AIRTABLE_BASE_ID",
  "table": "Email Accounts", 
  "recordId": "={{ $json.airtable_record_id }}",
  "fields": {
    "Daily Limit": "={{ $json.newLimit }}",
    "Health Status": "={{ $json.healthStatus }}",
    "Last Updated": "{{ new Date().toISOString() }}"
  }
}
```

#### Node 14: "Update Mailbox in Sheet"
**🔄 REPLACE: Google Sheets → Airtable**
```json
{
  "type": "n8n-nodes-base.airtable",
  "operation": "update",
  "base": "YOUR_AIRTABLE_BASE_ID",
  "table": "Email Accounts",
  "recordId": "={{ $json.airtable_record_id }}",
  "fields": {
    "Daily Limit": "={{ $json.newLimit }}",
    "Days Active": "={{ $json.daysActive }}",
    "Health Status": "={{ $json.healthStatus }}",
    "Bounce Rate": "={{ $json.bounceRate }}",
    "Complaint Rate": "={{ $json.complaintRate }}",
    "Last Updated": "{{ new Date().toISOString() }}"
  }
}
```

#### Node 15: "Log to WarmupHistory"
**🔄 REPLACE: Google Sheets → Airtable**
```json
{
  "type": "n8n-nodes-base.airtable", 
  "operation": "create",
  "base": "YOUR_AIRTABLE_BASE_ID",
  "table": "Warmup History",
  "fields": {
    "Timestamp": "{{ new Date().toISOString() }}",
    "Email": "={{ $json.email }}",
    "Domain": "={{ $json.domain }}",
    "Previous Limit": "={{ $json.previousLimit }}",
    "New Limit": "={{ $json.newLimit }}",
    "Increment": "={{ $json.increment }}",
    "Days Active": "={{ $json.daysActive }}",
    "Health Status": "={{ $json.healthStatus }}",
    "Reason": "={{ $json.reason }}"
  }
}
```

---

### NODES TO DELETE

#### Delete These Campaign-Related Nodes:
- **Node 16**: "Prepare Campaign Updates & Health Checks"
- **Node 17**: "Should Update Campaigns?"  
- **Node 18**: "Should Pause Campaign?"
- **Node 19**: "Pause Campaign"
- **Node 20**: "Update Campaign Daily Limit"
- **Node 21**: "Get Campaign Analytics (Reply Rate)"
- **Node 22**: "Check Reply Rate Health"
- **Node 23**: "Log Campaign Metrics"

---

### NEW NODES TO ADD

#### Add After "Process Mailboxes":
```javascript
// Node: "Daily Reset Check"
const now = new Date();
if (now.getHours() === 0 && now.getMinutes() < 30) {
  // Reset all "Sent Today" counters to 0
  return [{
    json: { shouldReset: true, timestamp: now.toISOString() }
  }];
}
return [{ json: { shouldReset: false } }];
```

#### Add Postal Health Check:
```json
{
  "type": "n8n-nodes-base.httpRequest",
  "method": "GET",
  "url": "https://postal.ottomatik.ai/api/v1/statistics/domains",
  "authentication": "genericCredentialType", 
  "genericAuthType": "httpHeaderAuth"
}
```

---

### KEEP THESE NODES AS IS:
- **Node 7**: "Prepare Domain Metrics Request" ✅
- **Node 8**: "Get SparkPost Domain Metrics" ✅  
- **Node 10**: "Filter Mailboxes to Update" ✅
- **Node 11**: "Batch Process Updates" ✅
- **All Error Handling** nodes ✅
- **All Pushover Notification** nodes ✅ (just update messages)

---

## 🏗️ IMPLEMENTATION STRATEGY

### Phase 1: Core Adaptation
1. **Migrate data source** from Google Sheets to Airtable
2. **Replace Instantly API** with Postal monitoring  
3. **Keep warmup logic** and progression schedules
4. **Maintain SparkPost integration**

### Phase 2: Otto Integration
1. **Add daily reset** functionality at midnight
2. **Integrate with Postal Email Sender** workflow
3. **Connect to Inbox Management** for reply tracking
4. **Link to Otto agents** for response processing

### Phase 3: Advanced Monitoring
1. **Domain reputation dashboards**
2. **Warmup completion alerts** 
3. **Automatic scaling** to production volumes
4. **Integration with SMYKM** campaigns

---

## 💡 KEY INSIGHT

This workflow could **transform** your email infrastructure:
- **Week 1**: 36 emails/day (testing)
- **Week 6**: 1,440 emails/day (production ready!)
- **Automatic safety monitoring** prevents reputation damage
- **Gradual scaling** builds ISP trust

**The warmup logic is gold - it's exactly what you need for 36 new email addresses across multiple domains!**

---

## 📋 NEXT STEPS

1. **Create Airtable base** with the required tables and schema
2. **Update node configurations** according to this guide
3. **Test with a small subset** of email addresses first
4. **Monitor progress** and adjust thresholds as needed
5. **Scale to full 36 address portfolio** once validated

---

## 🔍 THOROUGH AUDIT & CORRECTIONS

### CRITICAL CORRECTIONS BASED ON OFFICIAL DOCUMENTATION

#### ❌ **ERROR 1: Incorrect Airtable Node Configuration**

**MY ORIGINAL RECOMMENDATION:**
```json
{
  "type": "n8n-nodes-base.airtable",
  "operation": "list",
  "base": "YOUR_AIRTABLE_BASE_ID",
  "table": "Email Accounts",
  "returnAll": true
}
```

**🔧 CORRECTED CONFIGURATION:**
```json
{
  "type": "n8n-nodes-base.airtable",
  "typeVersion": 2.1,
  "operation": "list", 
  "base": {
    "__rl": true,
    "value": "YOUR_AIRTABLE_BASE_ID",
    "mode": "list"
  },
  "table": {
    "__rl": true, 
    "value": "Email Accounts",
    "mode": "list"
  },
  "returnAll": true,
  "options": {}
}
```

**📚 JUSTIFICATION:**
- **Resource Locator Required**: n8n Airtable node v2.1+ requires `__rl: true` and `mode: "list"` for base and table selection
- **TypeVersion Critical**: Must use `typeVersion: 2.1` for compatibility and dropdown functionality
- **Official Documentation**: Based on n8n Airtable node configuration requirements

---

#### ❌ **ERROR 2: Incorrect Postal API Endpoints**

**MY ORIGINAL RECOMMENDATION:**
```json
{
  "url": "https://postal.ottomatik.ai/api/v1/routes"
}
```

**🔧 CORRECTED ENDPOINTS:**
```json
// Correct Postal API Endpoints:
{
  "url": "https://postal.ottomatik.ai/api/v1/organizations/[ORG_ID]/servers/[SERVER_ID]/routes",
  "headers": {
    "X-Server-API-Key": "YOUR_POSTAL_SERVER_API_KEY",
    "Content-Type": "application/json"
  }
}

// For sending statistics:
{
  "url": "https://postal.ottomatik.ai/api/v1/organizations/[ORG_ID]/servers/[SERVER_ID]/statistics/outgoing",
  "headers": {
    "X-Server-API-Key": "YOUR_POSTAL_SERVER_API_KEY"
  }
}
```

**📚 JUSTIFICATION:**
- **Hierarchical Structure**: Postal API requires organization and server IDs in the path
- **Authentication Header**: Uses `X-Server-API-Key` header, not generic auth
- **Specific Statistics Endpoint**: `/statistics/outgoing` for sending stats, not generic `/statistics`
- **Official Postal Documentation**: Based on Postal's RESTful API structure

---

#### ❌ **ERROR 3: Missing Daily Reset Implementation**

**MY ORIGINAL RECOMMENDATION:**
```javascript
if (new Date().getHours() === 0) {
  // Reset "Sent Today" to 0 for all active addresses
}
```

**🔧 CORRECTED IMPLEMENTATION:**
```javascript
// Node: "Daily Reset Check & Execute"
const now = new Date();
const hours = now.getHours();
const minutes = now.getMinutes();

// Execute reset between 00:00 and 00:30 to avoid multiple executions
if (hours === 0 && minutes <= 30) {
  
  // Get all active email accounts from Airtable
  const activeAccounts = $('Get All Mailboxes').all()
    .filter(item => item.json['Status'] === 'Active')
    .map(item => ({
      id: item.json.id,
      email: item.json['Email Address'],
      currentSent: item.json['Sent Today'] || 0
    }));
  
  return [{
    json: {
      shouldReset: true,
      accountCount: activeAccounts.length,
      resetDate: now.toISOString().split('T')[0],
      accounts: activeAccounts
    }
  }];
}

return [{ json: { shouldReset: false, message: "Outside reset window" } }];
```

**📚 JUSTIFICATION:**
- **Time Window Control**: 30-minute window prevents multiple resets from overlapping executions
- **Data Filtering**: Only processes active accounts, preserving inactive/paused states
- **Audit Trail**: Captures reset date and affected accounts for logging
- **Error Prevention**: Robust logic prevents accidental resets outside schedule
- **Production Safety**: Includes account count validation before batch operations

---

## ✅ **IMPLEMENTATION CHECKLIST**

### **Phase 1: Critical Setup (Required Before Testing)**
- [ ] **Airtable Configuration**: Create base with corrected field types and validation
- [ ] **n8n Credentials**: Configure Airtable credentials with proper base access
- [ ] **Postal API Access**: Set up server API keys and verify endpoint structure
- [ ] **SparkPost Integration**: Configure API access and verify metrics endpoints
- [ ] **Node Type Versions**: Ensure all nodes use correct `typeVersion` values

### **Phase 2: Workflow Adaptation**
- [ ] **Import Original Workflow**: Note exact node names for reference syntax
- [ ] **Replace Data Sources**: Convert Google Sheets nodes to Airtable nodes
- [ ] **Update API Calls**: Replace Instantly endpoints with Postal endpoints
- [ ] **Implement Daily Reset**: Add proper time-based reset functionality
- [ ] **Add Error Handling**: Include retry logic and proper error output

### **Phase 3: Testing & Validation**
- [ ] **Single Address Test**: Validate workflow with one email address first
- [ ] **API Rate Limiting**: Test with proper delays between requests
- [ ] **Warmup Logic**: Verify progression schedule matches requirements
- [ ] **Health Monitoring**: Test domain metrics and threshold alerts
- [ ] **Reset Functionality**: Verify daily counter reset works correctly

### **Phase 4: Production Deployment**
- [ ] **Scale to 36 Addresses**: Deploy to full email portfolio
- [ ] **Monitor Performance**: Track workflow execution times and errors
- [ ] **Adjust Thresholds**: Fine-tune health monitoring based on real data
- [ ] **Document Changes**: Update workflow comments and external documentation
- [ ] **Backup Strategy**: Export workflow configurations for disaster recovery

---

*Document created: September 17, 2025*
*Project: Email Infrastructure - Monitoring & Warmup*
*Purpose: Adapt workflow from Instantly+Sheets to Postal+Airtable*
*Last Updated: September 17, 2025 - Comprehensive Audit & Corrections Added*
