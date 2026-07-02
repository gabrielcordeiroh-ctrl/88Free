-- Remove a trigger antiga se ela já existir para evitar conflitos de duplicação
DROP TRIGGER IF EXISTS trg_sincronizar_status_vaga ON public.diarias_realizadas;

-- Cria ou atualiza a função que sincroniza o status da vaga
CREATE OR REPLACE FUNCTION public.sincronizar_status_vaga_apos_match()
RETURNS TRIGGER AS $$
BEGIN
    -- Se o trabalhador foi confirmado na vaga, muda o status da vaga para 'preenchida'
    IF NEW.status_alocacao = 'confirmado' THEN
        UPDATE public.vagas
        SET status = 'preenchida'
        WHERE id = NEW.vaga_id;
    END IF;

    -- Caso no futuro uma alocação seja cancelada, a vaga volta a ficar aberta
    IF NEW.status_alocacao = 'cancelada' THEN
        UPDATE public.vagas
        SET status = 'aberta'
        WHERE id = NEW.vaga_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Cria a trigger atrelada à tabela diarias_realizadas
CREATE TRIGGER trg_sincronizar_status_vaga
AFTER INSERT OR UPDATE OF status_alocacao ON public.diarias_realizadas
FOR EACH ROW
EXECUTE FUNCTION public.sincronizar_status_vaga_apos_match();