CREATE OR REPLACE FUNCTION public.check_regra_consecutiva_anti_clt()
RETURNS TRIGGER AS $$
DECLARE
    v_estabelecimento_id UUID;
    v_data_nova TIMESTAMPTZ;
BEGIN
    -- Pega os detalhes da vaga que o trabalhador está tentando assumir
    SELECT estabelecimento_id, data_diaria 
    INTO v_estabelecimento_id, v_data_nova
    FROM public.vagas
    WHERE id = NEW.vaga_id;

    -- Conta se o mesmo trabalhador já tem diárias confirmadas naquele estabelecimento num raio de 2 dias
    IF EXISTS (
        SELECT 1
        FROM public.diarias_realizadas dr
        JOIN public.vagas v ON dr.vaga_id = v.id
        WHERE dr.trabalhador_id = NEW.trabalhador_id
          AND v.estabelecimento_id = v_estabelecimento_id
          AND dr.status_alocacao = 'confirmado'
          -- Correção aqui: Extrai a quantidade de dias como número puro (DOUBLE PRECISION)
          AND ABS(EXTRACT(DAY FROM (v.data_diaria - v_data_nova))) <= 2
    ) THEN
        RAISE EXCEPTION 'Regra Anti-CLT: O trabalhador não pode realizar diárias consecutivas num intervalo menor que 2 dias no mesmo estabelecimento.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;