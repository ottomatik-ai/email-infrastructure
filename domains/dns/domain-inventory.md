# Domain Inventory

## Current Domain Portfolio

### **Total Domains: 24**

### **ottomatik[ai] Domains (12)**

#### **Cloudflare-Managed Domains (9)**
- smarterbdrsys.com
- smarterbdr.com
- smarterbdr.co
- smartbdrsys.com
- smartbdr.co
- ottobdrsys.com
- ottobdr.com
- ottobdr.co
- aibdrsys.com

#### **GoDaddy/Outlook Domains (3)**
- goottomatik.com
- getottomatik.com
- tryottomatik.com

### **Pull The Chute Domains (12)**
- ptcgrowth.com
- ptcgrowth.net
- ptccoaching.net
- ptcgrowyourpeople.com
- ptcgrowyourpeople.net
- ptcgrow.net
- ptcgrow.com
- ptccoach.net
- ptccoach.com
- pullthechutecoaching.com
- pullthechutecoach.com
- pullthechuteteam.com

## Domain Management Process

### **1. Domain Purchase**
- Purchase from various sellers (GoDaddy, Namecheap, etc.)
- Transfer to Cloudflare nameservers
- Configure DNS records

### **2. Email Configuration**
- Set up MX records pointing to Migadu
- Configure SPF, DKIM, DMARC records
- Test email delivery

### **3. Netlify Forwarding**
- Create Netlify site for domain
- Configure redirects to main domain
- Set up custom domain aliases

### **4. Email Infrastructure**
- Add domain to Migadu account
- Create email addresses
- Configure IMAP API integration
- Set up n8n webhook processing

## DNS Configuration Template

```dns
# A Record (Root Domain)
@    A    104.198.14.52    # Netlify IP

# CNAME Record (WWW)
www  CNAME  netlify-domain.netlify.app

# MX Records (Email)
@    MX    10  mail.migadu.com

# SPF Record
@    TXT   "v=spf1 include:sparkpostmail.com include:migadu.com ~all"

# DKIM Record (Migadu)
migadu._domainkey  TXT  "v=DKIM1; k=rsa; p=..."

# DMARC Record
_dmarc  TXT  "v=DMARC1; p=quarantine; rua=mailto:dmarc@domain.com"
```

## Domain Status Tracking

| Domain | Status | Provider | Netlify | Migadu | Email Count |
|--------|--------|----------|---------|--------|-------------|
| smarterbdrsys.com | ✅ Active | Cloudflare | ✅ | ✅ | 4 |
| smarterbdr.com | ✅ Active | Cloudflare | ✅ | ✅ | 4 |
| ptcgrowth.com | ✅ Active | Cloudflare | ✅ | ✅ | 4 |
| ptcgrowth.net | ✅ Active | Cloudflare | ✅ | ✅ | 4 |
| ... | ... | ... | ... | ... | ... |

## Notes
- All domains use Cloudflare for DNS management
- Netlify handles domain forwarding and hosting
- Migadu manages email inboxes
- SparkPost handles outbound email delivery
