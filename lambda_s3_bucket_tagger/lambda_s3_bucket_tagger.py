import boto3
from pprint import pprint

def lambda_handler(event, context):

	s3 = boto3.client('s3')

	buckets = s3.list_buckets()
	
	for bucket in buckets['Buckets']:
	
    		print('Updating bucket: ' + bucket['Name'])
	
    		current_tagging = []
	
    		try:
        		print('Getting current tags')
        		current_tagging = s3.get_bucket_tagging(Bucket=bucket['Name'])['TagSet']
		
        		print('Deleting any current tags')
        		s3.delete_bucket_tagging(Bucket=bucket['Name'])
    		except Exception:
        		pass
		
    		if not any(d['Key'] == 'bucket_name' for d in current_tagging):
        		current_tagging.append({'Key': 'bucket_name', 'Value': bucket['Name']})
		
    		tagging = s3.put_bucket_tagging(
        		Bucket=bucket['Name'],
        		Tagging={
            		'TagSet': current_tagging
        		}
    		)
