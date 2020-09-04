#!/bin/bash

cd utils
./get_font.sh
cd ..

cd data
./load-all.sh
cd ..

