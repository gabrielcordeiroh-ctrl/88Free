CREATE EXTENSION IF NOT EXISTS http WITH SCHEMA extensions;

-- 1. Remove a trigger antiga se ela já existir
DROP TRIGGER IF EXISTS trg_sincronizar_status_vaga ON public.diarias_realizadas;

-- 2. Garante que a função está atualizada
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

-- 3. Cria a trigger novamente do zero
CREATE TRIGGER trg_sincronizar_status_vaga
AFTER INSERT OR UPDATE OF status_alocacao ON public.diarias_realizadas
FOR EACH ROW
EXECUTE FUNCTION public.sincronizar_status_vaga_apos_match();