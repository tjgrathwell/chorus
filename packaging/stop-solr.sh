#!/usr/bin/env bash
bin=`readlink "$0"`
if [ "$bin" == "" ]; then
 bin=$0
fi
bin=`dirname "$bin"`
bin=`cd "$bin"; pwd`

. "$bin"/chorus-config.sh

if [ -f $SOLR_PID_FILE ]; then
  if kill -0 `cat $SOLR_PID_FILE` > /dev/null 2>&1; then
    log_inline "stopping solr "
    kill `cat $SOLR_PID_FILE` && rm $SOLR_PID_FILE
    wait_for_stop $SOLR_PID_FILE
    rm -f $SOLR_PID_FILE
  else
    log "Could not stop solr. Check that process `cat $SOLR_PID_FILE` exists"
    exit 0
  fi
else
  log "no solr to stop"
fi
