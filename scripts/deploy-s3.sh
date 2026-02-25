#!/bin/bash
# Deploy Semantic API frontpage to S3

BUCKET_NAME="semantic-api-frontend"
REGION="us-east-1"

echo "📦 Deploying Semantic API frontpage to S3..."

# Create bucket if it doesn't exist
if ! aws s3 ls "s3://${BUCKET_NAME}" 2>/dev/null; then
    echo "Creating S3 bucket: ${BUCKET_NAME}"
    aws s3 mb "s3://${BUCKET_NAME}" --region ${REGION}
    
    # Enable static website hosting
    aws s3 website "s3://${BUCKET_NAME}" \
        --index-document index.html \
        --error-document index.html
    
    # Make bucket public
    aws s3api put-bucket-policy --bucket ${BUCKET_NAME} --policy '{
        "Version": "2012-10-17",
        "Statement": [{
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::'${BUCKET_NAME}'/*"
        }]
    }'
fi

# Upload files
echo "Uploading files..."
aws s3 sync public/ "s3://${BUCKET_NAME}/" \
    --delete \
    --cache-control "max-age=300"

echo "✅ Deployed!"
echo "🌐 Website URL: http://${BUCKET_NAME}.s3-website-${REGION}.amazonaws.com"
