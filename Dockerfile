FROM node:24-alpine AS dev

WORKDIR /usr/src/app

COPY package.json ./
COPY tsconfig.json ./

RUN npm install -g typescript
RUN npm install

COPY src ./src

RUN npm run build

FROM node:24-alpine AS prod 

WORKDIR /usr/src/app

COPY package.json ./
RUN npm install --prod

COPY --from=dev /usr/src/app/dist ./dist

CMD ["node", "/usr/src/app/dist/main"]