# [Int]$ValeurMin = 10
[Int]$ValeurMin = (Get-Random 100) + 1 # Nombre minimum situé entre 1 et 100
# [Int]$ValeurMax = 50
[Int]$ValeurMax = $ValeurMin+(Get-Random 51) + 50 #Intervale de recherche de 50 à 100 pas
[Int]$NombreSecret = (Get-Random -minimum $ValeurMin -maximum $ValeurMax) + 1
[Int]$NombreSaisi = 0
[Int]$Essais = 0
# [Int]$EssaisMax = 7
[Int]$EssaisMax = (Get-Random 5) + 6 # Entre 6 et 10
[String]$MessageDebut = "On cherche un nombre entre $ValeurMin et $ValeurMax"
[String]$X = "" # Nombre d'essais utilisés
[String]$GraphEssais = "-"*$EssaisMax
[String]$GraphEssaisRestants


cls ; Write-Host "______________________________"
$GraphEssaisRestants = $GraphEssais
Write-Host " Essais restants : [$GraphEssaisRestants]"
# echo $NombreSecret; pause

While ($NombreSecret -ne $NombreSaisi)
	{
	$Essais = $Essais + 1
	$X = $X+"X"
	$GraphEssaisRestants = $X+$GraphEssais.remove($EssaisMax-$Essais)
	
	Write-Host "$MessageDebut"
	Write-Host -NoNewline "Essai : " #On n'indique volontairement pas le nombre d'essais de manière numérique
	$NombreSaisi = [int] (Read-Host)
	
	cls ; Write-Host "______________________________"

	If ($NombreSaisi -gt $NombreSecret) { Write-Host " Essais restants : [$GraphEssaisRestants] -> $NombreSaisi : Trop haut."}
	If ($NombreSaisi -lt $NombreSecret) { Write-Host " Essais restants : [$GraphEssaisRestants] -> $NombreSaisi : Trop bas." }   
	If ($NombreSaisi -eq $NombreSecret) { Write-Host " Essais restants : [$GraphEssaisRestants] -> Correct! (Nombre secret : $NombreSecret)" ; break}
	If ($Essais -ge $EssaisMax) { Write-Host "          Trop tard ! Nombre secret : $NombreSecret" ; break }

	}
Write-Host "Nombre d'essais : $Essais/$EssaisMax"
Write-Host ""
Write-Host "      ..."
Write-Host "            GAME"
Write-Host "                  -"
Write-Host "                     OVER"
Write-Host "                            ..."
Write-Host ""