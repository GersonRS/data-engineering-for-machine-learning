import io
import os
import shutil
from typing import Any, Dict, Generator, List

import pandas as pd
import pytest
from minio import Minio
from pytest_docker_tools import container, fetch
from pytest_docker_tools.wrappers import Container

from dags.utils.constants import CURATED_ZONE, PROCESSING_ZONE

ACCESS_KEY = "minio"
SECRET_KEY = "minio123"

os.environ["AIRFLOW__CORE__LOAD_DEFAULT_CONNECTIONS"] = "False"
os.environ["AIRFLOW__CORE__LOAD_EXAMPLES"] = "False"
os.environ["AIRFLOW__CORE__UNIT_TEST_MODE"] = "True"
os.environ["AIRFLOW_HOME"] = os.path.dirname(os.path.dirname(__file__))


minio_image = fetch(repository="minio/minio:latest")

minio: Container = container(
    image="{minio_image.id}",
    command=["server", "/data"],
    environment={
        "MINIO_ACCESS_KEY": ACCESS_KEY,
        "MINIO_SECRET_KEY": SECRET_KEY,
    },
    ports={"9000/tcp": "9000"},
)


@pytest.fixture(autouse=True, scope="session")
def reset_db() -> Generator[Any, Any, Any]:
    """Reset the Airflow metastore for every test session."""
    from airflow.utils import db

    db.resetdb()
    yield

    # Cleanup temp files generated during tests
    os.remove(os.path.join(os.environ["AIRFLOW_HOME"], "unittests.cfg"))
    os.remove(os.path.join(os.environ["AIRFLOW_HOME"], "unittests.db"))
    os.remove(os.path.join(os.environ["AIRFLOW_HOME"], "webserver_config.py"))
    shutil.rmtree(os.path.join(os.environ["AIRFLOW_HOME"], "logs"))


@pytest.fixture()
def client(
    minio: Container, files: List[str], data_json: List[Dict[str, Any]]
) -> Minio:
    os.environ["S3_ENDPOINT_URL"] = f"{minio.ips.primary}:{minio.ports['9000/tcp'][0]}"
    os.environ["S3_ACCESS_KEY"] = ACCESS_KEY
    os.environ["S3_SECRET_KEY"] = SECRET_KEY
    # set up connectivity with minio storage
    client = Minio(
        f"{minio.ips.primary}:{minio.ports['9000/tcp'][0]}",
        ACCESS_KEY,
        SECRET_KEY,
        secure=False,
    )
    # create buckets
    client.make_bucket(PROCESSING_ZONE)
    client.make_bucket(CURATED_ZONE)

    # Upload data.
    df_business = pd.DataFrame.from_records(data_json)
    json_bytes = df_business.to_json(orient="records").encode("utf-8")
    json_buffer = io.BytesIO(json_bytes)

    for file in files:
        client.put_object(
            PROCESSING_ZONE,
            file,
            data=json_buffer,
            length=len(json_bytes),
            content_type="application/csv",
        )

    return client


@pytest.fixture()
def data_json() -> List[Dict[str, Any]]:
    return [
        {
            "id": 1534,
            "user_id": 3183,
            "title": "Audio curvo vulgaris ulterius suggero traho adiuvo.",
            "body": "Cubicularis capillus repellendus. Blandior ceno creo. Arto",
        },
        {
            "id": 1532,
            "user_id": 3178,
            "title": "Cervus auxilium vorax abscido cavus urbs arcesso nemo venio",
            "body": "Capitulus ab vel. Armo utor cetera. Solvo dicta sono. Vester",
        },
    ]


@pytest.fixture()
def files() -> List[str]:
    return ["exemple.json"]
