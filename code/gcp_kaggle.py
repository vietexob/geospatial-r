# import all the libraries we'll need
import os
from kaggle.api.kaggle_api_extended import KaggleApi
from google.cloud import storage

# you need to create a client to interact with cloud storage 
# (i.e. your bucket). You can delete this if you're not using one.
storage = storage.Client()

# temporary file directory we'll pull our notebook & metadata to
PATH = "/tmp/kaggle"

# The UPPER_CASE variables are the only things you need to edit. Replace the 
# text strings in quotes with the appropriate information for the notebook
# you're scheduling

# the username of author of the kernel you're updating (probably yours)
USERNAME = "vietexob"
# the slug of the kernel you're updating
KERNEL_SLUG = "speed_viz_markdown"
# The file extension for the kernel you're updating. E.g. ipynb, py, r
# Don't include a period in the file extension. 
KERNEL_EXTENSION = "Rmd"
# the name of the bucket you created earlier
BUCKET = "pgh-traffic-dashboard"

# this function pulls down the most recent version of the notebook you 
# specified and them pushes back to Kaggle. It then saves a copy to your
# bucket so you can refer to it or use it in other projects. If you were prefer
# not to save a copy, remove the code where indicated. 
def kernel_update(request):
    # pull the most recent version of the kernel
    api = KaggleApi()
    api.authenticate()
    api.kernels_pull_cli("{}/{}".format(USERNAME, KERNEL_SLUG), path="{}".format(PATH), metadata=True)

    # push our notebook
    api.kernels_push_cli("{}".format(PATH))

    # save a copy of our notebook in our bucket (if you would prefer
    # not to save a copy, delete all lines from here to the end of the file).
    bucket = storage.bucket(BUCKET)
    metadata_blob = bucket.blob("kernel-metadata.json")
    notebook_blob = bucket.blob("{}.{}".format(KERNEL_SLUG, KERNEL_EXTENSION ))

    metadata_blob.upload_from_filename("{}/kernel-metadata.json".format(PATH))
    notebook_blob.upload_from_filename("{}/{}.{}".format(PATH, KERNEL_SLUG, KERNEL_EXTENSION))
