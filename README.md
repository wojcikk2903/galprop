# Run GalProp in Docker

## Build Image

Make sure to have unarchived galprop_v57_release_r1 available in the same directory as your Dockerfile. Then Run the build with

	docker build -t galprop .


## Run Image

Run the image with your working directory available in the container as /galprop_data

	docker run --rm -ti -v $(pwd):/galprop_data galprop bash


Inside the image you can enter

	cd /galprop/GALPROP-57.0.3032

and run

	./bin/galprop -r example

## Run with non-embedded GalProp

Run the image with your working directory available in the container as /galprop_data

	docker run --rm -ti -v $(pwd):/galprop_data -v $(pwd)/galprop_v57_release_r1:/galprop galprop bash

Then you can compile GalProp

	cd /galprop
	bash ./install_galprop.sh

The compiled files and executable are located in your local ./galprop_v57_release_r1 directory. Inside the container you can run the simulations.
