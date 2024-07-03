FROM nginx:alpine

COPY Jenkinsfile /usr/share/nginx/Jenkinsfile

EXPOSE 80
