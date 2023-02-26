$accessToken = "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"
$name = "henryfung0"
$email = "henryfung721@gmail.com"
# Prompt for repository name and commit message
$repoName = Read-Host "Enter the repository name"
$commitMessage = Read-Host "Enter the commit message"

# Get the file or directory path from the drag-and-drop input
$filePath = $args[0]


# Prompt for confirmation
Write-Host "Repository name: $repoName"
Write-Host "Commit message: $commitMessage"
Write-Host "File/directory path: $filePath"
$confirm = Read-Host "Do you want to continue? (Y/N)"

if ($confirm -eq "Y") {
	if ((Get-Item $filePath).PSIsContainer) {
		Set-Location -Path $filePath
	}else{
		$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
		Set-Location -Path $scriptDir
	}
	
	# Create new repository on GitHub
	$uri = "https://api.github.com/user/repos"
	$body = @{
		name = $repoName
	}
	$headers = @{
		Authorization = "Bearer $accessToken"
		"User-Agent" = "PowerShell"
	}
	
	$retry = $true
	while ($retry) {
		try {
			$response = Invoke-RestMethod -Uri $uri -Method Post -Body ($body | ConvertTo-Json) -Headers $headers
			$retry = $false
		} catch {
			$errorMessage = $_.Exception.Response.GetResponseStream().ToString()
			if ($errorMessage.Contains("name already exists on this account")) {
				$repoName = Read-Host "That repository name already exists. Please enter a different name:"
				$body.name = $repoName
			} else {
				Write-Host "An error occurred while creating the repository:`n$($_.Exception.Message)"
				$retry = $false
				break
			}
		}
	}

	# Get the URL for the new repository
	$gitUrl = $response.ssh_url

	echo $gitUrl
	pause

	# Initialize a new Git repository and add the remote
	git init
	git config --global user.email "$email"
	git config --global user.name "$name"

	pause
	git remote add origin $gitUrl
	pause
	# Add the file/directory to the repository
	git add $filePath

	# Commit the changes
	git commit -m $commitMessage

	# Push the changes to the remote repository
	git push -u origin master

	pause
}
else {
    Write-Host "Script execution cancelled."
}