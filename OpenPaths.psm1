#######################
# Code by COPPERAZIDE #
#######################

$CommonPaths = Split-Path $script:MyInvocation.MyCommand.Path
$CommonPaths += "\CommonPaths.xml"

$global:p=@{}

function save {
    $p | Export-Clixml $CommonPaths
}

function addNosave($name, $path) {
    if($p.ContainsKey($name)) {
        Write-Verbose "Pathkey ""$name"" already exists." -Verbose
    } elseif (!(Test-Path $path)) {
        Write-Verbose "The specified path ""$path"" does not exist." -Verbose
    } else {
        $p.Add($name, $path)
        Set-Variable -Name $name -Value $path -Scope Global
    }
}

function renNosave($name, $newName) {
    if(!($p.ContainsKey($name))) {
        Write-Verbose "Pathkey ""$name"" does not exist." -Verbose
    } elseif($p.ContainsKey($newName)) {
        Write-Verbose "Pathkey ""$newName"" already exists." -Verbose
    } else {
        $value = $p.$name
        $p.Remove($name)
        addNosave $newName $value
    }
}

function deleteNosave($name) {
    if(!($p.ContainsKey($name))) {
        Write-Verbose "Pathkey ""$name"" cannot be removed because it does not exist." -Verbose
    } else {
        $p.Remove($name)
        Remove-Variable -Name $name -Scope Global
    }
}

function addKey{
    [CmdletBinding()]
    Param( 
        #Name of the Path Variable
        [Parameter(Mandatory=$true)]
        $name,

        #Path
        [Parameter(Mandatory=$true)]
        $path
    )

    Begin {
        addNosave $name $path
        save
    }
}

function renKey{
    [CmdletBinding()]
    Param( 
        #Name of the Path Variable
        [Parameter(Mandatory=$true)]
        $name,

        #Path
        [Parameter(Mandatory=$true)]
        $newName
    )

    Begin {
        renNosave $name $newName
        save
    }
}

function delKey{
    [CmdletBinding()]
    Param( 
        #Name of the Path Variable
        [Parameter(Mandatory=$true)]
        $name
    )

    Begin {
        deleteNosave $name $path
        save
    }       
}

function getMyPaths {
    [CmdletBinding()] Param()
    Begin {
        if (Test-Path $CommonPaths) {
            $global:p = Import-Clixml $CommonPaths

            foreach($key in $p.GetEnumerator()) { 
                Set-Variable -Name $key.name -Value $key.Value -Scope Global
            }
        } else {
            Write-Verbose "Common Paths not found." -Verbose
        }
    }
}

getMyPaths

Export-ModuleMember -Function addkey, delkey, renkey -Variable p