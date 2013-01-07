#!/usr/bin/env bash

# chg dir to the location of your Thunderbird msgFilterRules.dat.
cat msgFilterRules.dat | perl -ne 'chomp;if(/^condition=\"OR (.*)\"/){$g=$1;@f=split/ OR /,$g;my@h;for$f(@f){$f=~s/^\((.)(.+)\)/@{[uc($1)]}$2/;$f=~s/,contains,/:\.\*/;push@h,"^$f.*"}print":0:\n* ",join("|\\\n  ",@h),"\n$name\n\n"}elsif(/^name=\"(.+)\"/){$name=$1}'
