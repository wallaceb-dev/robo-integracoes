SELECT transacoes.transacao_status_id FROM matriculas LEFT JOIN transacoes ON transacoes.pedido_id = matriculas.pedido_id WHERE matriculas.id = @matricula_id
