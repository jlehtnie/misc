#!/bin/sh

perlcritic --verbose "%f\0%l\0%c\0%s\0%m\0%e\n" \
    ./jenkins/jenkins/translation-tool.pl ./checkout/gnome/cairomm-1.9.2/docs/doc-install.pl --nocolor
