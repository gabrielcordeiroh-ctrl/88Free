-- Teste de exibição do usuário

SELECT 
    dr.id AS escala_id,
    p.full_name AS trabalhador,
    e.razao_social AS contratante,
    f.nome_funcao AS funcao,
    v.data_diaria,
    v.valor_pagamento,
    dr.status_alocacao,
    v.status AS status_da_vaga
FROM public.diarias_realizadas dr
JOIN public.vagas v ON dr.vaga_id = v.id
JOIN public.profiles p ON dr.trabalhador_id = p.id
JOIN public.estabelecimentos e ON v.estabelecimento_id = e.id
JOIN public.funcoes f ON v.funcao_id = f.id;