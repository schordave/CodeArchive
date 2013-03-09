; ###########################################################################
; #  (c) 2009-2013, David Schor            [Licensed under the MIT license] #
; #                                        [See LICENSE.mrc for details.  ] #
; # SYNOPSIS:                                                               #
; #               $nohtml(<html_code>)                                      #
; # DESCRIPTION:                                                            #
; #               This  is a  very simple  alias that strips all HTML  tags #
; #               from the code specified. This  supports full HTML tags as #
; #               as  partial  HTML tags (that  might have  been  opened or #
; #               closed) on another line like "foo='bar' />sometext<foo".  #
; #                                                                         #
; # Example:                                                                #
; #                //echo -a $nohtml(<span class="foo">Some Text</span>)    #
; #                                                                         #
; #                Some Text                                                #
; #                                                                         #
; #                //echo -a $nohtml(id="foo">Some <strong>Text</strong>)   #
; #                                                                         #
; #                Some Text                                                #
; #                                                                         #
; #                //echo -a $nohtml(id="foo">Some <strong>Text<span)       #
; #                                                                         #
; #                Some Text                                                #
; #                                                                         #
; # NOTE:                                                                   #
; #               This alias ONLY strips HTML tags. To  convert things like #
; #               HTML entities into their appropriate representation check #
; #               out the $html2ascii() or the newer $html2unicode() idents.#
; #                                                                         #
; ###########################################################################
;
alias nohtml return $regsubex($1, /<[^>]+(?:>|$)|^[^<>]+>/g, )

