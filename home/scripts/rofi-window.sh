#!/bin/bash

rofi -i \
         -modi windowcd -show windowcd \
         -width 50 \
         -display-windowcd window \
         -location 2 \
         -no-fixed-num-lines \
         -hide-scrollbar \
         -no-plugins \
         -me-select-entry '' \
         -me-accept-entry MousePrimary
