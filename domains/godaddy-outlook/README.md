# GoDaddy/Outlook Domain Management

This directory contains documentation and configurations for ottomatik[ai] domains that are managed through GoDaddy with Outlook email hosting.

## Domains

### **ottomatik[ai] GoDaddy/Outlook Domains (3)**
- **goottomatik.com**
- **getottomatik.com** 
- **tryottomatik.com**

## Key Differences from Cloudflare Domains

### **DNS Management**
- **Provider**: GoDaddy DNS (not Cloudflare)
- **Nameservers**: GoDaddy nameservers
- **DNS Records**: Managed through GoDaddy control panel
- **No BIND files**: DNS configured directly in GoDaddy interface

### **Email Hosting**
- **Provider**: Microsoft Outlook/Office 365
- **IMAP Server**: `imap.secureserver.net`
- **IMAP Port**: 993 (SSL/TLS)
- **Individual Passwords**: Each email has unique password

### **Domain Forwarding**
- **Provider**: GoDaddy domain forwarding (not Netlify)
- **Configuration**: Set up in GoDaddy control panel
- **Target**: Redirect to ottomatik.ai or specific landing pages

## Email Configuration

### **IMAP Settings**
```
Host: imap.secureserver.net
Port: 993
Security: SSL/TLS
Authentication: Individual passwords per email
```

### **Email Addresses**
- **goottomatik.com**: 3 email addresses
- **getottomatik.com**: 3 email addresses  
- **tryottomatik.com**: 3 email addresses
- **Total**: 9 email addresses across 3 domains

## Setup Process

### **For New GoDaddy/Outlook Domains:**
1. **Purchase domain** through GoDaddy
2. **Set up Outlook email hosting** in GoDaddy
3. **Configure DNS records** in GoDaddy control panel
4. **Set up domain forwarding** in GoDaddy
5. **Add email addresses** to IMAP API configuration
6. **Test email sending/receiving**

### **DNS Records Required:**
- **A Records**: Point to hosting provider
- **CNAME Records**: www subdomain
- **MX Records**: Outlook email servers
- **TXT Records**: SPF, DKIM, DMARC (if needed)

## Important Notes

- **Separate from Cloudflare**: These domains don't use Cloudflare DNS
- **Individual Management**: Each domain managed separately in GoDaddy
- **No BIND Files**: DNS configured through GoDaddy interface
- **Outlook Integration**: Email hosted through Microsoft Outlook
- **Domain Forwarding**: Handled by GoDaddy, not Netlify

## Files in This Directory

- **README.md**: This documentation
- **dns-records.md**: DNS record requirements and examples
- **email-setup.md**: Email configuration guide
- **domain-forwarding.md**: GoDaddy forwarding setup



