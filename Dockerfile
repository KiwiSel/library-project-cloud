# Specifies base image
FROM python:3.14 

# Sets the working directory inside the container
WORKDIR /app

# Copies files or directories from the host system into the container
COPY requirements.txt .

# Executes commands during the build process. Often used to install packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Specifies the default command to run when the container starts
CMD ["fastapi", "run", "app/main.py", "--host", "0.0.0.0", "--port", "8000"]