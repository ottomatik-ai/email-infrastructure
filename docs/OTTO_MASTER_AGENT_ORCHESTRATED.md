# 🤖 OTTO MASTER AGENT - Orchestrated Multi-Agent System

## Overview

Otto Master Agent is the central AI brain of the ottomatik[ai] ecosystem. Built using proven orchestration patterns from the n8n workflow library, it coordinates between multiple specialized agents, manages contextual memory via Zep, and provides intelligent business development assistance to clients through a proper multi-agent architecture.

## 🏗️ Architecture

### Orchestrated Multi-Agent System (22 Nodes)
**File:** `Otto_Master_Agent_Orchestrated.json`

#### Core Orchestration Layer (7 nodes)
1. **Otto Webhook Trigger** (`n8n-nodes-base.webhook`) - Multi-channel entry point
2. **Otto Meta-Orchestrator** (`n8n-nodes-base.function`) - Master controller with state management
3. **Log Request to Supabase** (`n8n-nodes-base.supabase`) - Activity logging
4. **Agent Router** (`n8n-nodes-base.switch`) - Routes requests to specialized agents
5. **Agent Sequence Manager** (`n8n-nodes-base.function`) - Controls execution flow
6. **Final Response Aggregator** (`n8n-nodes-base.function`) - Combines all agent results
7. **Channel Router** (`n8n-nodes-base.switch`) - Routes responses to appropriate channels

#### Specialized Agent Layer (6 nodes - Execute Workflow Pattern)
8. **CRM Agent** (`n8n-nodes-base.executeWorkflow`) - Airtable integration for lead management
9. **Memory Agent** (`n8n-nodes-base.executeWorkflow`) - Zep contextual memory with relevance filtering
10. **Research Agent** (`n8n-nodes-base.executeWorkflow`) - Perplexity deep research capabilities
11. **Calendar Agent** (`n8n-nodes-base.executeWorkflow`) - Meeting scheduling and reminders
12. **Communication Agent** (`n8n-nodes-base.executeWorkflow`) - Email, SMS, social media
13. **Response Agent** (`n8n-nodes-base.executeWorkflow`) - Final response generation and formatting

#### Response & Error Handling Layer (9 nodes)
14. **Continue Sequence Check** (`n8n-nodes-base.if`) - Determines if sequence continues
15. **Log Completion to Supabase** (`n8n-nodes-base.supabase`) - Completion logging
16. **Web Response** (`n8n-nodes-base.respondToWebhook`) - Web chat responses
17. **WhatsApp Response** (`n8n-nodes-base.whatsApp`) - WhatsApp integration
18. **Slack Response** (`n8n-nodes-base.slack`) - Slack integration
19. **Telegram Response** (`n8n-nodes-base.telegram`) - Telegram integration
20. **Error Handler** (`n8n-nodes-base.function`) - Manages failures and retries
21. **Log Error to Supabase** (`n8n-nodes-base.supabase`) - Error logging
22. **Send Error Notification** (`n8n-nodes-base.pushover`) - Error notifications

### Core Components
- **Meta-Orchestrator** - Master controller with workflow state management
- **Dynamic Agent Sequencing** - Routes requests based on content analysis
- **Execute Workflow Pattern** - Calls specialized sub-agent workflows
- **State Management** - Tracks current agent, sequence, and execution status
- **Multi-Client Support** - Handles multiple clients with data isolation
- **Multi-Channel Interface** - Web chat, WhatsApp, Slack, Telegram support
- **Comprehensive Logging** - All activities tracked in Supabase

### Multi-Agent Request Flow
1. **Request Reception** → Otto Webhook receives user request
2. **Meta-Orchestrator Analysis** → Analyzes request type and determines agent sequence
3. **Agent Sequencing** → Dynamic routing based on request content analysis
4. **Agent Execution** → Execute Workflow calls specialized sub-agent workflows
5. **Sequence Management** → Controls execution flow between agents
6. **Response Aggregation** → Combines all agent results
7. **Channel Routing** → Routes responses to appropriate channels
8. **Activity Logging** → Records all interactions in Supabase
9. **Error Handling** → Manages failures with automatic retry and notifications

## 🎯 Capabilities

### Request Analysis & Dynamic Routing
The Meta-Orchestrator analyzes incoming requests and determines the optimal agent sequence:

- **Lead-related requests**: CRM → Memory → Research → Response
- **Research requests**: Research → Response  
- **Schedule requests**: Calendar → Response
- **Email requests**: Communication → Response
- **General queries**: Memory → Research → Response

### Specialized Agent Capabilities

#### **CRM Agent**
- **Lead Management** - Complete lead lifecycle management via Airtable MCP
- **Contact Enrichment** - Automatic lead data enhancement and validation
- **Pipeline Tracking** - Sales funnel monitoring and progression analysis

#### **Memory Agent**
- **Contextual Memory** - Zep-powered conversation context with 0.7+ relevance filtering
- **Historical Recall** - Access to previous interactions and decisions
- **User Preferences** - Remembers client-specific settings and preferences

#### **Research Agent**
- **Market Intelligence** - Perplexity-powered real-time market research
- **Lead Research** - Comprehensive prospect background investigation
- **Competitive Analysis** - Industry trend and competitor monitoring

#### **Calendar Agent**
- **Meeting Scheduling** - Google Calendar integration with smart scheduling
- **Availability Management** - Real-time calendar synchronization
- **Follow-up Automation** - Automated meeting reminders and follow-ups

#### **Communication Agent**
- **Response Generation** - OpenAI-powered intelligent response creation
- **Content Personalization** - Context-aware message customization
- **Multi-Channel Support** - Platform-optimized communication delivery

#### **Response Agent**
- **Final Response Generation** - Combines all agent outputs into coherent response
- **Formatting** - Channel-specific response formatting
- **Quality Assurance** - Ensures response quality and completeness

### State Management
- **Workflow State** - Tracks current agent, sequence, and execution status
- **Agent Sequencing** - Dynamic routing based on request content analysis
- **Context Preservation** - Maintains context across agent execution
- **Session Management** - Tracks user sessions and conversations

## 📱 Multi-Channel Interface

### Supported Platforms
- **Web Chat Interface** - Customizable WhatsApp-like interface with CSS branding
- **WhatsApp Business** - Direct WhatsApp integration for business messaging
- **Slack** - Workspace integration with bot functionality
- **Telegram** - Bot integration with inline keyboards and file sharing

### File Upload Support
**Supported Formats:**
- **Documents:** PDF, Word (.docx, .doc), Excel (.xlsx, .xls), PowerPoint (.pptx, .ppt)
- **Images:** JPEG, PNG, GIF, WebP, SVG
- **Data Files:** JSON, XML, CSV, SQL, Log files
- **Business Files:** Contact lists, Lead lists, Campaign data

### Channel-Specific Features
- **Web Chat:** File uploads, voice notes, team management, custom styling
- **WhatsApp:** Voice messages, image sharing, document sharing, quick replies
- **Slack:** Channel messages, slash commands, app home, file sharing
- **Telegram:** Private chats, group chats, inline keyboards, voice messages

### User Identity Management
- Cross-channel user identity tracking
- Unified conversation history across platforms
- Channel-specific message formatting
- Platform-appropriate response delivery

## 🔐 Multi-Client Architecture

### Client Isolation
- Each client has separate Supabase project
- Otto Admin project manages all clients
- Complete data isolation between clients
- Otto Admin can access all business data (except personal conversations)

### Access Levels
- **Admin Access** - Full organizational control
- **Leadership Access** - Business oversight and team performance
- **Regular Access** - Assigned leads and campaign participation

## 🧠 Zep Memory Integration

### Smart Relevance Filtering
- Only memories with 0.7+ relevance score are retrieved
- Maximum 3 memories per request
- Automatic token optimization
- Contextual memory for personalized responses

### Memory Types
- **Lead Context** - Lead information and interactions
- **Campaign Data** - Campaign performance and strategies
- **User Preferences** - Communication style and preferences
- **Business Context** - Industry and company information

## 📊 Data Sources

### Otto's Core Data (Supabase)
- Lead information and status
- Message history and interactions
- Campaign data and performance
- Research findings and insights
- Revenue tracking and analytics

### Client Data (Via MCPs)
- Google Sheets - Lead lists and contact info
- Airtable - CRM data and workflows
- Gmail - Email contacts and history
- Google Calendar - Meeting schedules
- Custom integrations - Client-specific systems

## 🚀 Sub-Agent Ecosystem

### Core Sub-Agents
1. **CRM Agent** - Lead management and pipeline tracking
2. **Communication Agent** - Email, SMS, social media
3. **Research Agent** - Lead research and market analysis
4. **Calendar Agent** - Meeting scheduling and reminders
5. **Memory Agent** - Contextual memory management
6. **Response Agent** - Final response generation

### MCP Sub-Agents
- **Google Sheets Agent** - Connect to client spreadsheets
- **Airtable Agent** - Sync with client Airtable bases
- **Gmail Agent** - Email contact management
- **Calendar Agent** - Meeting scheduling
- **Zep Memory Agent** - Contextual memory management
- **Perplexity Agent** - Research and insights

## 🔧 Customization System

### Request Types
- **Field Customization** - Add custom fields to existing tables
- **Table Customization** - Create new tables for client data
- **Workflow Customization** - Custom business processes
- **Integration Customization** - Connect new systems

### Permission Levels
- **Admin Approval Required** - All customizations initially
- **Self-Service Simple** - Basic field additions (when unlocked)
- **Self-Service Full** - Advanced customizations (when unlocked)

## 📈 Analytics & Reporting

### Otto Usage Analytics
- Interaction types and frequency
- Response times and success rates
- Client engagement metrics
- System performance monitoring

### Business Development Metrics
- Lead conversion rates
- Campaign performance
- Revenue tracking
- Client success metrics

## 🛡️ Security & Compliance

### Data Protection
- Client data isolation
- Encrypted API communications
- Role-based access control
- Audit logging for all actions

### Privacy Controls
- Personal conversations protected
- Client-specific encryption keys
- Automatic data retention policies
- Privacy flags for sensitive data

## 🔄 Integration Points

### Current Workflows
- **Postal Email Sender** - Otto logs email activities
- **Postal Webhook Handler** - Otto processes delivery confirmations
- **Postal Error Handler** - Otto manages error responses
- **Inbox Management** - Otto coordinates reply processing

### Future Integrations
- Client-specific CRM systems
- Marketing automation platforms
- Sales enablement tools
- Business intelligence dashboards

## 📋 Setup Requirements

### Required Credentials
- **Zep API** - For contextual memory
- **Supabase API** - For Otto's core data
- **OpenAI API** - For Otto Brain
- **Google API** - For calendar and email
- **Perplexity API** - For research capabilities

### Database Setup
- Otto Admin Supabase project
- Client-specific Supabase projects
- Zep memory configuration
- MCP server connections

## 🎯 Success Metrics

### Client Success
- Lead conversion rate improvement
- Campaign performance optimization
- Time savings on manual tasks
- Revenue growth acceleration

### System Performance
- Response time < 3 seconds
- 99.9% uptime
- < 1% error rate
- High client satisfaction scores

## 🔧 Orchestration Patterns

### Execute Workflow Pattern
- **Sub-Agent Workflows** - Each specialized agent runs as separate workflow
- **State Propagation** - Data flows between workflows via parameters
- **Error Isolation** - Agent failures don't crash entire system
- **Scalability** - Easy to add new agents or modify existing ones

### State Management
- **Workflow State** - Tracks current agent, sequence, and execution status
- **Agent Sequencing** - Dynamic routing based on request content analysis
- **Context Preservation** - Maintains context across agent execution
- **Session Management** - Tracks user sessions and conversations

### Error Handling & Monitoring
- **Automatic Retry** - Failed requests are retried with exponential backoff
- **Error Logging** - All errors logged to Supabase with full context
- **Pushover Notifications** - Real-time error alerts to Otto Admin
- **Graceful Degradation** - System continues operating despite individual agent failures

### Performance Optimization
- **Agent Sequencing** - Only necessary agents are executed
- **Context Filtering** - Zep relevance filtering reduces token usage
- **Parallel Processing** - Multiple agents can run concurrently when appropriate
- **State Management** - Efficient workflow state tracking and persistence

## 🔮 Future Enhancements

### Planned Features
- Advanced AI capabilities (predictive lead scoring)
- Enhanced automation workflows
- Real-time collaboration features
- Mobile app integration
- Voice interface support

### Scalability
- Support for 100+ clients
- Advanced multi-tenant architecture
- Global deployment capabilities
- Enterprise-grade security

---

*Otto Master Agent is the intelligent core of the ottomatik[ai] ecosystem, providing personalized business development assistance while maintaining complete client data isolation and security through proven orchestration patterns.*
