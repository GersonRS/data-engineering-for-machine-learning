import os
from datetime import datetime
from io import BytesIO
from typing import Tuple

import pandas as pd
from dags.utils.constants import CURATED_ZONE, PROCESSING_ZONE
from minio import Minio


def read_business_json_data(*file: Tuple[str]) -> str:

    client: Minio = Minio(
        os.getenv("S3_ENDPOINT_URL"),
        os.getenv("S3_ACCESS_KEY"),
        os.getenv("S3_SECRET_KEY"),
        secure=False,
    )

    obj_business = client.get_object(
        PROCESSING_ZONE,
        file[0],
    )

    df_business = pd.read_json(obj_business, orient="records")
    selected_data = df_business[["title", "body"]].head(5)
    selected_data.to_dict("records")

    csv_bytes = selected_data.to_csv(header=True, index=False).encode("utf-8")
    csv_buffer = BytesIO(csv_bytes)
    name = (
        f"business/{datetime.now().strftime('%Y%m%d')}/"
        + f"business-{datetime.now().strftime('%Y-%m-%d_%Hh%Mm%Ss%f')}.csv"
    )
    client.put_object(
        CURATED_ZONE,
        name,
        data=csv_buffer,
        length=len(csv_bytes),
        content_type="application/csv",
    )
    return name
