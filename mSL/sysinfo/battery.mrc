; #########################################################################
; #  (c) 2006-2013, David Schor          [Licensed under the MIT license] #
; #                                      [See LICENSE.mrc for details.  ] #
; # SYNOPSIS:                                                             #
; #               /battery                                                #
; #               $Battery().<property>                                   #
; # DESCRIPTION:                                                          #
; #               When  called  as   a  command  /battery  will  message  #
; #               the active channel  interesting information about your  #
; #               laptop's battery.                                       #
; #                                                                       #
; #               The current format is:                                  #
; #                                                                       #
; #               <@foobar> [[Battery Information]] Status: <STATUS> Life: <%%>% Type: <TYPE> Chemistry: <CHEM> Voltage: <##.##>v Operational Status: <TYPE>
; #                                                                       #
; #               (You are free to change it as you wish, if you upgrade  #
; #               the format in modular way, feel free to send me a patch)#
; #                                                                       #
; #               Note: The colors can be easily edited via the c1 and c2 #
; #               aliases.                                                #
; #                                                                       #
; #               When called as an identifier, it returns  a information #
; #               about a specific item.                                  #
; #                                                                       #
; #               The properties are:                                     #
; #                                                                       #
; #               $Battery().status - Returns  the current status  of the #
; #               battery (eg. On power, discharging, etc..)              #
; #                                                                       #
; #               $Battery().percent - Battery  Percentage,  WITHOUT  the #
; #               percent symbol                                          #
; #                                                                       #
; #               $Battery().type -  Type  of  battery installed (example #
; #               External Battery)                                       #
; #                                                                       #
; #               $Battery().chem -  Describes  the battery's  chemistry  #
; #               (example: Lead Acid)                                    #
; #                                                                       #
; #               $Battery().voltage - Design voltage of the battery      #
; #               (0 - if unsupported)                                    #
; #                                                                       #
; #               $Battery().ostatus - Operational Status                 #
; #                                                                       #
; # REFERENCE:                                                            #
; #             Win32_Battery Class - http://msdn.microsoft.com/en-us/library/aa394074(VS.85).aspx
; #             CIM_Battery Class - http://msdn.microsoft.com/en-us/library/aa387189(VS.85).aspx
; #             SWbemLocator.ConnectServer Method - http://msdn.microsoft.com/en-us/library/aa393720(VS.85).aspx
; #                                                                       #
; # EXAMPLES:                                                             #
; #               /battery                                                #
; #               [[Battery Information]] Status: On AC Power Life: 100% Type: Internal Battery Chemistry: Lithium-ion Voltage: 10v Operational Status: OK
; #                                                                       #
; #                                                                       #
; #               //echo -a $battery().voltage                            #
; #                                                                       #
; #########################################################################
;Color Aliases
Alias -l c1 return $+($chr(3),05,$$1-)
Alias -l c2 return $+($chr(3),10,$$1-)

Alias Battery {
  /* Connecting to the Win32_Battery class for battery information
  */  
  .comopen a WbemScripting.SWbemLocator
  .comclose a $com(a,connectserver,3,dispatch* b)
  .comclose b $com(b,execquery,3,bstr,Select * from Win32_Battery,dispatch* c)

  goto doAlias
  :error
  reseterror
  echo $color(info) -a * /Battery: Error
  if ($com(a)) .comclose $v1
  if ($com(b)) .comclose $v1
  if ($com(c)) .comclose $v1
  return
  :doAlias

  if ($isid) {
    if ($prop == status) return $Battery.BatteryStatus($comval(c, 1, BatteryStatus))
    elseif ($prop == percent) return $comval(c, 1, EstimatedChargeRemaining)
    elseif ($prop == type) return $comval(c, 1, Caption)
    elseif ($prop == chem) return $Battery.Chemistry($comval(c, 1, Chemistry))
    elseif ($prop == voltage) return $comval(c, 1, DesignVoltage)
    elseif ($prop == ostatus) return $comval(c, 1, Status)
    else {
      echo $color(info) -a * Invalid property: $Battery   
    }
    .comclose c
  }
  else {
    if ($comval(c, 0)) {
      msg $chan [[Battery Information]] $&
        $c1(Status:) $c2($Battery.BatteryStatus($comval(c, 1, BatteryStatus))) $&
        $c1(Life:) $c2($comval(c, 1, EstimatedChargeRemaining) $+ %) $&
        $c1(Type:) $c2($comval(c, 1, Caption)) $&
        $c1(Chemistry:) $c2($Battery.Chemistry($comval(c, 1, Chemistry))) $&
        $iif($comval(c, 1, DesignVoltage),$c1(Voltage:) $c2($calc($v1 / 1000) $+ v)) $&
        $c1(Operational Status:) $c2($comval(c, 1, Status))
    }
    else {
      msg $chan [[Battery Information]] $c2(No Battery Is Found.)
    }
    .comclose c
  }
}


/**
* Helper function for the battery alias
* @param BatteryStatus Code
* @return the status of the battery
*/
Alias -l Battery.BatteryStatus {
  goto $1
  :1
  return Discharging
  :2
  ;The system has access to AC so no battery is being discharged.
  ;             However, the battery is not necessarily charging.
  return On AC Power
  :3
  return Fully Charged
  :4
  return Low
  :5
  return Critical
  :6
  return Charging
  :7
  return Charging and High
  :8
  return Charging and Low
  :9
  return Charging and Critical
  :10
  return Undefined
  :11
  return Partially Charged
  :error
  echo $color(info) -a * Invalid Status Code Number: $!Battery.BatteryStatus
  reseterror
}

/**
* Helper function for the battery alias
* @param Chemistry Code
* @return the type of battery used in this computer
*/
alias -l Battery.Chemistry {
  goto $1
  :1
  return Other
  :2
  return Unknown
  :3
  return Lead Acid
  :4
  return Nickel Cadmium
  :5
  return Nickel Metal Hydride
  :6
  return Lithium-ion
  :7
  return Zinc air
  :8
  return Lithium Polymer
  echo $color(info) -a * Invalid Status Code Number: $!Battery.Chemistry
  reseterror
}

