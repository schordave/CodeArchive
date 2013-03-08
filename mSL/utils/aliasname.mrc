; ###########################################################################
; #  (c) 2009-2013, David Schor            [Licensed under the MIT license] #
; #                                        [See LICENSE.mrc for details.  ] #
; # NAME:                                                                   #
; #                Alias Name                                               #
; # SYNOPSIS:                                                               #
; #               $($aName,2)                                               #
; # DESCRIPTION:                                                            #
; #               This alias returns the name of the current alias. This is #
; #               a very simple alias  that can be used to return  the name #
; #               of the currently executing alias.                         #
; #                                                                         #
; # Example:                                                                #
; #                alias example_test {                                     #
; #                   echo -a $($aname,2)                                   #
; #                }                                                        #
; #                                                                         #
; # INFO:                                                                   #
; #               $($aName,2) is a short-hand version of the following full #
; #               script: $aliasName($scriptline, $script).                 #
; #                                                                         #
; ###########################################################################
Alias aliasName {
  if (!$exists($2) || $1 !isnum) {
    echo -stegc info * Invalid syntax: $!aliasName
    halt
  }
  if (*.ini iswm $2) {
    var %x = $1 + 1
    while (%x && !$regex($read($2, n, %x), /^n\d+=alias(?: -l)? (\S+) /i)) { dec %x }
    return $regml(1)
  }
  var %x = $1
  while (%x && !$regex($read($2, n, %x), /^alias(?: -l)? (\S+) /i)) { dec %x }
  return $regml(1)
}
alias aname return $!aliasName($scriptline,$script)

