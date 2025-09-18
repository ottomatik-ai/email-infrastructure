# 📊 SparkPost Tracking Domains Setup Guide

## 🎯 OVERVIEW

This guide provides step-by-step instructions for configuring SparkPost tracking domains for all 9 Otto domains to enable professional email analytics and tracking.

## 📋 PHASE 1: DNS CONFIGURATION

### ✅ REQUIRED BIND RECORD CHANGES

**Update tracking domains from Postal to SparkPost:**

```dns
# CHANGE FROM (Current):
track.aibdrsys.com      CNAME → postal.ottomatik.ai
track.ottobdr.co        CNAME → postal.ottomatik.ai  
track.ottobdr.com       CNAME → postal.ottomatik.ai
track.ottobdrsys.com    CNAME → postal.ottomatik.ai
track.smartbdr.co       CNAME → postal.ottomatik.ai
track.smartbdrsys.com   CNAME → postal.ottomatik.ai
track.smarterbdr.co     CNAME → postal.ottomatik.ai
track.smarterbdr.com    CNAME → postal.ottomatik.ai
track.smarterbdrsys.com CNAME → postal.ottomatik.ai

# CHANGE TO (SparkPost):
track.aibdrsys.com      CNAME → spgo.io
track.ottobdr.co        CNAME → spgo.io  
track.ottobdr.com       CNAME → spgo.io
track.ottobdrsys.com    CNAME → spgo.io
track.smartbdr.co       CNAME → spgo.io
track.smartbdrsys.com   CNAME → spgo.io
track.smarterbdr.co     CNAME → spgo.io
track.smarterbdr.com    CNAME → spgo.io
track.smarterbdrsys.com CNAME → spgo.io
```

### 🔒 KEEP POSTAL BOUNCE HANDLING (DO NOT CHANGE)

**Return Path/Bounce Handling - KEEP AS IS:**
```dns
psrp.aibdrsys.com      CNAME → rp.postal.ottomatik.ai
psrp.ottobdr.co        CNAME → rp.postal.ottomatik.ai  
psrp.ottobdr.com       CNAME → rp.postal.ottomatik.ai
psrp.ottobdrsys.com    CNAME → rp.postal.ottomatik.ai
psrp.smartbdr.co       CNAME → rp.postal.ottomatik.ai
psrp.smartbdrsys.com   CNAME → rp.postal.ottomatik.ai
psrp.smarterbdr.co     CNAME → rp.postal.ottomatik.ai
psrp.smarterbdr.com    CNAME → rp.postal.ottomatik.ai
psrp.smarterbdrsys.com CNAME → rp.postal.ottomatik.ai
```

**⚠️ Important:** Do NOT set up SparkPost bounce domains. Keep Postal handling bounces for infrastructure consistency.

## 📋 PHASE 2: SPARKPOST DASHBOARD CONFIGURATION

### 🔧 STEP-BY-STEP SPARKPOST SETUP

**For each of the 9 Otto domains, repeat these steps:**

#### 1. **Add Sending Domain (If Not Already Done)**
```
Login to SparkPost → Configuration → Sending Domains → Add a Domain
Enter: aibdrsys.com (example)
Follow verification process with provided DNS records
```

#### 2. **Add Tracking Domain**
```
Configuration → Tracking Domains → Add a Domain
Enter: track.aibdrsys.com
Click "Add Domain"
Wait for DNS propagation (up to 24-48 hours)
Click "Verify Domain" when ready
```

#### 3. **Link Tracking Domain to Sending Domain**
```
Configuration → Sending Domains → Select aibdrsys.com
Scroll to "Link Tracking Domain" section
Change from "Always Use Default (Currently System Default)"
Select: track.aibdrsys.com
Click "Update Tracking Domain"
```

#### 4. **Verify Configuration**
```
Return to Tracking Domains section
Confirm domain shows "Verified" status ✅
Send test email to verify tracking links work
```

### 📊 ALL 9 DOMAINS TO CONFIGURE

**Repeat above steps for each domain:**

1. **aibdrsys.com** → **track.aibdrsys.com**
2. **ottobdr.co** → **track.ottobdr.co**
3. **ottobdr.com** → **track.ottobdr.com**
4. **ottobdrsys.com** → **track.ottobdrsys.com**
5. **smartbdr.co** → **track.smartbdr.co**
6. **smartbdrsys.com** → **track.smartbdrsys.com**
7. **smarterbdr.co** → **track.smarterbdr.co**
8. **smarterbdr.com** → **track.smarterbdr.com**
9. **smarterbdrsys.com** → **track.smarterbdrsys.com**

## 📋 PHASE 3: WEBHOOK CONFIGURATION

### 🔔 SETUP SPARKPOST WEBHOOKS FOR N8N

**Configure webhook to receive real-time email events:**

#### 1. **Create Webhook Endpoint**
```
Configuration → Webhooks → Create Webhook

Webhook Settings:
- Name: "n8n Email Events"
- Target URL: https://n8n.ottomatik.ai/webhook/sparkpost-events
- Authentication: None (or Basic Auth if required)
```

#### 2. **Select Event Types**
```
✅ delivery         - Email successfully delivered
✅ bounce           - Email bounced (hard/soft)
✅ spam_complaint   - Marked as spam by recipient  
✅ click            - Link clicked in email
✅ open             - Email opened (pixel tracking)
✅ unsubscribe      - Unsubscribe link clicked
✅ out_of_band      - Delayed bounces/complaints
```

#### 3. **Configure Filters (Optional)**
```
- All domains: Leave blank for all tracking
- Specific domains: Add filter if needed
- Event filtering: Select all for comprehensive tracking
```

## 📋 PHASE 4: N8N WORKFLOW INTEGRATION

### 🔧 UPDATE EXISTING WORKFLOWS

**Modify current workflows to use SparkPost webhook data instead of API polling:**

#### 1. **Create SparkPost Webhook Receiver**
```
Add new Webhook node in n8n:
- Path: /webhook/sparkpost-events
- Method: POST
- Response: 200 OK
```

#### 2. **Process SparkPost Events**
```
Add Code node to parse webhook payload:
- Extract event type (delivery, bounce, click, open)
- Extract domain and email address
- Extract timestamp and metadata
- Format for Airtable storage
```

#### 3. **Update Airtable Integration**
```
Modify existing Airtable nodes:
- Use real-time event data instead of API polling
- Update bounce/complaint rates immediately
- Track click/open events per email address
- Monitor domain-level metrics
```

## 🧪 TESTING & VERIFICATION

### ✅ POST-SETUP CHECKLIST

**Test each domain thoroughly:**

#### 1. **DNS Verification**
- [ ] All 9 tracking domains resolve to `spgo.io`
- [ ] All 9 bounce domains still point to Postal
- [ ] DNS propagation complete (use dig/nslookup)

#### 2. **SparkPost Dashboard**
- [ ] All 9 tracking domains show "Verified" status
- [ ] All 9 sending domains linked to tracking domains
- [ ] Webhook configured and active

#### 3. **Email Testing**
- [ ] Send test emails from each domain
- [ ] Verify tracking links redirect correctly
- [ ] Confirm click tracking in SparkPost analytics
- [ ] Check open tracking pixel functionality
- [ ] Test bounce handling still works through Postal

#### 4. **N8N Integration**
- [ ] Webhook receives SparkPost events
- [ ] Event data parsed correctly
- [ ] Airtable updates in real-time
- [ ] No duplicate data from old API polling

## 📊 EXPECTED BENEFITS

### 🚀 TRACKING IMPROVEMENTS

**Vs Current Postal Setup:**

| Feature | Postal (Current) | SparkPost (New) |
|---------|------------------|-----------------|
| Click Tracking | ✅ Basic | ✅ Advanced + Analytics |
| Open Tracking | ✅ Basic | ✅ Advanced + First Opens |
| Real-time Data | ❌ Manual Polling | ✅ Instant Webhooks |
| Bounce Analysis | ⚠️ Limited | ✅ Detailed Categories |
| Spam Complaints | ⚠️ Basic | ✅ Advanced Reporting |
| Analytics Dashboard | ❌ None | ✅ Professional Charts |
| API Integration | ⚠️ Basic | ✅ Comprehensive |

### 📈 ENHANCED METRICS

**New tracking capabilities:**
- **Real-time click/open rates** per domain and email address
- **Detailed bounce categorization** (hard vs soft, reasons)
- **Spam complaint tracking** with recipient details
- **Engagement scoring** for email address warmup
- **Professional analytics** for decision-making

## 🚨 IMPORTANT NOTES

### ⚠️ CRITICAL REMINDERS

1. **Do NOT configure SparkPost bounce domains** - keep Postal handling bounces
2. **Update n8n workflows** after SparkPost setup to avoid duplicate data
3. **Test thoroughly** before relying on new tracking for production warmup
4. **Monitor both systems** during transition period
5. **Keep Postal tracking** as backup until SparkPost proven stable

### 🔄 ROLLBACK PLAN

**If issues arise, quickly rollback:**
```dns
# Revert tracking domains to Postal
track.*.com  CNAME → postal.ottomatik.ai
```

---

**Last Updated:** September 18, 2025  
**Status:** Ready for Implementation  
**Estimated Setup Time:** 2-4 hours (including DNS propagation)
