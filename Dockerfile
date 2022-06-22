# Define the name of the image that we'll be using
# This is the BASE IMAGE that we'll pull from Dockerhub
# that we will build on top of, to add dependencies to our
# project.

FROM python:3.9-alpine3.13

# Define the maintainer (WHOEVER IS MAINTAINING THE DOCKER IMAGE)
LABEL maintainer = "o.cadman@live.co.uk"

# Environment
# PYTHONUNBUFFERED 1 is recommended when using Python in a container.
# It tells python that you don't want to buffer the output.
# The output from Python will be printed directly to the console,
# which prevents any delays of messqges getting from our python
# running application to the screen, so we can see logs immediately
# as they're running.
ENV PYTHONUNBUFFERED 1


# COPY tells docker to copy our requirements.txt file from our
# local machine to /tmp/requirements.txt
# This copies the requirements file into the docker image.
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy the app directory, which is the directory that will contain
# the django app
COPY ./app /app

# The WORKDIR is the working directory.
# This is the default directory where all commands will be run from
# when running commands on our docker image.
# We're setting it to the location of where are Django project
# is going to be synced to, so that when we run the commands,
# we don't have to specify the full path of the Django management commands.
# It will automatically run from /app directory.
WORKDIR /app

# EXPOSE exposes a specified port from our container to out
# machine when we run a container. It allows us to access that port
# on the container that's running on our image, and allows us 
# to connect to the Django development server,
EXPOSE 8000

# This runs a command on the alpine image we are using,
# when building our image.

# List of commands
# 1. python -m venv /py - Create a virtual environment
# 2. Specify the full path of the new virtual environment
#   1. Upgrade pip for the path
#   2. Install requirements from requirements.txt
# 3. Remove the temp directory because it's not needed anymore
#    and we don't need the dependencies once they're installed.
#    Keeps docker image as lightweight as possible.
# 4. Call adduser command which adds a new user within our image.
#   1. We do this because it's best practice NOT to use the root user.
#   2. If we didn't specify the user, then the only user that would be available
#      inside the alpine image would be the root user. 

ARG DEV=true
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true"]; \
        then /py/bin/pip install -r requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Updates the environment variable inside our image.
# We're updating the PATH environemtn variable.
# The $PATH is the environemtn variable that's automatically
# created on Linux operating systems.

# It defines all of the directories where executables can be
# run.
ENV PATH="/py/bin:$PATH"

# Switch to the newly created user. NO FULL ROOT PRIVILEGES.
USER django-user


