import boto3
from pprint import pprint

def lambda_handler(event, context):

    logs = boto3.client('logs')
    logs.put_retention_policy(retentionInDays=7,logGroupName=context.log_group_name)

    s3 = boto3.client('s3')

    buckets = s3.list_buckets()
	
    for bucket in buckets['Buckets']:

        current_tagging = []
	
        try:
        	print('Getting current tags: ' + bucket['Name'])
       		current_tagging = s3.get_bucket_tagging(Bucket=bucket['Name'])['TagSet']

                if len(current_tagging) >= 50:
                    print('Tag limit met, not adding new tags: ' + bucket['Name'])
                    continue

    	        if not any(d['Key'] == 'bucket_name' for d in current_tagging):
                    current_tagging.append(
                        {
                            'Key': 'bucket_name',
                            'Value': bucket['Name']
                        }
                    )
                else:
                    print('Skipping to next, bucket_name tag already exists: ' + bucket['Name'])
                    continue
	
       		print('-- Deleting any current tags: ' + bucket['Name'])
       		s3.delete_bucket_tagging(Bucket=bucket['Name'])
    	except Exception:
       		pass
	
        print('** Adding bucket_name tag for: ' + bucket['Name'])	
   	tagging = s3.put_bucket_tagging(
            Bucket=bucket['Name'],
            Tagging={
                'TagSet': current_tagging
       	    }
	)
