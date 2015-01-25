# misc
misc tools and scripts

## critic2xml.pl
wrapper to run perlcritic. it will output the normal perlcritic output
to stdout but also the violations in checkstyle compatible xml into 
the given output file.

this is useful e.g. when you run perlcritic as a jenkins job and want
to use checkstyle plugin to present the results.
