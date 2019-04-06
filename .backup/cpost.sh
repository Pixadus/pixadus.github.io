#!/bin/bash
GREEN='\033[0;32m'
CYAN='\033[0;36m'
R='\033[0m'
YEAR="$(date +'%Y')"
MONTH="$(date +'%m')"
DAY="$(date +'%d')"
DATE="${YEAR}-${MONTH}-${DAY}"
TIME="$(date +'%H:%M:%S') MDT"
echo "Name of blogpost:"
read POSTNAME
printf "Creating post with name \"${GREEN}${POSTNAME}${R}\" on ${CYAN}${DATE}${R}\n"

# make postname lowercase & replace all spaces with dashes
POSTNAMEF="${POSTNAME,,}"
POSTNAMEF="${POSTNAMEF// /-}"
FILE="${YEAR}-${MONTH}-${DAY}-${POSTNAMEF}.markdown"
touch _posts/${FILE}
echo "---
layout: post
title:  \"${POSTNAME}\"
date:   ${DATE} ${TIME}
categories:
---" >> _posts/${FILE}
