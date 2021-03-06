SELECT
	m.data_criacao
FROM
	usuarios AS u
LEFT JOIN matriculas m ON m.usuario_id = u.id
INNER JOIN pedidos b ON	m.pedido_id = b.id
INNER JOIN pedidos_itens p ON b.id = p.pedido_id
LEFT JOIN usuarios_outras_informacoes uoi ON uoi.matricula_id = m.id
LEFT JOIN usuarios_enderecos ue on ue.usuario_id = u.id
LEFT JOIN enderecos e on e.id = ue.endereco_id 
LEFT JOIN usuarios_complemento uc on uc.usuario_id = u.id
LEFT JOIN cad_estados ce on ce.id = e.estado
WHERE
	uoi.matricula_interna_instituicao IS NULL
	AND m.situacao_matricula IN (1, 6, 7)
	AND u.grupo = 1
	AND u.email NOT LIKE '%acasadoconcurseiro%'
	AND u.cpf <> ''
	AND (LENGTH(u.cpf) <= 11)
	AND m.turno_id IS NULL
	AND u.bloqueado = 0
	AND EXISTS(
	SELECT
		(1)
	FROM
		transacoes AS s
	WHERE
		(m.pedido_id = s.pedido_id)
			AND (s.transacao_status_id = 3))
ORDER BY
	m.data_criacao DESC
	limit 1