# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.
if ( -not ( Test-Path -Path "$env:ProgramData\Chocolatey" ) ) {
	Write-Error -Message "Chocolatey is not installed" -ErrorAction Stop
}

import-module au

$domain			= 'https://github.com'
$latest			= $domain + '/JanisEst/KeePassBrowserImporter'
$pluginName		= 'KeePassBrowserImporter'
$pluginSuffix		= 'plgx'
$regexHTMLVersion	= 'tag/v[0-9]'
$regexVersion		= '<version>'
$releases		= $latest + '/releases/download/v' + $regexVersion + '/' + $pluginName + '.' + $pluginSuffix
$regexFileType		= '\.' + $pluginSuffix
$applBits		= '32'

function global:au_SearchReplace {
	@{
		".\tools\chocolateyInstall.ps1" = @{
			"($i)(^\s*url\s*=\s*)('.*')"			= "`$1'$($Latest.URL32)'"
			"($i)(^\s*checksum\s*=\s*)('.*')"		= "`$1'$($Latest.Checksum32)'"
			"($i)(^\s*filetype\s*=\s*)('.*')"		= "`$1'$($Latest.FileType)'"
		}
	}
}

function global:au_GetLatest {
	$myFuncName = $MyInvocation.MyCommand
	Write-Verbose "$($myFuncName):latest=$latest"
	$home_page = Invoke-WebRequest -Uri $latest -UseBasicParsing
	Write-Verbose "$($myFuncName):home_page=$home_page"
	Write-Verbose "$($myFuncName):regexHTMLVersion=$regexHTMLVersion"
	$p = ( "$home_page.Links".split('<').split('>') | Select-String -Pattern $regexHTMLVersion )
	Write-Verbose "$($myFuncName):p=$p"
	$version = ( ( $p -replace('^.* href=') ).split('/')[-1].split('v')[1].split('"')[0] )
	Write-Verbose "$($myFuncName):version=$version"
	Write-Verbose "$($myFuncName):releases=$releases"
	Write-Verbose "$($myFuncName):regexVersion=$regexVersion"
	$url = ( $releases.replace($regexVersion,$version) )
	Write-Verbose "$($myFuncName):url=$url"
	Write-Verbose "$($myFuncName):regexFileType=$regexFileType"
	Write-Verbose "$($myFuncName):applBits=$applBits"
	$p = "$url".split(' ') | Select-String -Pattern $regexFileType
	Write-Verbose "$($myFuncName):p=$p"
	$applName = ( (Split-Path ("$p") -leaf).split($regexFileType) )[0]
	Write-Verbose "$($myFuncName):applName=$applName"
	$filetype = ( "$p".ToUpper().split('"') -match('\.' ) )[0].split('.')[-1]
	Write-Verbose "$($myFuncName):filetype = $($filetype)"
	Write-Verbose "$($myFuncName):url = $($url)"
	Write-Verbose "$($myFuncName):version = $($version)"
	$s ="URL$applBits = '$($url)'; Version = '$($version)'; FileType = '$($filetype)';"
	Write-Verbose "$($myFuncName):s=$s"
	Invoke-Expression "@{ $s }"
}

#au_GetLatest
update
