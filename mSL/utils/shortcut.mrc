; ############################################################################
; #  (c) 2009-2013, David Schor             [Licensed under the MIT license] #
; #                                         [See LICENSE.mrc for details.  ] #
; # SYNOPSIS:                                                                #
; #               /shortcut <location>                                       #
; #               $shortcut(<location>)                                      #
; #                                                                          #
; # DESCRIPTION:                                                             #
; #               The shortcut alias can be used to open a specific locati-  #
; #               on like the  recycle bin, admin tools, history,  even      #
; #               your  inbox in a single  command  without knowing  the     #
; #               actual  executable name or  file path on the particular    #
; #               system.                                                    #
; #                                                                          #
; # LOCATIONS:                                                               #
; #               Below are the possible locations along with their full     #
; #               name. Some locations have multiple synonyms.               #
; #                                                                          #
; #               Settings/Configs:                                          #
; #                                                                          #
; #               - User Accounts        = account/user/useraccount          #
; #               - Administrative Tools = admintool/admintools              #
; #               - System Information   = system                            #
; #               - Control Panel        = control/ctrl                      #
; #               - Scheduled Tasks      = schedule/task/tasks/cron          #
; #               - Display Settings     = display/displaysettings           #
; #               - Fonts                = font/fonts                        #
; #               - Default Location     = loc/location/locations            #
; #               - Power Options        = power/battery/poweropts           #
; #               - Notification Area    = notification/notarea              #
; #               - Credential Manager   = creds/cred/credentials            #
; #               - Get Prog/NetInstall  = netinstall/installfromnet         #
; #               - Default Programs     = defprogs/defaults                 #
; #               - Langauge Settings    = lansettings/region                #
; #               - Time And Date        = timeanddate/date/time             #
; #               - Performance Info     = performance/performanceinfo       #
; #                                                                          #
; #               Network:                                                   #
; #                                                                          #
; #               - Network Connections  = cons/netcons                      #
; #               - Windows Firewall     = firewall                          #
; #               - Network Map          = netmap/networkmap                 #
; #                                                                          #
; #               Wireless:                                                  #
; #                                                                          #
; #               - Manage Wireless Nets = wireless/wirelessnets/wnets       #
; #               - Remote Apps/Desk Con = remote/remoteapps                 #
; #               - Bluetooth            = bluetooth/blue                    #
; #               - Connect To           = connectto/connect2/connect        #
; #                                                                          #
; #               Devices:                                                   #
; #                                                                          #
; #               - Printers/Faxes       = printers/print/fax/faxes          #
; #               - Scanners             = scanner/scanners/camera/cameras   #
; #               - Keyboard Properties  = keyboard                          #
; #               - Mouse Properties     = mouse                             #
; #                                                                          #
; #               Sensors:                                                   #
; #                                                                          #
; #               - Sensors              = sensors                           #
; #               - Biometric Devices    = bio/biometric/biodevices          #
; #               - Infrared             = infrared                          #
; #                                                                          #
; #               Encryption                                                 #
; #                                                                          #
; #               - BitLocker Encryption = bitlocker/encrypt                 #
; #                                                                          #
; #               Internet:                                                  #
; #                                                                          # 
; #               - History              =  internet history                 #
; #               - Inbox (mail program) =  inbox                            #
; #               - Microsoft Network    =  msnet                            #
; #                                                                          #
; #               Speech:                                                    #
; #                                                                          #
; #               - Speech Recognition   = speechrecognition/speech          #
; #               - Text To Speech       = texttospeech/tts/t2s              #
; #                                                                          #
; #               Updates:                                                   #
; #                                                                          #
; #               - Windows Updates      = updates/update/winupdates         #
; #               - System Recovery      = recovery/sysrecover               #
; #               - Backup and Restore   = backup/bckup/restore              #
; #                                                                          #
; #               Directories:                                               #
; #                                                                          #
; #               - My Computer          = mycomputer/computer               #
; #               - My Documents         = mydocuments/mydocs/docs/documents #
; #               - HomeGroup            = homegroup/homegroups              #
; #               - Network Places       = netplaces/net                     #
; #               - Network Computers    = netcomps                          #
; #               - Program Files        = progfiles/files/progs/programs    #
; #               - Recycle Bin          = bin/recycle/recyclebin            #
; #               - Start Menu           = start/menu/startmenu              #
; #               - Temp Internet Files  = temp/internetfiles/tempi          #
; #               - Internet             = internet/web                      #
; #                                                                          #
; #               Miscellaneous:                                             #
; #                                                                          #
; #               - Show Desktop         = desktop/showdesktop               #
; #                                                                          #
; #               Games:                                                     #
; #                                                                          #
; #               - Games                = games                             #
; #                                                                          #
; #                                                                          #
; # COMPATIBILITY: This script requires at least windows vista to work.      #
; #                                                                          #
; # EXAMPLES:                                                                #
; #               /shortcut bluetooth                                        #
; #               will open the bluetooth devices dialog                     #
; #                                                                          #
; #               /shortcut desktop                                          #
; #               Will bring the desktop to front                            #
; #                                                                          #
; #               //echo -a $shortcut(ctrl)                                  #
; #               Will echo the explorer path to the control panel           #
; #                                                                          #
; ############################################################################
alias shortcut {
  if ($0 != 1) {
    echo -gtesc info * /shortcut: Invalid parameters
    halt
  }
  if (!$istok(Vista 7 8, $os, 32)) {
    echo -gtesc info * /shortcut: Relies on CLSIDs which means Windows Vista and up.
    halt
  }
  /* ensure location exists
  */
  if (!$shortcut.clsid($1)) {
    echo -gtesc info * /shortcut: Invalid Location: $1
    halt
  }
  /* return the address
  */
  if ($isid) return $shortcut.compose($shortcut.clsid($1))
  /* execute it instead
  */
  run $shortcut.compose($shortcut.clsid($1))
}
alias -l shortcut.clsid {
  goto $1
  ;====================================================
  :account | :user | :useraccount
  return {60632754-c523-4b62-b45c-4172da012619}
  :admintools | :admintool
  return {D20EA4E1-3957-11d2-A40B-0C5020524153}
  :system
  return {BB06C0E4-D293-4f75-8A90-CB05B6477EEE}
  :control | :ctrl
  return {21EC2020-3AEA-1069-A2DD-08002b30309d}
  :tasks | :task | :cron | :schedule
  return {D6277990-4C6A-11CF-8D87-00AA0060F5BF}
  :display | :displaysettings | :displays
  return {C555438B-3C23-4769-A71F-B6D3D9B6053A}
  :font | :fonts
  return {D20EA4E1-3957-11d2-A40B-0C5020524152}
  :netcons | :cons
  return {7007ACC7-3202-11D1-AAD2-00805FC1270E}
  :printers | :print | :fax | :faxes
  return {2227A280-3AEA-1069-A2DE-08002B30309D}
  :scanner | :scanners | :camera | :cameras
  return {E211B736-43FD-11D1-9EFB-0000F8757FCD}
  :loc | :location | :locations
  return {00C6D95F-329C-409a-81D7-C46C66EA7F33}
  :power | :battery | :poweropts
  return {025A5937-A6BE-4686-A844-36FE4BEC8B6D}
  :notification | :notarea | :notifications
  return {05d7b0f4-2121-4eff-bf6b-ed3f69b894d9}
  :creds | :cred | :credentials
  return {1206F5F1-0569-412C-8FEC-3204630DFB70}
  :netinstall | :installfromnet
  return {15eae92e-f17a-4431-9f28-805e482dafd4}
  :defprogs | :defaultprograms | :defaults
  return {17cd9488-1228-4b2f-88ce-4298e93e0966}
  :firewall
  return {4026492F-2F69-46B8-B9BF-5654FC07E423}
  :lansettings | :region
  return {62D8ED13-C9D0-4CE8-A914-47DD628FB1B0}
  :timeanddate | :date | :time
  return {E2E7934B-DCE5-43C4-9576-7FE4F75E7480}
  :performance | :performanceinfo
  return {78F3955E-3B90-4184-BD14-5397C15F1EFC}

  :speech | :speechrecognition
  return {58E3C745-D971-4081-9034-86E34B30836A}
  :tts | :texttospeech | :t2s
  return {D17D1D6D-CC3F-4815-8FE3-607E7D5D10B3}

  :keyboard
  return {725BE8F7-668E-4C7B-8F90-46BDB0936430}
  :mouse
  return {6C8EEC18-8D75-41B2-A177-8831D59D2D50}

  :updates | :update | :winupdates | :windowsupdates
  return {36eef7db-88ad-4e81-ad49-0e313f0c35f8} 
  :recovery | :sysrecover
  return {9FE63AFD-59CF-4419-9775-ABCC3849F861}
  :backup | :bckup | :backupandrestore | :restore
  return {B98A2BEA-7D42-4558-8BD1-832F41BAC6FD}

  :history
  return {FF393560-C2A7-11CF-BFF4-444553540000}
  :inbox
  return {00020D75-0000-0000-C000-000000000046}
  :msnet
  return {00028B00-0000-0000-C000-000000000046}

  :wireless | :wirelessnets | :wnets
  return {1FA9085F-25A2-489B-85D4-86326EEDCD87}
  :remote | :remoteapps
  return {241D7C96-F8BF-4F85-B01F-E2B043341A4B}
  :bluetooth | :blue
  return {28803F59-3A75-4058-995F-4EE5503B023C}
  :netmap | :networkmap
  return {E7DE9B1A-7533-4556-9484-B26FB486475E}
  :connect | :connect2 | :connectto
  return {38A98528-6CBF-4CA9-8DC0-B1E1D10F7B1B} 

  :sensors
  return {E9950154-C418-419e-A90A-20C5287AE24B}
  :bio | :biometric | :biodevices
  return {0142e4d0-fb7a-11dc-ba4a-000ffe7ab428}
  :infrared 
  return {A0275511-0E86-4ECA-97C2-ECD8F1221D08}

  :bitlocker | :encrypt
  return {D9EF8727-CAC2-4e60-809E-86F80A666C91}

  :mycomputer | :computer
  return {20D04FE0-3AEA-1069-A2D8-08002B30309D}
  :mydocuments | :mydocs | :docs | :documents
  return {450D8FBA-AD25-11D0-98A8-0800361B1103}
  :homegroup | :homegroups
  return {B4FB3F98-C1EA-428d-A78A-D1F5659CBA93}
  :netplaces | :net
  return {208D2C60-3AEA-1069-A2D7-08002B30309D}
  :netcomps 
  return {1f4de370-d627-11d1-ba4f-00a0c91eedba}
  :progfiles | :files | :progs | :programs
  return {7be9d83c-a729-4d97-b5a7-1b7313c39e0a}
  :bin | :recycle | :recyclebin
  return {645FF040-5081-101B-9F08-00AA002F954E}
  :start | :menu | :startmenu
  return {48e7caab-b918-4e58-a94d-505519c795dc}
  :temp | :internetfiles | :tempi
  return {7BD29E00-76C1-11CF-9DD0-00A0C9034933}
  :internet | :web
  return {BDEADF00-C265-11d0-BCED-00A0C90AB50F}
  :desktop | :showdesktop
  return {3080F90D-D7AD-11D9-BD98-0000947B0257}

  :game | :games
  return {ED228FDF-9EA8-4870-83b1-96b02CFE0D52}
  ;====================================================
  :error
  reseterror
  return
}
alias -l shortcut.compose return explorer.exe shell::: $+ $1

