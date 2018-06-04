#!/bin/bash

for sub in $(ls subjects);do
	mkdir -p subjects/$sub/workdir/WMH_extract/subjects
	cp -r WMH_extract/subjects/$sub subjects/$sub/workdir/WMH_extract/subjects/
done
