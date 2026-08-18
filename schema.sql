-- Schema inicial para migrar os dados do sistema RC Estética Regenerativa
-- Baseado na estrutura atual do LocalStorage em index.html
-- Objetivo: equivaler ao estado atual do negócio antes da refatoração para Supabase

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE produto_tipo AS ENUM ('equipamento', 'insumo');
CREATE TYPE financeiro_tipo AS ENUM ('receita', 'despesa');
CREATE TYPE agendamento_status AS ENUM ('agendado', 'concluido', 'cancelado');
CREATE TYPE usuario_papel AS ENUM ('admin', 'operador', 'viewer');

CREATE TABLE IF NOT EXISTS pacientes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome TEXT NOT NULL,
    telefone TEXT,
    email TEXT,
    observacoes TEXT,
    data_nascimento DATE,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'ativo'
);

CREATE TABLE IF NOT EXISTS fornecedores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE,
    nome TEXT NOT NULL,
    contato TEXT,
    telefone TEXT,
    email TEXT,
    observacoes TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS produtos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE,
    nome TEXT NOT NULL,
    tipo produto_tipo NOT NULL,
    custo_total NUMERIC(12,2) DEFAULT 0,
    unidades NUMERIC(12,2) DEFAULT 0,
    custo_por_uso NUMERIC(12,2) DEFAULT 0,
    estoque NUMERIC(12,2) DEFAULT 0,
    estoque_min NUMERIC(12,2) DEFAULT 0,
    reservado NUMERIC(12,2) DEFAULT 0,
    unidade_medida TEXT DEFAULT 'un',
    obs TEXT,
    fornecedor_id UUID REFERENCES fornecedores(id),
    status_compra TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS procedimentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome TEXT NOT NULL,
    duracao_min INTEGER DEFAULT 60,
    insumos JSONB DEFAULT '[]'::jsonb,
    preco_sugerido NUMERIC(12,2) DEFAULT 0,
    preco_atual NUMERIC(12,2) DEFAULT 0,
    preco_max NUMERIC(12,2) DEFAULT 0,
    obs TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS protocolos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE,
    titulo TEXT NOT NULL,
    procedimento_id UUID REFERENCES procedimentos(id),
    itens JSONB DEFAULT '[]'::jsonb,
    materiais TEXT,
    cuidados_pre TEXT,
    passos TEXT,
    cuidados_pos TEXT,
    contraindicacoes TEXT,
    intervalo_recomendado TEXT,
    duracao_min INTEGER DEFAULT 60,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS agendamentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    paciente_id UUID NOT NULL REFERENCES pacientes(id) ON DELETE CASCADE,
    procedimento_id UUID REFERENCES procedimentos(id),
    protocolo_id UUID REFERENCES protocolos(id),
    data DATE NOT NULL,
    hora TIME NOT NULL,
    valor NUMERIC(12,2) DEFAULT 0,
    status agendamento_status NOT NULL DEFAULT 'agendado',
    observacoes TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    concluido_em TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS financeiro (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data DATE NOT NULL,
    tipo financeiro_tipo NOT NULL,
    categoria TEXT NOT NULL,
    descricao TEXT NOT NULL,
    valor NUMERIC(12,2) NOT NULL DEFAULT 0,
    paciente_id UUID REFERENCES pacientes(id),
    procedimento_id UUID REFERENCES procedimentos(id),
    protocolo_id UUID REFERENCES protocolos(id),
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS compras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    data DATE NOT NULL,
    fornecedor_id UUID REFERENCES fornecedores(id),
    descricao TEXT,
    valor_total NUMERIC(12,2) NOT NULL DEFAULT 0,
    status TEXT DEFAULT 'pendente',
    observacoes TEXT,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    senha_hash TEXT,
    papel usuario_papel NOT NULL DEFAULT 'admin',
    status TEXT NOT NULL DEFAULT 'ativo',
    permissoes JSONB DEFAULT '{}'::jsonb,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS anamneses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    paciente_id UUID NOT NULL UNIQUE REFERENCES pacientes(id) ON DELETE CASCADE,
    profissao TEXT,
    endereco TEXT,
    emergencia TEXT,
    termo TEXT,
    historico_saude TEXT,
    doencas_cronicas TEXT,
    cirurgias TEXT,
    medicamentos TEXT,
    alergias TEXT,
    gestante TEXT,
    nivel_stress TEXT,
    tabagismo TEXT,
    exercicio TEXT,
    expectativa TEXT,
    queixa TEXT,
    tipo_pele TEXT,
    fototipo TEXT,
    queratose TEXT,
    sol TEXT,
    doencas_pele TEXT,
    proc_anteriores TEXT,
    homecare TEXT,
    obs TEXT,
    retorno_whatsapp TEXT,
    ficha_importada JSONB DEFAULT '{}'::jsonb,
    ficha_importada_em TIMESTAMPTZ,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS evolucoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    paciente_id UUID NOT NULL REFERENCES pacientes(id) ON DELETE CASCADE,
    protocolo_id UUID REFERENCES protocolos(id),
    data DATE NOT NULL,
    titulo TEXT,
    texto TEXT,
    fotos JSONB DEFAULT '[]'::jsonb,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS exames (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    paciente_id UUID NOT NULL REFERENCES pacientes(id) ON DELETE CASCADE,
    indicador TEXT NOT NULL,
    valor NUMERIC(12,2) NOT NULL DEFAULT 0,
    unidade TEXT,
    data DATE NOT NULL,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pacotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    codigo TEXT UNIQUE,
    nome TEXT NOT NULL,
    protocolo_id UUID REFERENCES protocolos(id),
    valor NUMERIC(12,2) DEFAULT 0,
    sessoes INTEGER DEFAULT 1,
    ativo BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS solicitacoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    paciente_id UUID REFERENCES pacientes(id),
    tipo TEXT NOT NULL,
    descricao TEXT,
    status TEXT NOT NULL DEFAULT 'aberta',
    data_abertura DATE NOT NULL DEFAULT CURRENT_DATE,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS configuracoes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chave TEXT UNIQUE NOT NULL,
    valor JSONB NOT NULL DEFAULT '{}'::jsonb,
    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pacientes_nome ON pacientes (nome);
CREATE INDEX IF NOT EXISTS idx_pacientes_telefone ON pacientes (telefone);
CREATE INDEX IF NOT EXISTS idx_produtos_tipo ON produtos (tipo);
CREATE INDEX IF NOT EXISTS idx_procedimentos_nome ON procedimentos (nome);
CREATE INDEX IF NOT EXISTS idx_protocolos_codigo ON protocolos (codigo);
CREATE INDEX IF NOT EXISTS idx_agendamentos_data ON agendamentos (data, hora);
CREATE INDEX IF NOT EXISTS idx_financeiro_data ON financeiro (data);
CREATE INDEX IF NOT EXISTS idx_financeiro_tipo ON financeiro (tipo);
CREATE INDEX IF NOT EXISTS idx_fornecedores_nome ON fornecedores (nome);
CREATE INDEX IF NOT EXISTS idx_evolucoes_paciente_data ON evolucoes (paciente_id, data DESC);
CREATE INDEX IF NOT EXISTS idx_exames_paciente_data ON exames (paciente_id, data DESC);
CREATE INDEX IF NOT EXISTS idx_pacotes_codigo ON pacotes (codigo);

-- Dados iniciais de configuração equivalentes ao objeto DB.config usado no navegador
INSERT INTO configuracoes (chave, valor) VALUES
    ('aluguel_hora', '40'::jsonb),
    ('marketing', '400'::jsonb),
    ('contador', '200'::jsonb),
    ('prolabore', '1200'::jsonb),
    ('parcela_cartao', '800'::jsonb),
    ('faculdade_mensal', '1100'::jsonb),
    ('fase_zero_pendente', '1230.98'::jsonb),
    ('link_ficha_publica', '""'::jsonb),
    ('meta_atendimentos', '20'::jsonb)
ON CONFLICT (chave) DO NOTHING;

-- Visão útil de negócio para dashboard e relatórios
CREATE OR REPLACE VIEW vw_dashboard_financeiro AS
SELECT
    data,
    tipo,
    categoria,
    SUM(valor) AS total
FROM financeiro
GROUP BY data, tipo, categoria
ORDER BY data DESC;

CREATE OR REPLACE VIEW vw_estoque_baixo AS
SELECT
    p.id,
    p.codigo,
    p.nome,
    p.estoque,
    p.estoque_min,
    p.reservado,
    (p.estoque - p.reservado) AS disponivel
FROM produtos p
WHERE p.tipo = 'insumo'
  AND p.estoque_min > 0
ORDER BY (p.estoque - p.reservado) ASC;
