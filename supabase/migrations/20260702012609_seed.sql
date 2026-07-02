-- ==========================================
-- SEED DE DADOS DE TESTE (88 FREE)
-- ==========================================

-- 1. Inserir Funções Base
INSERT INTO public.funcoes (id, nome_funcao)
VALUES 
    ('c2a5079b-ebb7-45af-b08a-633bda87c7db', 'Garçom'),
    ('bc1a2048-6f64-4044-be6a-4a1727636c99', 'Cozinheiro')
ON CONFLICT (id) DO NOTHING;

-- 2. Inserir o Usuário de Autenticação no esquema
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
VALUES (
    '00000000-0000-0000-0000-000000000000',
    '99999999-9999-9999-9999-999999999999',
    'authenticated',
    'authenticated',
    'trabalhador_teste@88free.com',
    extensions.crypt('senha123', extensions.gen_salt('bf')), -- Senha criptografada fake
    NOW(), NOW(), NOW(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Teste_Profile"}',
    NOW(), NOW(), '', '', '', ''
)
ON CONFLICT (id) DO NOTHING;

-- 3. Inserir o Profile de Teste
INSERT INTO public.profiles (id, full_name, cpf, phone, localizacao)
VALUES (
    '99999999-9999-9999-9999-999999999999', 
    'Teste_Profile', 
    '12345678901', 
    '999999999', 
    'casa_do_teste' -- Incluído conforme sua atualização
)
ON CONFLICT (id) DO NOTHING;

-- 4. Inserir o Estabelecimento de Teste
INSERT INTO public.estabelecimentos (id, razao_social, cnpj, endereco)
VALUES (
    '88888888-8888-8888-8888-888888888888', 
    'lanchonete_teste', 
    '12345678000199', 
    'Rua dos Testes, 123'
)
ON CONFLICT (id) DO NOTHING;

-- 5. Inserir Vaga Inicial Limpa para Testes
INSERT INTO public.vagas (id, estabelecimento_id, funcao_id, data_diaria, valor_pagamento, status)
VALUES (
    '86ff8caa-f486-46b4-8a9b-aa3254c044b3',
    '88888888-8888-8888-8888-888888888888',
    'c2a5079b-ebb7-45af-b08a-633bda87c7db', 
    '2026-07-02 21:54:28.650956+00',
    150.00,
    'aberta'
)
ON CONFLICT (id) DO NOTHING;