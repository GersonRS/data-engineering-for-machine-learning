"""Basic Airflow unit tests, by calling operator.execute()."""

from typing import List

import pandas as pd
from airflow.models import DagBag
from airflow.operators.python import PythonOperator
from dags.src.s3_etl_business import read_business_json_data
from dags.utils.constants import CURATED_ZONE
from minio import Minio


def test_dag_tags_and_import() -> None:
    dag_bag = DagBag(include_examples=False)

    assert not dag_bag.import_errors

    for dag_id, dag in dag_bag.dags.items():
        assert dag.tags, f"{dag_id} in {dag.full_filepath} has no tags"


def test_s3_etl_operator_with_docker(client: Minio, files: List[str]) -> None:

    for file in files:
        test = PythonOperator(
            task_id="test", python_callable=read_business_json_data, op_args=(file,)
        )
        name = test.execute({})

        obj_curated = client.get_object(CURATED_ZONE, name)

        assert obj_curated

        df_curated = pd.read_csv(obj_curated)

        assert "title" in list(df_curated.columns) and "body" in list(
            df_curated.columns
        )
