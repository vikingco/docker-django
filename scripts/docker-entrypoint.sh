#!/bin/bash
set -e

# Include configuration bootstrap scripts
source "${SCRIPTSDIR}/make_configurations.sh"

# Define help message
show_help() {
    echo """
Usage: docker run <imagename> COMMAND

Commands

dev     : Start a normal Django development server. Provide the 'APPDIR' env
          which specifies the name of the dir that contains the manage.py file.
          Provide 'MANAGEFILE' to be the name of the manage.py file.
          Optionally provide the 'PORT' env
          variable to determine the port on which it listens.
worker  : Start a celery worker. Requires the env variables 'CELERYAPP' and
          'CELERYWORKER_LOGLEVEL'
bash    : Start a bash shell
test    : Run the python tests. Requires 'APPDIR' and 'MANAGEFILE'
shell   : Start a Django Python shell. Requires 'APPDIR' and 'MANAGEFILE'
uwsgi   : Run uwsgi server. Requires the env variables 'APPDIR', 'WSGIFILE',
          'DJANGO_SETTINGS_MODULE'. Optional env variables are 'PORT',
          'UWSGIPORT' and 'STATUSPORT'.
python  : Run a Python shell
help    : Show this message
"""
}

# Define manage.py name
if [ -z $MANAGEFILE ]; then
    export MANAGEFILE=manage.py
fi

# Run
case "$@" in
    dev)
        echo "Running Development Server..."
        export DJDEBUG=1
        python ${APPDIR}/${MANAGEFILE} runserver 0.0.0.0:${PORT}
    ;;
    worker)
        echo "Running Worker (Celery)..."
        celery worker \
            --uid=www-data \
            --gid=www-data \
            --app=${CELERYAPP} \
            --loglevel=${CELERYWORKER_LOGLEVEL}
    ;;
    bash)
        /bin/bash
    ;;
    test)
        echo "Running Django Tests..."
        python ${APPDIR}/${MANAGEFILE} test
    ;;
    shell)
        python ${APPDIR}/${MANAGEFILE} shell
    ;;
    help)
        show_help
    ;;
    uwsgi)
        echo "Running App (uWSGI)..."
        make_uwsgi_config
        uwsgi \
            --ini ${RUNDIR}/uwsgi.ini
    ;;
    python)
        ptipython
    ;;
    *)
        show_help
    ;;
esac