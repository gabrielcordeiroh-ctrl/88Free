-- 1. Atualiza a função usando apenas as colunas que existem na sua tabela
CREATE OR REPLACE FUNCTION public.gera_notificacao_diaria()
RETURNS TRIGGER AS $$
DECLARE
    v_estabelecimento_nome TEXT;
BEGIN
    -- Cenário 1: Contrato Aprovado (Status mudou para confirmado)
    IF NEW.status_alocacao = 'confirmado' AND (OLD.status_alocacao IS NULL OR OLD.status_alocacao <> 'confirmado') THEN
        
        -- Busca o nome do estabelecimento para a mensagem
        SELECT razao_social INTO v_estabelecimento_nome 
        FROM public.estabelecimentos 
        WHERE id = (SELECT estabelecimento_id FROM public.vagas WHERE id = NEW.vaga_id);

        INSERT INTO public.notificacoes (trabalhador_id, mensagem)
        VALUES (
            NEW.trabalhador_id, 
            'Vaga aprovada na ' || COALESCE(v_estabelecimento_nome, 'Lanchonete') || ', vamo trabalhar!'
        );
    END IF;

    -- Cenário 2: Contrato Cancelado
    IF NEW.status_alocacao = 'cancelada' AND OLD.status_alocacao = 'confirmado' THEN
        INSERT INTO public.notificacoes (trabalhador_id, mensagem)
        VALUES (
            NEW.trabalhador_id, 
            'Poxa, o estabelecimento cancelou a vaga.'
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 2. Remove a trigger antiga se existir
DROP TRIGGER IF EXISTS trigger_notifica_match ON public.diarias_realizadas;

-- 3. Cria o gatilho novamente
CREATE TRIGGER trigger_notifica_match
    AFTER INSERT OR UPDATE ON public.diarias_realizadas
    FOR EACH ROW
    EXECUTE FUNCTION public.gera_notificacao_diaria();