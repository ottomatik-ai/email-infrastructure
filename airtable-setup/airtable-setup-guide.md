# Airtable Setup Guide for Email Warmup System

## 📊 Required Tables

### Table 1: "Email Accounts"
**Import this CSV:** `email-accounts-schema.csv`

**⚠️ DELETE SAMPLE ROW**: After import, immediately delete the one sample row - it's ONLY for field type detection!

**⚠️ MANUAL FIXES REQUIRED**: 
1. Change "Email Address" field type from "Single line text" to "Email" after import
2. Change "Sender" field type from "Single select" to "Single line text" (Airtable auto-detects as select because all values are identical)

**Field Configuration (Auto-detected from CSV):**
- **Email Address**: Email (Primary field) - ⚠️ *Imports as Single line text, manually change to Email*
- **Sender**: Single line text - ⚠️ *May import as Single select, manually change to Single line text*
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

**⚠️ DELETE SAMPLE ROW**: After import, immediately delete the one sample row - it's ONLY for field type detection!

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

**⚠️ DELETE SAMPLE ROW**: After import, immediately delete the one sample row - it's ONLY for field type detection!

**⚠️ MANUAL FIX REQUIRED**: Change "Domain" field type from "Single line text" to "URL" after import.

**Field Configuration (Auto-detected from CSV):**
- **Domain**: URL (Primary field) - ⚠️ *Imports as Single line text, manually change to URL*
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
4. **⚠️ CRITICAL**: Change "Email Address" field type from "Single line text" to "Email"
5. **⚠️ CRITICAL**: Change "Sender" field type from "Single select" to "Single line text"
6. **Create "WarmupHistory" table**
7. **Import warmup-history-schema.csv**
8. **Create "Domain Metrics" table**
9. **Import domain-metrics-schema.csv**
10. **⚠️ CRITICAL**: Change "Domain" field type from "Single line text" to "URL"
11. **Configure field types** as specified above
12. **Copy Base ID** from Airtable URL: `airtable.com/BASE_ID/...`
13. **Copy Table IDs** from table URLs
14. **Update n8n workflow** with your actual Base/Table IDs
15. **Connect Domain Tracking Nodes**: Manually connect "Prepare Summary Report" → "Process Domain Metrics" → "Update Domain Metrics Table" in n8n workflow

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
