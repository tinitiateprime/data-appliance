FROM python:3.11-slim-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-17-jre-headless ca-certificates git && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/tutorial
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
ENV PYSPARK_PYTHON=python3
ENV SPARK_LOCAL_IP=127.0.0.1
WORKDIR /workspace/domains/banking/pipelines/s3_to_postgres
ENTRYPOINT ["python"]
