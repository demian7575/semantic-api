# Changelog

## 2026-02-26 - UI/UX Improvements

### Frontend Changes
- **Inline Input Section**: Replaced popup dialogs with inline yellow box for input editing
  - GET requests: Show URL in textarea (resizable, 80px min-height)
  - POST requests: Show JSON body in textarea
  - Input section stays visible after execution
  - Both Input and Response visible simultaneously for easy comparison

- **Port Configuration**: Fixed ec2-manager.js to use port 9000 (was incorrectly using 4000)
  - Updated `apiBaseUrl` from port 4000 to 9000
  - Updated `semanticApiUrl` from port 8083 to 9000

### Documentation Updates
- Updated README.md:
  - Architecture diagram now shows frontend flow with inline Input/Response
  - Corrected all port references from 8183 to 9000
  - Removed hardcoded EC2 IPs, replaced with `<EC2-IP>` placeholder
  - Added "Using the Frontend" section with step-by-step instructions
  - Updated troubleshooting to mention port 9000 check

- Updated AUTO-START-SETUP.md:
  - Added inline Input/Response UI flow
  - Changed to dynamic IP resolution (from Lambda status)
  - Removed hardcoded IPs

### Technical Details
- CSS fix: Added `#inputContent` specific rule to override global textarea min-height
- Made input textarea resizable (vertical)
- Input section uses yellow background (#fff3cd) for visibility
- Response section uses gray background (#f8f9fa)

### User Experience
Before: Click Test → Popup dialog → Edit → Execute → Dialog closes → See response
After: Click Test → Inline input appears → Edit → Execute → Response appears below (input stays visible)

## Previous Versions

### 2026-02-25 - Auto-Start Integration
- Integrated with AIPM Lambda for EC2 auto-start
- S3 static website frontend
- Shared Lambda function with AIPM

### 2026-02-04 - Initial Release
- Template-based API with Kiro CLI integration
- Synchronous request/response pattern
- Zero dependencies Node.js server
