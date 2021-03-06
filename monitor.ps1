$postmanBody ='{
	"info": {
		"_postman_id": "bd658fe8-2953-4b6f-b263-0f3cc91071af",
		"name": "PUC-PROD",
		"schema": "https://schema.getpostman.com/json/collection/v2.0.0/collection.json"
	},
	"item": [
		{
			"name": "MATRICULA-CREATE",
			"request": {
				"auth": {
					"type": "basic",
					"basic": {
						"password": "5c22a7b4-196b-492e-b569-f3aefb842649",
						"username": "e1ae3b39-da5f-40b3-bfd5-ec3a912484cd"
					}
				},
				"method": "POST",
				"header": [
					{
						"key": "Content-Type",
						"value": "application/json"
					}
				],
				"body": {
					"mode": "raw",
					"raw": "{}"
				},
				"url": "https://webappcl.pucrs.br/ws-uol/api/academic/lato/matricula"
			},
			"response": []
		}
	]
}'
$disableLogMsg = 0
$loopbreak = 0
$data = @()
$user_input = 0	
$PacoteSql = Get-Content .\queries\pacote_integra_aluno.sql
$DadosUsuarioSql = Get-Content .\queries\dados_usuario.sql
$UltimaMatriculaDataSql = Get-Content .\queries\ultima_matricula.sql
$ListaMatriculasIntegraveisSql = Get-Content .\queries\lista_matriculas_integraveis.sql

function Send-LogMessage {

	param (
		$Message,
		$FColor,
		$BColor
	)

	if (!$disableLogMsg) {
		if ($BColor -eq '') {
			Write-Host "`n$($Message)" -ForegroundColor $($FColor)
		}
		else {
			Write-Host "`n$($Message)" -ForegroundColor $($FColor) -BackgroundColor $($BColor)
		}
	}
}

function Save-LogFile {

	param (
		$Type,
		$RetornoWS
	)

	$Data = Get-Date -Format "MM.dd.yyyy"
	$MesNumber = Get-Date -Format "MM"
	$Ano = Get-Date -Format "yyyy"
	$MesName = (Get-Culture).DateTimeFormat.GetMonthName($MesNumber)
	$DataHora = Get-Date -Format "MM.dd.yyyy HH:mm:ss"
	$LogFileName = "$($Type).csv"
	$FolderPath = ".\logs\$($Ano)\$($MesName)\$($Data)";
	$FileName = $($LogFileName)
	$FilePath = "$($FolderPath)\$($FileName)"
	$Package = Get-Content -Path .\body.json;

	if (!(Test-Path -Path $FolderPath)) {
		New-Item -Path $FolderPath -ItemType Directory
		New-Item -Path $FilePath -ItemType File
		Add-Content -Path $FilePath -Value 'ID_MATRICULA;ID_USUARIO;DATA_HORA;MATRIX;PACOTE;RETORNO_WS'
	}

	if (!(Test-Path $FilePath -PathType Leaf)) {
		New-Item -Path $FilePath -ItemType File
		Add-Content -Path $FilePath -Value 'ID_MATRICULA;ID_USUARIO;DATA_HORA;MATRIX;PACOTE;RETORNO_WS'
	}

	Add-Content -Path $FilePath -Value "$($MatriculaId);$($UsuarioId);$($DataHora);https://matrix.pucrs.br/usuarios/$($UsuarioId)/edit;$($Package);$($RetornoWS)"

}

function Request-Api {

	$user = 'e1ae3b39-da5f-40b3-bfd5-ec3a912484cd'
	$pass = '5c22a7b4-196b-492e-b569-f3aefb842649'

	$pair = "$($user):$($pass)"

	$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

	$basicAuthValue = "Basic $encodedCreds"

	$Headers = @{
		"Authorization" = $basicAuthValue;
		"Content-Type"  = 'application/json';
		"Accept"        = "application/json;odata=fullmetadata"
	}

	$Body = @{
		'Json' = Get-Content -Path .\body.json
	}

	try {

		$Response = Invoke-WebRequest -Method Post -Uri 'https://webappcl.pucrs.br/ws-uol/api/academic/lato/matricula' -Headers $Headers -Body $Body['Json']

		$RequestResponse = $Response | ConvertFrom-Json

		Send-LogMessage $RequestResponse.msgRetorno.replace('??', 'a') 'Green' ''

		Send-LogMessage "https://matrix.pucrs.br/usuarios/$($UsuarioId)/edit" 'Green' ''

		Save-LogFile $RequestResponse.cdRetorno $Response

	} catch {
		$Message = '{"cdRetorno":"postman_no_response","msgRetorno":"Nao houve retorno da API"}';
		
		if ($null -ne $_.ErrorDetails.Message) {
			$Message = $_.ErrorDetails.Message 
		} Else {
			$formatedBody = $Body['Json'] -replace '"', '\"'
			$formatedBody = $formatedBody -replace '/', '\/'
			$formatedBody = $formatedBody -replace '\?\?', '??'
			$postmanBody = $postmanBody -replace '{}', $formatedBody
			Clear-Content -Path .\body.json
			Add-Content -Path .\body.json -Value $postmanBody
	
			$newmanResponse = newman run .\body.json --verbose | Select-String '\{"data.'

			if([string]$newmanResponse) {
				if(([string]$newmanResponse).indexOf('[') -eq -1) {
					$newmanResponse = "$newmanResponse`"}"
				} Elseif(([string]$newmanResponse).indexOf('dv') -ge 0) {
					$newmanResponse = "$newmanResponse`}"
				} Else {
					$newmanResponse = "$newmanResponse`"]}"
				}
				
				$Message = $newmanResponse.Substring(6)

			}
		}

		$RequestResponse = $Message | ConvertFrom-Json

		Send-LogMessage $RequestResponse.msgRetorno 'Red' ''

		Send-LogMessage "https://matrix.pucrs.br/usuarios/$($UsuarioId)/edit" 'Red' ''

		Save-LogFile $RequestResponse.cdRetorno $Message

	}
}

function Request-Database {

	param (
		$Query,
		$Type
	)
# Write-Host $Query
	if ($Type.length -gt 0 -and $Type -ne '') {
		$Query | mysql -X | Out-File -FilePath .\xml\$($Type).xml 
		return;
	} 

	return $Query | mysql 
	
}

function Test-PrimeiroPagamento {

	$PrimeiroPagamento = php .\php\validarPrimeiroPagamento.php

	if ($PrimeiroPagamento -eq 1) { 
		return 1;
	}
 Else { 
	 	Write-Warning "Nao consta primeiro pagamento."
		Save-LogFile 'restricoes' '{N??o h?? primeiro pagamento}'
		return 0;
	}
	
}

function Format-Pacote {
	# Montando pacote
	php .\php\buildJson.php
}

function Request-Integracao {

	param (
		$UsuarioId
	)

	Format-Pacote

	Request-Api

}

function Get-Data-Atual {
	return Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

function Request-Iterador {
	$total = $matriculas.Length;
	$PIterator = 1

	foreach ($MatriculaId in $matriculas) {
		Send-LogMessage "$($PIterator)/$total - Integracao Matricula $($MatriculaId)" 'DarkGray' 'White'

		$UsuarioId = Request-Database "SET @matricula_id = $($MatriculaId); $($DadosUsuarioSql)" | Select-String -Pattern '\d'

		Request-Database "SET @matricula_id = $($MatriculaId); $($PacoteSql)" 'pacote'

		if ($(Test-PrimeiroPagamento) -ne $true) {
			$PIterator++; 
			continue 
		}

		Request-Integracao $UsuarioId
		$PIterator++;
	}
}

function Test-Ultima-Matricula {
	$UltimaMatriculaData = Get-Content .\txt\data_ultima_integracao.txt | Select-String '\d'

	if($(get-date "$UltimaMatriculaData" -format 'dd') -lt $(Get-Date -format 'dd') -or $(get-date "$UltimaMatriculaData" -format 'MM') -ne $(Get-Date -format 'MM')) {
		$UltimaMatriculaData = Get-Date -Date (Get-Date).AddMonths(-5) -Format "yyyy-MM-dd HH:mm:ss"
		Write-Host $UltimaMatriculaData
	}

	if($UltimaMatriculaData -ne $null) {
		Request-Database "SET @data_atual = '$(Get-Data-Atual)'; SET @data_ultima_matricula = '$($UltimaMatriculaData)'; $($ListaMatriculasIntegraveisSql)" 'lista_matriculas_integraveis'
		Clear-Content -Path .\txt\data_ultima_integracao.txt
		Add-Content -Path .\txt\data_ultima_integracao.txt -Value $(Get-Data-Atual)
	}	else {
		$UltimaMatriculaData = Request-Database "$($UltimaMatriculaDataSql)"
		Add-Content -Path .\txt\data_ultima_integracao.txt -Value $UltimaMatriculaData	
		Request-Database "SET @data_atual = '$(Get-Data-Atual)'; SET @data_ultima_matricula = '$($UltimaMatriculaData)'; $($ListaMatriculasIntegraveisSql)" 'lista_matriculas_integraveis'
	}
}

while(1 -ne 2) {
	Write-Host "`nRodando Robo ($(Get-Data-Atual))"

	Test-Ultima-Matricula

	$matriculas = @()
	$matriculasString = php .\php\pegar_lista_matriculas_integrar.php

	if($matriculasString.Length -gt 0) {
		$matriculasString.Split(",") | ForEach {
			$matriculas += "$_"
		 }
	
		if($matriculas -ne $null) {
			Send-LogMessage "Novas matriculas encontradas: ($($matriculas.Length))." 'DarkCyan' ''
			Request-Iterador
		}	

		Send-LogMessage "Process finalizado. Proxima verificacao em 10 min." 'DarkYellow' ''
	} else {
		Send-LogMessage "Sem novas matriculas." 'DarkYellow' ''
		Send-LogMessage "Proxima verificacao daqui 10 min." 'DarkYellow' ''
	}

	Start-Sleep -s 600
}