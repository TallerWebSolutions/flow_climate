# Frontend build stage
FROM node:20.12.2 AS frontend-builder

WORKDIR /app

COPY app/spa/package*.json ./

RUN npm install -g npm@10.5.0

RUN npm install --legacy-peer-deps
COPY app/spa/ .
RUN npm run build

# Main application stage
FROM ruby:3.3.6

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    postgresql-client

WORKDIR /flowclimate

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# Copy the built frontend from the frontend-builder stage
COPY --from=frontend-builder /app/build /flowclimate/app/spa/build

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"] 
