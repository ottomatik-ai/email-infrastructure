# Email Infrastructure

Comprehensive email infrastructure management system for cold email campaigns, domain management, and automated email processing.

## Architecture Overview

### **Complete Email Stack:**
- **📤 Sending**: SparkPost (SMTP) - High deliverability email sending
- **📥 Receiving**: Migadu (IMAP) - Email inbox management  
- **🌐 Domain Forwarding**: Netlify - Domain-to-domain email routing
- ** Domain Management**: Various sellers → Cloudflare nameservers
- **⚡ Processing**: n8n workflows - Automated reply handling

### **Infrastructure Components:**
- **Domain Strategy** - Multi-domain email campaigns
- **SMTP Configuration** - SparkPost sending setup
- **IMAP Integration** - Migadu inbox management
- **Domain Forwarding** - Netlify email routing
- **Client Configurations** - Scalable client email setups
- **Campaign Infrastructure** - Cold email campaign support
- **n8n Workflow Integration** - Automated reply processing

## Current Infrastructure

### **Total Email Infrastructure:**
- **93 Email Addresses** across **24 Domains**
- **2 Active Clients** (PTC + ottomatik[ai])
- **Mixed Providers** (Migadu + GoDaddy)
- **Automated Processing** via n8n workflows

### **Client Breakdown:**
- **Pull The Chute (PTC)**: 48 email addresses, 12 domains
- **ottomatik[ai] (otto)**: 45 email addresses, 12 domains (9 Cloudflare + 3 GoDaddy/Outlook)

## Email Infrastructure Stack

### **1. Domain Management**
```
Domain Purchase → Cloudflare Nameservers → Netlify Forwarding → Migadu Inboxes
```

### **2. Sending Infrastructure**
- **SparkPost SMTP** - Primary sending service
- **High Deliverability** - Professional email delivery
- **Campaign Management** - Bulk email sending

### **3. Receiving Infrastructure**
- **Migadu IMAP** - Primary inbox management
- **GoDaddy/Outlook** - Secondary provider for specific domains
- **Automated Processing** - n8n webhook integration

### **4. Domain Forwarding**
- **Netlify** - Handles domain-to-domain email routing
- **Seamless Integration** - Transparent email forwarding
- **Multi-Domain Support** - Scales with campaign needs

## Quick Start

1. **Access IMAP API**: `http://98.81.118.238:3000`
2. **Import configurations** from `/mailboxes/` directory
3. **Configure webhooks** for n8n integration
4. **Monitor email processing** via webhook URLs

## Repository Structure

```
email-infrastructure/
├── mailboxes/                    # Email account configurations
│   ├── otto-mailboxes.json      # ottomatik[ai] email setup (45 addresses)
│   └── clients/                 # Client email configurations
│       ├── ptc-mailboxes.json   # Pull The Chute setup (48 addresses)
│       └── {slug}-mailboxes.json # Client template
├── domains/                     # Domain management
│   ├── cloudflare/             # DNS configurations
│   │   └── dns-config.json     # Cloudflare DNS settings
│   ├── netlify/                # Domain redirects
│   │   ├── _redirects          # Netlify redirect rules
│   │   ├── index.html          # Redirect page template
│   │   └── README.md           # Netlify setup guide
│   └── dns/                    # Domain tracking
│       └── domain-inventory.md # Domain portfolio
├── smtp/                       # Email sending
│   └── sparkpost/              # SparkPost configuration
│       └── sparkpost-config.json # SMTP settings
├── webhooks/                   # n8n integration
│   ├── n8n-webhooks.json      # Webhook configurations
│   └── webhook-urls.md        # Active webhook URLs
└── docs/                      # Documentation
    ├── email-flow.md          # Complete email flow
    ├── add-mailbox.md         # Adding email accounts
    ├── remove-mailbox.md      # Removing email accounts
    └── webhook-setup.md       # Webhook configuration
```

## Client Mailbox Configuration

### Template Structure

Client mailboxes follow this standardized JSON structure:

```json
{
  "client_slug": "client-slug",
  "mailboxes": [
    {
      "name": "client-slug-email-identifier",
      "email": "email@domain.com",
      "from_name": "Contact Name",
      "imap": {
        "host": "imap.migadu.com",
        "port": 993,
        "secure": true,
        "auth": {
          "user": "email@domain.com",
          "pass": "email-password"
        }
      },
      "webhook_enabled": true,
      "n8n_workflow": "https://n8n.ottomatik.ai/webhook/client-slug-inbox-management"
    }
  ],
  "migadu_settings": {
    "imap_server": "imap.migadu.com",
    "imap_port": 993,
    "security": "SSL/TLS",
    "provider": "Migadu",
    "domains": ["domain1.com", "domain2.com"]
  }
}
```

### Required Fields

- **`name`**: Unique identifier (format: `{slug}-{email-identifier}`)
- **`email`**: Full email address
- **`from_name`**: Display name for outgoing emails
- **`imap.host`**: IMAP server (Migadu: `imap.migadu.com`)
- **`imap.port`**: Port number (993 for SSL)
- **`imap.secure`**: Boolean (true for SSL/TLS)
- **`imap.auth.user`**: Email address for authentication
- **`imap.auth.pass`**: Email password
- **`webhook_enabled`**: Boolean for n8n integration
- **`n8n_workflow`**: Webhook URL for email processing

### Creating New Client Configuration

1. Copy `{slug}-mailboxes.json` template
2. Replace `{slug}` with client identifier
3. Update email addresses and domains
4. Set correct `from_name` and password
5. Configure webhook URL

## Infrastructure Services

### **IMAP API Access**
- **URL**: http://98.81.118.238:3000
- **Status**: ✅ Running
- **Redis**: Connected to `n8n_ottomatik_ai_otto-redis:6379/7`

### **SparkPost SMTP**
- **Service**: Email sending platform
- **Purpose**: High deliverability cold email campaigns
- **Integration**: Direct SMTP configuration

### **Migadu IMAP**
- **Service**: Email inbox management
- **Purpose**: Receiving and processing replies
- **Integration**: IMAP API for automated processing

### **Netlify Domain Forwarding**
- **Service**: Domain-to-domain email routing
- **Purpose**: Seamless email forwarding
- **Integration**: DNS configuration

### **Cloudflare Nameservers**
- **Service**: DNS management
- **Purpose**: Domain resolution and management
- **Integration**: Nameserver configuration

## Workflow Integration

### **n8n Automation**
- **Webhook Processing** - Automated reply handling
- **Campaign Management** - Email sequence automation
- **Client Routing** - Multi-client email processing

### **Email Processing Flow**
```
Incoming Email → Migadu IMAP → n8n Webhook → Automated Processing → Response
```

## Best Practices

### **Domain Management**
- Use Cloudflare for DNS management
- Set up Netlify forwarding for new domains
- Maintain consistent naming conventions

### **Email Configuration**
- Use SparkPost for sending campaigns
- Configure Migadu for receiving replies
- Set up proper webhook URLs for automation

### **Client Onboarding**
- Copy template configuration
- Update domain and email settings
- Test webhook integration
- Verify email flow end-to-end

### **⚠️ CRITICAL: Domain Setup Verification**
**Before making any repository changes for new domains, ALWAYS ask:**
- "Have you completed all 11 steps of the domain setup process?"
- "Have you added the domains to Netlify as domain aliases?"
- "Are the domains showing green checkmarks in Netlify Domain Management?"
- "Have you configured the DNS records (DNS-only, no proxy)?"

**If NO to any question, STOP and have them complete manual setup first.**

### **Complete 11-Step Domain Setup Process:**
1. **Purchase domains**
2. **Set up Google Workspace email alias** (`{slug}@ottomatik.ai`)
3. **Create Cloudflare account** for client
4. **Update domain nameservers** to Cloudflare
5. **Add domains to Migadu** and copy verifier codes
6. **Download BIND files** from Migadu and upload to Cloudflare
7. **Verify domains** in Migadu
8. **Add domains to SparkPost** and copy DKIM information
9. **Provide DKIM and verifier codes** to Cursor for BIND file creation
10. **Create and upload complete BIND files** to Cloudflare (separate file per domain, includes SparkPost, Migadu, Netlify)
11. **Verify domains on SparkPost**

## Documentation

- **[Complete Email Flow](docs/email-flow.md)** - Detailed infrastructure flow
- **[Domain Inventory](domains/dns/domain-inventory.md)** - Domain tracking
- **[Client BIND Files](domains/cloudflare/clients/README.md)** - Individual domain BIND files for easy upload
- **[GoDaddy/Outlook Domains](domains/godaddy-outlook/README.md)** - Domains managed through GoDaddy with Outlook email
- **[Domain Setup Guide](domains/netlify/domain-setup-guide.md)** - ⚠️ CRITICAL: How to add new domains
- **[Netlify Setup](domains/netlify/README.md)** - Domain redirect configuration
- **[Adding Mailboxes](docs/add-mailbox.md)** - Email account setup
- **[Webhook Configuration](docs/webhook-setup.md)** - n8n integration