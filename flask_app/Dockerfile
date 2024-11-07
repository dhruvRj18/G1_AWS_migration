# Use an official Python runtime as a parent image
FROM python:3.12

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app
# Copy the models directory that contains the .h5 file
COPY models /app/models

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port the app runs on
EXPOSE 5000

# Define environment variable
ENV FLASK_APP=flask_app.py

# Run gunicorn to serve the Flask app
CMD ["gunicorn", "--workers", "3", "--bind", "0.0.0.0:5000", "flask_app:app"]
