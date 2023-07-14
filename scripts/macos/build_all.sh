#!/bin/bash

(cd ../../crypto_plugins/flutter_libmonero/scripts/macos/ && ./build_all.sh  ) &

wait
echo "Done building"