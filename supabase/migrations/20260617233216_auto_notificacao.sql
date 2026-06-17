CREATE OR REPLACE FUNCTION public.gera_notificacao_diaria()
RETURNS TRIGGER AS $$
BEGIN
    -- 1. Cenário de Contrato Aprovado
    IF NEW.status_alocacao = 'confirmado' THEN
        INSERT INTO public.notificacoes (trabalhador_id, mensagem)
        VALUES (NEW.trabalhador_id, 'Vaga aprovada, vamo trabalhar!');
    END IF;

-- 2. Cenário de Contrato Cancelado
    IF NEW.status_alocacao = 'cancelado' AND OLD.status_alocacao = 'confirmado' THEN
        INSERT INTO public.notificacoes (trabalhador_id, message)
        VALUES (NEW.trabalhador_id, 'Poxa, o estabelecimento cancelou a vaga');
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. O Gatilho que dispara a função acima
CREATE OR REPLACE TRIGGER trigger_notifica_match
    AFTER INSERT OR UPDATE ON public.diarias_realizadas
    FOR EACH ROW
    EXECUTE FUNCTION public.gera_notificacao_diaria();