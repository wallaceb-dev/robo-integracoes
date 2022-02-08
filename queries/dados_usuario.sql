SELECT usuarios.id
FROM usuarios
INNER JOIN matriculas ON matriculas.usuario_id = usuarios.id
WHERE matriculas.id = @matricula_id