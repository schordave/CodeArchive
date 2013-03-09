; ###########################################################################
; #  (c) 2003-2013, David Schor            [Licensed under the MIT license] #
; #                                        [See LICENSE.mrc for details.  ] #
; # NAME:                                                                   #
; #               Expand Environment Variables                              #
; # SYNOPSIS:                                                               #
; #               $envvar(<string>)                                         #
; #                                                                         #
; # DESCRIPTION:                                                            #
; #               The $envvar() identifier expands the environment-variable #
; #               strings and replaces them with the values defined for the #
; #               current user.                                             #
; #                                                                         #
; #               This also means that  non-existing environment  variables #
; #               will not be replaced by anything  and will be treated  as #
; #               plain text.                                               #
; #                                                                         #
; # INFO:                                                                   #
; #               Some of the common env variables are:                     #
; #                                                                         #
; #       Variable                 | Description                            #
; #      --------------------------|--------------------------------------- #
; #      %ALLUSERSPROFILE%         | Path that contains all user profiles   #
; #      %AppData%                 | Application Data folder path           #
; #      %ComputerName%            | Computer Name                          #
; #      %CommonProgramFiles%      | Common Program files path              #
; #      %ProgramFiles%            | ""                                     #
; #      %ProgramFiles(x86)%       | ""                                     #
; #      %CommonProgramFiles(x86)% | ""                                     #
; #      %ProgramW6432%            | ""                                     #
; #      %ComSpec%                 | Command processor path                 #
; #      %HomeDrive%               | Home Drive                             #
; #      %HomePath%                | Home Path                              #
; #      %LogonServer%             | Logon Server name (network)            #
; #      %Path%                    | The Path variable                      #
; #      %PathExt%                 | Processed file extensions              #
; #      %SystemDrive%             | Drive of the system directory          #
; #      %SystemRoot%              | Root directory of the system           #
; #      %Temp%                    | Temp directory path                    #
; #      %Tmp%                     | ""                                     # 
; #      %UserDomain%              | The domain the current user belongs to #
; #      %UserName%                | The currently logged on user           #
; #      %UserProfile%             | User profile's directory               #
; #      %WinDir%                  | Window's directory's path              #
; #      %Public%                  | Public directory's path                #
; #                                                                         #
; #      For an exhaustive list, see                                        #
; #      http://technet.microsoft.com/en-us/library/cc749104(v=ws.10).aspx  #
; #                                                                         #
; # EXAMPLE:                                                                #
; #               //echo -a $envvar($(Hello %UserName%!,0))                 #
; #                                                                         #
; #               Hello David!                                              #
; #                                                                         #
; #               //echo -a Your windows dir is here: $envvar($(%WinDir%,0))#
; #                                                                         #
; #               Your windows dir is here: C:\Windows                      #
; #                                                                         #
; ###########################################################################
alias envvar {
  if (!$isid) {
    echo -gtesc info * Cannot be called as a command: $!envvar
    halt
  }
  if ($0 != 1) {
    echo -gtesc info * Invalid parameters: $!envvar
    halt
  }

  ; create object
  var %c = envvar. $+ $ticks
  .comopen %c WScript.Shell
  if ($comerr) goto err

  ; expand env string
  noop $com(%c, ExpandEnvironmentStrings, 3, bstr, $1)
  if ($comerr) goto err

  ; get value
  var %r = $com(%c).result
  .comclose %c
  return %r

  ; com errors
  :err
  else echo -esctg info * Com Error $com(%c).error - $com(%c).errortext $com(%c).argerr $+ : $!envvar
  if ($com(%c)) .comclose %c
  halt
}

