# Otto Postal Webhook Integration

## Overview

This document explains how Otto handles incoming replies from Postal webhooks when leads respond to cold email campaigns. Otto integrates with Postal's webhook system to provide intelligent, context-aware reply processing while maintaining full RFC 2822 compliance.

## Architecture Overview

```
Postal Server → Otto Reply Webhook Handler → Otto Reply Processing Sub-Agent → Response Generation → Postal API
```

## Postal Webhook Integration

### Webhook Endpoint
- **URL**: `https://your-n8n-instance.com/webhook/otto-reply-webhook`
- **Method**: POST
- **Content-Type**: application/json

### Postal Webhook Events
Otto handles the following Postal webhook events:
- `message_received` - When a reply is received
- `message_delivered` - When a message is successfully delivered
- `message_bounced` - When a message bounces
- `message_complained` - When a message receives a complaint

### Webhook Payload Structure
```json
{
  "message_id": "postal-message-id",
  "from": "lead@company.com",
  "to": "noreply@smarterbdr.com",
  "subject": "Re: Your proposal",
  "received_at": "2024-01-15T10:30:00Z",
  "plain_text": "Thanks for reaching out. I'd like to learn more.",
  "html_content": "<p>Thanks for reaching out. I'd like to learn more.</p>",
  "headers": {
    "In-Reply-To": "<campaign-message-type-record-id@domain>",
    "References": "<original-message-id@domain>",
    "Message-ID": "<reply-message-id@domain>"
  },
  "postal_message_id": "postal-internal-id",
  "event": "message_received"
}
```

## RFC 2822 Compliance

### Message Threading
Otto maintains proper email conversation threading using RFC 2822 standards:

#### Original Message Format
```
Message-ID: <campaign-message-type-record-id@domain>
```

#### Reply Message Format
```
Message-ID: <timestamp-random@domain>
In-Reply-To: <campaign-message-type-record-id@domain>
References: <original-message-id@domain> <reply-message-id@domain>
Subject: Re: Original Subject
```

### Required Headers for Replies
- **From**: Original sending account (maintains consistency)
- **To**: Reply sender's email address
- **Subject**: Properly threaded with "Re:" prefix
- **Message-ID**: Unique identifier for the reply
- **In-Reply-To**: References the original message
- **References**: Full conversation thread
- **Date**: RFC 2822 formatted timestamp
- **MIME-Version**: 1.0

### Otto-Specific Headers
- **X-Campaign-ID**: Campaign identifier
- **X-Message-Type**: "Reply"
- **X-Otto-Processed**: "true"
- **X-Otto-Category**: Reply category (ready_to_schedule, more_info_needed, etc.)
- **X-Otto-Sentiment**: Sentiment analysis result
- **X-Source**: "otto-ai-reply"

## Otto Reply Processing Flow

### 1. Webhook Reception
```
Postal Webhook → Otto Reply Webhook Handler
```
- Receives POST request from Postal
- Validates webhook payload
- Extracts reply information

### 2. Context Extraction
```
Parse Webhook → Extract Original Context → Lookup Lead
```
- Parses Postal webhook payload
- Extracts original message ID from `In-Reply-To` header
- Parses message ID to get campaign, message type, and record ID
- Looks up lead in Airtable using record ID

### 3. Otto Analysis
```
Prepare Otto Data → Call Reply Processing Agent → Process Response
```
- Combines lead context with reply data
- Calls Otto Reply Processing Sub-Agent via MCP
- Otto analyzes sentiment, intent, and urgency
- Otto generates appropriate response strategy

### 4. Response Generation
```
Check Reply Category → Build RFC 2822 Reply → Send via Postal
```
- Determines if response is needed
- Builds RFC 2822 compliant reply message
- Maintains proper threading headers
- Sends response via Postal API

### 5. Status Updates
```
Update Lead Status → Log Results → Webhook Response
```
- Updates lead status in Airtable
- Logs processing results
- Returns webhook response to Postal

## Otto Reply Categories

### 1. Ready to Schedule
- **Trigger**: Leads wanting to book meetings or demos
- **Action**: Coordinate with Calendar Agent for availability
- **Response**: Professional meeting confirmation with calendar link
- **Status Update**: "Meeting Scheduled"

### 2. More Info Needed
- **Trigger**: Leads requesting additional information
- **Action**: Research Agent gathers relevant insights
- **Response**: Comprehensive, value-focused response
- **Status Update**: "Qualified"

### 3. Not Interested
- **Trigger**: Leads declining but potentially open to value
- **Action**: Research Agent finds clever company insights
- **Response**: Value-focused, non-pushy response
- **Status Update**: "Nurture" or "Future Opportunity"

### 4. Unsubscribe
- **Trigger**: Leads requesting to stop communications
- **Action**: Respectful, professional response
- **Response**: Confirmation of unsubscribe
- **Status Update**: "Unsubscribed"

### 5. Objection Handling
- **Trigger**: Leads with specific concerns or objections
- **Action**: Research Agent provides solutions
- **Response**: Educational, helpful response with case studies
- **Status Update**: Based on objection type

### 6. Price Inquiry
- **Trigger**: Leads asking about pricing or cost
- **Action**: Focus on value and ROI
- **Response**: Value-focused response with discovery call offer
- **Status Update**: "Price Qualified"

## Technical Implementation

### Webhook Handler Workflow
The `Otto_Reply_Webhook_Handler.json` workflow includes:

1. **Postal Reply Webhook** - Receives webhook from Postal
2. **Parse Postal Webhook** - Extracts reply information
3. **Extract Original Context** - Parses message ID for lead lookup
4. **Lookup Lead in Airtable** - Finds lead record
5. **Prepare Otto Reply Data** - Combines context for Otto
6. **Call Otto Reply Processing Agent** - Triggers Otto analysis
7. **Process Otto Response** - Extracts Otto's analysis
8. **Check Reply Category** - Determines response strategy
9. **Update Lead Status** - Updates Airtable with analysis
10. **Check if Response Needed** - Determines if reply is required
11. **Build RFC 2822 Reply** - Creates compliant reply message
12. **Send Otto Reply via Postal** - Sends response via Postal API
13. **Log Otto Reply Results** - Records processing results
14. **Webhook Response** - Returns response to Postal

### Otto Reply Processing Sub-Agent
The `Otto_Reply_Processing_SubAgent.json` workflow includes:

1. **Reply Processing MCP Trigger** - Receives requests from webhook handler
2. **Reply Processing Agent** - LangChain agent with specialized system message
3. **Grok 3 Mini Model** - AI model for reply analysis
4. **Reply Processing Memory** - Maintains conversation context
5. **MCP Client Tools** - Access to Airtable, Zep, Perplexity, Google, Gmail, Supabase
6. **THINK Tool** - Strategic response planning

## Message ID Format

### Original Message ID
```
<campaign-message-type-record-id@domain>
```
- **campaign**: Campaign identifier (e.g., "Q1-SMYKM")
- **message-type**: Message type (e.g., "Initial", "Follow-up")
- **record-id**: Airtable record ID for direct lookup
- **domain**: Sending domain (e.g., "smarterbdr.com")

### Reply Message ID
```
<timestamp-random@domain>
```
- **timestamp**: Unix timestamp when reply was generated
- **random**: Random string for uniqueness
- **domain**: Sending domain

## Error Handling

### Webhook Validation
- Validates required fields (from_email, to_email)
- Checks for original message ID in headers
- Validates message ID format

### Lead Lookup Errors
- Handles missing lead records
- Provides fallback for invalid record IDs
- Logs lookup failures for debugging

### Otto Processing Errors
- Handles Otto agent timeouts
- Provides fallback responses for failed analysis
- Logs processing errors for optimization

### Postal API Errors
- Retries failed API calls
- Handles rate limiting
- Logs delivery failures

## Security Considerations

### Webhook Authentication
- Validates webhook source
- Implements signature verification
- Rate limits webhook processing

### Data Privacy
- Encrypts sensitive lead data
- Implements client data separation
- Logs access for audit trails

### RFC Compliance
- Prevents mail loops with proper headers
- Maintains conversation threading
- Respects unsubscribe requests

## Monitoring and Analytics

### Processing Metrics
- Webhook processing time
- Otto analysis confidence
- Response generation success rate
- Postal delivery success rate

### Business Metrics
- Reply category distribution
- Sentiment analysis trends
- Response effectiveness
- Lead conversion rates

### Error Tracking
- Webhook validation failures
- Lead lookup errors
- Otto processing timeouts
- Postal API failures

## Configuration

### Postal Webhook Setup
1. Configure Postal to send webhooks to Otto endpoint
2. Set webhook events to include `message_received`
3. Configure webhook authentication
4. Test webhook delivery

### Otto Agent Configuration
1. Deploy Otto Reply Processing Sub-Agent
2. Configure MCP client connections
3. Set up Airtable credentials
4. Configure Postal API credentials

### Airtable Schema
Ensure Airtable includes fields for:
- Lead Status
- Last Contacted Date
- Reply Category
- Reply Sentiment
- Reply Intent
- Otto Analysis
- Original Reply Content
- Reply From

## Testing

### Webhook Testing
1. Send test webhook to Otto endpoint
2. Verify webhook parsing
3. Test lead lookup functionality
4. Validate Otto processing

### Reply Testing
1. Send test reply to Postal
2. Verify Otto receives webhook
3. Test Otto analysis accuracy
4. Validate response generation
5. Check RFC 2822 compliance

### Integration Testing
1. Test full end-to-end flow
2. Verify Airtable updates
3. Test Postal delivery
4. Validate conversation threading

## Troubleshooting

### Common Issues
1. **Webhook not received**: Check Postal configuration
2. **Lead lookup fails**: Verify message ID format
3. **Otto timeout**: Check MCP client connections
4. **Response not sent**: Verify Postal API credentials
5. **Threading broken**: Check RFC 2822 header format

### Debug Information
- Webhook payload logging
- Otto processing logs
- Postal API responses
- Airtable update confirmations

## Future Enhancements

### Phase 1: Core Integration
- Deploy webhook handler
- Test with sample replies
- Validate RFC 2822 compliance

### Phase 2: Advanced Features
- Multi-language support
- Advanced sentiment analysis
- A/B testing for responses

### Phase 3: Analytics
- Response effectiveness tracking
- Lead conversion optimization
- Predictive response strategies

### Phase 4: Multi-Channel
- SMS reply handling
- Social media reply processing
- Voice message analysis

## Conclusion

Otto's Postal webhook integration provides intelligent, context-aware reply processing while maintaining full RFC 2822 compliance. The system automatically analyzes incoming replies, generates appropriate responses, and maintains proper email conversation threading.

Key benefits:
- **Intelligent Analysis**: AI-powered sentiment and intent recognition
- **RFC Compliance**: Proper email threading and formatting
- **Context Awareness**: Full conversation history and lead data
- **Automated Processing**: End-to-end reply handling
- **Business Intelligence**: Comprehensive analytics and insights

This integration transforms cold email campaigns from one-way communications into intelligent, conversational lead nurturing systems that drive better business results.
