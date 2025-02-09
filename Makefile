all: 
	@echo 'tailwind - Run tailwind'
	@echo 'tailwind-watch - Run tailwind in watch mode'
	@echo 'dev-install - Install the site executable'
	@echo 'build - Build the site and assets'

tailwind:
	npx @tailwindcss/cli -i ./css/default.css -o ./css/generated.css

tailwind-watch:
	npx @tailwindcss/cli -i ./css/default.css -o ./css/generated.css --watch

dev-install:
	cabal install --overwrite-policy=always

build: tailwind
	site clean && site build

.PHONY: tailwind tailwind-watch dev-install build
