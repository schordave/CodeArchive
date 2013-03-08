; ###########################################################################
; #  (c) 2010-2013, David Schor            [Licensed under the MIT license] #
; #                                        [See LICENSE.mrc for details.  ] #
; # SYNOPSIS:                                                               #
; #               $safe(<code>)                                             #
; # DESCRIPTION:                                                            #
; #               This is the single most important alias EVER created!     #
; #                                                                         #
; #               Whenever  using a  timer, or even  /scon or  /scid, you   #
; #               should ALWAYS use that alias to prevent double evaluation #
; #               of code, especially user input.                           #
; #                                                                         #
; #               Consider:                                                 #
; #                          on *:text:!delay *:#:{                         #
; #                              timer 1 10 msg $chan $2-                   #
; #                          }                                              #
; #                                                                         #
; #               Now, meet Bob. Bob is going to use !delay in a way you    #
; #               never imagined:                                           #
; #                                                                         #
; #                          <bob> !delay lol | ns drop | exit -n           #
; #                                                                         #
; #               The final code executed is:                               #
; #                                                                         #
; #                          /timer 1 10 msg $chan lol | ns drop | exit -n  #
; #                                                                         #
; #               Since the timer will execute the code when its timer is   #
; #               up.                                                       #
; #                                                                         #
; #               How to solve it? $safe()!                                 #
; #                                                                         #
; #                          on *:text:!delay *:#:{                         #
; #                              timer 1 10 msg $safe($chan $2-)            #
; #                          }                                              #
; #                                                                         #
; #                                                                         #
; ########################################################################### 

; DO NOT change the spacing, they are there for a reason.
alias safe return $!decode( $encode($1-, m) ,m)

