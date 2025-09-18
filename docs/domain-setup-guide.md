# 🌐 Domain Setup Guide

## 📋 OVERVIEW

Complete step-by-step guide for setting up new domains after purchase with nameservers pointed to Cloudflare. This process configures email infrastructure, tracking, and web redirects.

**Prerequisites:**
- Domain purchased
- Nameservers pointed to Cloudflare
- Access to SparkPost, Postal, and Netlify accounts

---

## 🔧 PHASE 1: SERVICE CONFIGURATION

### **Step 1: Add Domain to SparkPost**

**1.1 Add Sending Domain:**
```
Login to SparkPost → Configuration → Sending Domains → Add a Domain
Enter: yourdomain.com
Click "Add Domain"
```

**1.2 Copy SparkPost DKIM Record:**
```
Navigate to your domain settings
Copy the DKIM record provided (format: selector._domainkey.domain.com)
Save for BIND file creation
Example: scph0725._domainkey.yourdomain.com
```

**1.3 Add Tracking Domain:**
```
Configuration → Tracking Domains → Add a Domain  
Enter: track.yourdomain.com
Click "Add Domain"
(Will verify after DNS is configured)
```

### **Step 2: Add Domain to Postal**

**2.1 Add Domain:**
```
Login to Postal → Organizations → Your Org → Domains → Add Domain
Enter: yourdomain.com
Click "Add Domain"
```

**2.2 Copy Postal DKIM Record:**
```
Navigate to domain settings
Copy the DKIM record provided (format: postal-XXXXX._domainkey.domain.com)
Save for BIND file creation
Example: postal-dwhC5K._domainkey.yourdomain.com
```

### **Step 3: Add Domain to Netlify**

**3.1 Option A: New Client (Fork Required)**
```
Fork domain-redirects repository for new client
Create new Netlify site
Add custom domain: yourdomain.com
Note Netlify app name (e.g., glittering-daifuku-9f7966)
```

**3.2 Option B: Existing Client**
```
Access existing Netlify site
Site Settings → Domain Management → Add Domain
Enter: yourdomain.com
Note existing Netlify app name
```

---

## 📝 PHASE 2: BIND FILE CREATION

### **Step 4: Provide Information to Assistant**

**Required Information:**
- Domain name: `yourdomain.com`
- Postal DKIM record: `postal-XXXXX._domainkey.yourdomain.com`
- SparkPost DKIM record: `scph0725._domainkey.yourdomain.com` 
- Netlify app name: `your-app-name-123456`

### **Step 5: BIND File Template**

**Assistant will create file using Otto template:**

```dns
yourdomain.com.	1	IN	A	75.2.60.5 ; cf_tags=cf-proxied:false
www.yourdomain.com.	1	IN	CNAME	{NETLIFY_APP}.netlify.app. ; cf_tags=cf-proxied:false
psrp.yourdomain.com.	300	IN	CNAME	rp.postal.ottomatik.ai. ; cf_tags=cf-proxied:false
track.yourdomain.com.	1	IN	CNAME	spgo.io. ; cf_tags=cf-proxied:false
yourdomain.com.	300	IN	MX	10	mx.postal.ottomatik.ai.
yourdomain.com.	300	IN	TXT	"v=spf1 a mx include:spf.postal.ottomatik.ai include:_spf.sparkpostmail.com ~all"
_dmarc.yourdomain.com.	300	IN	TXT	"v=DMARC1; p=reject; rua=mailto:bryce@ottomatik.ai"
{POSTAL_DKIM_SELECTOR}._domainkey.yourdomain.com.	300	IN	TXT	"{POSTAL_DKIM_RECORD}"
{SPARKPOST_DKIM_SELECTOR}._domainkey.yourdomain.com.	300	IN	TXT	"{SPARKPOST_DKIM_RECORD}"
```

**Key Features:**
- **A Record**: Points to Netlify IP (75.2.60.5)
- **WWW CNAME**: Points to Netlify app
- **Track CNAME**: Points to SparkPost (`spgo.io`)
- **PSRP CNAME**: Points to Postal bounce handling
- **MX Record**: Points to Postal mail server
- **SPF Record**: Includes both Postal and SparkPost
- **DMARC**: Strict policy with reporting
- **DKIM Records**: Both Postal and SparkPost authentication

---

## ☁️ PHASE 3: CLOUDFLARE & TESTING

### **Step 6: Upload BIND File to Cloudflare**

**6.1 Import DNS Records:**
```
Cloudflare Dashboard → DNS → Records
Click "Import DNS records"
Upload the BIND file created in Phase 2
Review imported records
```

**6.2 Verify DNS-Only Configuration:**
```
Check ALL records have gray cloud (DNS-only)
Orange cloud MUST be OFF for:
- A records (breaks Netlify)
- CNAME records (breaks email)
- MX records (breaks email delivery)
- TXT records (breaks authentication)
```

**6.3 Wait for DNS Propagation:**
```
Allow 24-48 hours for full propagation
Use dig or online tools to verify records
dig track.yourdomain.com CNAME
dig yourdomain.com MX
```

### **Step 7: Service Verification**

**7.1 Verify SparkPost Domain:**
```
SparkPost → Configuration → Sending Domains
Click "Verify" next to yourdomain.com
Status should show "Verified" ✅
```

**7.2 Verify SparkPost Tracking Domain:**
```
SparkPost → Configuration → Tracking Domains  
Click "Verify" next to track.yourdomain.com
Link to sending domain when verified
```

**7.3 Test Postal Configuration:**
```
Postal → Domain Settings
Check domain status is "Verified"
Send test email to verify delivery
```

**7.4 Test Netlify Forwarding:**
```
Visit yourdomain.com in browser
Should redirect to target destination
Check www.yourdomain.com also redirects
```

---

## 🔀 PHASE 4: GITHUB DOMAIN REDIRECTS

### **Step 8: New Client Setup**

**8.1 Fork Repository:**
```
Fork domain-redirects repository
Create new branch: client-slug
Example: git checkout -b acme-corp
```

**8.2 Configure Redirects:**
```
Edit _redirects file:
/* https://target-domain.com/:splat 301!

Edit index.html:
Update CLIENT_NAME and TARGET_DOMAIN placeholders
```

**8.3 Deploy to Netlify:**
```
Connect new Netlify site to forked repository
Set deploy branch to client-slug
Configure custom domain: yourdomain.com
```

### **Step 9: Existing Client Setup**

**9.1 Add Domain to Existing Site:**
```
Netlify → Site Settings → Domain Management
Add custom domain: yourdomain.com
SSL certificate will auto-provision
```

**9.2 Update Branch (if needed):**
```
If multiple domains for client:
Update _redirects file with new domain rules
Commit and push to trigger deployment
```

---

## 🧪 PHASE 5: FINAL TESTING

### **Step 10: Comprehensive Verification**

**10.1 DNS Resolution:**
```bash
# Verify all records resolve correctly
dig yourdomain.com A
dig yourdomain.com MX  
dig track.yourdomain.com CNAME
dig _dmarc.yourdomain.com TXT
```

**10.2 Email Authentication:**
```
Use MXToolbox or similar to test:
- SPF record validation
- DKIM record validation  
- DMARC policy check
- MX record connectivity
```

**10.3 SparkPost Integration:**
```
Send test email from domain
Verify tracking links work
Check SparkPost analytics dashboard
Confirm webhook events (if configured)
```

**10.4 Postal Integration:**
```
Send test email to domain
Verify email is received in Postal
Check bounce handling works
Test reply-to functionality
```

**10.5 Web Redirects:**
```
Test yourdomain.com redirects correctly
Test www.yourdomain.com redirects correctly
Verify SSL certificate is active
Check redirect response codes (301)
```

---

## 🚨 TROUBLESHOOTING

### **Common Issues:**

**DNS Not Propagating:**
- Wait 24-48 hours for full propagation
- Check TTL values (should be low for testing)
- Use multiple DNS checkers worldwide

**Email Authentication Failing:**
- Verify DKIM records copied exactly
- Check SPF record includes both services
- Ensure DMARC policy is not too strict initially

**Netlify Redirects Not Working:**
- Confirm A record points to 75.2.60.5
- Verify Cloudflare proxy is OFF (gray cloud)
- Check Netlify custom domain configuration

**SparkPost Domain Not Verifying:**
- Wait for DNS propagation
- Check DKIM record format and content
- Verify tracking domain CNAME is correct

**Postal Domain Issues:**
- Confirm MX record points to Postal
- Check domain status in Postal dashboard
- Verify bounce handling CNAME is correct

---

## 📋 CHECKLIST

**Pre-Setup:**
- [ ] Domain purchased and nameservers updated
- [ ] Access to SparkPost, Postal, Netlify accounts
- [ ] GitHub repository access (for new clients)

**Service Configuration:**
- [ ] Domain added to SparkPost
- [ ] Domain added to Postal  
- [ ] Domain added to Netlify
- [ ] DKIM records copied

**DNS Configuration:**
- [ ] BIND file created with correct records
- [ ] BIND file uploaded to Cloudflare
- [ ] All records set to DNS-only (gray cloud)
- [ ] DNS propagation verified

**Verification:**
- [ ] SparkPost domain verified
- [ ] SparkPost tracking domain verified and linked
- [ ] Postal domain verified and functional
- [ ] Netlify redirects working correctly

**Final Testing:**
- [ ] Email sending/receiving works
- [ ] Email authentication passes
- [ ] Web redirects function properly
- [ ] SSL certificates active

---

**Last Updated:** September 18, 2025  
**Status:** Complete Setup Guide  
**Scope:** Domain Infrastructure Only (Mailbox creation is separate process)
