# Airtable Setup Guide for Email Warmup System

## 📊 Required Tables

### Table 1: "Email Accounts"
**Import this CSV:** `email-accounts-schema.csv`

**IMPORTANT**: After import, you can clear the sample data and start fresh - it's only for field type detection.

**Field Configuration (Auto-detected from CSV):**
- **Email Address**: Single line text (Primary field)
- **Daily Limit**: Number (integer)
- **Sent Today**: Number (integer)
- **Status**: Single select options: `Active`, `Paused`
- **Warmup Start Date**: Date
- **Health Status**: Single select options: `healthy`, `paused`, `stuck`
- **Days Active**: Number (integer)
- **Bounce Rate**: Number (decimal, represents percentage)
- **Complaint Rate**: Number (decimal, represents percentage)
- **Last Updated**: Date & time

### Table 2: "WarmupHistory"
**Import this CSV:** `warmup-history-schema.csv`

**IMPORTANT**: After import, delete the 3 sample data rows - they're only for field type detection.

**Field Configuration (Auto-detected from CSV):**
- **Timestamp**: Date & time (Primary field)
- **Email**: Single line text  
- **Domain**: Single line text
- **Previous Limit**: Number (integer)
- **New Limit**: Number (integer) 
- **Increment**: Number (integer)
- **Days Active**: Number (integer)
- **Health Status**: Single line text
- **Reason**: Long text
- **Bounce Rate**: Number (decimal, represents percentage)
- **Complaint Rate**: Number (decimal, represents percentage)

### Table 3: "Domain Metrics"
**Import this CSV:** `domain-metrics-schema.csv`

**IMPORTANT**: After import, you can clear the 9 sample domain rows and let the workflow populate real data.

**Field Configuration (Auto-detected from CSV):**
- **Domain**: Single line text (Primary field)
- **Email Count**: Number (integer)
- **Total Daily Limit**: Number (integer)
- **Total Sent Today**: Number (integer)
- **Bounce Rate**: Number (decimal, represents percentage)
- **Complaint Rate**: Number (decimal, represents percentage)
- **Health Status**: Single select options: `healthy`, `issues`, `paused`
- **Last Updated**: Date & time
- **Average Days Active**: Number (integer)
- **SparkPost Verified**: Checkbox
- **Postal Routes Active**: Checkbox
- **Domain Age Days**: Number (integer)
- **Risk Level**: Single select options: `low`, `medium`, `high`

## 🔧 Setup Steps

1. **Create new Airtable Base** or use existing "CRM | ottomatik[ai]"
2. **Create "Email Accounts" table**
3. **Import email-accounts-schema.csv** 
4. **Create "WarmupHistory" table**
5. **Import warmup-history-schema.csv**
6. **Create "Domain Metrics" table**
7. **Import domain-metrics-schema.csv**
8. **Configure field types** as specified above
9. **Copy Base ID** from Airtable URL: `airtable.com/BASE_ID/...`
10. **Copy Table IDs** from table URLs
11. **Update n8n workflow** with your actual Base/Table IDs
12. **Connect Domain Tracking Nodes**: Manually connect "Prepare Summary Report" → "Process Domain Metrics" → "Update Domain Metrics Table" in n8n workflow

## 📋 Domains Included (36 Email Addresses)

1. **aibdrsys.com** (4 addresses)
2. **ottobdr.co** (4 addresses)
3. **ottobdr.com** (4 addresses)
4. **ottobdrsys.com** (4 addresses)
5. **smartbdr.co** (4 addresses)
6. **smartbdrsys.com** (4 addresses)
7. **smarterbdr.co** (4 addresses)
8. **smarterbdr.com** (4 addresses)
9. **smarterbdrsys.com** (4 addresses)

### Email Patterns for Each Domain:
- `bryce@domain.com`
- `bryce.h@domain.com`
- `bhenderson@domain.com`
- `b.henderson@domain.com`

## 🚀 Ready to Import!

All email addresses start with:
- **Daily Limit**: 1
- **Sent Today**: 0  
- **Status**: Active
- **Health Status**: healthy
