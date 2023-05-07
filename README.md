# PortfolioProject

## Table of contents

* [Project Overview](#project-overview)
* [Prerequisite](#prerequisite)
* [Reproducibility](#reproducibility)

## Project Overview

This project use the [Movie dataset](https://www.kaggle.com/datasets/rounakbanik/the-movies-dataset) from Kaggle. And proceed the data using Python with [Pandas](https://pandas.pydata.org/) package.
And visualize the data for Exploratory Data Analysis (EDA) using [Matplotlib](https://matplotlib.org/) + [Seaborn](https://seaborn.pydata.org/) package


## Prerequisite

To reproduce this you will need [Kaggle account](https://www.kaggle.com/) and [API Key](https://www.kaggle.com/docs/api)

1.Go to [Kaggle](https://www.kaggle.com/) and create an account

2.Go to [Setting](https://www.kaggle.com/settings) and scoll down you will see a API section select `Create New Token`

3.Once the file is downloaded create a `.kaggle` folder in your profile folder and paste the file there `~/.kaggle/kaggle.json `

4.Install Kaggle CLI
```
pip install Kaggle
```

You will also need the below package.
1. [Pandas](https://pandas.pydata.org/)
2. [Matplotlib](https://matplotlib.org/)
3. [Seaborn](https://seaborn.pydata.org/)


## Reproducibility
Clone this project

```
git clone https://github.com/Chalermdej-l/PortfolioProject
```

Access the clone directory

```
cd PortfolioProject
```

Intall the require package by 

```
pip install -r requirements.txt
```

Download the data from keggle

```
kaggle datasets download -d rounakbanik/the-movies-dataset -p data --unzip –force
```

Once the package is install please access the [file](/Movie.ipynb) and run the code.
