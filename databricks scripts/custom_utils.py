class transformations:

    def dedup(self, df: DataFrame, dedup_cols: List[str], cdc: str) -> DataFrame:
        """
        Deduplicate a DataFrame by keeping the latest record per key.
        :param df: Input DataFrame
        :param dedup_cols: Columns to deduplicate on
        :param cdc: Column to use for ordering (e.g. last_updated_timestamp)
        :return: Deduplicated DataFrame
        """
        df = df.withColumn("dedupKey", concat(*[col(c) for c in dedup_cols]))
        df = df.withColumn(
            "dedupCounts",
            row_number().over(Window.partitionBy("dedupKey").orderBy(col(cdc).desc()))
        )
        df = df.filter(col("dedupCounts") == 1).drop("dedupKey", "dedupCounts")
        return df
    
    def process_timestamp(self,df):
        df = df.withColumn("process_timestamp",current_timestamp())
        return df
    
    def upsert(self,spark,df, key_cols,table,cdc):
        merge_condition = " AND ".join([f"src.{i} = trg.{i}" for i in key_cols])
        dlt_obj = DeltaTable.forName(spark,f"pysparkdbt.silver.{table}")
        dlt_obj.alias("trg").merge(df.alias("src"),merge_condition)\
                            .whenMatchedUpdateAll(condition = f"src.{cdc} >= trg.{cdc}")\
                            .whenNotMatchedInsertAll()\
                            .execute()

        return "done" 

                    