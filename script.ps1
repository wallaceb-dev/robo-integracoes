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
$ParcelasSql = Get-Content .\queries\status_parcelas_matricula.sql
$ParcelasPacoteSql = Get-Content queries\pacote_parcelas.sql
$DadosUsuarioSql = Get-Content .\queries\dados_usuario.sql

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
	$Package = Get-Content -Path .\body.json -Encoding "utf8";

	if (!(Test-Path -Path $FolderPath)) {
		New-Item -Path $FolderPath -ItemType Directory
		New-Item -Path $FilePath -ItemType File
		Add-Content -Path $FilePath -Encoding "utf8" -Value 'ID_MATRICULA;ID_USUARIO;DATA_HORA;MATRIX;PACOTE;RETORNO_WS'
	}

	if (!(Test-Path $FilePath -PathType Leaf)) {
		New-Item -Path $FilePath -ItemType File
		Add-Content -Path $FilePath -Encoding "utf8" -Value 'ID_MATRICULA;ID_USUARIO;DATA_HORA;MATRIX;PACOTE;RETORNO_WS'
	}

	Add-Content -Path $FilePath -Encoding "utf8" -Value "$($MatriculaId);$($UsuarioId);$($DataHora);https://matrix.pucrs.br/usuarios/$($UsuarioId)/edit;$($Package);$($RetornoWS)"

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

	}
 catch {

		if ($null -ne $_.ErrorDetails.Message) { 
			$Message = $_.ErrorDetails.Message 
		} Else { 
			$formatedBody = $Body['Json'] -replace '"', '\"'
			$formatedBody = $formatedBody -replace '/', '\/'
			$postmanBody = $postmanBody -replace '{}', $formatedBody
			Clear-Content -Path .\body.json
			Add-Content -Path .\body.json -Encoding "utf8" -Value $postmanBody
	
			$newmanResponse = newman run .\body.json --verbose | Select-String '\{"data.'

			if(([string]$newmanResponse).indexOf('[') -eq -1) {
				$newmanResponse = "$newmanResponse`"}"
			} Elseif(([string]$newmanResponse).indexOf('dv') -ge 0) {
				$newmanResponse = "$newmanResponse`}"
			} Else {
				$newmanResponse = "$newmanResponse`"]}"
			}
			
			$Message = $newmanResponse.Substring(6)

		}

		$RequestResponse = $Message | ConvertFrom-Json

		Send-LogMessage $RequestResponse.msgRetorno 'Red' ''

		Send-LogMessage "https://matrix.pucrs.br/usuarios/$($UsuarioId)/edit" 'Red' ''

		Save-LogFile $RequestResponse.cdRetorno $Message

		# $Message = if ($null -ne $_.ErrorDetails.Message) { $_.ErrorDetails.Message } Else { '{"msgRetorno":"Nao integrado. Sem motivo aparente", "cdRetorno":"000"}' }

		# $RequestResponse = $Message | ConvertFrom-Json

		# Send-LogMessage $RequestResponse.msgRetorno 'Red' ''

		# Send-LogMessage "https://matrix.pucrs.br/usuarios/$($UsuarioId)/edit" 'Red' ''

		# Save-LogFile $RequestResponse.cdRetorno $Message

	}
}

function Request-Database {

	param (
		$Query,
		$Type
	)

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
		Save-LogFile 'restricoes' '{Não há primeiro pagamento}'
		return 0;
	}
	
}

function Format-Pacote {
	# Montando pacote
	php .\php\buildJson.php

	# Resolvendo possiveis erros de encoding
	php .\php\encoding.php

	# Substituindo possiveis codigos de desconto invalidos
	php .\php\codigoDesconto208.php
}

function Request-Integracao {

	param (
		$UsuarioId
	)

	Format-Pacote

	Request-Api

}

Send-LogMessage "`tINTEGRAR MATRICULAS DE ALUNOS" 'Green' ''
Send-LogMessage "`tInsira os IDs das matriculas abaixo:" 'White' ''

while (!$loopbreak) {
	$user_input = Read-Host "`n`t`tID"

	if ($user_input -ne '') {
		$data += $user_input -replace '[a-zA-z]'
	} else {
		$loopbreak = !$loopbreak;
		$total = $data.Length;
		$PIterator = 1

		foreach ($MatriculaId in $data) {
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
}
