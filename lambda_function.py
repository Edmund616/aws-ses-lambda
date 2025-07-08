import json
import boto3
import os

ses_client = boto3.client('ses')

def lambda_handler(event, context):
    # Get emails from environment variables
    source_email = os.environ.get('SOURCE_EMAIL')
    dest_email = os.environ.get('DEST_EMAIL')
    
    # Basic validation
    if not source_email or not dest_email:
        return {
            'statusCode': 500,
            'body': json.dumps('Source or Destination email not configured.')
        }
    
    # Compose email
    subject = "Test Email from AWS Lambda"
    body_text = "Hello,\nThis is a test email sent from AWS Lambda using SES."
    
    try:
        response = ses_client.send_email(
            Source=source_email,
            Destination={
                'ToAddresses': [dest_email]
            },
            Message={
                'Subject': {
                    'Data': subject
                },
                'Body': {
                    'Text': {
                        'Data': body_text
                    }
                }
            }
        )
        return {
            'statusCode': 200,
            'body': json.dumps(f"Email sent! Message ID: {response['MessageId']}")
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error sending email: {str(e)}")
        }
