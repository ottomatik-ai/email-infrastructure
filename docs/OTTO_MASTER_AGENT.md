# 🤖 OTTO MASTER AGENT - LangChain Multi-Agent System

## Overview

Otto Master Agent is the central AI brain of the ottomatik[ai] ecosystem. Built using actual n8n LangChain nodes, it coordinates between multiple MCP integrations, manages contextual memory via Zep, and provides intelligent business development assistance to clients through a proper multi-agent architecture.

## 🏗️ Architecture

### LangChain Multi-Agent System (13 Nodes)
**File:** `Otto_Master_Agent_LangChain.json`

1. **Otto Chat Interface** (`@n8n/n8n-nodes-langchain.chatTrigger`) - Entry point for user interactions
2. **Otto Master Agent** (`@n8n/n8n-nodes-langchain.agent`) - Core LangChain agent with system message
3. **Otto OpenAI Model** (`@n8n/n8n-nodes-langchain.lmChatOpenAi`) - GPT-4o-mini language model
4. **Otto Memory (Zep)** (`@n8n/n8n-nodes-langchain.memoryBufferWindow`) - Contextual memory buffer
5. **CRM MCP Tool** (`n8n-nodes-mcp.mcpClientTool`) - Airtable/Supabase CRM operations
6. **Research MCP Tool** (`n8n-nodes-mcp.mcpClientTool`) - Research capabilities via MCP
7. **Google Workspace MCP Tool** (`n8n-nodes-mcp.mcpClientTool`) - Google integrations
8. **Supabase MCP Tool** (`n8n-nodes-mcp.mcpClientTool`) - Database operations
9. **Perplexity Research Tool** (`@n8n/n8n-nodes-langchain.toolPerplexityApi`) - Deep research
10. **Zep Memory Tool** (`n8n-nodes-mcp.mcpClientTool`) - Advanced memory operations
11. **Response Processor** (`n8n-nodes-base.code`) - Processes and adds metadata
12. **Log Otto Activity** (`n8n-nodes-base.supabase`) - Logs interactions
13. **Otto Final Response** (`n8n-nodes-base.respondToWebhook`) - Returns response

### Core Components
- **Otto Brain** - LangChain-powered decision making
- **Zep Memory Integration** - Contextual memory with relevance filtering (0.7+ threshold)
- **Supabase Integration** - Otto's core business development data
- **MCP Sub-Agent Coordination** - Manages specialized sub-agents
- **Multi-Client Support** - Handles multiple clients with data isolation
- **Multi-Channel Interface** - Web chat, WhatsApp, Slack, Telegram support
- **File Processing** - Handles document uploads and processing

### Multi-Agent Request Flow
1. **Request Reception** → Otto Master Webhook receives user request
2. **Master Brain Analysis** → Analyzes request type, complexity, and intent
3. **Agent Selection** → Determines which specialized agents are needed
4. **Execution Strategy** → Chooses parallel or sequential execution based on complexity
5. **Agent Orchestration** → Coordinates execution of selected agents
6. **Specialized Processing** → Each agent processes request in their domain
7. **Response Aggregation** → Collects and standardizes agent responses
8. **Master Synthesis** → Combines responses into coherent final answer
9. **Memory Storage** → Saves conversation context to Zep
10. **Activity Logging** → Records interaction metrics in Supabase
11. **Response Delivery** → Returns final response to user

## 🎯 Capabilities

### Specialized Agent Capabilities

#### **Memory Agent**
- **Contextual Memory** - Zep-powered conversation context with 0.7+ relevance filtering
- **Historical Recall** - Access to previous interactions and decisions
- **User Preferences** - Remembers client-specific settings and preferences

#### **CRM Agent**
- **Lead Management** - Complete lead lifecycle management via Supabase
- **Contact Enrichment** - Automatic lead data enhancement and validation
- **Pipeline Tracking** - Sales funnel monitoring and progression analysis

#### **Research Agent**
- **Market Intelligence** - Perplexity-powered real-time market research
- **Lead Research** - Comprehensive prospect background investigation
- **Competitive Analysis** - Industry trend and competitor monitoring

#### **Analytics Agent**
- **Performance Metrics** - Campaign and lead performance analysis
- **ROI Tracking** - Revenue attribution and business impact measurement
- **Predictive Insights** - Data-driven forecasting and recommendations

#### **Calendar Agent**
- **Meeting Scheduling** - Google Calendar integration with smart scheduling
- **Availability Management** - Real-time calendar synchronization
- **Follow-up Automation** - Automated meeting reminders and follow-ups

#### **Communication Agent**
- **Response Generation** - OpenAI-powered intelligent response creation
- **Content Personalization** - Context-aware message customization
- **Multi-Channel Support** - Platform-optimized communication delivery

#### **Integration Agent**
- **Customization Management** - Database and workflow customization requests
- **System Integration** - Third-party tool and service connections
- **Configuration Updates** - Dynamic system parameter adjustments

### MCP Integrations
- **Zep MCP** - Contextual memory management
- **Supabase MCP** - Otto's core business data
- **Google MCP** - Calendar and email integration
- **Perplexity MCP** - Research and insights
- **Airtable MCP** - Client CRM integration (via sub-agents)
- **Custom MCPs** - Client-specific integrations

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
4. **Analytics Agent** - Performance metrics and forecasting
5. **Calendar Agent** - Meeting scheduling and reminders
6. **Content Agent** - Email templates and content generation
7. **Integration Agent** - Third-party system connections
8. **Personal Assistant Agent** - Client personal requests
9. **Onboarding Agent** - Client setup and training

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

## 🔧 Multi-Agent Architecture (18 Nodes)

### Master Agent Layer (3 nodes)
1. **Otto Master Webhook** - Central entry point for all requests
2. **Otto Master Brain** - Request analysis, routing, and coordination
3. **Execution Strategy Router** - Determines parallel vs sequential execution

### Agent Orchestration Layer (2 nodes)
4. **Parallel Execution Coordinator** - Manages simultaneous agent execution
5. **Sequential Execution Coordinator** - Manages ordered agent execution

### Agent Routing Layer (1 node)
6. **Agent Type Router** - Routes requests to appropriate specialized agents

### Specialized Agent Layer (7 nodes)
7. **Memory Agent** - Zep contextual memory retrieval and management
8. **CRM Agent** - Lead and contact management via Supabase
9. **Research Agent** - Perplexity-powered research and insights
10. **Analytics Agent** - Performance metrics and data analysis
11. **Calendar Agent** - Google Calendar integration and scheduling
12. **Communication Agent** - OpenAI-powered response generation
13. **Integration Agent** - Customization requests and system integration

### Response Processing Layer (3 nodes)
14. **Agent Response Processor** - Processes and standardizes agent outputs
15. **Master Response Synthesis** - Combines agent responses into coherent reply
16. **Store Conversation Memory** - Saves interaction to Zep for future context

### Logging & Output Layer (2 nodes)
17. **Log Otto Activity** - Records interaction metrics in Supabase
18. **Otto Final Response** - Returns final response to user

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

*Otto Master Agent is the intelligent core of the ottomatik[ai] ecosystem, providing personalized business development assistance while maintaining complete client data isolation and security.*
