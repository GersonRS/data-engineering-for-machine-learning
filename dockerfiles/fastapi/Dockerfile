# Base image
FROM python:3.10

# set envs
ENV MLFLOW_TRACKING_URI=http://10.96.4.1:5000
ENV MLFLOW_S3_ENDPOINT_URL=http://minio.deepstorage.svc.cluster.local:9000

# Set working directory
WORKDIR /app

# Copy files
COPY main.py /app
COPY requirements.txt /app

# Install dependencies
RUN pip install -r requirements.txt

# Run the application
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# kind load docker-image sleepy:latest
# kind load docker-image sleepy:0.1.0
