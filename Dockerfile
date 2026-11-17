FROM mirror.gcr.io/library/python:3.12-slim
WORKDIR /app
COPY app/ .
ENV PORT=8080
EXPOSE 8080
CMD ["python", "main.py"]
