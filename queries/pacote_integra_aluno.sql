SET SESSION group_concat_max_len = 1000000;	

SELECT
	CONCAT('{', 
				'\"cdCurso\":\"' , ifnull(c.curso_parceiro_id, '') , '\",' 
				'\"cdAlunoUol\":\"' , ifnull(b.id, '') , '\",' 
				'\"cdPeriodo\":\"' , (select p.cdperiodo from ws_cursos p where c.curso_parceiro_id = p.cdcurso limit 1), '\",' 
				'\"nmAluno\":\"' , ifnull(usuarios.nome, '') , '\",' 
				'\"dtMatricula\":\"' , ifnull(b.data_criacao, '') , '\",' 
				'\"txSexo\":\"' , ifnull(e.sexo, ''), '\",' 
				'\"dtNascimento\":\"' , ifnull(usuarios.data_nascimento, '') , '\",' 
				'\"tpNecessidade\":\"' , ifnull(e.portador_necessidade_especial, ''), '\",' 
				'\"txPaisNascimento\":\"' , ifnull(k.sigla2, ''), '\",' 
				'\"txUfNascimento\":\"' , ifnull(m.uf, ''), '\",' 
				'\"txCidadeNascimento\":\"' , ifnull(e.cidade, ''), '\",' 
				'\"txCpf\":\"' , ifnull(usuarios.cpf, '') , '\",' 
				'\"txRg\":\"' , ifnull(e.rg, '') , '\",' 
				'\"txRgUf\":\"' , ifnull(l.uf, '') , '\",' 
				'\"txRgOrgaoEmissor\":\"' , ifnull(j.sigla, '') , '\",' 
				'\"txPassaporte\":\"' , ifnull(e.passaporte, ''), '\",' 
				'\"dtPassaporte\":\"' , case when e.passaporte_data_validade = '0000-00-00' OR e.passaporte_data_validade = '' OR e.passaporte_data_validade IS NULL then curdate() else e.passaporte_data_validade END, '\",' 
				'\"nmMae\":\"' , ifnull(e.mae_nome, '') , '\",' 
				'\"nmPai\":\"' , ifnull(e.pai_nome, '') , '\",' 
				'\"txCep\":\"' , ifnull(g.cep, '') , '\",' 
				'\"txCidade\":\"' , ifnull(g.cidade, '') , '\",' 
				'\"txBairro\":\"' , ifnull(g.bairro, '') , '\",' 
				'\"txLogradouro\":\"', ifnull(g.logradouro, '') , '\",' 
				'\"txNumero\":\"' , ifnull(g.numero, '') , '\",' 
				'\"txComplemento\":\"' , case when g.complemento = '' or g.complemento is null then 'Não Informado' else g.complemento end, '\",' 
				'\"txUf\":\"' , ifnull(n.uf, '') , '\",' 
				'\"txEmail\":\"' , ifnull(usuarios.email, '') , '\",' 
				'\"txDddTelefone\":\"' , (case when (length(ifnull(usuarios.telefone, '')) >= 10) then left(usuarios.telefone, 2) else '' end), '\",' 
				'\"txTelefone\":\"' , (
									CASE WHEN (length(ifnull(usuarios.telefone, '')) = 10) 
											THEN 
											RIGHT(usuarios.telefone, 8)
											ELSE (
											CASE WHEN (length(usuarios.telefone) = 11) 
													then right(usuarios.telefone, 9)
													else ''
													END
											)
										END
								), '\",' 
				'\"txDddCelular\":\"' , (case when (length(ifnull(usuarios.celular, '')) >= 10) then left(usuarios.celular, 2) else (case when (length(ifnull(usuarios.telefone, '')) >= 10) then left(usuarios.telefone, 2) else '' end) end), '\",' 
				'\"txCelular\":\"' , (case when (length(ifnull(usuarios.celular, '')) = 10) then right(usuarios.celular, 8) else (case when (length(usuarios.celular) = 11) then right(usuarios.celular, 9) else (case when (length(ifnull(usuarios.telefone, '')) = 10) then right(usuarios.telefone, 8) else (case when (length(usuarios.telefone) = 11) then right(usuarios.telefone, 9) else '' END) end) end) end), '\",' 
				'\"cdNivel\":\"' , ifnull(i.id, ''), '\",' 
				'\"txCurso\":\"' , ifnull(e.curso, ''), '\",' 
				'\"tpAluno\":\"' , 'I', '\",' 
				'\"nrAnoFormacao\":\"' , ifnull(e.ano_formacao, ''), '\",' 
				'\"cdInstituicao\":\"' , ifnull(e.instituicao_id, ''), '\",') AS JSON
FROM

	usuarios
	
INNER JOIN matriculas AS b ON usuarios.id = b.usuario_id
INNER JOIN cursos AS c ON b.curso_id = c.id
LEFT JOIN usuarios_outras_informacoes AS d ON d.matricula_id = b.id
LEFT JOIN usuarios_complemento AS e ON usuarios.id = e.usuario_id
LEFT JOIN usuarios_enderecos AS f ON usuarios.id = f.usuario_id
LEFT JOIN enderecos AS g ON	f.endereco_id = g.id
LEFT JOIN instituicoes AS h ON e.instituicao_id = h.id
LEFT JOIN usuarios_escolaridade AS i ON	e.nivel_formacao = i.id
LEFT JOIN rg_emissores AS j ON e.rg_orgao_emissor = j.id
LEFT JOIN cad_paises AS k ON e.nacionalidade = k.id
LEFT JOIN cad_estados AS l ON e.rg_estado_emissor = l.id
LEFT JOIN cad_estados AS m ON e.estado = m.id
LEFT JOIN cad_estados AS n ON n.id = g.estado

WHERE 

b.id =  @matricula_id

AND b.situacao_matricula IN(1, 3, 5)
AND usuarios.grupo = 1
AND usuarios.email NOT LIKE '%acasadoconcurseiro%'
AND usuarios.id NOT IN(23, 6231, 7322, 7717, 625, 626, 627, 628, 629, 1470, 1970, 2081, 1973, 1974, 1975, 1977, 1978, 2810, 2812, 2836, 2837, 2838, 2841, 2844, 2868, 2869, 2876, 3318, 3319, 3320, 3321, 3322, 3323, 3324, 3325, 3327, 3328, 3329, 1202, 3785, 6231, 6231, 7322, 7717, 5600, 31, 30067)
AND b.turno_id IS NULL
AND usuarios.bloqueado = 0

UNION

SELECT

	GROUP_CONCAT('{', 
                  '\"cdCurso\":\"' , b.curso_parceiro_id , '\",' 
                  '\"cdPeriodo\":\"' , c.cdperiodo, '\",' 
                  '\"cdDisciplina\":\"' , c.cddisciplina, '\" ', 
              	 '}') AS JSON

FROM

	matriculas a

INNER JOIN cursos b ON a.curso_id = b.id
INNER JOIN ws_disciplinas c ON c.cdcurso = b.curso_parceiro_id

WHERE a.id = @matricula_id
	
UNION 

SELECT
			
	GROUP_CONCAT('{',
	  	'\"nuParcParceiro\":', concat('\"PARCELA ', lpad(transacoes.parcela, 6, '0'), '\"'),
	  	',\"vlrParcela\":', '\"', (ifnull((case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) >= (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)))) and ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0) and (transacoes.valor_desconto = 0))
							            then (transacoes.valor_bruto + (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_liquido)))
							            else (case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) < (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)))) and (pedidos.valor_desconto > 0) and (transacoes.valor_desconto = 0))
							            then (transacoes.valor_bruto + (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_liquido)))
							            else (case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) < (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)))) and ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0) and (transacoes.valor_desconto > 0) and ((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) > 0))
							            then (transacoes.valor_bruto + (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_bruto)))
							            else (case when (((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0) and (transacoes.valor_desconto > 0) and ((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) = 0))
							            then (ws_cursos.valorcurso / transacoes.total_parcelas)
							            else ((transacoes.valor_bruto + ifnull(lancamentos_financeiros.valor, 0) / pedidos_itens.parcelamento) + ((transacoes.valor_bruto + ifnull(lancamentos_financeiros.valor, 0) / pedidos_itens.parcelamento) * ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) / (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))))) end) end) end)end),0)), '\"',
		',\"cdDesconto\":', '\"', (case when (motivos_descontos.codigo in (235,236,239) and pedidos_itens.parcelamento = 24) then '236'
				                when (motivos_descontos.codigo in (235,236,239) and pedidos_itens.parcelamento < 24) then '239'
				                when motivos_descontos.codigo is not null then motivos_descontos.codigo
				                else case when matriculas.motivo_ingresso_id = 2 then '212'
				                        else case when ((pedidos.valor_desconto > 0) or (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)))) then 226
				                        else 0
				                    end
				                end
				            end), '\"',
		',\"vlrDesconto\":', '\"', (ifnull((case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) >= pedidos.valor_desconto)
							            and ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0) and (transacoes.valor_desconto = 0))
							            then (ABS(transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_liquido)))
							            else (case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) < (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)))) and (pedidos.valor_desconto > 0) and (transacoes.valor_desconto = 0))
							            then (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_liquido))
							            else (case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) < (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))))
							            and ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0) and (transacoes.valor_desconto > 0))
							            then (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_bruto))
							            else (case when  ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0 and pedidos.valor_desconto is null and transacoes.valor_desconto = 0)
							            then (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_liquido))
							            else (case when  ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0 and pedidos.valor_desconto >0 and transacoes.valor_desconto > 0)
							            then transacoes.valor_desconto
							            else (ABS(ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)))) end) end) end) end) end),0)), '\"',
	    ',\"dtVencimento\":', DATE_FORMAT(transacoes.data_vencimento, '\"%Y-%m-%d\"'),
	    ',\"cdDesconto2\":', '\"0\"',
	    ',\"vlrDesconto2\":', '\"0.00\"',
	    ',\"cdDesconto3\":', '\"0\"',
	    ',\"vlrDesconto3\":', '\"0.00\"',
	    ',\"cdDesconto4\":', '\"0\"',
	    ',\"vlrDesconto4\":', '\"0.00\"',
		'}') AS JSON
	    
    FROM 
    
    usuarios
 
	INNER JOIN matriculas ON usuarios.id = matriculas.usuario_id
	INNER JOIN cursos ON matriculas.curso_id = cursos.id
	LEFT JOIN usuarios_outras_informacoes ON matriculas.id = usuarios_outras_informacoes.matricula_id
	INNER JOIN transacoes ON transacoes.pedido_id = matriculas.pedido_id
	LEFT JOIN transacoes_status ON transacoes.transacao_status_id = transacoes_status.id
	LEFT JOIN pedidos ON transacoes.pedido_id = pedidos.id
	LEFT JOIN lancamentos_financeiros ON lancamentos_financeiros.reference_id = pedidos.id AND lancamentos_financeiros.reference_type like "%Pedido%"
	LEFT JOIN pedidos_itens ON pedidos_itens.pedido_id = pedidos.id
	LEFT JOIN cupons ON pedidos_itens.cupom_id = cupons.id
	LEFT JOIN motivos_descontos ON cupons.motivo_desconto_id = motivos_descontos.id
	LEFT JOIN ws_cursos ON cursos.curso_parceiro_id = ws_cursos.cdcurso
	
	WHERE 
	
	matriculas.id =  @matricula_id
	
	AND transacoes_status.id IN (1,3,6,7)
	AND transacoes.data_remocao IS NULL
	AND usuarios.email NOT LIKE '%acasadoconcurseiro%'
	AND usuarios.id NOT IN (123, 6231, 7322, 7717, 625, 626, 627, 628, 629, 1470, 1970, 2081, 1973, 1974, 1975, 1977, 1978, 2810, 2812, 2836, 2837, 2838, 2841, 2844, 2868, 2869, 2876, 3318, 3319, 3320, 3321, 3322, 3323, 3324, 3325, 3327, 3328, 3329, 1202, 3785, 6231, 6231, 7322, 7717, 5600, 31, 30067)
	AND usuarios.bloqueado = 0