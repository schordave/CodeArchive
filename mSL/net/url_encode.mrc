; #########################################################################
; #  (c) 2006-2013, David Schor          [Licensed under the MIT license] #
; #                                      [See LICENSE.mrc for details.  ] #
; # SYNOPSIS:                                                             #
; #               $url_encode(<url_data>)                                 #
; # DESCRIPTION:                                                          #
; #               This alias encodes the query  part of a URL appropria-  #
; #               tely suitable  to be passed  to a server  as part of an #
; #               HTTP request.                                           #
; #                                                                       #
; #               This script supports the following representations:     #
; #                                                                       #
; #               - Converts spaces into pluses                           #
; #               - Converts symbols into their %hex values               #
; #                                                                       #
; # COMPLIANCE:   - RFC 1738                                              #
; #                                                                       #
; # EXAMPLES:                                                             #
; #               1) Main Example:                                        #
; #                                                                       #
; #                //echo -a $url_encode(this is a te!@#%st)              #
; #                                                                       #
; #                this+is+a+te%21%40%23%25st                             #
; #                                                                       #
; #               2) Works correctly with unicode:                        #
; #                                                                       #
; #               //echo -a $url_encode(♥)                                #
; #                                                                       #
; #                %E2%99%A5                                              #
; #                                                                       #
; #               3)                                                      #
; #                                                                       #
; #               //echo -a $url_encode(This Is An Example)               #
; #                                                                       #
; #                This+Is+An+Example                                     #
; #                                                                       #
; #########################################################################
;
alias url_encode return $regsubex($1, /([\W\s])/Sg, $iif(\t == $chr(32), +, $+(%, $base($asc(\t), 10, 16, 2))))

