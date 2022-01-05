#!/bin/bash
_tmp="/tmp/zab_dock_stats_tmp"
_lock="/tmp/zab_dock_lock"



#docker service  ls |awk '{ print $2}' |cut -d_ -f1 |sort |uniq

if [[  ${1} == 'json-stacks' ]] ; then
  _x=$(mktemp)
  echo -n "{ \"STACKS\": [" > ${_x} 
  docker service  ls |awk '{ print $2}' |cut -d_ -f1 |grep -v NAME |sort|uniq |xargs -I@ echo  "{ \"NAME\":\"@_\" }," >> ${_x} 
  x=$(cat ${_x})
  y=${x::-1}
  echo -n $y"]}"
  rm ${_x} 
  exit
    
fi

if [[  ${1} == 'json-services' ]] ; then
  _x=$(mktemp)
  echo -n "{ \"SERVICES\": [" > ${_x} 
  docker ps --format "{{.Names}}" |cut -d. -f1 |grep -v NAME |sort|uniq |xargs -I@ echo  "{ \"NAME\":\"@.\" }," >> ${_x} 
  x=$(cat ${_x})
  y=${x::-1}
  echo -n $y"]}"
  rm ${_x} 
  exit
    
fi

while [ -f ${_lock} ] ; do
  sleep 1
  if [ `stat --format=%Y ${_lock}` -lt $(( `date +%s` - 180)) ]; then 
    rm ${_lock}
  fi
done


function pega () { 
        touch ${_lock}
        docker stats  --no-stream  --format "{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}" > ${_tmp} 
        rm ${_lock}
}

if [ ! -f ${_tmp} ]; then
  pega   
fi

if [ `stat --format=%Y ${_tmp}` -lt $(( `date +%s` - 60)) ]; then 
  pega
fi

####

if [[ ${2} == 'cpu' ]]; then
  x=$(grep "${1}" ${_tmp} | awk '{ print $2 }'|cut -d% -f1 | paste -sd+ | bc)
  if [ -z "$x" ] ; then
     echo 0
  else
     echo $x
  fi   
     
fi

if [[ ${2} == 'mem' ]]; then
  x=$(grep "${1}" ${_tmp} | awk '{ print $3 }' |  sed 's/B//g' | numfmt --from=auto | paste -sd+ | bc)
  if [ -z "$x" ] ; then
     echo 0
  else
     echo $x
  fi   
fi

if [[ ${2} == 'pids' ]]; then
  x=$(grep "${1}" ${_tmp} | awk '{ print $12 }' |paste -sd+ |bc) 
  if [ -z "$x" ] ; then
     echo 0
  else
     echo $x
  fi   
fi
