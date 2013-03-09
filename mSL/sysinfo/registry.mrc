; ###########################################################################
; #  (c) 2003-2013, David Schor            [Licensed under the MIT license] #
; #                                        [See LICENSE.mrc for details.  ] #
; # NAME:                                                                   #
; #               Registry Manipulation Library                             #
; # SYNOPSIS:                                                               #
; #               $regread(<key_path>)[.q]                                  #
; #                                                                         #
; #               /regwrite "Path\To\Your\Key" <type> <value>               #
; #                                                                         #
; #               /regdel "Path\To\Your\Key"                                #
; #                                                                         #
; # DESCRIPTION:                                                            #
; #               This is a complete registry manipulation library for mSL. #
; #               This  library  allows you  to  read, write,  and  delete  #
; #               registry keys.                                            #
; #                                                                         #
; #               The $regread() identifier can be used to read  a registry #
; #               key value.                                                #
; #                                                                         #
; #               The /regwrite command can be used to overwrite an existing#
; #               key as well as to create new keys.                        #
; #
; #               The /regdel  command can be  used to  delete  an existing #
; #               registry key.                                             #
; #                                                                         #
; #               By  default,  $regread errors  on  invalid  keys, the 'q' #
; #               (quiet)  property can be used  to  quiet  that  error and #
; #               instead return $null.                                     #
; #                                                                         #
; # REG TYPES:    The following are legal registry types:                   #
; #                                                                         #
; #               - REG_SZ        - A standard string type.                 #
; #               - REG_DWORD     - A 32-bit integer type.                  #
; #               - REG_EXPAND_SZ - An extended string type.                #
; #                                                                         #
; # REG LOCATIONS:                                                          #
; #               The following are the directories used by the system:     #
; #                                                                         #
; #         Directory           | Abrv.| Description                        #
; #         --------------------|------|----------------------------------  #
; #         HKEY_CURRENT_USER   | HKCU | Current logged on user settings.   #
; #         HKEY_USERS          | HKU  | Contains all loaded user profiles. #
; #         HKEY_LOCAL_MACHINE  | HKLM | Contains computer specific data.   #
; #         HKEY_CLASSES_ROOT   | HKCR | HKLM\Software, program's settings. #
; #         HKEY_CURRENT_CONFIG | HCC  | Hardware profile's data.           #
; #                                                                         #
; # EXAMPLE:                                                                #
; #               //regwrite HKCU\Test\Example REG_SZ This Is An Example!   #
; #                                                                         #
; #               //echo -a $regread(HKCU\Test\Example)                     #
; #                                                                         #
; #               //regdel HKCU\Test\Example                                #
; #                                                                         #
; #               //echo -a $qt($regread(HKCU\Test\Example).q)              #
; #                                                                         #
; ###########################################################################
alias regread {
  /* not a command 
  */
  if (!$isid) {
    echo -esctg info * $!regread: Not a command.
    halt
  }
  /* ensure correct argc
  */
  if ($0 != 1) {
    echo -esctg info * Invalid parameters: $!regread
    halt
  }

  ; create object
  var %c = regread. $+ $ticks
  .comopen %c WScript.Shell
  if ($comerr) goto err

  ; read value
  noop $com(%c, RegRead, 3, bstr, $1-)
  if ($comerr) goto err

  ; results
  var %r = $com(%c).result
  .comclose %c
  return %r

  ; com errors
  :err
  if ($com(%c).error == 9 && !$com(%c).argerr) {
    if ($prop == q) {
      if ($com(%c)) .comclose %c
      return
    }
    echo -esctg info * No such registry path: $1- $!regread
  }
  else echo -esctg info * Com Error $com(%c).error - $com(%c).errortext $+ : $!regread
  if ($com(%c)) .comclose %c
  halt
}
alias regwrite {
  /* first handle quotes 
  */
  if ("*" * iswm $1-) {
    var %pos = $pos($1-, ", 2)
    var %key = $mid($1-, 2, $calc(%pos - 2))
    tokenize 32 $mid($1-, $calc(%pos + 1))
  }
  else {
    var %key = $1
    tokenize 32 $2-
  }
  /* we are never an identifier
  */
  if ($isid) {
    echo -esctg info * /regwrite: Not an identifier.
    halt
  }
  if ($0 < 2) {
    echo -esctg info * /regwrite: insufficient parameters
    halt
  }
  if (!$reg_isvalid_type($1)) {
    echo -esctg info * /regwrite: invalid parameters
    halt
  }

  ;create object
  var %c = regread. $+ $ticks
  .comopen %c WScript.Shell
  if ($comerr) goto err

  ; write value
  noop $com(%c, RegWrite, 3, bstr, %key, bstr, $2-, bstr, $1)
  if ($comerr) goto err

  ; close, return
  .comclose %c
  return

  ; com errors
  :err
  echo -esctg info * /regwrite: Com Error $com(%c).error - $com(%c).errortext $com(%c).argerr
  if ($com(%c)) .comclose %c
  halt
}
alias regdel {
  /* we are never an identifier
  */
  if ($isid) {
    echo -esctg info * /regwrite: Not an identifier.
    halt
  }
  /* ensure argc 
  */
  if (!$0) {
    echo -esctg info * /regwrite: insufficient parameters
    halt
  }
  /* first handle quotes (even though there shouldn't be any)
  */
  if ("*"* iswm $1-) {
    tokenize 32 $mid($1-, 2, $calc($pos($1-, ", 2) - 2))
  }

  ;create object
  var %c = regread. $+ $ticks
  .comopen %c WScript.Shell
  if ($comerr) goto err

  ; write value
  noop $com(%c, RegDelete, 3, bstr, $1-)
  if ($comerr) goto err

  ; close, return
  .comclose %c
  return

  ; com errors
  :err
  if ($com(%c).error == 9 && !$com(%c).argerr) {
    echo -esctg info * /regdel: No such registry path: $1-
  }
  else echo -esctg info * /regdel: Com Error $com(%c).error - $com(%c).errortext $com(%c).argerr
  if ($com(%c)) .comclose %c
  halt
}
alias -l reg_isvalid_type {
  return $istok(REG_DWORD REG_EXPAND_SZ REG_SZ, $1, 32)
}

