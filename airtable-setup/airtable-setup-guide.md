# Airtable Setup Guide for Email Warmup System

## 📊 Required Tables

### Table 1: "Email Accounts"
**Import this CSV:** `email-accounts-complete.csv`

**Field Configuration:**
- **Email Address**: Single line text (Primary field)
- **Daily Limit**: Number
- **Sent Today**: Number
- **Status**: Single select options: `Active`, `Paused`
- **Warmup Start Date**: Date
- **Health Status**: Single select options: `healthy`, `paused`, `stuck`
- **Days Active**: Number
- **Bounce Rate**: Number (0.00 format)
- **Complaint Rate**: Number (0.00 format)
- **Last Updated**: Date & time

### Table 2: "WarmupHistory"
**Import this CSV:** `warmup-history-schema.csv`

**Field Configuration:**
- **Timestamp**: Date & time (Primary field)
- **Email**: Single line text
- **Domain**: Single line text
- **Previous Limit**: Number
- **New Limit**: Number
- **Increment**: Number
- **Days Active**: Number
- **Health Status**: Single line text
- **Reason**: Long text
- **Bounce Rate**: Number (0.00 format)
- **Complaint Rate**: Number (0.00 format)

## 🔧 Setup Steps

1. **Create new Airtable Base** or use existing "CRM | ottomatik[ai]"
2. **Create "Email Accounts" table**
3. **Import email-accounts-complete.csv** 
4. **Create "WarmupHistory" table**
5. **Configure field types** as specified above
6. **Copy Base ID** from Airtable URL: `airtable.com/BASE_ID/...`
7. **Copy Table IDs** from table URLs
8. **Update n8n workflow** with your actual Base/Table IDs

## 📋 Domains Included (36 Email Addresses)

1. **aibdrsys.com** (4 addresses)
2. **aipracticeautomation.com** (4 addresses)
3. **myaibdr.com** (4 addresses)
4. **ottomatik.ai** (4 addresses)
5. **smarterbdr.com** (4 addresses)
6. **smarterleadgen.com** (4 addresses)
7. **smartermarketing.ca** (4 addresses)
8. **talktoyourdoc.ca** (4 addresses)
9. **vbdatabase.ca** (4 addresses)

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
