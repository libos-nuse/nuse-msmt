#!/bin/bash

cd git

for repo in 0.git 1.git; do

	git -C $repo log \
		--date=iso \
		--author="David Miller" \
		--grep="^\[GIT\] Networking" \
		--pretty="%H %cd" \
	> commits-${repo}.txt

	git -C $repo log \
		--date=iso \
		--author="David Miller" \
		--grep="^\[GIT\]: Networking" \
		--pretty="%H %cd" \
	>> commits-${repo}.txt
done
