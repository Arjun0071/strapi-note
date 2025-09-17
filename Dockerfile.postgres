FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy dependency files first (enables Docker layer caching)
COPY package*.json ./
COPY yarn.lock ./

# Install dependencies
RUN yarn install

# Copy application source code
COPY . .

# Expose Strapi default port
EXPOSE 1337

# Start Strapi in development mode
CMD ["yarn", "develop"]

