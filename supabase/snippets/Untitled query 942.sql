-- 1. Cria o Match como 'confirmado'
INSERT INTO public.diarias_realizadas (vaga_id, trabalhador_id, status_alocacao)
VALUES (
    '86ff8caa-f486-46b4-8a9b-aa3254c044b3', 
    '99999999-9999-9999-9999-999999999999', 
    'confirmado'
);

-- 2. Finaliza a diária mudando para 'concluido' (ajustado para o masculino)
UPDATE public.diarias_realizadas
SET status_alocacao = 'concluido'
WHERE vaga_id = '86ff8caa-f486-46b4-8a9b-aa3254c044b3';