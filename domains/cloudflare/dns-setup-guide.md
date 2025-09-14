# DNS Setup Guide

## Overview

This guide explains how to configure DNS records for email infrastructure using Cloudflare. The BIND template provides essential records without Cloudflare-specific details.

## ⚠️ CRITICAL: DNS-ONLY Configuration

**ALL DNS RECORDS MUST BE DNS-ONLY (NO PROXY) IN CLOUDFLARE**

- **Orange Cloud OFF** - Disable Cloudflare proxy for all records
- **Email records require direct DNS resolution** - Proxy breaks email authentication
- **MX, SPF, DKIM, DMARC records** - Must be DNS-only for proper email delivery
- **A and CNAME records** - Must be DNS-only for Netlify integration

## DNS Records Required

### **1. A Record (Root Domain)**
```
{DOMAIN}.    A    {NETLIFY_IP}
```
- **Purpose**: Points root domain to Netlify
- **Value**: Netlify IP address (e.g., 75.2.60.5)
- **⚠️ CRITICAL**: DNS-ONLY (Orange cloud OFF) - Proxy breaks Netlify integration

### **2. CNAME Record (WWW)**
```
www.{DOMAIN}.    CNAME    {NETLIFY_SITE}.netlify.app.
```
- **Purpose**: Points www subdomain to Netlify site
- **Value**: Netlify site URL (e.g., glittering-daifuku-9f7966.netlify.app)
- **⚠️ CRITICAL**: DNS-ONLY (Orange cloud OFF) - Proxy breaks Netlify integration

### **3. MX Records (Email)**
```
{DOMAIN}.    MX    10    aspmx1.migadu.com.
{DOMAIN}.    MX    20    aspmx2.migadu.com.
```
- **Purpose**: Routes email to Migadu servers
- **Priority**: 10 (primary), 20 (secondary)
- **⚠️ CRITICAL**: DNS-ONLY (Orange cloud OFF) - Proxy breaks email delivery

### **4. DKIM Records (Migadu)**
```
key1._domainkey.{DOMAIN}.    CNAME    key1.{DOMAIN}._domainkey.migadu.com.
key2._domainkey.{DOMAIN}.    CNAME    key2.{DOMAIN}._domainkey.migadu.com.
key3._domainkey.{DOMAIN}.    CNAME    key3.{DOMAIN}._domainkey.migadu.com.
```
- **Purpose**: Email authentication for Migadu
- **Type**: CNAME records pointing to Migadu
- **⚠️ CRITICAL**: DNS-ONLY (Orange cloud OFF) - Proxy breaks email authentication

### **5. SPF Record**
```
{DOMAIN}.    TXT    "v=spf1 include:_spf.sparkpostmail.com -all"
```
- **Purpose**: Authorizes SparkPost to send emails
- **Policy**: -all (reject all unauthorized senders)
- **⚠️ CRITICAL**: DNS-ONLY (Orange cloud OFF) - Proxy breaks email authentication

### **6. DMARC Record**
```
_dmarc.{DOMAIN}.    TXT    "v=DMARC1; p=reject; rua=mailto:bryce@ottomatik.ai"
```
- **Purpose**: Email security policy
- **Policy**: reject (strict enforcement)
- **Reporting**: Sends reports to bryce@ottomatik.ai
- **⚠️ CRITICAL**: DNS-ONLY (Orange cloud OFF) - Proxy breaks email authentication

### **7. Migadu Verification**
```
{DOMAIN}.    TXT    "hosted-email-verify={MIGADU_VERIFICATION_CODE}"
```
- **Purpose**: Verifies domain ownership with Migadu
- **Value**: Unique verification code from Migadu
- **⚠️ CRITICAL**: DNS-ONLY (Orange cloud OFF) - Proxy breaks domain verification

### **8. DKIM Public Key (SparkPost)**
```
{DKIM_SELECTOR}._domainkey.{DOMAIN}.    TXT    "v=DKIM1; k=rsa; h=sha256; p={DKIM_PUBLIC_KEY}"
```
- **Purpose**: Email authentication for SparkPost
- **Selector**: Unique identifier (e.g., scph0925)
- **Key**: RSA public key from SparkPost
- **⚠️ CRITICAL**: DNS-ONLY (Orange cloud OFF) - Proxy breaks email authentication

## Setup Process

### **1. Domain Preparation**
1. Purchase domain from any registrar
2. Change nameservers to Cloudflare
3. Wait for DNS propagation (up to 24 hours)

### **2. Cloudflare Configuration**
1. Add domain to Cloudflare account
2. Configure DNS records using template
3. **⚠️ CRITICAL**: Ensure ALL records have proxy disabled (orange cloud OFF)
4. Enable SSL/TLS encryption
5. **Verify**: All records show "DNS-only" status (gray cloud)

### **3. Netlify Setup**
1. Create new Netlify site
2. Configure custom domain
3. Set up redirects in `_redirects` file
4. Get Netlify IP and site URL for DNS records

### **4. Email Configuration**
1. Add domain to Migadu account
2. Get verification code from Migadu
3. Configure SparkPost DKIM settings
4. Test email delivery

## Template Variables

Replace these placeholders in the BIND template:

- `{DOMAIN}` → Your domain name (e.g., ptcgrowyourpeople.net)
- `{NETLIFY_IP}` → Netlify IP address (e.g., 75.2.60.5)
- `{NETLIFY_SITE}` → Netlify site identifier (e.g., glittering-daifuku-9f7966)
- `{MIGADU_VERIFICATION_CODE}` → Code from Migadu (e.g., si6nuuj5)
- `{DKIM_SELECTOR}` → SparkPost DKIM selector (e.g., scph0925)
- `{DKIM_PUBLIC_KEY}` → SparkPost DKIM public key

## Verification

### **DNS Propagation**
- Use `dig` or online tools to verify records
- Check all records are properly configured
- Ensure TTL values are appropriate

### **Email Testing**
- Send test emails to verify delivery
- Check SPF, DKIM, and DMARC alignment
- Monitor bounce rates and deliverability

### **Security**
- Verify SSL/TLS is enabled
- Check DMARC policy is working
- Monitor for unauthorized email sending

## Troubleshooting

### **Common Issues**
1. **Email not delivering**: Check MX records and authentication
2. **DNS not propagating**: Wait 24-48 hours for full propagation
3. **Authentication failures**: Verify SPF, DKIM, and DMARC records
4. **Netlify redirects not working**: Check A and CNAME records
5. **⚠️ PROXY ISSUES**: If email/redirects fail, check all records are DNS-only (gray cloud)

### **Debugging Tools**
- Cloudflare DNS checker
- MXToolbox DNS lookup
- DMARC analyzer tools
- Email authentication testers
