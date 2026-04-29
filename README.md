# Walmart-Sales-Data-Analysis
This is an end-to-end data analysis project designed to extract critical business insights from Walmart sales data. I utilized Python for data processing and analysis, and SQL for advanced querying,

## Project Steps

### 1. Set Up the Environment
   - **Tools Used**: VS Code, Python, PostgreSQL
   - **Goal**: Create an isolated virtual workspace where you will run your project.

### 2. Set Up Kaggle API
   - **API Setup**: Obtain your Kaggle Legacy API credentials from [Kaggle](https://www.kaggle.com/) by navigating to your profile settings and downloading the JSON file.
   - **Configure Kaggle**: 
      - Place the downloaded `kaggle.json` file in your local `.kaggle` folder.
      - Use the command `kaggle datasets download -d <najir0123/walmart-10k-sales-datasets>` to pull datasets directly into your project.

### 3. Download Walmart Sales Data
   - **Data Source**: Use the Kaggle API to download the Walmart sales datasets from Kaggle.
   - **Dataset Link**: [Walmart Sales Dataset](https://www.kaggle.com/najir0123/walmart-10k-sales-datasets)

### 4. Install Required Libraries and Load Data
- **Libraries**: Install necessary Python libraries using:
```bash
pip install pandas numpy sqlalchemy mysql-connector-python psycopg2
```
- **Loading Data**: Read the data into a Pandas DataFrame.
```python
#Importing the dataset

df = pd.read_csv('Walmart.csv', encoding_errors='ignore')
```
	
### 5. Explore the Data
- **Exploration**: Use functions like `.info()`, `.describe()`, and `.head()` to get a quick overview of the data structure and statistics.

### 6. Data Cleaning
- **Remove Duplicates**: Identify and remove duplicate entries.
```Python
#Checking for duplicates

df.duplicated().sum() 
```
	
```Python
#Removing duplicates from the dataset
	
df.drop_duplicates(inplace=True) 

#Checking for duplicates
	
df.duplicated().sum() 
```
- **Handle Missing Values**: Drop rows or columns with missing values if they are insignificant; fill values where essential.
```Python
#Dropping rows with null values
	
df.dropna(inplace=True) 

#Checking for null values after dropping rows with null values
	
df.isnull().sum()
```
- **Fix Data Types**: Ensure all columns have consistent data types (e.g., dates as `datetime`, prices as `float`).
```Python
#Removing the dollar sign from the unit_price column and converting it to float
	
df['unit_price'].str.replace('$', '').astype(float)
```
- **Currency Formatting**: Use `.replace()` to handle ($) for analysis.
```Python
df['unit_price'] = df['unit_price'].str.replace('$', '').astype(float)
```
- **Validation**: Check for any remaining inconsistencies and verify the cleaned data.

### 7. Feature Engineering
- **Create New Columns**: Calculate the `Total Amount` for each transaction by multiplying `unit_price` by `quantity` and adding this as a new column.
```Python
#Adding a new column 'Total' which is the product of quantity and unit_price
		
df['Total'] = df['quantity'] * df['unit_price']

df.head()
```
   - **Enhance Dataset**: Adding this calculated field will streamline further SQL analysis.

### 8. Load Data into MySQL and PostgreSQL
- **Set Up Connections**: Connect to PostgreSQL using `sqlalchemy` and load the cleaned data into the database.
```Python
# psql connection

engine_psql = create_engine('postgresql+psycopg2://postgres:****@localhost:5432/walmart_db')

try:
	engine_psql
	print("Connection to PostgreSQL database successful!")
except:
	print("Connection to PostgreSQL database failed.")
```
- **Table Creation**: Set up tables in PostgreSQL using Python SQLAlchemy to automate table creation and data insertion.
```Python
# Exporting the cleaned dataset to PostgreSQL database
df.to_sql(name='walmart_sales', con=engine_psql, if_exists='replace', index=False)

if engine_psql:
	print("Data exported to PostgreSQL database successfully!")
else:
	print("Failed to export data to PostgreSQL database.")
```
   - **Verification**: Run initial SQL queries to confirm that the data has been loaded accurately.
```SQL
SELECT * from walmart_sales
```

### 9. SQL Analysis: Complex Queries and Business Problem Solving
- **Business Problem-Solving**:
- Identify the highest-rated category in each branch, displaying the branch, category, AVG RATING.
```SQL
WITH ranked_data AS (
	SELECT 
	ws."Branch", 
	ws.category, 
	ROUND(AVG(rating)::numeric, 2) AS average_rating,
	RANK() OVER (
		PARTITION BY ws."Branch" 
		ORDER BY AVG(rating) DESC
	) AS rank
	FROM walmart_sales ws 
	GROUP BY ws."Branch", ws.category
	)
SELECT *
FROM ranked_data
WHERE rank = 1
```
- Identify the busiest day for each branch based on the number of transactions.
```SQL
SELECT * 
	FROM
		(SELECT 
		"Branch",
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY "Branch" ORDER BY COUNT(*) DESC) as rank
	from walmart_sales ws
	GROUP BY 1, 2
	)
WHERE rank = 1
```	
	
- Determine the most common payment method for each Branch. Display Branch and the preferred_payment_method..
```SQL
WITH most_common_payment_method 
	AS
	(SELECT 
		"Branch",
		payment_method,
		COUNT(*) as total_trans,
		RANK() OVER(PARTITION BY "Branch" ORDER BY COUNT(*) DESC) as rank
	FROM walmart_sales ws
	GROUP BY 1, 2 ---cardinal referencing
	)
SELECT *
FROM most_common_payment_method 
WHERE rank = 1
```   
## Requirements

- **Python 3.8+**
- **SQL Databases**: MySQL, PostgreSQL
- **Python Libraries**:
  - `pandas`, `numpy`, `sqlalchemy`, `mysql-connector-python`, `psycopg2`
- **Kaggle API Legacy Key** (for data downloading)

## Getting Started

1. Clone the repository:
```bash
git clone https://github.com/Peterkinywa/Walmart-Sales-Data-Analysis.git
```
2. Install Python libraries:
```bash
pip install -r requirements.txt
```
3. Set up your Kaggle API, download the data, load and analyze.

---	 
## Author
Peter Kinywa Mutua, Data Analyst

## License

This repository and its contents are intended for **SQL practice only**, unless otherwise explicitly stated.

![License](https://img.shields.io/badge/License-Internal-orange)