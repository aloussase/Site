FROM node:23 as css

WORKDIR /app

COPY . .

RUN npm install
RUN npx @tailwindcss/cli -i ./css/default.css -o ./css/generated.css

FROM arm64v8/haskell:9.4.8

WORKDIR /app

# Update cabal index
RUN cabal update

# Cache dependencies
COPY alexandergoussas-com.cabal alexandergoussas-com.cabal
RUN cabal build --only-dependencies -j4

# Build the site helper
COPY . /app/
RUN cabal install -j4

# Copy the generated CSS
COPY --from=css /app/css/generated.css ./css/generated.css

# Build the actual site
RUN site rebuild

ENTRYPOINT ["site", "server", "--host=0.0.0.0", "--port=8080"]
