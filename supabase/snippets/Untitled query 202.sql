INSERT INTO public.funcoes (nome_funcao)
VALUES ('Garçom'), ('Cozinheiro')
ON CONFLICT (nome_funcao) DO NOTHING;