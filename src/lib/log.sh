#!/bin/bash

log() {
  local message="$*"
  local timestamp="\e[35m$(date '+%Y-%m-%d %H:%M:%S')\e[0m │ "

  printf "%b%s\n" "$timestamp" "$message"
}