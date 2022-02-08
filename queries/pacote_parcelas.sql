			select
			
			concat('PARCELA ', lpad(transacoes.parcela, 6, '0')) AS nuParcParceiro,
            ifnull((case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) >= (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)))) and ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0) and (transacoes.valor_desconto = 0))
            then (transacoes.valor_bruto + (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_liquido)))
            else (case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) < (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)))) and (pedidos.valor_desconto > 0) and (transacoes.valor_desconto = 0))
            then (transacoes.valor_bruto + (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_liquido)))
            else (case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) < (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)))) and ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0) and (transacoes.valor_desconto > 0) and ((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) > 0))
            then (transacoes.valor_bruto + (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_bruto)))
            else (case when (((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0) and (transacoes.valor_desconto > 0) and ((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) = 0))
            then (ws_cursos.valorcurso / transacoes.total_parcelas)
            else ((transacoes.valor_bruto + ifnull(lancamentos_financeiros.valor, 0) / pedidos_itens.parcelamento) + ((transacoes.valor_bruto + ifnull(lancamentos_financeiros.valor, 0) / pedidos_itens.parcelamento) * ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) / (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))))) end) end) end)end),0) AS vlrParcela,
            case when (motivos_descontos.codigo in (235,236,239) and pedidos_itens.parcelamento = 24) then '236'
                when (motivos_descontos.codigo in (235,236,239) and pedidos_itens.parcelamento < 24) then '239'
                when motivos_descontos.codigo is not null then motivos_descontos.codigo
                else case when matriculas.motivo_ingresso_id = 2 then '212'
                        else case when ((pedidos.valor_desconto > 0) or (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)))) then 226
                        else 0
                    end
                end
            end AS cdDesconto,
            ifnull((case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) >= pedidos.valor_desconto)
            and ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0) and (transacoes.valor_desconto = 0))
            then (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_liquido))
            else (case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) < (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)))) and (pedidos.valor_desconto > 0) and (transacoes.valor_desconto = 0))
            then (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_liquido))
            else (case when (((pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0)) < (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))))
            and ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0) and (transacoes.valor_desconto > 0))
            then (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_bruto))
            else (case when  ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0 and pedidos.valor_desconto is null and transacoes.valor_desconto = 0)
            then (transacoes.valor_bruto * ((ws_cursos.valorcurso - pedidos.valor_liquido) / pedidos.valor_liquido))
            else (case when  ((ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) > 0 and pedidos.valor_desconto >0 and transacoes.valor_desconto > 0)
            then transacoes.valor_desconto
            else (ws_cursos.valorcurso - (pedidos.valor_liquido + ifnull(lancamentos_financeiros.valor, 0))) end) end) end) end) end),0) AS vlrDesconto,
            DATE_FORMAT(transacoes.data_vencimento, '%Y-%m-%d') as dtVencimento,
            usuarios_outras_informacoes.matricula_interna_instituicao as txMatricula,
            cursos.curso_parceiro_id as cdCurso,
            transacoes.data_pagamento,
            matriculas.id as matricula_id,
            transacoes.id as transacao_id,
            pedidos.id as pedido_id,
            transacoes.total_parcelas,
            pedidos.valor_bruto,
            pedidos.valor_desconto,
            pedidos.valor_liquido,
            transacoes.valor_liquido as valor_liquido_parcela,
            transacoes.valor_desconto as valor_desconto_parcela,
            transacoes.data_remocao,
            transacoes.operador_id,
            ws_cursos.valorcurso,
            matriculas.situacao_matricula,
            transacoes.transacao_status_id,
            case when (matriculas.turno_id is null or matriculas.turno_id = '') then 'N' else 'S' end as stpresencial,
            pedidos_itens.parcelamento,
            ifnull(lancamentos_financeiros.valor, 0) juros
            
            from 
            
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
			
			matriculas.id = @matricula_id
            AND transacoes_status.id IN (1,3,6,7)
			AND transacoes.data_remocao IS NULL
			AND usuarios.email NOT LIKE '%acasadoconcurseiro%'
			AND usuarios.id NOT IN (123, 6231, 7322, 7717, 625, 626, 627, 628, 629, 1470, 1970, 2081, 1973, 1974, 1975, 1977, 1978, 2810, 2812, 2836, 2837, 2838, 2841, 2844, 2868, 2869, 2876, 3318, 3319, 3320, 3321, 3322, 3323, 3324, 3325, 3327, 3328, 3329, 1202, 3785, 6231, 6231, 7322, 7717, 5600, 31, 30067)
			AND usuarios.bloqueado = 0