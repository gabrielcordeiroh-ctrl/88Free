CREATE OR REPLACE FUNCTION public.aplica_taxa_48horas()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se a diferença entre o início do trabalho e o momento da criação é menor que 48 horas
    IF (NEW.data_inicio_trabalho - NOW()) < INTERVAL '48 hours' THEN
        -- Aplica o aumento de 20% no valor da diária
        NEW.valor_diaria := NEW.valor_diaria * 1.20;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- O Gatilho correspondente
CREATE OR REPLACE TRIGGER trigger_urgencia_vaga
    BEFORE INSERT ON public.vagas
    FOR EACH ROW
    EXECUTE FUNCTION public.aplica_taxa_48horas();