-- 1. Tabela de Perfis (Trabalhadores)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT NOT NULL,
    cpf CONSTRAINT cpf_length CHECK (char_length(cpf) = 11),
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. Tabela de Estabelecimentos (Contratantes)
CREATE TABLE IF NOT EXISTS public.estabelecimentos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    razao_social TEXT NOT NULL,
    cnpj CONSTRAINT cnpj_length CHECK (char_length(cnpj) = 14),
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

-- 5. Tabela de notificao pos match
CREATE TABLE IF NOT EXISTS public.notificacoes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    trabalhador_id UUID REFERENCES public.profiles ON DELETE CASCADE NOT NULL,
    mensagem TEXT NOT NULL,
    mensagem_lida BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);