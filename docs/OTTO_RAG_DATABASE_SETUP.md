# Otto RAG Database Setup Guide

## Overview

This document provides comprehensive instructions for setting up RAG (Retrieval-Augmented Generation) databases for Otto's intelligent reply processing system. Each client requires their own RAG database for data isolation and privacy, while ottomatik[ai] maintains the master knowledge base.

## Database Architecture

### Multi-Tenant Structure
```
otto-admin-project (Supabase)
├── ottomatik[ai] RAG Database
├── client-1 RAG Database
├── client-2 RAG Database
└── client-n RAG Database
```

### Database Schema

#### Core Tables
```sql
-- Client Knowledge Base
CREATE TABLE client_knowledge (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id VARCHAR(50) NOT NULL,
  knowledge_type VARCHAR(50) NOT NULL, -- 'case_study', 'template', 'resource', 'insight', 'faq'
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  summary TEXT,
  tags TEXT[] NOT NULL,
  industry VARCHAR(100),
  topic VARCHAR(100),
  relevance_score INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(100),
  is_active BOOLEAN DEFAULT true
);

-- Industry Insights
CREATE TABLE industry_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id VARCHAR(50) NOT NULL,
  industry VARCHAR(100) NOT NULL,
  insight_type VARCHAR(50) NOT NULL, -- 'trend', 'challenge', 'opportunity', 'best_practice', 'statistic'
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  source_url TEXT,
  relevance_score INTEGER DEFAULT 0,
  confidence_level DECIMAL(3,2) DEFAULT 0.8,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Success Stories and Case Studies
CREATE TABLE success_stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id VARCHAR(50) NOT NULL,
  industry VARCHAR(100) NOT NULL,
  company_name VARCHAR(255),
  challenge TEXT NOT NULL,
  solution TEXT NOT NULL,
  results TEXT NOT NULL,
  metrics JSONB,
  timeline VARCHAR(100),
  tags TEXT[] NOT NULL,
  anonymized BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Email Templates and Resources
CREATE TABLE email_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id VARCHAR(50) NOT NULL,
  resource_type VARCHAR(50) NOT NULL, -- 'template', 'script', 'guide', 'checklist'
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  category VARCHAR(100), -- 'introduction', 'follow_up', 'objection_handling', 'closing'
  industry VARCHAR(100),
  tags TEXT[] NOT NULL,
  usage_count INTEGER DEFAULT 0,
  success_rate DECIMAL(3,2),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Client-Specific FAQs
CREATE TABLE client_faqs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id VARCHAR(50) NOT NULL,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  category VARCHAR(100),
  industry VARCHAR(100),
  tags TEXT[] NOT NULL,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Research Queries and Results
CREATE TABLE research_queries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id VARCHAR(50) NOT NULL,
  query_type VARCHAR(50) NOT NULL, -- 'company_research', 'industry_analysis', 'competitor_analysis'
  query_text TEXT NOT NULL,
  results TEXT,
  sources TEXT[],
  relevance_score INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  lead_id VARCHAR(100),
  campaign_id VARCHAR(100)
);
```

#### Indexes for Performance
```sql
-- Performance indexes
CREATE INDEX idx_client_knowledge_client_id ON client_knowledge(client_id);
CREATE INDEX idx_client_knowledge_type ON client_knowledge(knowledge_type);
CREATE INDEX idx_client_knowledge_tags ON client_knowledge USING GIN(tags);
CREATE INDEX idx_client_knowledge_industry ON client_knowledge(industry);

CREATE INDEX idx_industry_insights_client_id ON industry_insights(client_id);
CREATE INDEX idx_industry_insights_industry ON industry_insights(industry);
CREATE INDEX idx_industry_insights_type ON industry_insights(insight_type);

CREATE INDEX idx_success_stories_client_id ON success_stories(client_id);
CREATE INDEX idx_success_stories_industry ON success_stories(industry);
CREATE INDEX idx_success_stories_tags ON success_stories USING GIN(tags);

CREATE INDEX idx_email_resources_client_id ON email_resources(client_id);
CREATE INDEX idx_email_resources_type ON email_resources(resource_type);
CREATE INDEX idx_email_resources_category ON email_resources(category);
```

## Setup Procedures

### 1. Create Supabase Projects

#### Otto Admin Project
```bash
# Create main Otto admin project
supabase projects create otto-admin --region us-east-1
```

#### Client Projects
```bash
# Create client-specific projects
supabase projects create client-{slug} --region us-east-1
```

### 2. Initialize Database Schema

#### For Each Project:
```sql
-- Run schema creation script
\i /path/to/otto-rag-schema.sql

-- Set up Row Level Security (RLS)
ALTER TABLE client_knowledge ENABLE ROW LEVEL SECURITY;
ALTER TABLE industry_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE success_stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_faqs ENABLE ROW LEVEL SECURITY;
ALTER TABLE research_queries ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "otto_admin_full_access" ON client_knowledge
  FOR ALL USING (auth.jwt() ->> 'role' = 'otto_admin');

CREATE POLICY "client_access_own_data" ON client_knowledge
  FOR ALL USING (
    client_id = (auth.jwt() ->> 'client_id')::text
    AND auth.jwt() ->> 'role' IN ('client_admin', 'client_user')
  );
```

### 3. Populate ottomatik[ai] Knowledge Base

#### Company Knowledge
```sql
-- Insert ottomatik[ai] company knowledge
INSERT INTO client_knowledge (client_id, knowledge_type, title, content, tags, industry) VALUES
('otto', 'insight', 'ottomatik[ai] Core Services', 'We specialize in AI-powered business development, lead generation, and sales automation...', ARRAY['services', 'ai', 'automation'], 'technology'),
('otto', 'case_study', 'Lead Generation Success Story', 'Client achieved 300% increase in qualified leads using our AI-powered outreach system...', ARRAY['lead_generation', 'success', 'roi'], 'technology');
```

#### Industry Insights
```sql
-- Insert industry insights
INSERT INTO industry_insights (client_id, industry, insight_type, title, content, relevance_score) VALUES
('otto', 'technology', 'trend', 'AI Adoption in B2B Sales', '78% of B2B companies are implementing AI tools for sales automation...', 95),
('otto', 'saas', 'challenge', 'Lead Quality vs Quantity', 'SaaS companies struggle with balancing lead volume and quality...', 88);
```

#### Success Stories
```sql
-- Insert success stories
INSERT INTO success_stories (client_id, industry, challenge, solution, results, metrics, tags) VALUES
('otto', 'saas', 'Low lead conversion rates', 'Implemented AI-powered lead scoring and personalized outreach', 'Increased conversion by 250%', '{"conversion_rate": 250, "time_to_close": -40}', ARRAY['saas', 'conversion', 'ai']);
```

### 4. Create Client-Specific Databases

#### Client Database Template
```sql
-- Create client-specific knowledge base
INSERT INTO client_knowledge (client_id, knowledge_type, title, content, tags, industry) VALUES
('{client_slug}', 'insight', '{Client Name} Services', '{Client-specific service descriptions...}', ARRAY['{client_tags}'], '{client_industry}'),
('{client_slug}', 'case_study', '{Client Name} Success Story', '{Client-specific success story...}', ARRAY['{client_tags}'], '{client_industry}');
```

## Knowledge Base Population Strategies

### 1. Automated Data Import

#### From Existing Systems:
```python
# Import from Google Sheets
def import_from_google_sheets(client_id, sheet_url):
    # Connect to Google Sheets API
    # Extract knowledge data
    # Transform to database format
    # Insert into client database
    pass

# Import from Airtable
def import_from_airtable(client_id, base_id, table_name):
    # Connect to Airtable API
    # Extract knowledge data
    # Transform to database format
    # Insert into client database
    pass
```

#### From Documents:
```python
# Import from PDFs and documents
def import_documents(client_id, document_paths):
    # Extract text from documents
    # Chunk content appropriately
    # Generate summaries
    # Insert into knowledge base
    pass
```

### 2. Manual Knowledge Entry

#### Web Interface:
- Admin dashboard for knowledge management
- Client-specific knowledge entry forms
- Bulk import tools
- Knowledge validation workflows

#### API Integration:
```python
# Knowledge entry API
@app.post("/api/knowledge")
async def add_knowledge(knowledge: KnowledgeEntry):
    # Validate input
    # Process content
    # Insert into database
    # Return success confirmation
    pass
```

## Otto Integration

### 1. MCP Client Configuration

#### Supabase MCP Setup:
```json
{
  "mcp_servers": {
    "supabase": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-supabase"],
      "env": {
        "SUPABASE_URL": "https://{project_id}.supabase.co",
        "SUPABASE_ANON_KEY": "{anon_key}",
        "SUPABASE_SERVICE_ROLE_KEY": "{service_role_key}"
      }
    }
  }
}
```

### 2. Knowledge Retrieval Queries

#### Otto Query Examples:
```python
# Search for relevant knowledge
def search_knowledge(client_id, query, knowledge_type=None):
    base_query = """
    SELECT * FROM client_knowledge 
    WHERE client_id = %s 
    AND (content ILIKE %s OR title ILIKE %s)
    """
    
    if knowledge_type:
        base_query += " AND knowledge_type = %s"
    
    base_query += " ORDER BY relevance_score DESC LIMIT 10"
    
    return execute_query(base_query, [client_id, f"%{query}%", f"%{query}%", knowledge_type])

# Get industry insights
def get_industry_insights(client_id, industry, insight_type=None):
    query = """
    SELECT * FROM industry_insights 
    WHERE client_id = %s AND industry = %s
    """
    
    if insight_type:
        query += " AND insight_type = %s"
    
    query += " ORDER BY relevance_score DESC LIMIT 5"
    
    return execute_query(query, [client_id, industry, insight_type])
```

### 3. Otto Reply Processing Integration

#### Enhanced Otto Workflow:
```json
{
  "otto_reply_processing": {
    "research_phase": {
      "perplexity_research": "Deep company and industry research",
      "rag_database_query": "Client-specific knowledge retrieval",
      "knowledge_synthesis": "Combine research with client knowledge"
    },
    "response_generation": {
      "value_identification": "Find value opportunities",
      "personalization": "Use client-specific insights",
      "relationship_building": "Focus on goodwill and value"
    }
  }
}
```

## Maintenance and Updates

### 1. Regular Knowledge Updates

#### Automated Updates:
- Weekly industry trend updates
- Monthly success story additions
- Quarterly knowledge base reviews
- Annual comprehensive updates

#### Manual Updates:
- Client feedback integration
- Performance-based content updates
- Seasonal campaign adjustments
- New service offering additions

### 2. Performance Monitoring

#### Metrics to Track:
- Knowledge retrieval accuracy
- Response quality improvements
- Client satisfaction scores
- Conversion rate improvements

#### Optimization:
- A/B testing different knowledge sources
- Relevance score adjustments
- Content freshness monitoring
- Usage pattern analysis

## Security and Privacy

### 1. Data Isolation

#### Client Data Separation:
- Separate Supabase projects per client
- Row Level Security (RLS) policies
- Client-specific API keys
- Encrypted data transmission

### 2. Access Control

#### Role-Based Access:
- Otto Admin: Full access to all databases
- Client Admin: Full access to client database
- Client User: Read access to client database
- API Access: Limited to specific operations

## Troubleshooting

### Common Issues:

#### Database Connection:
- Verify Supabase credentials
- Check network connectivity
- Validate project URLs
- Confirm API key permissions

#### Knowledge Retrieval:
- Verify client_id matches
- Check RLS policies
- Validate query syntax
- Monitor query performance

#### Content Quality:
- Review knowledge relevance
- Update outdated information
- Validate source accuracy
- Monitor usage patterns

## Conclusion

The RAG database setup provides Otto with comprehensive, client-specific knowledge to generate intelligent, value-focused responses. This infrastructure enables:

- **Intelligent Responses**: Context-aware replies using client knowledge
- **Value Demonstration**: Always provide genuine value in responses
- **Relationship Building**: Focus on goodwill and conversation starting
- **Scalable Architecture**: Support for unlimited clients with data isolation
- **Performance Optimization**: Fast knowledge retrieval and synthesis

This foundation transforms Otto from a generic response system into an intelligent business development partner that understands each client's unique context and provides valuable, personalized interactions.
