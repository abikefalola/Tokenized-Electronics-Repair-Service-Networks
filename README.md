# Tokenized Electronics Repair Service Networks

A comprehensive blockchain-based system for managing electronics repair services using Clarity smart contracts on the Stacks blockchain.

## Overview

This system provides a decentralized platform for electronics repair services with the following key features:

- **Service Provider Verification**: Validates and manages electronics repair service providers
- **Repair Tracking**: Comprehensive tracking of repair processes from start to completion
- **Parts Authentication**: Ensures authenticity and traceability of repair parts
- **Warranty Management**: Digital warranty system with claim processing
- **Customer Satisfaction**: Rating and feedback system for service quality assurance

## Architecture

The system consists of five interconnected smart contracts:

### 1. Service Provider Verification Contract
- Provider registration and verification
- Reputation scoring system
- Performance statistics tracking
- Owner-controlled verification process

### 2. Repair Tracking Contract
- Job creation and management
- Status updates throughout repair process
- Cost estimation and final billing
- Update history tracking

### 3. Parts Authentication Contract
- Part registration with manufacturer details
- Verification and authentication process
- Usage tracking for warranty purposes
- Supplier management system

### 4. Warranty Management Contract
- Digital warranty creation and management
- Claim filing and processing system
- Warranty status tracking
- Terms and coverage management

### 5. Customer Satisfaction Contract
- Multi-dimensional rating system
- Customer feedback collection
- Provider response system
- Satisfaction analytics

## Key Features

### For Service Providers
- Register and get verified on the platform
- Create and manage repair jobs
- Track repair progress and update customers
- Manage warranties and process claims
- Respond to customer feedback
- Build reputation through quality service

### For Customers
- Find verified repair providers
- Track repair progress in real-time
- Submit ratings and feedback
- File warranty claims
- Access repair history and documentation

### For Parts Suppliers
- Register authentic parts with verification
- Track part usage across repairs
- Maintain supply chain transparency
- Support warranty processes

## Smart Contract Functions

### Service Provider Verification
\`\`\`clarity
;; Register as a service provider
(register-provider (name (string-ascii 50)) (specialization (string-ascii 100)))

;; Verify a provider (owner only)
(verify-provider (provider principal))

;; Update reputation score
(update-reputation (provider principal) (score uint))
\`\`\`

### Repair Tracking
\`\`\`clarity
;; Create a new repair job
(create-repair-job (provider principal) (device-type (string-ascii 50))
(issue-description (string-ascii 200)) (estimated-completion uint)
(cost-estimate uint))

;; Update repair status
(update-repair-status (job-id uint) (new-status uint) (notes (string-ascii 200)))

;; Complete repair
(complete-repair (job-id uint) (final-cost uint))
\`\`\`

### Parts Authentication
\`\`\`clarity
;; Register a new part
(register-part (part-id (string-ascii 50)) (manufacturer (string-ascii 50))
(part-name (string-ascii 100)) (part-number (string-ascii 50))
(batch-number (string-ascii 30)) (manufacturing-date uint)
(expiry-date (optional uint)))

;; Record part usage in repair
(record-part-usage (part-id (string-ascii 50)) (job-id uint)
(quantity-used uint) (warranty-period uint))
\`\`\`

### Warranty Management
\`\`\`clarity
;; Create warranty for completed repair
(create-warranty (job-id uint) (customer principal) (warranty-type (string-ascii 50))
(duration-blocks uint) (coverage-details (string-ascii 200))
(terms (string-ascii 300)))

;; File warranty claim
(file-warranty-claim (warranty-id uint) (issue-description (string-ascii 200)))

;; Process warranty claim
(process-warranty-claim (claim-id uint) (approved bool) (resolution (string-ascii 200)))
\`\`\`

### Customer Satisfaction
\`\`\`clarity
;; Submit service rating
(submit-service-rating (job-id uint) (provider principal) (overall-rating uint)
(quality-rating uint) (timeliness-rating uint)
(communication-rating uint) (value-rating uint)
(review-text (string-ascii 500)))

;; Submit feedback
(submit-feedback (provider principal) (job-id uint) (feedback-type (string-ascii 20))
(feedback-text (string-ascii 300)))
\`\`\`

## Status Codes

### Repair Status
- \`1\` - Pending
- \`2\` - In Progress
- \`3\` - Completed
- \`4\` - Cancelled

### Warranty Status
- \`1\` - Active
- \`2\` - Expired
- \`3\` - Claimed
- \`4\` - Voided

### Claim Status
- \`1\` - Pending
- \`2\` - Approved
- \`3\` - Rejected
- \`4\` - Resolved

## Error Codes

### Service Provider Verification (100-199)
- \`100\` - Owner only operation
- \`101\` - Provider already registered
- \`102\` - Provider not registered
- \`103\` - Provider not verified

### Repair Tracking (200-299)
- \`200\` - Job not found
- \`201\` - Unauthorized operation
- \`202\` - Invalid status
- \`203\` - Job already exists

### Parts Authentication (300-399)
- \`300\` - Part not found
- \`301\` - Unauthorized operation
- \`302\` - Part already exists
- \`303\` - Invalid part

### Warranty Management (400-499)
- \`400\` - Warranty not found
- \`401\` - Unauthorized operation
- \`402\` - Warranty expired
- \`403\` - Already claimed
- \`404\` - Invalid warranty

### Customer Satisfaction (500-599)
- \`500\` - Rating not found
- \`501\` - Unauthorized operation
- \`502\` - Already rated
- \`503\` - Invalid rating

## Testing

The system includes comprehensive test suites using Vitest:

\`\`\`bash
# Run all tests
npm test

# Run specific contract tests
npm test service-provider-verification
npm test repair-tracking
npm test parts-authentication
npm test warranty-management
npm test customer-satisfaction
\`\`\`

## Deployment

1. Deploy contracts in the following order:
    - Service Provider Verification
    - Repair Tracking
    - Parts Authentication
    - Warranty Management
    - Customer Satisfaction

2. Initialize contract owner permissions
3. Register initial service providers
4. Set up parts suppliers

## Usage Examples

### Complete Repair Workflow

1. **Provider Registration**
   \`\`\`clarity
   (contract-call? .service-provider-verification register-provider
   "TechFix Pro" "Smartphone and tablet repairs")
   \`\`\`

2. **Create Repair Job**
   \`\`\`clarity
   (contract-call? .repair-tracking create-repair-job
   'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
   "iPhone 12" "Cracked screen" u1500 u150)
   \`\`\`

3. **Register and Use Parts**
   \`\`\`clarity
   (contract-call? .parts-authentication register-part
   "PART-001" "Apple Inc." "iPhone 12 Screen"
   "A2172-DISPLAY" "BATCH-2024-001" u1000 none)
   \`\`\`

4. **Complete Repair and Create Warranty**
   \`\`\`clarity
   (contract-call? .repair-tracking complete-repair u1 u175)
   (contract-call? .warranty-management create-warranty
   u1 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5
   "Standard Repair" u2160 "Covers repair defects"
   "Warranty void if tampered")
   \`\`\`

5. **Customer Rating**
   \`\`\`clarity
   (contract-call? .customer-satisfaction submit-service-rating
   u1 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
   u4 u5 u3 u4 u4 "Good service, quality repair")
   \`\`\`

## Security Considerations

- All contracts implement proper authorization checks
- Owner-only functions are protected
- Input validation prevents invalid data
- Status transitions are controlled
- Warranty expiration is enforced

## Future Enhancements

- Integration with payment systems
- Mobile app interface
- IoT device integration for automated status updates
- Machine learning for predictive maintenance
- Multi-signature warranty approvals
- Decentralized dispute resolution

## Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
