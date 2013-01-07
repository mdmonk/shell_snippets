#!/usr/bin/csh
##------------- delete ---------------------
set Files=`echo $*`
set Date=`date +"%d%b%Y.%H%M%S."`
foreach i ($Files)
  set Src=$i;
  if ( ! (-d  $HOME/.trashcan) ) then
    \mkdir  $HOME/.trashcan
  endif
  if ( ! (-e $Src) ) then
    echo -n "$i"
    echo ": No such file or directory"
    continue
  endif
  set Dest=`echo $HOME/.trashcan/$Date$Src`
  echo -n "rm: remove $i (y/n)? "
  set Option = $<
  if ( $Option =~ [yY]* ) then
    mv  $Src  $Dest
  endif
end

##------------- undelete ---------------------
#!/usr/bin/csh
set Files=`\ls -1t ~/.trashcan`
foreach Undelete ($*)
  foreach i ($Files)
    set Src=~/.trashcan/$i;
    set Dest=`echo $i | nawk '{sub(substr($0,0,17), "", $0); print $0}'`
    if ( $Dest !~ $Undelete ) then
      continue
    endif
    if ( -e $Dest) then
      echo -n "unrm: Overwrite $Dest (y/n)? "
    else
      echo -n "unrm: unremove $Dest (y/n)? "
    endif
    set Option = $<
    if ( $Option =~ [yY]* ) then
      mv  -f $Src  $Dest
      break;
    endif
  end
end
