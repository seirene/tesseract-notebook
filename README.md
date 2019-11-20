# tesseract-notebook

Jupyter notebook with Tesseract 3.05. Includes training data for english, finnish, swedish, estonian and german.

## Build

```
docker build -t cinia/tesseract-3.05 .
```

## Run

```
docker run -v "$PWD"/notebooks/:/home/jovyan/notebooks --user $(id -u) --group-add users -p 8888:8888 cinia/tesseract-3.05
```
