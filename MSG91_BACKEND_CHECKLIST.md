# Backend MSG91 Configuration Checklist

This checklist helps backend developers verify MSG91 OTP configuration.

## Prerequisites
- [ ] MSG91 account created at [msg91.com](https://msg91.com)
- [ ] Account activated and verified
- [ ] Wallet has sufficient balance

## Required MSG91 Credentials

### 1. Auth Key (API Key)
- [ ] Auth key obtained from MSG91 dashboard
- [ ] Auth key added to backend `.env` file as `MSG91_AUTH_KEY`
- [ ] Auth key is active (not expired or revoked)

**Get Auth Key:**
1. Login to MSG91
2. Go to Settings → API Keys
3. Copy your Auth Key

### 2. Template ID (DLT Approved)
- [ ] OTP template created in MSG91
- [ ] Template submitted for DLT approval
- [ ] Template status is "APPROVED" (not Pending/Rejected)
- [ ] Template ID added to `.env` as `MSG91_TEMPLATE_ID`

**Template Format Example:**
```
Your OTP for {#brand_name#} login is {#var#}. Valid for {#time#} minutes. Do not share.
```

**Check Template:**
1. Go to MSG91 → SMS → Templates
2. Verify status = APPROVED
3. Copy Template ID

### 3. Sender ID
- [ ] Sender ID (6 characters) created
- [ ] Sender ID approved by MSG91
- [ ] Sender ID added to `.env` as `MSG91_SENDER_ID`

**Example:** `DRM247`, `DREAM2`, etc.

## Backend Code Verification

### Environment Variables
```env
MSG91_AUTH_KEY=your_auth_key_here
MSG91_TEMPLATE_ID=your_template_id_here
MSG91_SENDER_ID=DRM247
```

### Mobile Number Format
- [ ] Backend sends mobile with country code: `919876543210`
- [ ] OR backend sends 10 digits and MSG91 SDK adds prefix

### MSG91 API Endpoint
- [ ] Using correct endpoint: `https://control.msg91.com/api/v5/otp`
- [ ] OR using MSG91 SDK (recommended)

### Error Handling
- [ ] Backend logs MSG91 API responses
- [ ] Backend returns MSG91 errors to frontend
- [ ] Backend includes delivery status in response

## DLT Compliance (India Only)

### Entity Registration
- [ ] Telecom entity registered on DLT portal
- [ ] Entity ID obtained
- [ ] Entity ID added to MSG91

### Template DLT Mapping
- [ ] Template registered on DLT portal
- [ ] Content template ID obtained
- [ ] Template mapped in MSG91 dashboard

**DLT Portals:**
- Jio: https://trueconnect.jio.com
- Airtel: https://dltconnect.airtel.in
- VI: https://www.vilpower.in
- BSNL: https://www.ucc-bsnl.co.in

### Testing
- [ ] Test OTP send to your registered mobile
- [ ] Check MSG91 dashboard → Reports → Sent SMS
- [ ] Verify delivery status is "Delivered"

## Common Issues

| Issue | Solution |
|-------|----------|
| "Invalid Auth Key" | Check MSG91_AUTH_KEY in .env |
| "Template not found" | Verify MSG91_TEMPLATE_ID is correct |
| "DLT Error" | Ensure template is DLT approved |
| "Insufficient balance" | Recharge MSG91 wallet |
| "Invalid mobile number" | Check number format (91XXXXXXXXXX) |
| SMS not delivered | Check DLT approval status |

## Debug Commands

### Check Environment Variables
```bash
echo $MSG91_AUTH_KEY
echo $MSG91_TEMPLATE_ID
echo $MSG91_SENDER_ID
```

### Test MSG91 API Directly
```bash
curl -X POST "https://control.msg91.com/api/v5/otp" \
  -H "Content-Type: application/json" \
  -d '{
    "template_id": "YOUR_TEMPLATE_ID",
    "mobile": "919876543210",
    "authkey": "YOUR_AUTH_KEY"
  }'
```

### Check Backend Logs
```bash
# If using PM2
pm2 logs | grep MSG91

# If using direct logs
tail -f logs/app.log | grep MSG91
```

## Support

If all checks pass but SMS still not delivered:
1. Open MSG91 support ticket
2. Provide: Account ID, Template ID, mobile number, timestamp
3. Ask for delivery failure reason
