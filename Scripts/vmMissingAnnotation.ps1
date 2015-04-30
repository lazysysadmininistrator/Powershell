Add-PSSnapin VMware.VimAutomation.Core
 
Connect-VIServer MyvCentreServer
 
$VirtualMachines = Get-VM | Where {$_.Guest -like "*Microsoft Windows*"} | Sort Name
 
$List = @()
 
foreach($VM in $VirtualMachines) {
 
 
    If ($VM.CustomFields["Server Description"] -eq "" -OR $VM.CustomFields["Environment"] -eq "")
     {
             
            $Event = Get-VIEvent $VM.Name -Types Info | Where { $_.Gettype().Name -eq "VmBeingDeployedEvent" -or $_.Gettype().Name -eq "VmCreatedEvent" -or $_.Gettype().Name -eq "VmRegisteredEvent" -or $_.Gettype().Name -eq "VmClonedEvent"} | select UserName,CreatedTime 
            If (($Event | Measure-Object).Count -eq 0)
                {
                    $User = "Unknown"
                    $Created = "Unknown"
                }
            Else
                {
                    If ($Event.Username -eq "" -or $Event.Username -eq $null)
                        {
                            $User = "Unknown"
                        }
                    Else
                        {
                            $User = $Event.Username
                            $Created = $Event.CreatedTime
                        }
 
                }
 
            $List += @(Get-VMGuest $VM.Name | Select VM, OSFullName, State, @{Name="Owner";Expression={$User}}, @{Name="Created";Expression={$Created}})
 
        }
    else
     {
      # Custom Fields are Not Empty
     }
}
 
$list