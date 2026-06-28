FROM node:24-slim

WORKDIR /app

COPY package.json ./

RUN npm install --omit=dev

COPY index.js ./

EXPOSE 5001

CMD ["npm", "start"]
