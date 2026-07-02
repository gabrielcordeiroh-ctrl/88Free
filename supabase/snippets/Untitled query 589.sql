INSERT INTO public.vagas (estabelecimento_id, funcao_id, data_diaria, valor_pagamento)
VALUES (
    '88888888-8888-8888-8888-888888888888',
    (SELECT id FROM public.funcoes WHERE nome_funcao = 'Cozinheiro' LIMIT 1),
    NOW() + INTERVAL '30 days', -- Daqui a 4 dias (Vaga Normal)
    150.00 -- Valor Base
);