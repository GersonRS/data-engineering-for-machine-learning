# import libraries
from os.path import abspath

from pyspark import SparkConf
from pyspark.sql import SparkSession
from pyspark.sql.functions import (
    col,
    concat_ws,
    current_timestamp,
    encode,
    from_json,
    lit,
    split,
)
from pyspark.sql.types import ArrayType, StringType, StructField, StructType

# set default location for warehouse
warehouse_location = abspath("spark-warehouse")

# main spark program
if __name__ == "__main__":
    # init session
    spark = (
        SparkSession.builder.appName("transform_and_enrichment_from_bronze_to_silver")
        .config("spark.sql.warehouse.dir", abspath("spark-warehouse"))
        .enableHiveSupport()
        .getOrCreate()
    )

    # show configured parameters
    print(SparkConf().getAll())

    # set log level
    spark.sparkContext.setLogLevel("INFO")

    # set dynamic input file [hard-coded]
    # can be changed for input parameters [spark-submit]
    get_users_file = "s3a://lakehouse/bronze/users/"
    get_subscription_file = "s3a://lakehouse/bronze/subscriptions/"
    get_credit_card_file = "s3a://lakehouse/bronze/credit_cards/"
    get_movies_file = "s3a://lakehouse/bronze/movies/"

    # read user data
    df_bronze_users = spark.read.format("delta").format("delta").load(get_users_file)
    enhance_column_selection_users = (
        df_bronze_users.withColumn(
            "complete_address",
            concat_ws(
                ", ",
                "address.street_address",
                "address.city",
                "address.state",
                "address.zip_code",
                "address.country",
            ),
        )
        .select(
            "user_id",
            concat_ws(" ", "first_name", "last_name").alias("user_complete_name"),
            col("complete_address").alias("user_complete_address"),
            col("employment.title").alias("user_job"),
            col("ingestion_time").alias("user_ingestion_time"),
            col("source_system").alias("user_source_system"),
            col("user_name").alias("user_user_name"),
            col("ingestion_type").alias("user_ingestion_type"),
            col("base_format").alias("user_base_format"),
            col("file_size").alias("user_file_size"),
            col("rows_written").alias("user_rows_written"),
            col("schema").alias("user_schema"),
        )
        .distinct()
    )
    # read subscription data
    df_bronze_subscriptions = spark.read.format("delta").load(get_subscription_file)
    enhance_column_selection_subscriptions = df_bronze_subscriptions.select(
        col("user_id").alias("subscription_user_id"),
        col("plan").alias("subscription_plan"),
        col("status").alias("subscription_status"),
        col("dt_current_timestamp").alias("subscription_event_time"),
        col("ingestion_time").alias("subscription_ingestion_time"),
        col("source_system").alias("subscription_source_system"),
        col("user_name").alias("subscription_user_name"),
        col("ingestion_type").alias("subscription_ingestion_type"),
        col("base_format").alias("subscription_base_format"),
        col("file_size").alias("subscription_file_size"),
        col("rows_written").alias("subscription_rows_written"),
        col("schema").alias("subscription_schema"),
    ).distinct()
    # read credit card data
    df_bronze_credit_cards = spark.read.format("delta").load(get_credit_card_file)
    enhance_column_selection_credit_cards = df_bronze_credit_cards.select(
        col("user_id").alias("credit_card_user_id"),
        col("credit_card_number").alias("credit_card_number"),
        col("credit_card_expiry_date").alias("credit_card_expiry_date"),
        col("credit_card_type").alias("credit_card_type"),
        col("dt_current_timestamp").alias("credit_card_event_time"),
        col("ingestion_time").alias("credit_card_ingestion_time"),
        col("source_system").alias("credit_card_source_system"),
        col("user_name").alias("credit_card_user_name"),
        col("ingestion_type").alias("credit_card_ingestion_type"),
        col("base_format").alias("credit_card_base_format"),
        col("file_size").alias("credit_card_file_size"),
        col("rows_written").alias("credit_card_rows_written"),
        col("schema").alias("credit_card_schema"),
    ).distinct()
    # read movies data
    df_bronze_movies = spark.read.format("delta").load(get_movies_file)
    enhance_column_selection_movies = df_bronze_movies.select(
        col("user_id").alias("movies_user_id"),
        col("adult").alias("movies_adult"),
        col("title").alias("movies_title"),
        col("popularity").cast("double").alias("movies_popularity"),
        col("vote_average").alias("movies_vote_average"),
        col("vote_count").alias("movies_vote_count"),
        split(col("release_date"), "-")[0].alias("movies_release_date"),
        from_json(
            col("genres"),
            ArrayType(
                StructType(
                    [
                        StructField("id", StringType(), True),
                        StructField("name", StringType(), False),
                    ]
                )
            ),
        )[0]["name"].alias("movies_genres_name"),
        col("dt_current_timestamp").alias("movies_event_time"),
        col("ingestion_time").alias("movies_ingestion_time"),
        col("source_system").alias("movies_source_system"),
        col("user_name").alias("movies_user_name"),
        col("ingestion_type").alias("movies_ingestion_type"),
        col("base_format").alias("movies_base_format"),
        col("file_size").alias("movies_file_size"),
        col("rows_written").alias("movies_rows_written"),
        col("schema").alias("movies_schema"),
    ).distinct()

    def subscription_importance(subscription_plan):
        if subscription_plan in ("Business", "Diamond", "Gold", "Platinum", "Premium"):
            return "High"
        elif subscription_plan in (
            "Bronze",
            "Essential",
            "Professianl",
            "Silver",
            "Standard",
        ):
            return "Normal"
        else:
            return "Low"

    spark.udf.register("fn_subscription_importance", subscription_importance)

    enhance_column_selection_subscriptions.createOrReplaceTempView("vw_subscription")

    enhance_column_selection_subscriptions = spark.sql(
        """
    SELECT subscription_user_id,
        subscription_plan,
        CASE WHEN subscription_plan = 'Basic' THEN 6.00
             WHEN subscription_plan = 'Bronze' THEN 8.00
             WHEN subscription_plan = 'Business' THEN 10.00
             WHEN subscription_plan = 'Diamond' THEN 14.00
             WHEN subscription_plan = 'Essential' THEN 9.00
             WHEN subscription_plan = 'Free Trial' THEN 0.00
             WHEN subscription_plan = 'Gold' THEN 25.00
             WHEN subscription_plan = 'Platinum' THEN 9.00
             WHEN subscription_plan = 'Premium' THEN 13.00
             WHEN subscription_plan = 'Professional' THEN 17.00
             WHEN subscription_plan = 'Silver' THEN 11.00
             WHEN subscription_plan = 'Standard' THEN 13.00
             WHEN subscription_plan = 'Starter' THEN 5.00
             WHEN subscription_plan = 'Student' THEN 2.00
        ELSE 0.00 END as subscription_price,
        subscription_status,
        fn_subscription_importance(subscription_plan) AS subscription_importance,
        subscription_event_time AS subscription_event_time
    FROM vw_subscription
    """
    )

    # sql join into a new [df]
    # enhance_column_selection_subscriptions.createOrReplaceTempView("subscriptions")
    # enhance_column_selection_users.createOrReplaceTempView("users")
    # enhance_column_selection_credit_cards.createOrReplaceTempView("credit_cards")
    # inner_join_user_subscribers_with_credit_card = spark.sql(
    #     """
    #     SELECT u.user_id,
    #         u.user_complete_name AS user_name,
    #         u.user_complete_address AS user_address,
    #         u.user_job,
    #         u.user_ingestion_time,
    #         u.user_source_system,
    #         u.user_user_name,
    #         u.user_ingestion_type,
    #         u.user_base_format,
    #         u.user_file_size,
    #         u.user_rows_written,
    #         u.user_schema,
    #         s.subscription_user_id,
    #         s.subscription_plan,
    #         s.subscription_price,
    #         s.subscription_importance,
    #         s.subscription_status,
    #         s.subscription_event_time,
    #         s.subscription_ingestion_time,
    #         s.subscription_source_system,
    #         s.subscription_user_name,
    #         s.subscription_ingestion_type,
    #         s.subscription_base_format,
    #         s.subscription_file_size,
    #         s.subscription_rows_written,
    #         s.subscription_schema,
    #         c.credit_card_user_id,
    #         c.credit_card_number,
    #         c.credit_card_expiry_date,
    #         c.credit_card_type,
    #         c.credit_card_event_time,
    #         c.credit_card_ingestion_time,
    #         c.credit_card_source_system,
    #         c.credit_card_user_name,
    #         c.credit_card_ingestion_type,
    #         c.credit_card_base_format,
    #         c.credit_card_file_size,
    #         c.credit_card_rows_written,
    #         c.credit_card_schema,
    #         current_timestamp() AS processing_time,
    #     FROM users AS u
    #     INNER JOIN subscriptions AS s
    #     ON u.user_id = s.subscription_user_id
    #     INNER JOIN credit_cards AS c
    #     ON u.user_id = c.credit_card_user_id
    # """
    # )

    inner_join_users_with_subscriptions = enhance_column_selection_users.join(
        enhance_column_selection_subscriptions,
        enhance_column_selection_users.user_id
        == enhance_column_selection_subscriptions.subscription_user_id,
        how="inner",
    )

    inner_join_user_subscribers_with_credit_card = (
        inner_join_users_with_subscriptions.join(
            enhance_column_selection_credit_cards,
            inner_join_users_with_subscriptions.user_id
            == enhance_column_selection_credit_cards.credit_card_user_id,
            how="inner",
        ).withColumn("processing_time", lit(current_timestamp()))
    )

    inner_join_user_subscribers_with_credit_card.write.format("delta").mode(
        "overwrite"
    ).save("s3a://lakehouse/silver/subscribers")

    inner_join_users_with_movies = enhance_column_selection_users.join(
        enhance_column_selection_movies,
        enhance_column_selection_users.user_id
        == enhance_column_selection_movies.movies_user_id,
        how="inner",
    ).withColumn("processing_time", lit(current_timestamp()))

    inner_join_users_with_movies.write.format("delta").mode("overwrite").save(
        "s3a://lakehouse/silver/voters"
    )

    inner_join_user_subscribers_with_credit_card.printSchema()
    inner_join_users_with_movies.printSchema()
    # stop session
    spark.stop()
