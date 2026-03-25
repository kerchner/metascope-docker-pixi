# metascope-docker-pixi

I needed to use [MetaScope](https://github.com/wejlab/MetaScope), which is an R-based approach for preprocessing and aligning 16S, metagenomic, and metatranscriptomic data (and it's also
the successor to [PathoScope](https://github.com/PathoScope/PathoScope).

I also want to use [Pixi](https://pixi.prefix.dev/) for MUCH better package management and reproducibility (versus `conda`, versus `renv` and versus `install.packages`).
There is a [Bioconda package for MetaScope](https://anaconda.org/bioconda/bioconductor-metascope/) so Pixi can use it.

Another constraint: One of the dependencies for the `bioconductor-metascope` conda package is only available for `linux-64`, so I can't just use this on my Mac.

Enter `Docker`!  I can create a `linux-64` container so that I can install from conda (using Pixi, of course).   But then how will I work with the `MetaScope` package?
I'll need RStudio Server!  So my Docker container will need to run RStudio Server *AND* use the Pixi environment created from my `pixi.toml` (and `pixi.lock`).

## Instructions

You will need [Docker](https://docs.docker.com/engine/install/) installed on your computer.

```
docker compose up -d
```

Browse to [localhost:8787](http://localhost:8787) to access RStudio.  Log in as `rstudio/rstudio`.

## To add more packages:

Assuming that the package is available through `conda` or `bioconda` (you can also add other channels as needed):
```
pixi add <package-name>
```

Then, to update the lock file:
```
pixi lock
```

You will then need to rebuild the Docker image.
