CREATE OR REPLACE FUNCTION public.check_regra_consecutiva_anti_clt()
RETURNS TRIGGER AS $$
DECLARE
    v_estabelecimento_id UUID;
    v_data_nova DATE;
    v_total_consecutivo INT;
BEGIN
    -- 1. Descobrir qual é o estabelecimento e a data da nova vaga que o trabalhador quer aceitar
    SELECT estabelecimento_id, data_diaria 
    INTO v_estabelecimento_id, v_data_nova
    FROM public.vagas 
    WHERE id = NEW.vaga_id;

    -- 2. Contar quantas diárias confirmadas o trabalhador já tem no mesmo estabelecimento nos 3 dias anteriores ou posteriores
    SELECT COUNT(*)
    INTO v_total_consecutivo
    FROM public.diarias_realizadas dr
    JOIN public.vagas v ON dr.vaga_id = v.id
    WHERE dr.trabalhador_id = NEW.trabalhador_id
      AND v.estabelecimento_id = v_estabelecimento_id
      AND dr.status_alocacao = 'confirmado'
      AND ABS(v.data_diaria - v_data_nova) <= 2; -- Bloqueia se houver diárias muito próximas no mesmo lugar

    IF v_total_consecutivo >= 2 THEN
        RAISE EXCEPTION 'Operação Bloqueada: Limite de diárias consecutivas no mesmo estabelecimento atingido (Regra Anti-CLT).';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_verificar_anti_clt
BEFORE INSERT ON public.diarias_realizadas
FOR EACH ROW
EXECUTE FUNCTION public.check_regra_consecutiva_anti_clt();