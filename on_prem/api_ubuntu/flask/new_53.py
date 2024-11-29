ubuntu@cc-ubt-122:~/flask_app$ cat flask_app_new_53.py
import datetime
from flask import Flask, request, jsonify
from tensorflow.keras.models import load_model
import yfinance as yf
import numpy as np
import pandas_datareader.data as web
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
import logging
from flask_cors import CORS
import psycopg2
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
import os
from flask import make_response
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*", "supports_credentials": True}})


# Configure JWT
app.config['JWT_SECRET_KEY'] = 'super-secret-key'
jwt = JWTManager(app)


@app.route('/<path:path>', methods=['OPTIONS'])
def options_handler(path):
    response = make_response()
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS, PUT, DELETE"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type"
    return response


@app.after_request
def add_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS, PUT, DELETE"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type"
    return response

def get_db_connection():
    conn = psycopg2.connect(
        host="10.173.65.53",
        database="user_management_db",
        user="flask_user",
        password="Secret55"
    )
    return conn



# User Registration Endpoint
@app.route('/register', methods=['POST'])
def register_user():
    data = request.get_json()
    username = data['username']
    email = data['email']
    password = data['password']

    # Hash the password
    password_hash = generate_password_hash(password)

    conn = get_db_connection()
    cur = conn.cursor()

    # Insert the user into the database
    try:
        cur.execute(
            "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s)",
            (username, email, password_hash)
        )
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({"message": "User registered successfully"}), 201
    except psycopg2.IntegrityError:
        conn.rollback()
        return jsonify({"error": "Username or email already exists"}), 400





# User Login Endpoint with JWT Token issuance
@app.route('/login', methods=['POST'])
def login_user():
    data = request.get_json()
    username = data['username']
    password = data['password']

    conn = get_db_connection()
    cur = conn.cursor()

    # Fetch user details from the database
    cur.execute("SELECT password_hash FROM users WHERE username = %s", (username,))
    user = cur.fetchone()

    cur.close()
    conn.close()

    if user and check_password_hash(user[0], password):
        # Generate a JWT token
        access_token = create_access_token(identity=username)
        return jsonify({"message": "Login successful", "token": access_token}), 200
    else:
        return jsonify({"error": "Invalid credentials"}), 401



# Function to fetch stock data for prediction
def fetch_stock_data(ticker):
    stock_data = yf.download(ticker)
    stock_data['Date'] = stock_data.index
    stock_data.reset_index(drop=True,inplace=True)
    return stock_data


def get_economic_indicators(indicator_id):
    start = datetime.datetime(1992, 1, 1)
    end = datetime.datetime.now()
    data = web.DataReader(indicator_id, 'fred', start, end)
    data['Date'] = data.index
    return data


# 2. Fetch multiple market indicators and merge them
def fetch_multiple_indicators(indicator_ids):
    merged_df = get_economic_indicators(indicator_ids[0])
    # Loop through the remaining indicators and merge them on the 'Date' column
    for indicator in indicator_ids[1:]:
        indicator_df = get_economic_indicators(indicator)
        merged_df = pd.merge(merged_df, indicator_df, on='Date', how='outer')
    return merged_df


def preprocess_data(stock_data, indicators_df, ticker):
    logging.info("processing both the dfs")


    indicators_df['Date'] = pd.to_datetime(indicators_df['Date'])
    stock_data['Date'] = pd.to_datetime(stock_data['Date']).dt.tz_localize(None)

    stock_data.columns = ['_'.join(col).strip() if isinstance(col,tuple)else col for col in stock_data.columns]

    print(f'after processing stock data: {stock_data.info()}')
    stock_data.rename(columns={'Date_':'Date'},inplace=True)
    stock_data.columns = stock_data.columns.str.replace(f'_{ticker}','',regex=False)

    merged_df = pd.merge(stock_data, indicators_df, on='Date', how='left')
    merged_df.fillna(method='ffill', inplace=True)
    merged_df.fillna(method='bfill', inplace=True)

    merged_df['LogReturn'] = np.log(merged_df['Close'] / merged_df['Close'].shift(1))
    merged_df['RollingVolatility_30d'] = merged_df['LogReturn'].rolling(window=30).std()
    merged_df.dropna(inplace=True)
    return merged_df


def calculate_var(returns, confidence_level=0.95):
    """
    Calculate Value at Risk (VaR) using historical simulation method.
    """
    sorted_returns = np.sort(returns)
    var_index = int((1 - confidence_level) * len(sorted_returns))
    var_value = sorted_returns[var_index]
    return var_value


def get_latest_model(directory):
    """
    Returns the latest model file in the directory based on the timestamp in the filename.
    Assumes the format is: volatility_model_<timestamp>.h5
    """
    model_files = [f for f in os.listdir(directory) if f.startswith('volatility_model_') and f.endswith('.h5')]

    # Sort the files based on the timestamp in the filename
    if model_files:
        model_files.sort(key=lambda x: os.path.getmtime(os.path.join(directory, x)), reverse=True)
        return os.path.join(directory, model_files[0])
    else:
        raise FileNotFoundError("No model files found in the specified directory")

@app.route('/get_var', methods=['POST'])
@jwt_required()
def get_var():
    try:
        data = request.json
        ticker = data['ticker']

        model_directory = '/home/flask/Desktop/models/'
        latest_model_path = get_latest_model(model_directory)
        print(f"Loading model from {latest_model_path}")
        model = load_model(latest_model_path)

        indicator_ids = ['GDP', 'FEDFUNDS', 'CPIAUCSL', 'UNRATE', 'GS10', 'INDPRO', 'PPIACO', 'RSXFS', 'HOUST',
                         'PSAVERT']
        indicators_df = fetch_multiple_indicators(indicator_ids)
        print(f"got indicator df : {indicators_df.info()}")
        stock_data = fetch_stock_data(ticker)
        print(f"got stock  df : {stock_data.info()}")

        combined_data = preprocess_data(stock_data, indicators_df, ticker)
        features = combined_data.columns.difference(['Date', 'RollingVolatility_30d'])

        scaler = MinMaxScaler()
        combined_data[features] = scaler.fit_transform(combined_data[features])
        X = combined_data[features].values
        X = X.reshape((X.shape[0], 1, X.shape[1]))

        pred = model.predict(X)

        var_value = calculate_var(pred)

        return jsonify({'ticker': ticker, 'VaR': float(var_value)}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
