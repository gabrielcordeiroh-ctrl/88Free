-- 1. Tabela de Perfis (Trabalhadores)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    nome_completo TEXT NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. Tabela de Estabelecimentos (Contratantes)
CREATE TABLE IF NOT EXISTS public.estabelecimentos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    razao_social TEXT NOT NULL,
    cnpj VARCHAR(14) UNIQUE NOT NULL,
    endereco TEXT NOT NULL,
    dono_id UUID REFERENCES auth.users ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. Tabela de Vagas de Diárias
CREATE TABLE IF NOT EXISTS public.vagas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    estabelecimento_id UUID REFERENCES public.estabelecimentos ON DELETE CASCADE NOT NULL,
    funcao TEXT NOT NULL,
    data_diaria DATE NOT NULL,
    valor_pagamento NUMERIC(10, 2) NOT NULL,
    status TEXT DEFAULT 'aberta' CHECK (status IN ('aberta', 'preenchida', 'cancelada', 'concluida')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 4. Tabela de Diárias Realizadas (Escala/Alocação)
CREATE TABLE IF NOT EXISTS public.diarias_realizadas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    vaga_id UUID REFERENCES public.vagas ON DELETE CASCADE NOT NULL,
    trabalhador_id UUID REFERENCES public.profiles ON DELETE CASCADE NOT NULL,
    status_alocacao TEXT DEFAULT 'confirmado' CHECK (status_alocacao IN ('confirmado', 'cancelado', 'pago')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- =========================================================================
-- REGRA ANTI-CLT: TRIGGER PARA IMPEDIR DIÁRIAS CONSECUTIVAS NO MESMO LOCAL
-- =========================================================================

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
    -- Isso evita o preenchimento de escalas que caracterizam pessoalidade e continuidade (vínculo de emprego)
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