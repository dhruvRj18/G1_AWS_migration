import os

import yfinance as yf
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, GRU, Dense, Dropout, Bidirectional
from tensorflow.keras.optimizers import Nadam
from tensorflow.keras.callbacks import EarlyStopping
import matplotlib.pyplot as plt
from kerastuner.tuners import RandomSearch
import datetime
import pandas_datareader.data as web


# 1. Fetch historical stock data
def fetch_stock_data(ticker):
    stock_data = yf.download(ticker)
    stock_data['Date'] = stock_data.index
    return stock_data

# function to fetch market indicator data
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

def preprocess_data(stock_data, indicators_df):
    indicators_df = indicators_df.reset_index(drop=True)
    stock_data = stock_data.reset_index(drop=True)
    indicators_df['Date'] = pd.to_datetime(indicators_df['Date'])
    stock_data['Date'] = pd.to_datetime(stock_data['Date'])
    merged_df = pd.merge(stock_data, indicators_df, on='Date', how='left')
    merged_df.fillna(method='ffill', inplace=True)
    merged_df.fillna(method='bfill', inplace=True)
    merged_df['LogReturn'] = np.log(merged_df['Close'] / merged_df['Close'].shift(1))
    merged_df['RollingVolatility_30d'] = merged_df['LogReturn'].rolling(window=30).std()
    merged_df.dropna(inplace=True)
    return merged_df


# Build and compile the model
def build_model(hp):
    model = Sequential()
    model.add(Bidirectional(LSTM(hp.Int('lstm_units', 32, 128, step=32), return_sequences=True, activation='relu')))
    model.add(GRU(hp.Int('gru_units', 32, 128, step=32), activation='relu'))
    model.add(Dropout(hp.Float('dropout', 0.1, 0.5, step=0.1)))
    model.add(Dense(1))
    model.compile(optimizer=Nadam(hp.Float('learning_rate', 1e-4, 1e-2, sampling='LOG')), loss='mean_squared_error')
    return model


# Hyperparameter tuning using Keras Tuner
def tune_hyperparameters(X_train_reshaped, y_train):
    tuner = RandomSearch(build_model, objective='val_loss', max_trials=5, directory='tuning_dir', project_name='volatility')
    tuner.search(X_train_reshaped, y_train, epochs=50, validation_split=0.2)
    return tuner.get_best_hyperparameters(num_trials=1)[0]

# Train model with early stopping
def train_model(X_train_reshaped, y_train):
    best_hps = tune_hyperparameters(X_train_reshaped, y_train)
    model = build_model(best_hps)
    early_stopping = EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True)
    history = model.fit(X_train_reshaped, y_train, epochs=100, validation_split=0.2, batch_size=32)
    return model, history


# Plot predictions vs actual
def plot_predictions(y_test, y_pred):
    plt.figure(figsize=(10, 6))
    plt.plot(y_test, label='Actual Volatility')
    plt.plot(y_pred, label='Predicted Volatility')
    plt.title('Actual vs Predicted Volatility')
    plt.legend()
    plt.show()

# Plot training history
def plot_loss(history):
    plt.figure(figsize=(10, 6))
    plt.plot(history.history['loss'], label='Training Loss')
    plt.plot(history.history['val_loss'], label='Validation Loss')
    plt.title('Training and Validation Loss')
    plt.legend()
    plt.show()


def trasfer_model_to_backend(model_path):
    backend_vm_user = "flask"
    backend_vm_ip = "10.173.54.160"
    destination_path = f"{backend_vm_user}@{backend_vm_ip}:/home/{backend_vm_user}/Desktop/models/"

    # SCP command to transfer model
    scp_command = f"scp {model_path} {destination_path}"

    # Execute SCP command
    os.system(scp_command)
    print(f"Model transferred to {backend_vm_ip}")


if __name__ == '__main__':
    indicator_ids = ['GDP','FEDFUNDS','CPIAUCSL','UNRATE',
                     'GS10','INDPRO','PPIACO','RSXFS','HOUST','PSAVERT']

    indicators_df = fetch_multiple_indicators(indicator_ids)
    stock_ticker = "GOOG"
    stock_data = fetch_stock_data(stock_ticker)
    combined_data = preprocess_data(stock_data, indicators_df)


    # Define features and target
    features = combined_data.columns.difference(['Date', 'RollingVolatility_30d'])
    scaler = MinMaxScaler()
    combined_data[features] = scaler.fit_transform(combined_data[features])
    X = combined_data[features].values
    y = combined_data['RollingVolatility_30d'].values

    # Train-test split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, shuffle=False)

    # Reshape input for LSTM/GRU model
    X_train_reshaped = X_train.reshape((X_train.shape[0], 1, X_train.shape[1]))
    X_test_reshaped = X_test.reshape((X_test.shape[0], 1, X_test.shape[1]))

    # Train the model
    model, history = train_model(X_train_reshaped, y_train)

    # Predict on test data
    y_pred = model.predict(X_test_reshaped)

    # Plot predictions and training loss
    plot_predictions(y_test, y_pred)
    plot_loss(history)

    # Save model and combined data
    model.save(f'/home/model/Desktop/models/volatility_model_{datetime.datetime.now()}.h5')
    combined_data.to_csv('combined_data.csv')