# Domain Setup Guide

## Complete Process for Adding New Domains

### **⚠️ CRITICAL: Complete Setup Process Required**

Repository updates alone will NOT work. You must complete this entire process first:

### **🔍 VERIFICATION STEP:**
**Before making any repository changes, ALWAYS ask the user:**
- "Have you completed all 9 steps of the domain setup process?"
- "Have you added the domains to Netlify as domain aliases?"
- "Are the domains showing green checkmarks in Netlify Domain Management?"
- "Have you configured the DNS records (DNS-only, no proxy)?"

**If the answer is NO to any of these questions, STOP and have them complete the manual setup first.**

## Complete 9-Step Domain Setup Process

### **Step 1: Purchase Domains**
- Purchase domains from any registrar
- Ensure domains are available and registered

### **Step 2: Set Up Google Workspace Email**
- Create alias email address: `{slug}@ottomatik.ai`
- Use this email for Cloudflare account creation

### **Step 3: Create Cloudflare Account**
- Use the `{slug}@ottomatik.ai` email address
- Create new Cloudflare account for the client
- This provides DNS management and security features

### **Step 4: Update Domain Nameservers**
- Change domain nameservers to Cloudflare
- Wait for DNS propagation (up to 24 hours)
- Verify nameservers are active

### **Step 5: Add Domains to Migadu**
- Add domains to Migadu email account
- Copy Email Verifier Codes from Migadu
- These codes are needed for DNS configuration

### **Step 6: Configure DNS with Migadu**
- Download BIND files from Migadu
- Upload BIND files to Cloudflare
- This configures email authentication (SPF, DKIM, DMARC)

### **Step 7: Verify Migadu Setup**
- Ensure domains have been verified in Migadu
- Check that email authentication is working
- Test email delivery

### **Step 8: Add Domains to SparkPost**
- Add domains to SparkPost account
- Copy DKIM information from SparkPost
- This enables high deliverability email sending

### **Step 9: Provide Information to Cursor**
- Provide DKIM from SparkPost
- Provide Email Verifier Code from Migadu
- Cursor will create complete BIND file for DNS configuration

### **Step 10: Create and Upload Complete BIND Files**
- **For Cloudflare-managed domains**: Cursor creates separate BIND file for each domain
- **Files stored in**: `domains/cloudflare/{slug}/` folder (otto) or `domains/cloudflare/clients/{slug}/` folder (clients)
- **Each file includes**: SparkPost sending, Migadu receiving, Netlify forwarding
- **Upload each BIND file individually** to Cloudflare
- **For GoDaddy/Outlook domains**: DNS configured directly in GoDaddy control panel (no BIND files)
- Ensures all DNS records are properly configured

### **Step 11: Verify Domains on SparkPost**
- Verify domains are properly configured in SparkPost
- Test email sending functionality
- Ensure DKIM authentication is working

## Step 12: Netlify Setup (After DNS Configuration)

### **12.1 Add Domain to Netlify**
1. **Go to Netlify Domain Management**
   - Navigate to your project: `glittering-daifuku-9f7966`
   - Click "Domain management" in sidebar
2. **Click "Add domain alias"**
3. **Enter the new domain** (e.g., `newdomain.com`)
4. **Click "Add"**
5. **Repeat for each domain**

### **12.2 Verify Domain Status**
- Domain should show **green checkmark** and **"Netlify DNS"**
- If it shows **"External DNS"**, you need to configure DNS records

## Step 3: Repository Configuration

### **3.1 Branch Structure**
- **All PTC domains** use the `ptc` branch
- **All ottomatik[ai] domains** would use an `otto` branch
- **Each client** gets their own branch

### **3.2 Files to Update**
The `ptc` branch contains:
- **`_redirects`**: `/*    https://pullthechute.net/:splat    301!`
- **`index.html`**: Redirect page with proper branding

### **3.3 No Repository Changes Needed**
- **Existing configuration** handles all domains
- **New domains** automatically use the same redirect rules
- **Only manual Netlify setup** is required

## Step 4: Verification

### **4.1 Test Domain**
1. **Visit the domain** in browser
2. **Should redirect** to `https://pullthechute.net/`
3. **Check SSL certificate** is issued
4. **Verify redirect** works properly

### **4.2 Troubleshooting**
- **"Site not found"**: Domain not added to Netlify
- **DNS errors**: Check DNS records and propagation
- **SSL issues**: Wait for certificate issuance (up to 24 hours)

## Complete Domain List

### **PTC Domains (All Working)**
1. `ptcgrow.com` ✅
2. `ptcgrowth.com` ✅
3. `ptcgrowth.net` ✅
4. `ptccoaching.net` ✅
5. `ptcgrowyourpeople.com` ✅
6. `ptcgrowyourpeople.net` ✅
7. `ptcgrow.net` ✅
8. `ptccoach.net` ✅
9. `ptccoach.com` ✅
10. `pullthechutecoaching.com` ✅
11. `pullthechutecoach.com` ✅
12. `pullthechuteteam.com` ✅

## Adding Future Domains

### **For New PTC Domains:**
1. **Add to Netlify** as domain alias
2. **Configure DNS records** (DNS-only)
3. **Test redirect** - no repository changes needed

### **For New Clients:**
1. **Create new branch** (e.g., `newclient`)
2. **Update redirect target** in `_redirects` and `index.html`
3. **Add domains to Netlify** as domain aliases
4. **Configure DNS records**

## Important Notes

- **Repository changes alone will NOT work**
- **Manual Netlify setup is always required**
- **DNS records must be DNS-only** (no proxy)
- **SSL certificates** take up to 24 hours to issue
- **Test each domain** after setup
