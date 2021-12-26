import boto3
import logging
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)
glue = boto3.client('glue')

job_name = 'file-intake-job'


def lambda_handler(event, context):
    logger.info("File intake lambda triggered")

    s3_bucket_name = event['Records'][0]['s3']['bucket']['name'].replace(
        '+', ' ')
    s3_object_key = event['Records'][0]['s3']['object']['key'].replace(
        '+', ' ')

    logger.info(f'Bucket name {s3_bucket_name}')
    logger.info(f'Object key {s3_object_key}')

    glue.start_job_run(
        JobName=job_name,
        Arguments={
            '--s3-bucket': s3_bucket_name,
            '--s3-object': s3_object_key
        }
    )
    logger.info(f'{job_name} invoked Glue Job from Lambda')

    return {
        'statusCode': 200,
        'body': json.dumps(f'{job_name} Glue Job started')
    }


if __name__ == "__main__":
    print("Lambda triggered")
