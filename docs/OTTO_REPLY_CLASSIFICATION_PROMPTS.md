# Otto Reply Classification Prompts

## Overview

This document contains the exact classification prompts used by Otto for categorizing incoming replies from cold email campaigns. These prompts are based on the user's specific requirements and are integrated into the Otto Reply Processing Sub-Agent.

## Available Reply Categories:

1. **Ready to Schedule** - Leads wanting to book meetings or demos
2. **More Info Needed** - Leads requesting additional information or details
3. **Follow-Up Later** - Leads interested but not ready to proceed now
4. **Referred** - Leads referring others or mentioning colleagues
5. **Not Interested** - Leads declining but potentially open to value-based responses
6. **No Budget** - Leads citing budget constraints
7. **Already Using Competitor** - Leads with existing solutions
8. **Unsubscribe/Do Not Contact** - Leads requesting to stop communications
9. **Out-of-Office** - Leads temporarily unavailable
10. **Error Correction** - Leads pointing out errors in personalization or research
11. **Miscellaneous** - Emails that don't fit other categories

## Classification System

### Category Keywords and Patterns

#### 1. Ready to Schedule
**Key Phrases:**
- "Let's schedule a call"
- "I'd like to learn more"
- "When can we meet?"
- "I'm interested in a demo"
- "Let's set up a meeting"
- "I'd like to discuss this further"
- "Can we schedule a time?"

**Patterns:**
- Direct meeting requests
- Demo requests
- Call scheduling
- Interest in learning more
- Availability inquiries

**Example Emails:**
- "Hi, I'd like to schedule a call to learn more about your services."
- "This sounds interesting. When can we meet to discuss further?"
- "I'm interested in a demo. What times work for you?"

#### 2. More Info Needed
**Key Phrases:**
- "Can you tell me more about..."
- "What exactly do you offer?"
- "How does this work?"
- "I need more details"
- "Can you explain..."
- "What are your prices?"
- "Tell me more"

**Patterns:**
- Information requests
- Detail inquiries
- Explanation needs
- Pricing questions
- Service clarification

**Example Emails:**
- "This sounds interesting but I need more details about how it works."
- "Can you tell me more about your pricing structure?"
- "What exactly do you offer that's different from other providers?"

#### 3. Follow-Up Later
**Key Phrases:**
- "Not right now"
- "Maybe later"
- "We're not ready yet"
- "Check back in a few months"
- "Timing isn't right"
- "We're busy right now"
- "Not at this time"

**Patterns:**
- Timing objections
- Future interest
- Current busyness
- Delayed decisions
- Seasonal timing

**Example Emails:**
- "This looks interesting but we're not ready to make changes right now."
- "Maybe check back with us in a few months when we have more time."
- "We're busy with other projects at the moment."

#### 4. Referred
**Key Phrases:**
- "You should talk to..."
- "Contact my colleague"
- "Speak with..."
- "I'll forward this to..."
- "My team lead is..."
- "The decision maker is..."

**Patterns:**
- Colleague mentions
- Decision maker referrals
- Team member references
- Forwarding requests
- Authority delegation

**Example Emails:**
- "You should talk to my colleague Sarah who handles this."
- "I'll forward this to our marketing director."
- "The decision maker on this is our CEO."

#### 5. Not Interested
**Key Phrases:**
- "Not interested"
- "We're good"
- "We're satisfied"
- "Not for us"
- "We don't need this"
- "Thanks but no thanks"
- "We're all set"

**Patterns:**
- Direct rejections
- Satisfaction statements
- No need declarations
- Polite declines
- Current solution satisfaction

**Example Emails:**
- "Thanks for reaching out but we're not interested."
- "We're satisfied with our current solution."
- "Not for us at this time."

#### 6. No Budget
**Key Phrases:**
- "No budget"
- "Can't afford it"
- "Too expensive"
- "Budget constraints"
- "No money for this"
- "Cost is too high"
- "Not in the budget"

**Patterns:**
- Budget limitations
- Cost objections
- Financial constraints
- Pricing concerns
- Affordability issues

**Example Emails:**
- "This sounds good but we don't have budget for it right now."
- "The cost is too high for our current situation."
- "We have budget constraints this quarter."

#### 7. Already Using Competitor
**Key Phrases:**
- "We already use..."
- "We work with..."
- "We have a provider"
- "We're with..."
- "We use [competitor name]"
- "We already have this"

**Patterns:**
- Competitor mentions
- Existing provider references
- Solution already in place
- Vendor relationships
- Current partnerships

**Example Emails:**
- "We already use HubSpot for this."
- "We work with another provider for this service."
- "We have a solution in place already."

#### 8. Unsubscribe/Do Not Contact
**Key Phrases:**
- "Remove me"
- "Stop contacting me"
- "Unsubscribe"
- "Don't email me"
- "Take me off your list"
- "Stop sending"
- "Do not contact"

**Patterns:**
- Removal requests
- Contact cessation
- List removal
- Communication stopping
- Privacy requests

**Example Emails:**
- "Please remove me from your mailing list."
- "Stop contacting me."
- "I don't want to receive these emails."

#### 9. Out-of-Office
**Key Phrases:**
- "Out of office"
- "I'm away"
- "Not available"
- "On vacation"
- "Will be back"
- "Currently unavailable"
- "Out until"

**Patterns:**
- Unavailability notices
- Vacation messages
- Absence notifications
- Return date mentions
- Temporary unavailability

**Example Emails:**
- "I'm out of the office until next week."
- "Currently on vacation, will respond when I return."
- "Not available until Monday."

#### 10. Error Correction
**Key Phrases:**
- "That's not correct"
- "You have the wrong information"
- "That's not accurate"
- "You're mistaken about"
- "Actually, we don't"
- "That's incorrect"
- "You got it wrong"

**Patterns:**
- Factual corrections
- Information errors
- Misunderstanding corrections
- Accuracy disputes
- Wrong details

**Example Emails:**
- "Actually, we don't use that software anymore."
- "That's not correct - we're not in that industry."
- "You have the wrong information about our company."

#### 11. Miscellaneous
**Key Phrases:**
- Various unrelated content
- Questions about other topics
- General inquiries
- Random comments
- Unclear intent

**Patterns:**
- Non-business related
- Unclear categorization
- Random content
- General questions
- Unrelated topics

**Example Emails:**
- "How's the weather there?"
- "Do you know anyone who can help with..."
- "This is interesting but not relevant to us."

## Classification Algorithm

### Step 1: Keyword Analysis
- Scan email content for key phrases
- Count keyword matches per category
- Identify strongest category matches

### Step 2: Pattern Recognition
- Analyze sentence structure and intent
- Look for specific patterns associated with each category
- Consider context and tone

### Step 3: Context Evaluation
- Review overall email tone and sentiment
- Consider business relationship context
- Evaluate urgency and priority

### Step 4: Category Assignment
- Assign to category with highest confidence score
- Use "Miscellaneous" for unclear cases
- Ensure single category assignment

## Classification Prompt Template

### SYSTEM Prompt:
```
You are an expert email classifier specializing in categorizing business reply emails. Your task is to analyze incoming replies from cold email campaigns and classify them into one of 11 specific categories.

Available Categories:
1. Ready to Schedule - Leads wanting to book meetings or demos
2. More Info Needed - Leads requesting additional information or details
3. Follow-Up Later - Leads interested but not ready to proceed now
4. Referred - Leads referring others or mentioning colleagues
5. Not Interested - Leads declining but potentially open to value-based responses
6. No Budget - Leads citing budget constraints
7. Already Using Competitor - Leads with existing solutions
8. Unsubscribe/Do Not Contact - Leads requesting to stop communications
9. Out-of-Office - Leads temporarily unavailable
10. Error Correction - Leads pointing out errors in personalization or research
11. Miscellaneous - Emails that don't fit other categories

Classification Rules:
- Analyze the email content for key phrases and patterns
- Consider the overall tone and intent of the message
- Assign to the most appropriate single category
- Use "Miscellaneous" only when no other category fits
- Focus on the primary intent or request in the email

Output Format:
ONLY the category name. No explanations, no additional text, just the category name.
```

### USER Prompt:
```
Classify this email reply:

Email Content: {{ $('Split Out Mails + Order').item.json.message.content.emails[0].content }}

Category:
```

## Implementation Notes

### Integration with Otto Reply Processing Sub-Agent:
- Classification is performed as the first step in reply processing
- Results are used to trigger appropriate response generation strategies
- Category determines which tools and research are needed
- Classification accuracy is critical for proper response handling

### Quality Assurance:
- Monitor classification accuracy through response outcomes
- Track misclassifications and adjust prompts accordingly
- Use feedback from successful responses to improve accuracy
- Regular review of category definitions and examples

### Error Handling:
- Default to "Miscellaneous" for unclear cases
- Log classification confidence scores
- Flag low-confidence classifications for review
- Provide fallback responses for edge cases

## Success Metrics

### Classification Accuracy:
- Percentage of correctly classified emails
- Reduction in misclassification over time
- Response effectiveness by category
- User satisfaction with response quality

### Response Quality:
- Appropriate response generation per category
- Successful follow-up actions
- Lead progression through sales funnel
- Relationship building effectiveness

## Maintenance and Updates

### Regular Review:
- Monthly review of classification accuracy
- Quarterly update of category definitions
- Annual review of classification algorithm
- Continuous improvement based on feedback

### Category Evolution:
- Add new categories as needed
- Refine existing category definitions
- Update keyword lists and patterns
- Improve classification prompts

### Performance Optimization:
- Monitor classification speed and accuracy
- Optimize prompt engineering
- Improve pattern recognition
- Enhance context understanding
