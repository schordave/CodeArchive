; ###########################################################################
; #  (c) 2005-2013, David Schor            [Licensed under the MIT license] #
; #                                        [See LICENSE.mrc for details.  ] #
; # NAME:                                                                   #
; #               IRSSI-style /exec                                         #
; # SYNOPSIS:                                                               #
; #               (Identical syntax)                                        #
; #               /exec [-nocmd] [-out | -msg <target> | -notice <target> | -window [@window]] <cmd line>
; # DESCRIPTION:                                                            #
; #               This is an mSL clone of the IRSSI /exec command,  with a  #
; #               close syntax.                                             #
; #                                                                         #
; #               -nocmd: Don't start command through cmd.exe               #
; #               -out: Send output to active channel/query                 #
; #               -msg: Send output to specified nick/channel               #
; #               -notice: Send output to specified nick/channel as notices #
; #               -window: Send output to window name (if  needed,  window  #
; #                        will be created)                                 #
; #                                                                         #
; # EXAMPLE:                                                                #
; #               Example 1: /exec -out ping ::1                            #
; #                                                                         #
; #                Pinging ::1 with 32 bytes of data:                       #
; #                Reply from ::1: time<1ms                                 #
; #                Reply from ::1: time<1ms                                 #
; #                Reply from ::1: time<1ms                                 #
; #                Reply from ::1: time<1ms                                 #
; #                Ping statistics for ::1:                                 #
; #                Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),     #
; #                Approximate round trip times in milli-seconds:           #
; #                Minimum = 0ms, Maximum = 0ms, Average = 0ms              #
; #                                                                         #
; #               Example 2: /exec -nocmd -msg #FooBar reg query HKEY_LOCAL_MACHINE
; #                                                                         #
; #                <@Wiz126> HKEY_LOCAL_MACHINEBCD00000000                  #
; #                <@Wiz126> HKEY_LOCAL_MACHINEHARDWARE                     #
; #                <@Wiz126> HKEY_LOCAL_MACHINESAM                          #
; #                <@Wiz126> HKEY_LOCAL_MACHINESECURITY                     #
; #                <@Wiz126> HKEY_LOCAL_MACHINESOFTWARE                     #
; #                <@Wiz126> HKEY_LOCAL_MACHINESYSTEM                       #
; #                                                                         #
; #               Example 3: /exec -out systeminfo                          #
; #                                                                         #
; #                Host Name: NAPTUNE-B                                     #
; #                OS Name: Microsoft Windows 7 Professional                #
; #                OS Version: 6.1.7600 N/A Build 7600                      # 
; #                OS Manufacturer: Microsoft Corporation                   #
; #                 ... output goes on...                                   #
; #                                                                         #
; #               Example 4: /exec -out myProgram.exe                       #
; #                                                                         #
; #                 ... your program's stdout output .. (puts/printf/cout..)#
; #                                                                         #
; ###########################################################################
; #
alias exec {
  if ($0 < 2) {
    echo -atce info * /exec: insufficient parameters
    halt
  }

  if ($1 == -nocmd) {
    var %n 1
    tokenize 32 $2-
  }

  if ($istok(-out -msg -notice -window, $1, 32)) {
    var %out = $1
    tokenize 32 $2-
    if ((%out == -window) && ($left($1, 1) != @)) {
      echo -atce info * /exec: invalid parameters
      halt
    }
    if (%out != -out) {
      var %how = $1
      tokenize 32 $2-
    }
  }
  else {
    echo -atce info * /exec: invalid parameters
    halt
  }

  ;unique com names
  var %c = $uniqueCom(wscript.shell)
  var %y = $uniqueCom(dispatched.x)
  var %z = $uniqueCom(dispatched.y)

  ;start a shell object
  .comopen %c WScript.Shell
  .comclose %c $com(%c, exec, 1, bstr, $iif(!%n, cmd.exe /c) $1-, dispatch* %y)

  ;attach onto std out
  noop $com(%y, stdout, 3, dispatch* %z) 
  noop $com(%y, status, 3) 

  ;get the results, send them to output
  while (!$com(%z).result) { 

    ;read the next stdout line
    noop $com(%z, ReadLine, 3) 

    ;anything back? print it
    if ($com(%z).result) {
      noop $exOut(%out, %how, $v1)
    }

    ;check if stream is at EOF
    noop $com(%z, AtEndOfStream, 3)
  } 

  ;cleanup
  .comclose %z
  .comclose %y

  return

  ;error handling
  :error
  reseterror
  if ($com(%c)) .comclose %c
  if ($com(%y)) .comclose %y
  if ($com(%z)) .comclose %z
}

alias -l uniqueCom {
  ;generate a unique com name
  var %com = $1. $+ $ticks
  while ($com(%com)) var %com = $1. $+ $ticks
  return %com
}

alias -l exOut {
  if ($1 == -out) echo -a $3-
  elseif ($1 == -msg) msg $2-
  elseif ($1 == -notice) notice $2-
  elseif ($1 == -window) {   
    if (!$window($2)) window $2
    echo $2-
  }
}

