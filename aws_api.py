# connection test to aws s3
import boto3

client = boto3.client("s3")
response = client.list_buckets()

print(response)
