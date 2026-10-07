import sqlite3
import pandas as pd

conn = sqlite3.connect('pizza_sales.db')
cursor = conn.cursor()

cursor.execute("PRAGMA foreign_keys =ON;")

cursor.executescript("""
DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS pizza_types;
DROP TABLE IF EXISTS pizzas;
""")

cursor.executescript("""
CREATE TABLE orders (
order_id INT PRIMARY KEY,
date TEXT NOT NULL,
time TEXT NOT NULL
);

CREATE TABLE pizza_types(
pizza_type_id TEXT PRIMARY KEY,
name TEXT NOT NULL,
category TEXT NOT NULL,
ingredients TEXT NOT NULL
);

CREATE TABLE pizzas(
pizza_id TEXT PRIMARY KEY,
pizza_type_id TEXT NOT NULL,
size TEXT NOT NULL,
price REAL NOT NULL,
FOREIGN KEY (pizza_type_id) REFERENCES pizza_types(pizza_type_id)
);

CREATE TABLE order_details(
order_details_id INT PRIMARY KEY,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
FOREIGN KEY (order_id) REFERENCES orders(order_id),
FOREIGN KEY (pizza_id ) REFERENCES pizzas(pizza_id )
);
""")

conn.commit()

pd.read_csv("orders.csv").to_sql("orders", conn, if_exists = 'append', index=False)
pd.read_csv("pizza_types.csv", encoding= 'latin1').to_sql("pizza_types", conn, if_exists = 'append', index=False)
pd.read_csv("pizzas.csv").to_sql("pizzas", conn, if_exists = 'append', index=False)
pd.read_csv("order_details.csv").to_sql("order_details", conn, if_exists = 'append', index=False)

conn.close()
print("Databse built and loaded successfully.")