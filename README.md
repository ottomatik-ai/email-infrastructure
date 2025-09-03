# IMAP API Management

Simple management system for IMAP API mailboxes and n8n webhook integration.

## Overview

This repository manages:
- **ottomatik.ai mailboxes** - Internal email processing
- **Client mailboxes** - Client-specific email automation
- **Webhook configurations** - n8n integration endpoints

## Quick Start

1. **Access IMAP API**: `http://98.81.118.238:3000`
2. **Add mailboxes** using the configurations in `/mailboxes/`
3. **Configure webhooks** for n8n integration
4. **Track webhook URLs** in `/webhooks/`

## Repository Structure

```
├── mailboxes/
│   ├── otto-mailboxes.json        # ottomatik.ai mailboxes
│   ├── clients/                   # Client mailbox configs
│   │   └── {slug}-mailboxes.json  # Client mailbox template
├── webhooks/
│   ├── n8n-webhooks.json         # n8n webhook configurations
│   └── webhook-urls.md           # Active webhook URLs
└── docs/
    ├── add-mailbox.md            # How to add mailboxes
    ├── remove-mailbox.md         # How to remove mailboxes
    └── webhook-setup.md          # Webhook configuration guide
```

## IMAP API Access

- **URL**: http://98.81.118.238:3000
- **Status**: ✅ Running
- **Redis**: Connected to `n8n_ottomatik_ai_otto-redis:6379/7`
