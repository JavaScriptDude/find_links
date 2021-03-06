# find_links - Finds any kind of link in windows 
# Usage: find_links -p <path> [-r] [-x] [-t] [-f <filter>]
# -path | -p: Path to search (required)
# -recurse | -r: recursive search
# -exec | -x: Open tsv using explorer
# -tsv | -t: Output in tsv format (tab separated)
# -filter | -f: Filter the target using optional wildcards Eg: *foo*

# Local VC: /dpool/vcmain/dev/win/ps/find_links
# Github: https://github.com/JavaScriptDude/find_links

param (
    [Alias('r')][switch]$recurse,
    [Alias('x')][switch]$exec,
    [Alias('t')][switch]$tsv,
    [Alias('f')][string]$filter,
    [Alias('p')][string]$path = $(throw "-path is required.")
)

if ($filter -eq ""){
    $filter = $false
} else {
    $filter = $filter.ToLower()
}


if ($tsv){
    [System.Collections.ArrayList]$tsv_rows = @()
    $tsv_out_name = "$($env:TEMP)\z_find_links_$(Get-Date -Format 'yyyyMMdd_HHmmss_fff').tsv"
}
function main {
    #(get-childitem ${path}) | where {$_.LinkType -eq 'HardLink' -or $_.LinkType -eq 'SymbolicLink'} | select Directory, Name, Length, LastWriteTime, LinkType, Target | ForEach-Object { processRec $_r}
    
    if ($recurse) {
        if (-not($tsv)){pc "Links found under ${path} (recursive):"}
        (get-childitem -r ${path}) | _proc_children
    } else {
        if (-not($tsv)){pc "Links found under ${path}:"}
        (get-childitem ${path}) | _proc_children
    }

    if ($tsv){
        $tsv_rows | Export-Csv -Path $tsv_out_name -Delimiter `t -NoTypeInformation
        if ($exec) {
            pc "Launching $($tsv_out_name) using explorer ..."
            explorer $tsv_out_name
            exit
        } else {
            foreach($line in Get-Content $tsv_out_name) {pc $line}
            Remove-Item $tsv_out_name
        }
        
    }
}

function _proc_children {
    # Note: $input represents the full pipeline
    $input | where {$_.LinkType -eq 'HardLink' -or $_.LinkType -eq 'SymbolicLink'} | select Directory, Name, Length, LastWriteTime, LinkType, Target | ForEach-Object {
        $_r = $_
        if (-not($tsv)){
            pc "$($_r.Name) ($($_r.LinkType); $($_r.Directory.FullName); $("{0:N0}" -f $_r.Length); $($_r.LastWriteTime))"
            pc " . Targets:"
        }
        $_.Target | Sort-Object | ForEach-Object {
            if ( $(_filter $_) ) {
                if ($tsv){
                    $null = $tsv_rows.Add([PSCustomObject]@{
                        File=$_r.Name
                        Dir=$_r.Directory.FullName
                        LinkType=$_r.LinkType
                        Target=$_
                        Size=$_r.Length
                        LastWrite=$_r.LastWriteTime
                    })
                } else {
                    pc "   . $($_)"
                }
            }
        }
        if (-not($tsv)){
            pc ''
        }
    }
}

function _filter(){
    if ($_.Contains('$Recycle.Bin')) { return $false }
    if (-not($filter -eq $false)){
        return $_.toLower() -like $filter
    }
    return $true
}

function pc { Write-Host $args[0] }

main
