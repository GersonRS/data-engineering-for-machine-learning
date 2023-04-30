from datetime import timedelta

import airflow
from airflow import XComArg

# [START import_module]
from airflow.models import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.operators.s3 import (
    S3DeleteObjectsOperator,
    S3ListOperator,
)
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor

from src.s3_etl_business import read_business_json_data

# [START env_variables]
from utils.constants import PROCESSING_ZONE

# from airflow.decorators import task


# [END env_variables]

# [END import_module]

# [START default_args]
default_args = {
    "owner": "Gerson_S",
    "start_date": airflow.utils.dates.days_ago(1),
    "depends_on_past": False,
    "email": ["gerson.santos@dellteam.com"],
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 1,
    "retry_delay": timedelta(1),
}
# [END default_args]

# [START instantiate_dag]
with DAG(
    dag_id="s3-etl-business-part-2",
    default_args=default_args,
    catchup=False,
    schedule_interval="@once",
    tags=["development", "s3", "sensor", "minio", "python", "mongodb"],
) as dag:
    # [END instantiate_dag]
    # [START set_tasks]
    # verify if new file has landed into bucket
    verify_file_existence_processing = S3KeySensor(
        task_id="verify_file_existence_processing",
        bucket_name=PROCESSING_ZONE,
        bucket_key="business/" + "{{ ds_nodash }}" + "/*.json",
        wildcard_match=True,
        timeout=18 * 60 * 60,
        poke_interval=120,
        aws_conn_id="my_aws",
    )

    # list all files inside of a bucket processing
    # @task
    # def get_s3_files(current_prefix):

    #     s3_hook = S3Hook(aws_conn_id="my_aws")

    #     current_files = s3_hook.list_keys(
    #         bucket_name=PROCESSING_ZONE,
    #         prefix="business/" + current_prefix + "/",
    #         start_after_key="business/" + current_prefix + "/",
    #     )

    #     return [[file] for file in current_files]

    list_file_s3_processing_zone = S3ListOperator(
        task_id="list_file_s3_processing_zone",
        bucket=PROCESSING_ZONE,
        prefix="business/" + "{{ ds_nodash }}" + "/",
        delimiter="/",
        aws_conn_id="my_aws",
    )

    # apply transformation [python function]
    process_business_data = PythonOperator.partial(
        task_id="process_business_data", python_callable=read_business_json_data
    ).expand(op_args=XComArg(list_file_s3_processing_zone).zip())

    # delete files from processed zone
    delete_s3_file_processed_zone = S3DeleteObjectsOperator(
        task_id="delete_s3_file_processed_zone_1",
        aws_conn_id="my_aws",
        bucket=PROCESSING_ZONE,
        prefix="business/" + "{{ ds_nodash }}" + "/",
    )

    # [START task_sequence]

    (
        verify_file_existence_processing
        >> list_file_s3_processing_zone
        >> process_business_data
        >> delete_s3_file_processed_zone
    )
    # [END task_sequence]
