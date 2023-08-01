#https://docs.docker.com/language/nodejs/build-images/

FROM node:20-alpine3.17

WORKDIR /app

COPY ["package.json", "package-lock.json", "start.sh", "./"]

RUN npm install \
    && chmod 755 /app/start.sh 

COPY . .

ENV PORT=3000

EXPOSE 3000

CMD ["node", "index.js"]