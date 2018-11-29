#Requires -Version 2.0 
<# 
.SYNOPSIS 
    This process queries Active Directory for all enabled Windows systems and then pings each system 
 
.DESCRIPTION 
    The script is designed for multi-domain / layer environments. 
    The host runs the script and places the output to a share that traverses the layers bringing it up to the business layer.
    This allows for quick access to IP to computer name relations when needed for reporting and or troubleshooting.      
 
.EXAMPLE 
    PS C:\>IP_Helper
     
.NOTE 
    Make sure to set the Out-File location
#> 

Function IP_Helper{
    Try{
            #Get list of computers from AD
            $MyComputers=Get-ADcomputer -properties * -filter * -ErrorAction Stop | ?{$_.Operatingsystem -like "Windows*" -and $_.Enabled -eq $True} | Select -ExpandProperty Name
            #Decalre Array
            $MyArray=@()
    
            Foreach($Computer in $MyComputers){
                #Ping test
                $Results=Test-Connection $Computer -Count 1 -ea 0

                if($Results){
                    #Add IPv4 Address
                    $MyArray+="$Computer `t $($results.IPV4Address)"

                }Else{
                    #Show Ping Failure
                    $MyArray+="$Computer `t Ping Failed"

                }
              #Export to CSV
            } $MyArray | Out-File "C:\Temp\IP_Helper.csv"
        }
    Catch{

            $wshell = New-Object -ComObject Wscript.Shell
		    $wshell.Popup("Error: $($_.Exception)", 0, "Error - Script Halted", 0x0)
            
        }
}


