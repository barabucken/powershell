#  Connect-ExchangeOnline

$OldDomain = "tld.se"
$NewDomain = "tld.com"

$Groups = Get-DistributionGroup

$Groups | ForEach-Object {
    
    $ID = $_.PrimarySmtpAddress
    $ID = $ID -split "@"
    $ID = $ID[0]+"@"+$NewDomain
    Write-Host "Setting" $_.PrimarySmtpAddress "to" $ID
    #Set-DistributionGroup -Identity $_.PrimarySmtpAddress -PrimarySmtpAddress $ID

    $_.EmailAddresses.ToLower() |ForEach-Object{
        Write-Host "Looking at" $_
        if ($_ | Select-String "smtp"){
        Write-Host $_ "matches smtp"
            if ( $_ | Select-String $OldDomain ){
            Write-Host $_ "matches" $OldDomain
            $tmp = $_
            $tmp = $tmp -split ":"
            $tmp = $tmp[1]
            $tmp = $tmp -split "@"
            $tmp = $tmp[0]+"@"+$NewDomain
            Write-Host $_ "converted to" $tmp
                if($_ | Select-String $tmp -NotMatch){
                if($_ | Select-String "onmicrosoft.com" -NotMatch){
                    Write-Host "Adding" $tmp "to" $ID
                    #Set-DistributionGroup -Identity $ID -EmailAddresses @{Add=$tmp}
                }
                }

            }
        }
        Write-Host "Done with" $_ "`n"
    }
}
