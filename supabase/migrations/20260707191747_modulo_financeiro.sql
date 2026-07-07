-- 1. Cria o tipo enum para identificar a categoria da movimentação
CREATE TYPE public.tipo_transacao AS ENUM ('entrada_diaria', 'saque', 'estorno', 'taxa');

-- 2. Cria a tabela de transações financeiras (O extrato)
CREATE TABLE public.transacoes_financeiras (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    trabalhador_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    vaga_id UUID REFERENCES public.vagas(id) ON DELETE SET NULL,
    valor NUMERIC(10, 2) NOT NULL,
    tipo public.tipo_transacao NOT NULL,
    descricao TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- 3. Habilita o RLS (Row Level Security) por segurança
ALTER TABLE public.transacoes_financeiras ENABLE ROW LEVEL SECURITY;

-- 4. Cria a política para o trabalhador ver apenas o seu próprio extrato no app
CREATE POLICY "Usuários podem ver suas próprias transações" 
ON public.transacoes_financeiras 
FOR SELECT 
USING (auth.uid() = trabalhador_id);

-- 5. Cria a função que vai injetar o dinheiro no extrato
CREATE OR REPLACE FUNCTION public.gerar_credito_diaria_concluida()
RETURNS TRIGGER AS $$
DECLARE
    v_valor_diaria NUMERIC(10, 2);
    v_estabelecimento_nome TEXT;
BEGIN
    -- Ajustado para disparar quando o status vira 'pago'
    IF NEW.status_alocacao = 'pago' AND (OLD.status_alocacao IS NULL OR OLD.status_alocacao <> 'pago') THEN
        
        SELECT v.valor_pagamento, e.razao_social 
        INTO v_valor_diaria, v_estabelecimento_nome
        FROM public.vagas v
        JOIN public.estabelecimentos e ON e.id = v.estabelecimento_id
        WHERE v.id = NEW.vaga_id;

        INSERT INTO public.transacoes_financeiras (trabalhador_id, vaga_id, valor, tipo, descricao)
        VALUES (
            NEW.trabalhador_id,
            NEW.vaga_id,
            v_valor_diaria,
            'entrada_diaria',
            'Diária concluída em ' || COALESCE(v_estabelecimento_nome, 'Estabelecimento')
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 6. Remove a trigger se ela já existir para evitar conflitos
DROP TRIGGER IF EXISTS trg_credito_diaria ON public.diarias_realizadas;

-- 7. Cria o gatilho para disparar após o update do status
CREATE TRIGGER trg_credito_diaria
    AFTER UPDATE ON public.diarias_realizadas
    FOR EACH ROW
    EXECUTE FUNCTION public.gerar_credito_diaria_concluida();