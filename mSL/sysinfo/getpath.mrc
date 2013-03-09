; ###########################################################################
; #  (c) 2003-2013, David Schor            [Licensed under the MIT license] #
; #                                        [See LICENSE.mrc for details.  ] #
; # NAME:                                                                   #
; #               Path To Special Folders                                   #
; # SYNOPSIS:                                                               #
; #               $getpath(<dir_name>)                                      #
; #                                                                         #
; # DESCRIPTION:                                                            #
; #               The $getpath() identifier returns the path of any special #
; #               folder that maps to a standard directory.                 #
; #                                                                         #
; # INFO:                                                                   #
; #               Some common directories:                                  #
; #                 - AllUsersDesktop       - AllUsersStartMenu             #
; #                 - AllUsersPrograms      - AllUsersStartup               #
; #                 - Desktop               - Favorites                     #
; #                 - Fonts                 - MyDocuments                   #
; #                 - NetHood               - PrintHood                     #
; #                 - Programs              - Recent                        #
; #                 - SendTo                - StartMenu                     #
; #                 - Startup               - Templates                     #
; #                                                                         #
; # EXAMPLE:                                                                #
; #               //echo -a $getpath(desktop)                               #
; #                                                                         #
; #               C:\Users\David\Desktop                                    #
; #                                                                         #
; #               //echo -a $getpath(MyDocuments)                           #
; #                                                                         #
; #               C:\Users\David\Documents                                  #
; #                                                                         #
; ###########################################################################
alias getpath {
  if (!$isid) {
    echo -gtecs info * Cannot be called as a command: $!getpath
    halt
  }
  if ($0 != 1) {
    echo -gtesc info * Invalid parameters: $!getpath
    halt
  }

  ; create object
  var %c = getpath. $+ $ticks
  .comopen %c WScript.Shell
  if ($comerr) goto err

  ; get special folder
  noop $com(%c, SpecialFolders, 3, bstr, $1)
  if ($comerr) goto err

  ; get value
  var %r = $com(%c).result
  .comclose %c
  return %r

  ; com errors
  :err
  echo -esctg info * Com Error $com(%c).error - $com(%c).errortext $com(%c).argerr $+ : $!getpath
  if ($com(%c)) .comclose %c
  halt
}
