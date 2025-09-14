# Domain Setup Verification Checklist

## 🔍 **BEFORE ANY REPOSITORY CHANGES - ASK THESE QUESTIONS:**

### **1. Complete 11-Step Process:**
- ✅ "Have you completed all 11 steps of the domain setup process?"
- ✅ "Have you purchased the domains?"
- ✅ "Have you set up the Google Workspace email alias?"
- ✅ "Have you created the Cloudflare account?"
- ✅ "Have you updated the domain nameservers?"
- ✅ "Have you added domains to Migadu and copied verifier codes?"
- ✅ "Have you downloaded and uploaded BIND files to Cloudflare?"
- ✅ "Have you verified domains in Migadu?"
- ✅ "Have you added domains to SparkPost and copied DKIM info?"
- ✅ "Have you provided DKIM and verifier codes to Cursor?"
- ✅ "Have you created and uploaded the complete BIND files to Cloudflare (separate file per domain)?"
- ✅ "Have you verified domains on SparkPost?"

### **2. Netlify Setup:**
- ✅ "Have you added the domains to Netlify as domain aliases?"
- ✅ "Are the domains showing green checkmarks in Netlify Domain Management?"
- ✅ "Do the domains show 'Netlify DNS' status?"

### **3. DNS Configuration:**
- ✅ "Have you configured the DNS records (DNS-only, no proxy)?"
- ✅ "Are the A records pointing to Netlify IP?"
- ✅ "Are the CNAME records pointing to the Netlify site?"
- ✅ "Is the Cloudflare proxy OFF (gray cloud, not orange)?"

### **4. Verification:**
- ✅ "Have you tested the domains to ensure they redirect properly?"
- ✅ "Are SSL certificates issued for the domains?"

## ⚠️ **IF ANY ANSWER IS NO:**
**STOP and have them complete the manual setup first.**

## ✅ **IF ALL ANSWERS ARE YES:**
**Then proceed with repository changes.**

---

## Quick Reference:

### **Netlify Steps:**
1. Go to Domain Management
2. Click "Add domain alias"
3. Add each domain
4. Verify green checkmarks

### **DNS Steps:**
1. Add A record: `domain.com` → Netlify IP
2. Add CNAME: `www.domain.com` → Netlify site
3. Ensure proxy is OFF (gray cloud)

### **Test:**
1. Visit domain in browser
2. Should redirect to target site
3. Check SSL certificate
