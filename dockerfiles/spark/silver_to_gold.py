# import libraries
from os.path import abspath

from delta import DeltaTable
from pyspark import SparkConf
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_timestamp

# set default location for warehouse
warehouse_location = abspath("spark-warehouse")

# main spark program
if __name__ == "__main__":
    # init session
    spark = (
        SparkSession.builder.appName("delivery-data-from-silver-to-gold")
        .config("spark.sql.warehouse.dir", abspath("spark-warehouse"))
        .enableHiveSupport()
        .getOrCreate()
    )

    # show configured parameters
    print(SparkConf().getAll())

    # set log level
    spark.sparkContext.setLogLevel("INFO")

    # read subscribers data
    get_subscribers = "s3a://lakehouse/silver/subscribers"
    df_silver_subscribers = DeltaTable.forPath(spark, get_subscribers)

    select_column_subscribers = (
        df_silver_subscribers.toDF()
        .withColumn("delivery_time", current_timestamp())
        .withColumn(
            "time_to_process",
            col("delivery_time").cast("long") - col("user_ingestion_time").cast("long"),
        )
    )

    get_gold_subscribers = select_column_subscribers.select(
        col("user_id").alias("id"),
        col("user_complete_name").alias("name"),
        col("user_complete_address").alias("address"),
        col("subscription_plan").alias("plan"),
        col("subscription_importance").alias("importance"),
        col("subscription_status").alias("status"),
        col("credit_card_type").alias("card"),
        col("time_to_process"),
        col("delivery_time").alias("event_time"),
    )

    delta_gold_tb_subers_location = "s3a://lakehouse/gold/subers"
    (
        DeltaTable.createIfNotExists(spark)
        .tableName("subers")
        .addColumn("id", "BIGINT")
        .addColumn("name", "STRING")
        .addColumn("address", "STRING")
        .addColumn("plan", "STRING")
        .addColumn("importance", "STRING")
        .addColumn("status", "STRING")
        .addColumn("card", "STRING")
        .addColumn("time_to_process", "BIGINT")
        .addColumn("event_time", "TIMESTAMP")
        .addColumn("date", "DATE", generatedAlwaysAs="CAST(event_time as DATE)")
        .partitionedBy("date")
        .location(delta_gold_tb_subers_location)
        .execute()
    )

    get_gold_subscribers.write.format("delta").mode("overwrite").save(
        delta_gold_tb_subers_location
    )

    get_voters = "s3a://lakehouse/silver/voters"
    df_silver_voters = DeltaTable.forPath(spark, get_voters)

    select_column_voters = (
        df_silver_voters.toDF()
        .withColumn("delivery_time", current_timestamp())
        .withColumn(
            "time_to_process",
            col("delivery_time").cast("long") - col("user_ingestion_time").cast("long"),
        )
    )

    get_gold_voters = select_column_voters.select(
        col("user_id").alias("id"),
        col("user_complete_name").alias("name"),
        col("movies_title").alias("title"),
        col("movies_popularity").alias("popularity"),
        col("movies_vote_average").alias("average"),
        col("movies_vote_count").alias("count"),
        col("movies_release_date").alias("release"),
        col("movies_genres_name").alias("genre"),
        col("time_to_process"),
        col("delivery_time").alias("event_time"),
    )

    delta_gold_tb_voters_location = "s3a://lakehouse/gold/voters"
    (
        DeltaTable.createIfNotExists(spark)
        .tableName("voters")
        .addColumn("id", "BIGINT")
        .addColumn("name", "STRING")
        .addColumn("title", "STRING")
        .addColumn("popularity", "DOUBLE")
        .addColumn("average", "DOUBLE")
        .addColumn("count", "DOUBLE")
        .addColumn("release", "STRING")
        .addColumn("genre", "STRING")
        .addColumn("time_to_process", "BIGINT")
        .addColumn("event_time", "TIMESTAMP")
        .addColumn("date", "DATE", generatedAlwaysAs="CAST(event_time as DATE)")
        .partitionedBy("date")
        .location(delta_gold_tb_voters_location)
        .execute()
    )

    get_gold_voters.write.format("delta").mode("overwrite").save(
        delta_gold_tb_voters_location
    )

    get_gold_subscribers.printSchema()
    get_gold_voters.printSchema()
    # test save dataframe into postgres
    # yugabytedb database [ysql]
    # k8s cluster ip for yugabytedb [intra-communication]
    """
    get_gold_subscribers \
        .write \
        .format("jdbc") \
        .mode("overwrite") \
        .option("url", "jdbc:postgresql://10.0.206.213:5433/yugabyte") \
        .option("dbtable", "public.subers") \
        .option("user", "yugabyte") \
        .option("password", "yugabyte") \
        .save()
    """

    # stop session
    spark.stop()
