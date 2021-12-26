import boto3
import logging
import sys


def setup_logger():
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger


def put_item(item, table_name='TerraformPOC', dynamodb=None):
    if dynamodb is None:
        dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    return table.put_item(
        Item=item
    )


if __name__ == '__main__':
    logger = setup_logger()
    logger.info('File intake job triggered')

    item = {
        'EmployeeId': '12345',
        'DepartmentId': '1',
        'EmployeeName': 'Johnny Appleseed',
        'DaysEmployeed': 0
    }
    response = put_item(item, 'TerraformPOC')

    logger.info('Added employee to dynamodb table with the following response')
    logger.info(f'{response}')
