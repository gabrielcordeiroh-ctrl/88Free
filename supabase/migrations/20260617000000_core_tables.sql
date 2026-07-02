-- Tabela de Funções
CREATE TABLE IF NOT EXISTS public.funcoes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nome_funcao TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Tabela de Perfis (Trabalhadores)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    cpf TEXT CONSTRAINT cpf_length CHECK (char_length(cpf) = 11) NOT NULL,
    phone TEXT NOT NULL,
    localizacao TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Tabela de Estabelecimentos (Contratantes)
CREATE TABLE IF NOT EXISTS public.estabelecimentos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    razao_social TEXT NOT NULL,
    cnpj TEXT CONSTRAINT cnpj_length CHECK (char_length(cnpj) = 14) NOT NULL,
    endereco TEXT NOT NULL,
    dono_id UUID REFERENCES auth.users ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Tabela de Vagas de Diárias
CREATE TABLE IF NOT EXISTS public.vagas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    estabelecimento_id UUID REFERENCES public.estabelecimentos ON DELETE CASCADE NOT NULL,
    funcao_id UUID REFERENCES public.funcoes ON DELETE RESTRICT NOT NULL, -- Garante que toda vaga tem função obrigatória
    data_diaria TIMESTAMPTZ NOT NULL,
    valor_pagamento NUMERIC(10, 2) NOT NULL,
    status TEXT DEFAULT 'aberta' CHECK (status IN ('aberta', 'preenchida', 'cancelada', 'concluida')),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Tabela de Diárias Realizadas (Escala/Alocação)
CREATE TABLE IF NOT EXISTS public.diarias_realizadas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    vaga_id UUID REFERENCES public.vagas ON DELETE CASCADE NOT NULL,
    trabalhador_id UUID REFERENCES public.profiles ON DELETE CASCADE NOT NULL,
    status_alocacao TEXT DEFAULT 'confirmado' CHECK (status_alocacao IN ('confirmado', 'cancelado', 'pago')),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Tabela de notificao pos match
CREATE TABLE IF NOT EXISTS public.notificacoes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    trabalhador_id UUID REFERENCES public.profiles ON DELETE CASCADE NOT NULL,
    mensagem TEXT NOT NULL,
    mensagem_lida BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);