FROM nginx:1.27-alpine

# Remove default nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy the Nexora recon site (public pages + the robots.txt-leaked internal doc)
COPY index.html about.html careers.html news.html directory.html technology.html documents.html /usr/share/nginx/html/
COPY robots.txt /usr/share/nginx/html/robots.txt
COPY style.css /usr/share/nginx/html/style.css
COPY documents/internal/security_bulletin.txt /usr/share/nginx/html/documents/internal/security_bulletin.txt
