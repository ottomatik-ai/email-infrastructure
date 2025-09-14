# Client BIND Files

This directory contains complete BIND files for each client's domains.

## Directory Structure

```
domains/cloudflare/
├── otto/                   # ottomatik[ai] domains (company, not client)
│   ├── smarterbdrsys.com.txt
│   ├── smarterbdr.com.txt
│   ├── smarterbdr.co.txt
│   ├── smartbdrsys.com.txt
│   ├── smartbdr.co.txt
│   ├── ottobdrsys.com.txt
│   ├── ottobdr.com.txt
│   ├── ottobdr.co.txt
│   └── aibdrsys.com.txt
└── clients/
    └── ptc/                # Pull The Chute domains (client)
        ├── ptcgrowth.com.txt
        ├── ptcgrowth.net.txt
        ├── ptccoaching.net.txt
        ├── ptcgrowyourpeople.com.txt
        ├── ptcgrowyourpeople.net.txt
        ├── ptcgrow.com.txt
        ├── ptcgrow.net.txt
        ├── ptccoach.com.txt
        ├── ptccoach.net.txt
        ├── pullthechutecoaching.com.txt
        ├── pullthechutecoach.com.txt
        └── pullthechuteteam.com.txt
```

## File Naming Convention

- **Format**: `{domain}.txt`
- **Example**: `ptcgrowth.com.txt`

## BIND File Contents

Each BIND file includes:
- **A Records**: Netlify IP for domain forwarding
- **CNAME Records**: Netlify site and DKIM keys
- **MX Records**: Migadu email receiving
- **TXT Records**: SPF, DKIM, DMARC, and verification codes
- **SparkPost DKIM**: For email sending authentication

## Upload Process

1. **Create separate BIND file** for each domain
2. **Store in appropriate client folder** (`ptc/` or `otto/`)
3. **Upload individually** to Cloudflare DNS
4. **Verify all records** are DNS-only (no proxy)

## ⚠️ Critical Requirements

- **ALL records must be DNS-only** (gray cloud, not orange)
- **Each domain gets its own file** for easy management
- **Files are ready for direct upload** to Cloudflare
- **No nameserver records** included (handled separately)
