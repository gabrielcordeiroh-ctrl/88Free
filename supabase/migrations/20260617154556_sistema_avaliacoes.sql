-- 1. Cria o tipo ENUM primeiro
CREATE TYPE public.tipo_avaliador AS ENUM ('usuario', 'estabelecimento');

-- 2. Cria a tabela que depende do ENUM acima
CREATE TABLE public.avaliacoes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    diaria_id UUID NOT NULL REFERENCES public.diarias_realizadas(id) ON DELETE CASCADE,
    
    avaliador_id UUID NOT NULL REFERENCES public.profiles(id),
    avaliado_id UUID NOT NULL REFERENCES public.profiles(id),
    
    papel_avaliador public.tipo_avaliador NOT NULL,
    
    nota INT NOT NULL CHECK (nota >= 1 AND nota <= 5),
    comentario TEXT,
    
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,

    CONSTRAINT avaliacao_unica_por_diaria UNIQUE (diaria_id, avaliador_id),
    CONSTRAINT auto_avaliacao_proibida CHECK (avaliador_id <> avaliado_id)
);