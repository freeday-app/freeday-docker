########################################### clone repositories + run builds

FROM node:16-alpine AS builder

# install git & openssh
RUN apk update && apk add git

# clone repositories
RUN git clone https://github.com/freeday-app/freeday-api.git api
RUN git clone https://github.com/freeday-app/freeday-web.git web

# install web client dependencies
WORKDIR /web
RUN npm install
# build web client
RUN npm run build

########################################### final image with api server + web client

FROM node:16-alpine

# work dir
WORKDIR /app

# copy api server files
COPY --from=builder /api .
# install prod dependencies
RUN npm install --only=prod

# create web client directory
RUN mkdir web

# copy web client build
COPY --from=builder /web/build ./web

# entry point
ENTRYPOINT ["npm", "run", "prod"]
