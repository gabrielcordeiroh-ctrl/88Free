CREATE OR REPLACE FUNCTION public.aplica_taxa_urgencia_vaga()
RETURNS TRIGGER AS $$
BEGIN
    -- Se a data da diária menos o momento atual for menor que 48 horas, aplica a taxa
    IF (NEW.data_diaria - NOW()) < INTERVAL '48 hours' THEN
        -- Aumenta o valor do pagamento em 20%
        NEW.valor_pagamento := NEW.valor_pagamento * 1.20;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Gatilho disparado ANTES de salvar a vaga no banco
CREATE OR REPLACE TRIGGER trigger_urgencia_vaga
    BEFORE INSERT ON public.vagas
    FOR EACH ROW
    EXECUTE FUNCTION public.aplica_taxa_urgencia_vaga();