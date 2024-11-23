# Use the official Nginx base image
FROM nginx:latest

# Set the working directory (optional, not used in this case)
WORKDIR /app

# Copy the build output to Nginx's default HTML directory
COPY build/ /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
