; #########################################################################
; #  (c) 2006-2013, David Schor          [Licensed under the MIT license] #
; #                                      [See LICENSE.mrc for details.  ] #
; # SYNOPSIS:                                                             #
; #               $url_decode(<encoded_url_data>)                         #
; # DESCRIPTION:                                                          #
; #               This alias decodes the query  part of a URL appropria-  #
; #               tely usually retrived as part of a server reply from a  #
; #               typical HTTP request.                                   #
; #                                                                       #
; #               This script supports the following representations:     #
; #                                                                       #
; #               - Converts pluses into space                            #
; #               - Converts %hex values into symbols                     #
; #                                                                       #
; # COMPLIANCE:   - RFC 1738                                              #
; #                                                                       #
; # EXAMPLES:                                                             #
; #               1) Main Example:                                        #
; #                                                                       #
; #                //echo -a $url_decode(this+is+a+te%21%40%23%25st)      #
; #                                                                       #
; #                this is a te!@#%st                                     #
; #                                                                       #
; #               2) Works correctly with unicode:                        #
; #                                                                       #
; #               //echo -a $url_decode($(%E2%99%A5,0))                   #
; #                                                                       #
; #                 ♥                                                     #
; #                                                                       #
; #               3)                                                      #
; #                                                                       #
; #               //echo -a $url_decode(This+Is+An+Example)               #
; #                                                                       #
; #                This Is An Example                                     #
; #                                                                       #
; #########################################################################
;
alias url_decode returnex $utfdecode($regsubex($replace($1,+,$chr(32)),/%([A-F\d]{2})/gi,$chr($base(\1,16,10))))

