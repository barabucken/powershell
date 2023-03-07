#
# Skript för att ändra domän från $FromDomain till $ToDomain.
# Inloggning och primär mail ändras.
# 
# mail@domän1.se -> mail@domän1.com.
# alias skapas för mail@domän1.se, och alla alias som fanns under .se kommer kopieras till .com
# 
# Justera utkommenterat block under detta för att ställa in ditt konto som ska loggas in med.
#

<#
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName $UserName
Import-Module MSOnline
Connect-MsolService
#>

$FromDomain = "@tld.se"
$ToDomain = "@tld.com"

$Groups = Get-UnifiedGroup | Select PrimarySmtpAddress,EmailAddresses

$Groups | ForEach-Object {

    if ($_.PrimarySmtpAddress | Select-String $FromDomain){
        Write-Host $_.PrimarySmtpAddress
        $LiveID = $_.PrimarySmtpAddress -split "@"
        $LiveID = $LiveID[0]+$ToDomain
        Write-Host "Live ID is " $LiveID
        Write-Host "WindowsLiveID is " $_.PrimarySmtpAddress
      #  if(Set-UnifiedGroup -Identity $_.PrimarySmtpAddress -PrimarySmtpAddress $LiveID){
            $_.PrimarySmtpAddress = $LiveID
            Write-Host "LiveID is " + $_.PrimarySmtpAddress
      #  }

        $_.EmailAddresses.ToLower() |ForEach-Object{
        if ($_ | Select-String "smtp"){
            if ( $_ | Select-String $FromDomain ){
                if ($_ -ne "smtp:"+$LiveID.ToLower()){
                    $tmp = $_ -split "@"
                    $tmp = $tmp[0]+$ToDomain
                    if($Groups.EmailAddresses.ToLower() | Select-String $tmp -NotMatch){
                    $tmp = $tmp -split ":"
                    $tmp = $tmp[1]
                    if($tmp.ToLower() -ne $LiveID.ToLower()){
                    Write-Host "tmp is" $tmp
                   # Set-Mailbox -Identity $LiveID -EmailAddresses @{Add=$tmp}
                    }
                }
                }
            }   
        }
    }
    }
}