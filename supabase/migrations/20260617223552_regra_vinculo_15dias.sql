-- 1. Cria a função que executa a validação baseada no seu core_tables.sql
CREATE OR REPLACE FUNCTION public.check_limite_vinculo_15_dias()
RETURNS TRIGGER AS $$
DECLARE
    total_diarias INT;
    v_estabelecimento_id UUID;
BEGIN
    -- Só dispara se o contrato estiver sendo confirmado/ativado
    IF NEW.status_alocacao = 'confirmado' THEN 

        -- Descobre quem é o dono da vaga que está recebendo a alocação
        SELECT estabelecimento_id INTO v_estabelecimento_id
        FROM public.vagas
        WHERE id = NEW.vaga_id;

        -- Conta quantos dias de trabalho confirmados ou pagos o freelancer tem nesse mesmo bar nos últimos 30 dias
        SELECT COUNT(*)
        INTO total_diarias
        FROM public.diarias_realizadas dr
        JOIN public.vagas v ON dr.vaga_id = v.id
        WHERE dr.trabalhador_id = NEW.trabalhador_id
          AND v.estabelecimento_id = v_estabelecimento_id
          AND dr.status_alocacao IN ('confirmado', 'pago') 
          AND v.data_diaria >= NOW()::DATE - INTERVAL '30 days'; -- Compara DATE com DATE perfeitamente

        -- Se a contagem bater 15 diárias, impede o Match
        IF total_diarias >= 15 THEN
            RAISE EXCEPTION 'Bloqueio de Vínculo: O limite de 14 diárias em 30 dias foi atingido para este estabelecimento.';
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Cria o gatilho (Trigger) associado à sua tabela
CREATE OR REPLACE TRIGGER trigger_valida_vinculo_15_dias
    BEFORE INSERT OR UPDATE ON public.diarias_realizadas
    FOR EACH ROW
    EXECUTE FUNCTION public.check_limite_vinculo_15_dias();