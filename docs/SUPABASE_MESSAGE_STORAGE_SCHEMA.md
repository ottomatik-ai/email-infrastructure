# Supabase Message Storage Schema

## Overview

This document defines the Supabase database schema for storing comprehensive message content and campaign metrics as chosen in Option 3: Supabase-Only Logging.

## Database Tables

### 1. message_content

Primary table for storing all email message content and metadata.

```sql
CREATE TABLE message_content (
  id BIGSERIAL PRIMARY KEY,
  message_id TEXT UNIQUE NOT NULL,
  campaign_id TEXT NOT NULL,
  message_type TEXT NOT NULL, -- 'Initial', 'Reply', 'Follow-up'
  sending_account TEXT NOT NULL,
  recipient_email TEXT NOT NULL,
  subject TEXT NOT NULL,
  html_content TEXT,
  plain_content TEXT,
  rfc2822_message TEXT NOT NULL,
  postal_response JSONB,
  sent_at TIMESTAMP WITH TIME ZONE NOT NULL,
  delivery_status TEXT NOT NULL DEFAULT 'sent', -- 'sent', 'failed', 'bounced'
  lead_id TEXT NOT NULL,
  client_id TEXT NOT NULL DEFAULT 'default',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_message_content_message_id ON message_content(message_id);
CREATE INDEX idx_message_content_campaign_id ON message_content(campaign_id);
CREATE INDEX idx_message_content_recipient_email ON message_content(recipient_email);
CREATE INDEX idx_message_content_sent_at ON message_content(sent_at);
CREATE INDEX idx_message_content_client_id ON message_content(client_id);
CREATE INDEX idx_message_content_lead_id ON message_content(lead_id);

-- Full text search on subject and content
CREATE INDEX idx_message_content_search ON message_content USING gin(
  to_tsvector('english', subject || ' ' || COALESCE(plain_content, '') || ' ' || COALESCE(html_content, ''))
);
```

### 2. lead_activity_log

Secondary table for tracking lead engagement and activity patterns.

```sql
CREATE TABLE lead_activity_log (
  id BIGSERIAL PRIMARY KEY,
  lead_id TEXT NOT NULL,
  client_id TEXT NOT NULL,
  activity_type TEXT NOT NULL, -- 'email_sent', 'email_opened', 'email_clicked', 'reply_received'
  activity_data JSONB,
  message_id TEXT REFERENCES message_content(message_id),
  occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_lead_activity_lead_id ON lead_activity_log(lead_id);
CREATE INDEX idx_lead_activity_client_id ON lead_activity_log(client_id);
CREATE INDEX idx_lead_activity_type ON lead_activity_log(activity_type);
CREATE INDEX idx_lead_activity_occurred_at ON lead_activity_log(occurred_at);
```

### 3. campaign_metrics

Aggregated metrics table for campaign performance tracking.

```sql
CREATE TABLE campaign_metrics (
  id BIGSERIAL PRIMARY KEY,
  campaign_id TEXT NOT NULL,
  client_id TEXT NOT NULL,
  metric_date DATE NOT NULL,
  messages_sent INTEGER DEFAULT 0,
  messages_delivered INTEGER DEFAULT 0,
  messages_failed INTEGER DEFAULT 0,
  replies_received INTEGER DEFAULT 0,
  unique_recipients INTEGER DEFAULT 0,
  avg_response_time_ms INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(campaign_id, client_id, metric_date)
);

-- Indexes for performance
CREATE INDEX idx_campaign_metrics_campaign_id ON campaign_metrics(campaign_id);
CREATE INDEX idx_campaign_metrics_client_id ON campaign_metrics(client_id);
CREATE INDEX idx_campaign_metrics_date ON campaign_metrics(metric_date);
```

## Data Flow Integration

### Postal Email Sender Workflow Integration

The Postal Email Sender workflow now includes a "Log to Supabase" node that:

1. **Captures Full Message Content**:
   - RFC 2822 formatted message
   - HTML and plain text content
   - Subject line and metadata
   - Postal API response

2. **Stores Campaign Metrics**:
   - Message ID for tracking
   - Campaign ID and message type
   - Sending account and recipient
   - Delivery status and timestamps

3. **Maintains Lead Association**:
   - Links to Airtable lead ID
   - Client ID for multi-tenancy
   - Full conversation history

### Otto Agent Integration

The Otto Reply Processing system can query Supabase for:

1. **Conversation History**:
   ```sql
   SELECT * FROM message_content 
   WHERE recipient_email = $1 
   ORDER BY sent_at DESC 
   LIMIT 10;
   ```

2. **Campaign Context**:
   ```sql
   SELECT * FROM message_content 
   WHERE campaign_id = $1 
   AND client_id = $2 
   ORDER BY sent_at DESC;
   ```

3. **Lead Activity Patterns**:
   ```sql
   SELECT activity_type, COUNT(*), MAX(occurred_at)
   FROM lead_activity_log 
   WHERE lead_id = $1 
   GROUP BY activity_type;
   ```

## Multi-Tenant Architecture

### Client Isolation

Each client's data is isolated using the `client_id` field:

- **Default Client**: `client_id = 'default'` for ottomatik[ai] operations
- **Client-Specific**: `client_id = 'client-slug'` for individual clients
- **Row Level Security**: Can be implemented for additional security

### Data Access Patterns

```sql
-- Client-specific queries (always include client_id filter)
SELECT * FROM message_content 
WHERE client_id = 'client-slug' 
AND campaign_id = 'campaign-name';

-- Cross-client analytics (admin only)
SELECT client_id, COUNT(*) as total_messages
FROM message_content 
GROUP BY client_id;
```

## Performance Considerations

### Indexing Strategy

1. **Primary Lookups**: message_id, campaign_id, lead_id
2. **Time-based Queries**: sent_at, occurred_at
3. **Client Isolation**: client_id for multi-tenant queries
4. **Full-text Search**: Subject and content search

### Data Retention

```sql
-- Automatic cleanup of old data (optional)
CREATE OR REPLACE FUNCTION cleanup_old_messages()
RETURNS void AS $$
BEGIN
  -- Keep message content for 2 years
  DELETE FROM message_content 
  WHERE sent_at < NOW() - INTERVAL '2 years';
  
  -- Keep activity logs for 1 year
  DELETE FROM lead_activity_log 
  WHERE occurred_at < NOW() - INTERVAL '1 year';
END;
$$ LANGUAGE plpgsql;

-- Schedule cleanup (run monthly)
-- SELECT cron.schedule('cleanup-messages', '0 0 1 * *', 'SELECT cleanup_old_messages();');
```

## API Integration

### Supabase Client Configuration

```javascript
// n8n Supabase node configuration
{
  "operation": "insert",
  "table": "message_content",
  "columns": {
    "message_id": "={{ $json.metrics.message_id }}",
    "campaign_id": "={{ $json.metrics.campaign_id }}",
    "message_type": "={{ $json.metrics.message_type }}",
    "sending_account": "={{ $json.metrics.sending_account }}",
    "recipient_email": "={{ $json.metrics.recipient_email }}",
    "subject": "={{ $json.metrics.subject }}",
    "html_content": "={{ $json.fields['HTML Content'] }}",
    "plain_content": "={{ $json.fields['Plain Text Content'] }}",
    "rfc2822_message": "={{ $json.rfc2822_message }}",
    "postal_response": "={{ $json.metrics.postal_response }}",
    "sent_at": "={{ $json.metrics.sent_at }}",
    "delivery_status": "={{ $json.metrics.delivery_status }}",
    "lead_id": "={{ $json.fields['id'] }}",
    "client_id": "={{ $json.fields['Client ID'] || 'default' }}"
  }
}
```

## Benefits of Supabase-Only Logging

### Scalability
- **Unlimited Storage**: No Airtable record limits
- **Fast Queries**: PostgreSQL performance for large datasets
- **Real-time Updates**: WebSocket support for live dashboards

### Data Integrity
- **ACID Compliance**: Transactional integrity
- **Backup & Recovery**: Built-in PostgreSQL features
- **Version Control**: Track changes over time

### Advanced Analytics
- **Complex Queries**: SQL for sophisticated reporting
- **Aggregations**: Built-in functions for metrics
- **Machine Learning**: Direct integration with AI tools

### Multi-Tenant Support
- **Client Isolation**: Secure data separation
- **Custom Schemas**: Client-specific configurations
- **Scalable Architecture**: Handle unlimited clients

## Implementation Status

✅ **Completed**:
- Supabase node added to Postal Email Sender workflow
- Database schema designed and documented
- Multi-tenant architecture planned
- Integration points identified

⏳ **Pending**:
- Supabase database creation and table setup
- Credential configuration in n8n
- Testing with sample data
- Performance optimization
- Backup and monitoring setup

## Next Steps

**🚨 PENDING SETUP TASKS:**

1. **Create Supabase Project**: Set up database and configure credentials
2. **Run Schema Migration**: Create tables and indexes
3. **Configure n8n Credentials**: Add Supabase API credentials
4. **Test Workflow**: Verify message storage functionality
5. **Monitor Performance**: Optimize queries and indexes as needed

**NOTE**: Supabase workflow integration is complete but requires manual setup steps above before the Postal Email Sender workflow can store message content to Supabase.
