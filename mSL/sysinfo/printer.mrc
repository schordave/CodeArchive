; #########################################################################
; #  (c) 2005-2013, David Schor          [Licensed under the MIT license] #
; #                                      [See LICENSE.mrc for details.  ] #
; # SYNOPSIS:                                                             #
; #           /Printer -l <printerName>                                   #
; #           /Printer -cprd <PrinterIndex>                               #
; #           /Printer -n <index> <new printerName>                       #
; #                                                                       #
; #           $Printer(<printerName>).index                               #
; #           $Printer(<index>).<isPaused/isDefault>                      #
; #                                                                       #
; #           /PrintJob -lpr [jobID]                                      #
; #                                                                       #
; #           $PrintJob(<Nth Job>|<JobID>, M).                            #
; #                        <doc,desc,printer,printerIndex>                #
; #                        <jobID,jobStatus,name,owner,size>              #
; #                        <paperSize,pW,totalPages,isPaused>             #
; #                                                                       #
; # DESCRIPTION:                                                          #
; #                                                                       #
; #           /Printer -l <printerName>                                   #
; #           lists names of printers installed on this computer          #
; #                                                                       #
; #           /Printer -cprd <PrinterIndex>                               #
; #             -c cancels all jobs for a printer                         #
; #             -p pauses the print queue                                 #
; #             -r resumes paused print queue                             #
; #             -d sets the printer as the default printer                #
; #                                                                       #
; #           /Printer -n <index> <new printerName>                       #
; #            renames the printer                                        #
; #            EDIT: NEEDS TO BE RE-WORKED, STOPPED WORKING IN VISTA      #
; #                                                                       #
; #                                                                       #
; #           $Printer properties                                         #
; #            - with no properties, it will return the name or $null     #
; #              if the printer exists or not.                            #
; #                                                                       #
; #           .index    - returns the numberic index for the name         #
; #           .isPaused - returns $true/$false is the printer is paused   #
; #           .isDefault- returns $true/$false if default printer         #
; #                                                                       #
; #           /PrintJob -l                                                #
; #            Lists active print jobs in queue                           #
; #                                                                       #
; #           $PrintJob(<Nth Job>|<JobID>, M)                             #
; #            Returns information on a job, <Nth Job> if M = 0           #
; #            or <JobID> if M = 1                                        #
; #                                                                       #
; #          Properties:                                                  #
; #           .doc          - Name of the print job                       #
; #           .desc         - Description of the print job                #
; #           .printer      - Name of the printer driver                  #
; #           .printerIndex - printer index of $PrintJob().printer        #
; #           .jobID        - returns the print job ID of this job        #
; #           .jobStatus    - returns the status of the print job         #
; #           .owner        - user that submitted the job                 #
; #           .size         - size of the document, formatted             #
; #           .rawSize      - size of the document in bytes               #
; #           .paperSize    - size of the paper                           #
; #           .totalPages   - number of pages                             #
; #           .pW           - width of document                           #
; #           .isPaused     - returns $true/$false if job is paused       #
; #                                                                       #
; # EXAMPLE:                                                              #
; #           /printer -l                                                 #
; #                                                                       #
; #             Printer list:                                             #
; #             1) Microsoft XPS Document Writer - Unknown - 600 DPI      #
; #             2) Fax - Unknown - 200 DPI                                #
; #             3) HP OfficeJet Pro 8600 - 1200 DPI                       #
; #                                                                       #
; # BUGS:                                                                 #
; #          Some  features like the  /printer -n has stopped working  in #
; #          Windows Vista. It is yet to be fixed. Sorry.                 #
; #                                                                       #
; #########################################################################
Alias -l getPrinterStatus {
  if ($1 !isnum 1-18) {
    echo $color(info) -ea * Invalid parameters: $!getPrinterStatus 
    halt
  }
  else {
    var %status = $&
      Other, Unknown, Idle, Printing, Warming Up, Stopped printing, $&
      Offline, Paused, Error, Busy, Not Available, Waiting, Processing $&
      Initialization, Power Save, Pending Deletion, I/O Active, Manual Feed
    return $gettok(%status, $1, 44)
  }

}
/*
*  Printer Alias
*    - see top comment for details
*
*/
Alias printer {
  var %t = $ticks $+ $r(1,9)
  var %pQ = printQ $+ %t
  .comopen _WbemScripting $+ %t WbemScripting.SWbemLocator
  .comclose _WbemScripting $+ %t $com(_WbemScripting $+ %t,connectserver,3,dispatch* _cServer $+ %t)
  .comclose _cServer $+ %t $com(_cServer $+ %t,execquery,3,bstr,Select * from Win32_Printer,dispatch* %pQ)
  ;$ident or /command
  if ($isid) {
    ;$printer().index or $printer()
    if (!$prop || $prop == index) {
      /* return the index for the printer name, or $null if not found
      */
      var %x = 1, %return = $null
      while (%x <= $comval(%pQ, 0)) {
        if ($1- == $comval(%pQ, %x, Caption)) {
          %return = %x
        }
        inc %x
      }
      .comclose %pQ
      return $iif($prop,%return,$iif(%return, $true, $false))
    }
    ;$printer().isPaused
    elseif ($prop == isPaused) {
      if ($1 < 1 || $1 > $comval(%pQ, 0)) {
        echo $color(info) -ae * Invalid parameters: $!Printer
        halt
      }
      else {
        var %x = $comval(%pQ, $1, ExtendedPrinterStatus)
        .comclose %pQ
        return $iif(%x == 8, $true, $false)
      }
    }
    elseif ($prop == isDefault) {
      var %x = $comval(%pQ, $1, Default)
      .comclose %pQ
      return %x
    }
    else {
      ;other properties
    }
    .comclose %pQ
  }
  else {
    if (-* iswm $1) {
      if (l isin $1) {
        /* List all printers
        */
        echo $color(info) -a * Printer list:
        var %x = 1
        while (%x <= $comval(%pQ, 0)) {
          echo $color(info) -a $v1 $+ ) $comval(%pQ, %x, Caption) - $&
            $getPrinterStatus($comval(%pQ, %x, ExtendedPrinterStatus)) - $&
            $comval(%pQ, %x, VerticalResolution) DPI
          inc %x
        }
      }
      elseif (c isin $1) {
        /* Cancel all printing jobs for a printer
        */
        if ($0 < 2 || $2 < 1 || $2 > $comval(%pQ, 0)) {
          echo $color(info) -ae * /printer: insufficient parameters
          halt
        }
        else {
          var %s = $comval(%pQ, $2, CancelAllJobs)
          if (%s == 5) {
            $iif(!$show, noop) echo $color(info) -ae * Access denied while canceling print jobs for $qt($comval(%pQ, $2, Caption))
          }
          elseif (%s == 0) {
            $iif(!$show, noop) echo $color(info) -ae * Canceling print jobs for $qt($comval(%pQ, $2, Caption)) was successful
          }
          else {
            $iif(!$show, noop) echo $color(info) -ae * Error canceling print jobs for $qt($comval(%pQ, $2, Caption)) $+ !
          }
        }
      }
      elseif (p isin $1) {
        /* Pauses the print queue.
        */
        if ($0 < 2 || $2 < 1 || $2 > $comval(%pQ, 0)) {
          echo $color(info) -ae * /printer: insufficient parameters
          halt
        }
        else {
          var %s = $comval(%pQ, $2, Pause)
          if (%s == 5) {
            $iif(!$show, noop) echo $color(info) -ae * Access denied while pausing printr $qt($comval(%pQ, $2, Caption))
          }
          elseif (%s == 0) {
            $iif(!$show, noop) echo $color(info) -ae * Printer $qt($comval(%pQ, $2, Caption)) was paused successfully
          }
          else {
            $iif(!$show, noop) echo $color(info) -ae * Error pausing printr $qt($comval(%pQ, $2, Caption)) $+ !
          }
        }
      }
      elseif (r isin $1) {
        /* Resume printer
        */
        if ($0 < 2 || $2 < 1 || $2 > $comval(%pQ, 0)) {
          echo $color(info) -ae * /printer: insufficient parameters
          halt
        }
        else {
          var %s = $comval(%pQ, $2, Resume)
          if (%s == 5) {
            $iif(!$show, noop) echo $color(info) -ae * Access denied while resuming printer $qt($comval(%pQ, $2, Caption))
          }
          elseif (%s == 0) {
            $iif(!$show, noop) echo $color(info) -ae * Printer $qt($comval(%pQ, $2, Caption)) was resumed successfully
          }
          else {
            $iif(!$show, noop) echo $color(info) -ae * Error resuming printer $qt($comval(%pQ, $2, Caption)) $+ !
          }
        }
      }
      elseif (n isin $1) {
        /* Rename printer
        */
        if ($0 < 3 || $2 < 1 || $2 > $comval(%pQ, 0)) {
          echo $color(info) -ae * /printer: insufficient parameters
          halt
        }
        else {
          /*
          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
          fix
          @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
          */
        }
      }
      elseif (d isin $1) {
        /* default printer
        */
        if ($0 < 2 || $2 < 1 || $2 > $comval(%pQ, 0)) {
          echo $color(info) -ae * /printer: insufficient parameters
          halt
        }
        else {
          var %r = $comval(%pQ, $2, SetDefaultPrinter)
          if (!%r) {
            $iif(!$show, noop) echo $color(info) -ae * $qt($comval(%pQ, $2, Caption)) is set as the default printer.
          }
          else {
            $iif(!$show, noop) echo $color(info) -ae * Error while setting $qt($comval(%pQ, $2, Caption)) as the default printer!
          }
        }
      }
    }
    .comclose %pQ
  }
}

Alias PrintJob {
  var %t = $ticks $+ $r(1,9)
  var %pQ = printQ $+ %t
  .comopen _WbemScripting $+ %t WbemScripting.SWbemLocator
  .comclose _WbemScripting $+ %t $com(_WbemScripting $+ %t,connectserver,3,dispatch* _cServer $+ %t)
  .comclose _cServer $+ %t $com(_cServer $+ %t,execquery,3,bstr,Select * from Win32_PrintJob,dispatch* %pQ)
  if ($isid) {
    if (($0 > 2) || (($2 !isnum 0-1) && ($0 != 1))) {
      echo $color(info) -ae * Invalid parameters: $!PrintJob
      halt
    }
    else {
      var %job = -1
      if ($2 == 0 || $0 == 1) {
        /* Nth Job
        */
        var %job = $1

      }
      else {
        /* JobID
        */
        var %x = 1
        while (%x <= $comval(%pQ, 0)) {
          if ($1 == $comval(%pQ, %x, JobId)) {
            var %job = %x
          }
          inc %x
        }
      }

      if (%job < 0) {
        return $false
      }


      ;follow request
      if ($findtok(doc:desc:jobID:jobStatus:owner:rawSize:paperSize:totalPages:pW, $prop, 58)) {
        var %Methods = Document:Description:JobId:JobStatus:Owner:Size:PaperSize:TotalPages:PaperWidth
        var %result = $comval(%pQ, %job , $gettok(%Methods, $v1, 58) )
        .comclose %pQ
        return %result
      }
      elseif ($prop == isPaused) {
        var %x = $iif($comval(%pQ, %job, StatusMask), $true, $false)
        .comclose %pQ
        return %x
      }
      elseif ($prop == printer) {
        var %printer = $gettok($comval(%pQ, %job, name), 1, 44)
        .comclose %pQ
        return %printer
      }
      elseif ($prop == printerIndex) {
        var %printer = $gettok($comval(%pQ, %job, name), 1, 44)
        .comclose %pQ
        return $printer(%printer).index
      }
      elseif ($prop == size) {
        var %size = $bytes($comval(%pQ, %job, size)).suf
        .comclose %pQ
        return %size
      }  


    }
  }
  else {
    if (-* iswm $1) {
      if (l isin $1) {
        /* List active jobs
        */
        var %x = 1
        echo $color(info) -a * Print Job List:
        while (%x <= $comval(%pQ, 0)) {
          echo $color(info) -a $v1 $+ ) $comval(%pQ, %x, Document) - $&
            $comval(%pQ, %x, Status) - $&
            $comval(%pQ, %x, TotalPages) pages - $&
            $bytes($comval(%pQ, %x, Size)).suf - $&
            $comval(%pQ, %x, JobID)
          inc %x
        }
      }
      elseif (p isin $1) {
        /* pause print job
        */
        if (!$2 || $2 !isnum) {
          echo $color(info) -ae * /PrintJob: insufficient parameters
          halt
        }
        else {
          var %x = 1, %job = -1
          while (%x <= $comval(%pQ, %x, JobID)) {
            if ($2 == $comval(%pQ, %x, JobID)) {
              %job = %x
            }
            inc %x
          }
          if (%job < 0) {
            echo $color(info) -ae * /PrintJob: insufficient parameters
            halt
          }
          else {
            if ($comval(%pQ, %job, Pause)) {
              $iif(!$show, noop) echo $color(info) -ae * Error pausing $qt($comval(%pQ, %job, Document) $+ !
            }
            else {
              $iif(!$show, noop) echo $color(info) -ae * Job $qt($comval(%pQ, %job, Document)) was paused successfully
            }
          }
        } 
      }
      elseif (r isin $1) {
        /* resume print job
        */
        if (!$2 || $2 !isnum) {
          echo $color(info) -ae * /PrintJob: insufficient parameters
          halt
        }
        else {
          var %x = 1, %job = -1
          while (%x <= $comval(%pQ, %x, JobID)) {
            if ($2 == $comval(%pQ, %x, JobID)) {
              %job = %x
            }
            inc %x
          }
          if (%job < 0) {
            echo $color(info) -ae * /PrintJob: insufficient parameters
            halt
          }
          else {
            if ($comval(%pQ, %job, Resume)) {
              $iif(!$show, noop) echo $color(info) -ae * Error resuming $qt($comval(%pQ, %job, Document) $+ !
            }
            else {
              $iif(!$show, noop) echo $color(info) -ae * Job $qt($comval(%pQ, %job, Document)) was resumed successfully
            }
          }
        } 
      }

    }
  }
  .comclose %pQ
}

