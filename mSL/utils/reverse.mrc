; #########################################################################
; #  (c) 2005-2013, David Schor          [Licensed under the MIT license] #
; #                                      [See LICENSE.mrc for details.  ] #
; # SYNOPSIS:                                                             #
; #               $reverse(<string>)                                      #
; # DESCRIPTION:                                                          #
; #               This alias reverses  the order of the characters in the #
; #               string specified.                                       #
; #                                                                       #
; #               This alias does not preserve consequtive spaces.        #
; #                                                                       #
; # EXAMPLE:                                                              #
; #               1) //echo -a $reverse(This is an example!)              #
; #                  !elpmaxe na si sihT                                  #
; #                                                                       #
; #               2) //echo -a $reverse(a b c d e f g)                    #
; #                  g f e d c b a                                        #
; #                                                                       #
; #########################################################################
alias reverse {
  var %temp = $1
  return $regsubex(%temp, /(.)/g, $mid(%temp, -\n, 1))
}

