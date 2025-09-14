# 11-Step Domain Setup Quick Reference

## Complete Process for New Domain Batches

### **Step 1: Purchase Domains**
- Buy domains from any registrar
- Ensure availability and registration

### **Step 2: Google Workspace Email**
- Create alias: `{slug}@ottomatik.ai`
- Use for Cloudflare account creation

### **Step 3: Cloudflare Account**
- Create new account with `{slug}@ottomatik.ai`
- Provides DNS management and security

### **Step 4: Nameservers**
- Change domain nameservers to Cloudflare
- Wait for propagation (up to 24 hours)

### **Step 5: Migadu Setup**
- Add domains to Migadu account
- Copy Email Verifier Codes

### **Step 6: DNS Configuration**
- Download BIND files from Migadu
- Upload BIND files to Cloudflare

### **Step 7: Migadu Verification**
- Verify domains in Migadu
- Test email authentication

### **Step 8: SparkPost Setup**
- Add domains to SparkPost
- Copy DKIM information

### **Step 9: Cursor Integration**
- Provide DKIM from SparkPost
- Provide Email Verifier Code from Migadu
- Cursor creates complete BIND file

### **Step 10: Create and Upload Complete BIND Files**
- **Cloudflare domains**: Cursor creates separate BIND file for each domain
- **Files stored in**: `domains/cloudflare/{slug}/` folder (otto) or `domains/cloudflare/clients/{slug}/` folder (clients)
- **Upload each BIND file individually** to Cloudflare
- **GoDaddy/Outlook domains**: DNS configured directly in GoDaddy control panel
- Includes SparkPost sending, Migadu receiving, Netlify forwarding

### **Step 11: Verify Domains on SparkPost**
- Verify domains are properly configured in SparkPost
- Test email sending functionality
- Ensure DKIM authentication is working

## After 11 Steps Complete:

### **Step 12: Netlify Setup**
- Add domains as aliases in Netlify
- Verify green checkmarks

### **Step 13: Repository Updates**
- Only after all manual steps complete
- Repository changes will then work

## Key Points:
- **All 11 steps must be completed first**
- **Repository changes alone will NOT work**
- **Manual setup is always required**
- **Test each domain after setup**
