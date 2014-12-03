#!/bin/bash

find . -type f -not -name $(basename ${0}) -a -not -iwholename '*.git*'  -print0 | xargs -0 sed -i 's/com_irontec_zsugarH/com_btactic_bsugarH/g'

