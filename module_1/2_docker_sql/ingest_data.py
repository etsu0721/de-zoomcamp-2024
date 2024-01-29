#!/usr/bin/env python
# coding: utf-8

import pandas as pd
from sqlalchemy import create_engine
from time import time
import argparse
import os


def main(params):
    # Store parameter values
    user = params.user
    pswd = params.pswd
    host = params.host
    port = params.port
    db = params.db
    tbl_name = params.tbl_name
    url = params.url

    # Download CSV
    csv_name = '{}.csv.gz'.format(tbl_name)
    os.system('curl -L {} -o {}'.format(url, csv_name))

    # Connect to database
    conn_str = 'postgresql://{}:{}@{}:{}/{}'.format(user, pswd, host, port, db)
    engine = create_engine(conn_str)

    # Process data in chunks
    df_iter = pd.read_csv(csv_name, compression='gzip', iterator=True, 
                          chunksize=100000)
    
    df = next(df_iter)
    
    df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
    df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)

    # Load first chunk with column names as 'replace'
    df.to_sql(name=tbl_name, con=engine, if_exists='replace')
    
    while (df := next(df_iter, None)) is not None:
        t_start = time()

        df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
        df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)

        df.to_sql(name=tbl_name, con=engine, if_exists='append')

        print('inserted chunk in {s} seconds'.format(s=time()-t_start))


if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        prog='Ingest Data',
        description='Ingest CSV data to Postgres'
    )

    parser.add_argument('--user', help='username for postgres')
    parser.add_argument('--pswd', help='password for postgres')
    parser.add_argument('--host', help='host for postgres')
    parser.add_argument('--port', help='port for postgres')
    parser.add_argument('--db', help='database name for postgres')
    parser.add_argument('--tbl_name', help='table where we will write results')
    parser.add_argument('--url', help='url of csv file')

    args = parser.parse_args()
    main(args)
