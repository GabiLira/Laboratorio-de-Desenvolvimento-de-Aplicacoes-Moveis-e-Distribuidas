FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install dotenv
RUN npm install swagger-ui-express yamljs

RUN npm install

COPY . .

# Garante que .env seja copiado
#COPY .env .env

CMD ["node", "server.js"]
