# PortfolioProject

## Table of contents

* [Problem Statement](#problem-statement)
* [Technologies](#technologies)
* [Project Data flow](#project-data-flow)
  - [(1) Ingest the Data via API](#1-ingest-the-data-via-api)
  - [(2) Load data via External table](#2-load-data-via-an-external-table)
  - [(3) Data tranformation](#3-data-tranformation)
  - [(4) Visualize data to find insight](#4-visualize-data-to-find-insight)
  - [(5)(6) Schedule daily data ingest and tranformation](#56-schedule-daily-data-ingest-and-transformation)
* [Reproducability](#reproducability)
  - [Step 1: Create infratructure](#step-1-create-infrastructure)
  - [Step 2: Connect to VM and install dependency](#step-2-connect-to-the-vm-and-install-the-dependency)
  - [Step 3: Deploy code to prefect](#step-3-deploy-code-to-prefect)
  - [Step 4: Run the script](#step-4-run-the-script)
  - [Step 5: Clean up](#step-5-clean-up)
* [Further Improvements](#further-improvements)

## Project Overview

This project use the [Movie dataset](https://www.kaggle.com/datasets/rounakbanik/the-movies-dataset) from Kaggle. And proceed the data using Python with [Pandas](https://pandas.pydata.org/) package.
And visualize the data for Exploratory Data Analysis (EDA) using [Matplotlib](https://matplotlib.org/) + [Seaborn](https://seaborn.pydata.org/) package

## Technologies

This project used the tool below.

- Perfect as data Orchestration
- DBT core as a data transformation tool for data warehouse
- Terraform as infrastructure setup and management
- Docker for hosting Prefect Agent
- Google Cloud Storage Bucket as a data lake.
- Google BigQuery as a Data warehouse
- Google Compute Engine as VM to host the pipeline
- Looker Studio for report and visualization
- Makefile for ease of reproducibility

## Project Data flow

![/other/image/dataflow.PNG](/other/image/dataflow.PNG)

The Data flow for this project

### (1) Ingest the Data via API

The data is called from [FRED API](https://fred.stlouisfed.org/docs/api/fred/#API).

We first need to get the category id from for all the topics. But FRED does not have an endpoint to get all the category id so to get this data we need to scape it from the [Category Page](https://fred.stlouisfed.org/categories) by ussing this [Python script](/flows/Fred_Category_Scape.py).

Checking the [Robots.txt](https://fred.stlouisfed.org/robots.txt) FRED does not disallow scraping of this data.

After we ran the script and get the category id we then can use the id to call [Cagetory Series](https://fred.stlouisfed.org/docs/api/fred/category_series.html) endpoint to get all the series associated with the category.

After we get the series id we can call [Maps API - Series Group Info](https://fred.stlouisfed.org/docs/api/geofred/series_group.html) to get the group id of the series not all series id have group id and there is no easy way to find out which series have seris group id and which one is not. So to reduce the complexity down. I have extract the series with the group id and saved them in this [CSV](/DBT/seeds/series_group.csv).

This file use a column Active to indicate which data should be call daily by the script. And have data for the frequency of the data collect along with the date data start collect and the current data date.

![active](/other/image/active.png)


then we use the series group id to call the [Maps API - Series Data](https://fred.stlouisfed.org/docs/api/geofred/series_data.html) endpoint which will return the data by country for the id we requested.

### (2) Load data via an External table

The data is stored in google cloud storage in stagging folder for the most recent data.

![/other/image/bucket1.png](/other/image/bucket1.png)

When the new data is call the previos data is move to the archive folder to keep at log and will be delete in 30 day

![/other/image/bucket2.png](/other/image/bucket2.png)

We use Google BigQuery to connect to the data using external table data sources this connection is defined in [Terraform](/infra/bq.tf) file.
The dataset is seperate into 2 datasets for development and production.

### (3) Data tranformation

This project uses [DBT](/DBT) for data transformation the model is separated into 2 stages core and stagging. In staging this is for casting the data type into the correct type and in core use this to join all the tables from stagging and from seed into one table

### (4) Visualize data to find insight

Use Looker Studio to connect to the BigQuery data warehouse and create reports to find trends and insight
![/other/image/bucket1.png](/other/image/Dashboard.png)

![/other/image/bucket1.png](/other/image/Dashboard2.png)

[Link to the Dashboard](https://lookerstudio.google.com/reporting/88eb65d7-c3ec-44b1-898a-55ded00812a0)

Due to the trail account the above link may no longer work.

If you can't access the link please use this [video](https://www.youtube.com/watch?v=zlVFyw2MGy0) to see the dashboard created instead.

### (5)(6) Schedule daily data ingest and transformation

Used prefect as an orchestrator tool to schedule the daily call of our script and data transformation using the deployment functionality.

## Reproducibility

`Prerequisite`:
To reproduce this project you would need the below account

1. [Google Cloud Account And Service Account](/other/gcpsetup)
2. [Prefect Cloud Account And API Key](/other/prefectsetup)
3. [Fred's Economic Account And API Key](/other/fredsetup)

You also need below package

1. [Makefile](https://pypi.org/project/make/) `pip install  make`
2. [Gcloud CLI](https://pypi.org/project/gcloud/) `pip install gcloud`
3. [Terraform](https://developer.hashicorp.com/terraform/downloads)
4. [DotEnv](https://pypi.org/project/python-dotenv/) `pip install python-dotenv`

### Step 1: Create infrastructure

Clone this project

```
git clone https://github.com/Chalermdej-l/Final_Project_FredETE
```

Access the clone directory

```
cd Final_Project_FredETE
```

Input the credential create in the `Prerequisite` step into the [.env](/.env) file

![env](/other/image/envcred.png)

Input the `credential.json` create in Google Cloud Account into the folder cred

![credential](/other/image/gcpsetup8.png)


Run the following command using Makefile depending on your system

```
make update-yml-window
```

```
make update-yml-linix
```

This code will populate the credential in the YAML file using the credential input in the [.env](/.env) file

`!!Please note if you ran this command before input the credential please re-clone the project again as the YAML file will be populate with incorrect data`


Next, let's setup the infrastructure

```
make infra-setup
```

This command will setup the terraform and run the plan to check for any error

![/other/image/repeoducesetup1.png](/other/image/repeoducesetup1.png)

To create the resource please run

```
make infra-create
```

This will create [BigQuery](https://console.cloud.google.com/bigquery), [Google Cloud Storage](https://console.cloud.google.com/storage/browser), [VM Instances](https://console.cloud.google.com/compute/instances)

Once the code is done please go to the [VM Instances](https://console.cloud.google.com/compute/instances) and copy the `external IP`

![/other/image/repeoducesetup3.png](/other/image/repeoducesetup3.png)

Please input the External IP into the [.env](/.env) file we will need this to connect to the VM

### Step 2: Connect to the VM and install the dependency

Open a `new terminal` and navigate to the clone directory we will use this terminal to connect to our created VM.
And run the below command

```
make vm-connect
```

This script will connect to the VM. There might be a question asking to save this host into the known host please select `yes`.

![connect](/other/image/vm-connnect.png)

After we are in the VM please clone the repository again

```
git clone https://github.com/Chalermdej-l/Final_Project_FredETE
```

Then navigate to the clone folder

```
cd Final_Project_FredETE
```

Run the below command to install Python Make and dotenv

```
sudo apt-get update -y
```

```
sudo apt install python3-pip -y
```

```
sudo pip install make python-dotenv
```


Then go back to the `local terminal` and run

```
make vm-copycred
```

This will copy the credential we input in .env and the credential.json we download to the VM

Go back to the `VM terminal` and run the below command to setup the credential

```
make update-yml-linix
```

`!!Please note if you ran this command before copy the credential over please re-clone the project again in the VM and start at previous step`


Then run the below command to install Docker and Docker-Compose

```
make vm-setup
```

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

```
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

If docker-compose installed correctly then there will print the current version. 

After finishing run the below command to create the docker image
```
make docker-build
```

Then run this command to spin up the docker image which will host our prefect agent in the background

```
make docker-up
```

### Step 3: Deploy code to prefect

After the docker is running please run this commnad will deploy our python script to prefect with the schedule to run monthly

```
make deployment-create
```

This command will deploy the sciprt to run DBT to tranform our database with a schedule to run monthly. As the data only updated by month.

```
make deployment-dbtprod
```


![/other/image/prefectschedule.png](/other/image/prefectschedule.png)

Then please run the below command to set up the data to call the script

```
make dbt-ingest
```

If you run this command and receive this eror `[Errno 2] No such file or directory: 'cred/credential.json'` then run the below command
```
nano profiles.yml
 ```
 
 And please change the keyfile to `../cred/credential.json` and re run the above command
 
 ![error](/other/image/profileerror.png)
 
 This will run the DBT seed and set up the data for the script to run

### Step 4: Run the script

Please go to [Prefect](https://app.prefect.cloud/auth/login) and run the job in below order to start ingesting the data

1. Fred-Category

2. Fred-Series

3. Fred-MapAPI

4. DBT-Daily-prod

After finish running all the jobs the data will be ingested into [BigQuery](https://console.cloud.google.com/bigquery)

### Step 5: Clean up

After finish with the project if you want to remove the project you can run the below command in `local terminal`

```
make infra-down
 ```

This command will run terraform destory to all resource we created in this project.

## Further Improvements

- Implement CI/CD
- Explore other Endpoint of the API
