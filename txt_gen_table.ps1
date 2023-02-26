# user may drag the file directly to the shortcut
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noprofile -file "C:\Users\henry\code\txt_gen_table.ps1"
param (
    [string]$FilePath
)

# Settings
$table_started = $false
$col1_width = 25
$col2_width = 40
$theme = 2
if ($theme -eq 1) {
	$hor_symb = "═"
	$vert_symb = "║"

	$tl_symb = '╔'
	$tm_symb =  "═"
	$tr_symb =  "╗"

	$bl_symb =  "╚"
	$bm_symb =  "═"
	$br_symb =  "╝"

	$mt_symb =  "╦"
	$ml_symb =  "╠"
	$mm_symb =  "╬"
	$mr_symb =  "╣" 
	$mb_symb =  "╩" 
}else{
	$hor_symb = "-"
	$vert_symb = "|"

	$tl_symb = '|'
	$tm_symb =  "="
	$tr_symb =  "|"

	$bl_symb =  "|"
	$bm_symb =  "="
	$br_symb =  "|"

	$mt_symb =  "="
	$ml_symb =  "|"
	$mm_symb =  "-"
	$mr_symb =  "|" 
	$mb_symb =  "=" 
}

# Process file content
$content = Get-Content $FilePath
for ($i = 0; $i -lt $content.Length; $i++) {
    $line = $content[$i]
	
	# Check for table start/end marker
    if ($line -like "*--t--*") {
        if (!$table_started) {
            $content[$i] = $tl_symb + $tm_symb*$col1_width + $mt_symb + $tm_symb*$col2_width + $tr_symb
            $table_started = $true
        } else {
            $table_started = $false
			$content[$i] = $bl_symb + $bm_symb*$col1_width + $mb_symb + $bm_symb*$col2_width + $br_symb
        }
    }
    if ($line -like "*-----*") {
        if ($table_started) {
            $table_started = $false
			$content[$i] = $bl_symb + $bm_symb*$col1_width + $mb_symb + $bm_symb*$col2_width + $br_symb
        }
    }
	# Check for table row
	elseif ($table_started) {
		 # Only process lines that is not formated
		if ($line -notlike "$vert_symb*$vert_symb") {
			$new_lines = [System.Collections.Generic.List[string]]::new()
			if ($line -like "*|*") {
				$parts = $line.Split('|').Trim()
				$part1 = $parts[0].ToString().Substring(0, [Math]::Min($col1_width, $parts[0].Length)).Trim()
				$part2 = $parts[1].ToString().Substring(0, [Math]::Min($col2_width, $parts[1].Length)).Trim()
				
				# Split parts that are too long to next line
				$remaining1 = $parts[0].ToString().Substring([Math]::Min($col1_width, $parts[0].Length)).Trim()
				$remaining2 = $parts[1].ToString().Substring([Math]::Min($col2_width, $parts[1].Length)).Trim()
 
			} else {
				# handle if the line do not have "|"
				$part1 = $line.ToString().Substring(0, [Math]::Min($col1_width, $line.Length)).Trim()
				$part2 = ""
				$remaining1 = $line.ToString().Substring([Math]::Min($col1_width, $line.Length)).Trim()
				$remaining2 = ""
			}

			# fill in the tab , to make the table looks better
			$part1_padded = $part1.PadRight($col1_width, ' ')
			$part2_padded = $part2.PadRight($col2_width, ' ')
			$new_lines.Add($vert_symb + $part1_padded + $vert_symb + $part2_padded + $vert_symb)
			
			# handle the remain part if too long 
			while (($remaining1.Length -ne 0) -or ($remaining2.Length -ne 0)) {
			    $part1 = $remaining1.ToString().Substring(0, [Math]::Min($col1_width, $remaining1.Length)).Trim()
			    $part2 = $remaining2.ToString().Substring(0, [Math]::Min($col2_width, $remaining2.Length)).Trim()	
				$remaining1 = $remaining1.ToString().Substring([Math]::Min($col1_width, $remaining1.Length)).Trim()
				$remaining2 = $remaining2.ToString().Substring([Math]::Min($col2_width, $remaining2.Length)).Trim()
			
				$part1_padded = $part1.PadRight($col1_width, ' ')
			    $part2_padded = $part2.PadRight($col2_width, ' ')
			    $new_lines.Add($vert_symb + $part1_padded + $vert_symb + $part2_padded + $vert_symb)
			}
			
			$nextline = $content[$i+1]
			
			# check next line is not the end of table
			if ($nextline -notlike "*--t--*"){
				$new_lines.Add($ml_symb + $hor_symb*$col1_width + $mm_symb + $hor_symb*$col2_width + $mr_symb)
			}
			$content[$i] = $new_lines -join "`r`n"
		}
    }
}

# put the content to the original file
Set-Content -Path $FilePath -Value $content
