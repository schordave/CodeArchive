;Last updated on 01/07/09
/*
***************************************************************
**                                   David Schor 2004-2009   **
**                                                           **
**                MD2 Message-Digest Algorithm               **
**               ------------------------------              **
**                                                           **
** INFO:                                                     **
**      Size: 128-bit                                        **
**       OID: {iso(1) member-body(2) us(840) rsadsi(113549)} **
**       RFC: 1319                                           **
**                                                           **
** FOLLOW:                                                   **
**         - RFC 1319                                        **
**         - RFC Errata 1319                                 **
**                                                           **
**                                                           **
**   An implementation of the MD2 message digest algorithm   **
**                                                           **
**   + This should not be used for not applications          **
**   + This is here for compatibility only!                  **
**                                                           **
** * Please note:                                            **
**       I never took the time to optimize my code. Using    **
**       large files *will* work, however, it *might* take   **
**       a long time.                                        ** 
**                                                           **
**                                                           **
** USAGE:                                                    **
**                                                           **
**        $md2(text|&binvar|filename,[N])                    **
**                                                           **
** DESCRIPTION:                                              **
**                                                           **
**   Returns md2 hash value for the specified data, where    **
**     N = 0 for plain text (default), 1 for &binvar,        **
**     2 for filename.                                       **
**                                                           **
***************************************************************
*/
;--------------------------------------------------------------
;  START MD2
;--------------------------------------------------------------
Alias MD2 {
  if ($isid) {
    ;get set the message
    if ($0 == 1 || $2 == 0) {
      /* Normal string input
      */
      if ($1 == $null) {
        /* null string needs to be taken care on its own due to mIRC's null var problem
        */
        var %pad = 1
      }
      else {
        bset -t &message 1 $1
      }
    }
    elseif ($2 == 1) {
      /* Binary variable input
      */
      if ($bvar($1, 0) > 0) {
        bcopy &message 1 $1 1 $v1
      }
      else {
        echo $color(info) -ae * Invalid parameters: $!md2
        halt
      }
    }
    elseif ($2 == 2) {
      /* File input
      */
      if ($exists($1)) { 
        bread $1 0 $lof($1) &message
      }
      else  {
        echo $color(info) -ae * Error accessing file: $!md2
        halt
      }
    }


    if (%pad) {
      /* null string needs to be taken care on its own due to mIRC's null var problem
      */
      bcopy &message $calc($bvar(&message, 0) + 1) $Pedding(16) 1 -1
    }
    else {
      ;pedding, if needed (MOD 16, for 128 bit)
      if ($calc($bvar(&message, 0) % 16)) {
        ;pedding is needed
        bcopy &message $calc($bvar(&message, 0) + 1) $Pedding($calc(16 - ($v1 % 16))) 1 -1
      }
    }

    ;generates a checksum
    checkSum 

    ;append the 16-byte checksum
    bcopy &message $calc($bvar(&message, 0) + 1) &c 1 -1

    ;compute the message digest
    computeMD 

    ;output, convert ASCII -> HEX, lowercase everything
    return $remove($lower($regsubex($bvar(&md, 1, 16),/(\d+)/g,$base(\t, 10, 16, 2))),$chr(32))
  }
  else {
    ;we don't accept it as a command, pass it on...
    md2 $1-
  }
}

/* Pedding for the message
*/
Alias Pedding {
  if ($0) {
    bset &pedding 1 $str($+($mid(0 $+ $1, -2), $chr(32)), $1)
    return &pedding
  }
  else {
    echo $color(info) -es * Invalid parameters: $!Pedding
  }
}

/* 16-byte checksum
*/
Alias -l checkSum {
  ;clear checksum
  bset &c 16 0
  ;reset tempL
  bset &tempL 1 0


  ;process each 16-word block
  var %i = 0, %len = $calc($bvar(&message, 0) /16)

  while (%i < %len) {
    ;Checksum block i
    var %j = 1
    while (%j <= 16) {
      bcopy &tempC 1 &message $calc(%i * 16 + %j) 1
      bset &c %j $xor($bvar(&c, %j), $Perm($xor($bvar(&tempC, 1),$bvar(&tempL, 1))))
      bset &tempL 1 $bvar(&c, %j)
      inc %j
    }
    inc %i
  }

}

/*
* permutation of 1 to 256
* constructed from digits of pi.
*/
Alias Perm {


  var %PermTable = $&
    41,46,67,201,162,216,124,1,61,54,84,161,236,240,6,19, $&
    98,167,5,243,192,199,115,140,152,147,43,217,188,76,130,202, $&
    30,155,87,60,253,212,224,22,103,66,111,24,138,23,229,18, $&
    190,78,196,214,218,158,222,73,160,251,245,142,187,47,238,122, $&
    169,104,121,145,21,178,7,63,148,194,16,137,11,34,95,33, $&
    128,127,93,154,90,144,50,39,53,62,204,231,191,247,151,3, $&
    255,25,48,179,72,165,181,209,215,94,146,42,172,86,170,198, $&
    79,184,56,210,150,164,125,182,118,252,107,226,156,116,4,241, $&
    69,157,112,89,100,113,135,32,134,91,207,101,230,45,168,2, $&
    27,96,37,173,174,176,185,246,28,70,97,105,52,64,126,15, $&
    85,71,163,35,221,81,175,58,195,92,249,206,186,197,234,38, $&
    44,83,13,110,133,40,132,9,211,223,205,244,65,129,77,82, $&
    106,220,55,200,108,193,171,250,36,225,123,8,12,189,177,74, $&
    120,136,149,139,227,99,232,109,233,203,213,254,59,0,29,57, $&
    242,239,183,14,102,88,208,228,166,119,114,248,235,117,75,10, $&
    49,68,80,180,143,237,31,26,219,153,141,51,159,17,131,20
  return $gettok(%PermTable, $calc($1 + 1), 44)
}




Alias computeMD {
  bset &md 48 0

  ;process each 16-word block
  var %i = 0, %len = $calc($bvar(&message, 0) /16)
  while (%i < %len) {
    ;Copy block i into md
    var %j = 1
    while (%j <= 16) {
      var %tt = 16 + %j
      bcopy &md %tt &message $calc(%i * 16 + %j) 1
      bset &temp 1 $xor($bvar(&md, %tt), $bvar(&md, %j))
      bcopy &md $calc(32 + %j) &temp 1 1
      inc %j
    }

    bset &t 1 0
    ;Do 18 rounds
    var %j = 0
    while (%j < 18) {

      ;Round j
      var %k = 1
      while (%k <= 48) {
        bset &temp 1 $xor($bvar(&md, %k), $Perm($bvar(&t, 1)))
        bcopy &t 1 &temp 1 1
        bcopy &md %k &temp 1 1
        inc %k
      } 

      ;Set t to (t+j) modulo 256.
      bset &t 1 $calc($bvar(&t, 1) + %j) % 256)
      inc %j
    }

    inc %i
  }
}

;--------------------------------------------------------------
;  EOF
