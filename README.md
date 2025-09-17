# Email Infrastructure

Comprehensive email infrastructure management system for cold email campaigns, domain management, and automated email processing.

## Architecture Overview

### **Complete Email Stack:**
- **📤 Sending**: n8n workflows → Postal → SparkPost (dedicated IPs)
- **📥 Receiving**: Postal webhooks → Inbox Management → (future: Otto AI)
- **🌐 Domain Management**: Various sellers → Cloudflare nameservers
- **⚡ Processing**: n8n workflows - Automated email campaigns and reply handling

### **Infrastructure Components:**
- **Domain Strategy** - Multi-domain email campaigns
- **Postal Integration** - Email sending and receiving hub
- **SparkPost Backend** - Dedicated IP email delivery
- **Domain Management** - Cloudflare DNS configuration
- **Client Configurations** - Scalable client email setups
- **Campaign Infrastructure** - Cold email campaign support
- **n8n Workflow Integration** - Automated email processing and reply handling

## Current Infrastructure

### **Total Email Infrastructure:**
- **93 Email Addresses** across **24 Domains**
- **2 Active Clients** (PTC + ottomatik[ai])
- **Postal Server** - Centralized email hub
- **Automated Processing** via n8n workflows

### **Client Breakdown:**
- **Pull The Chute (PTC)**: 48 email addresses, 12 domains
- **ottomatik[ai] (otto)**: 45 email addresses, 12 domains (9 Cloudflare + 3 GoDaddy/Outlook)

## Email Infrastructure Stack

### **1. Domain Management**
```
Domain Purchase → Cloudflare Nameservers → Postal Server
```

### **2. Sending Infrastructure**
- **n8n Workflows** - Campaign automation and lead management
- **Postal Server** - Email hub and API
- **SparkPost Backend** - Dedicated IP delivery via SMTP

### **3. Receiving Infrastructure**
- **Postal Server** - Centralized email receiving
- **Webhook Integration** - Real-time reply processing
- **n8n Inbox Management** - Automated reply handling

### **4. Domain Forwarding**
- **Netlify** - Handles domain-to-domain email routing
- **Seamless Integration** - Transparent email forwarding
- **Multi-Domain Support** - Scales with campaign needs

## Quick Start

1. **Configure Postal server** for email sending and receiving
2. **Set up n8n workflows** for campaign automation
3. **Configure webhooks** for Postal → n8n integration
4. **Monitor email processing** via n8n workflow executions

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
      "postal_integration": {
        "server": "postal.ottomatik.ai",
        "webhook_url": "https://n8n.ottomatik.ai/webhook/client-slug-inbox-management",
        "campaign_tracking": true
      },
      "n8n_workflow": "https://n8n.ottomatik.ai/webhook/client-slug-inbox-management"
    }
  ],
  "postal_settings": {
    "server": "postal.ottomatik.ai",
    "domains": ["domain1.com", "domain2.com"],
    "webhook_processing": true
  }
}
```

### Required Fields

- **`name`**: Unique identifier (format: `{slug}-{email-identifier}`)
- **`email`**: Full email address
- **`from_name`**: Display name for outgoing emails
- **`postal_integration.server`**: Postal server URL (postal.ottomatik.ai)
- **`postal_integration.webhook_url`**: n8n webhook for reply processing
- **`postal_integration.campaign_tracking`**: Boolean for tracking integration
- **`n8n_workflow`**: Webhook URL for email processing

### Creating New Client Configuration

1. Copy `{slug}-mailboxes.json` template
2. Replace `{slug}` with client identifier
3. Update email addresses and domains
4. Set correct `from_name` and password
5. Configure webhook URL

## Infrastructure Services

### **Postal Server**
- **URL**: postal.ottomatik.ai
- **Purpose**: Centralized email sending and receiving hub
- **Integration**: API-based email processing with webhook support

### **SparkPost Backend**
- **Service**: Dedicated IP email delivery
- **Purpose**: High deliverability via professional SMTP infrastructure
- **Integration**: Postal → SparkPost for actual email delivery

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
n8n Campaign → Postal → SparkPost → Recipient
Recipient Reply → Postal → n8n Webhook → Inbox Management → (future: Otto AI)
```

## Best Practices

### **Domain Management**
- Use Cloudflare for DNS management
- Set up Netlify forwarding for new domains
- Maintain consistent naming conventions

### **Email Configuration**
- Use Postal server as central email hub
- Configure SparkPost backend for high deliverability
- Set up webhook URLs for automated reply processing

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

### **Complete Domain Setup Process:**
1. **Purchase domains**
2. **Set up Google Workspace email alias** (`{slug}@ottomatik.ai`)
3. **Create Cloudflare account** for client
4. **Update domain nameservers** to Cloudflare
5. **Add domains to Postal server** and configure routing
6. **Add domains to SparkPost** and copy DKIM information
7. **Create and upload complete BIND files** to Cloudflare (includes SparkPost, Postal, Netlify)
8. **Verify domains on SparkPost**
9. **Test Postal integration** and webhook delivery
10. **Configure n8n workflows** for domain-specific processing

## Documentation

- **[Complete Email Flow](docs/email-flow.md)** - Detailed infrastructure flow
- **[Domain Inventory](domains/dns/domain-inventory.md)** - Domain tracking
- **[Client BIND Files](domains/cloudflare/clients/README.md)** - Individual domain BIND files for easy upload
- **[GoDaddy/Outlook Domains](domains/godaddy-outlook/README.md)** - Domains managed through GoDaddy with Outlook email
- **[Domain Setup Guide](domains/netlify/domain-setup-guide.md)** - ⚠️ CRITICAL: How to add new domains
- **[Netlify Setup](domains/netlify/README.md)** - Domain redirect configuration
- **[Adding Mailboxes](docs/add-mailbox.md)** - Email account setup
- **[Webhook Configuration](docs/webhook-setup.md)** - n8n integration