-- 1. Verifica se a notificação foi gerada na tabela com a mensagem correta
SELECT * FROM public.notificacoes;

-- 2. Verifica se a vaga de teste mudou automaticamente de 'aberta' para 'preenchida'
SELECT id, status FROM public.vagas WHERE id = '86ff8caa-f486-46b4-8a9b-aa3254c044b3';