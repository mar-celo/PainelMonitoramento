# Atuar como:
Arquiteto de Sistemas, Cientista de Dados e Especialista em Business Intelligence voltado para Gestão de Pessoas no Setor Público.

# Objetivo:
Solicito a reestruturação e o desmembramento do módulo geral "PFGP" do nosso aplicativo de Painel de Monitoramento | Gestão de Pessoas. O módulo único deverá ser desmembrado em 6 novos módulos independentes, correspondentes às 6 Dimensões Estratégicas estabelecidas na base de dados "plataforma_pfgp_indicadores.xlsx".

Abaixo estão as regras estruturais e de negócio de cada módulo, contendo o escopo de indicadores, links externos de referência e status de dados:

---

## 📌 ESTRUCTURA GERAL DOS 6 NOVOS MÓDULOS:

### **Módulo 1: Dimensionamento da Força de Trabalho**
- **Referência:** Dimensão 1 do arquivo "plataforma_pfgp_indicadores.xlsx"
- **Público-alvo:** Gestores estratégicos e analistas de planejamento de RH.

### **Módulo 2: Carreiras, Cargos, Progressão e Promoção**
- **Referência:** Dimensão 2 do arquivo "plataforma_pfgp_indicadores.xlsx"
- **Público-alvo:** Áreas de administração de pessoal, carreiras e desenvolvimento profissional.

### **Módulo 3: Alocação, Ambientação, Estágio Probatório e Bem-Estar**
- **Referência:** Dimensão 3 do arquivo "plataforma_pfgp_indicadores.xlsx" (Filtro = 1)
- **Regras de Negócio e Indicadores Específicos:**
  1. **Indicadores de Turnover:**
     - *Fonte:* SIAPE
     - *Status:* Dados disponíveis/obtidos
     - *Dificuldade de obtenção:* 3
  2. **Taxa de Absenteísmo:**
     - *Fonte:* SIAPE
     - *Status:* Dados disponíveis/obtidos
     - *Dificuldade de obtenção:* 2
  - **Nota Estratégica / Regra de Construção:** Para estes dois indicadores (Turnover e Absenteísmo), o sistema deve exibir uma notificação ou rótulo visual indicando: *"Regras de conceitos em fase de alinhamento entre a equipe técnica e áreas de negócio"*, estruturando os campos de fórmulas de forma flexível para atualizações breves.

### **Módulo 4: Desenvolvimento e Desempenho de Pessoas e Formação de Lideranças Públicas**
- **Referência:** Dimensão 4 do arquivo "plataforma_pfgp_indicadores.xlsx"
- **Público-alvo:** Equipes de T&D (Treinamento e Desenvolvimento) e Gestão de Desempenho.

### **Módulo 5: Remuneração, Benefícios, Reconhecimento e Recompensas Não Pecuniárias**
- **Referência:** Dimensão 5 do arquivo "plataforma_pfgp_indicadores.xlsx" (Filtro = 1)
- **Regras de Negócio e Indicadores Específicos:**
  1. **Índice de Desigualdade de Remuneração:**
     - *Fonte:* SIAPE
     - *Status:* Dados disponíveis/obtidos
     - *Dificuldade de obtenção:* 2
     - *Regra de Modelagem/Cálculo:* O cálculo deste indicador deve ser construído tomando como premissa metodológica os dois estudos produzidos sobre o tema disponíveis em:
       - `https://mar-celo.github.io/Coef_de_Gini_e_Curva_de_Lorenz/`
       - `https://mar-celo.github.io/Indice_de_Gini/`
       *(Implementar o Coeficiente de Gini e a Curva de Lorenz para a distribuição salarial).*

### **Módulo 6: Aposentação, Pensões e Desligamentos**
- **Referência:** Dimensão 6 do arquivo "plataforma_pfgp_indicadores.xlsx" (Filtro = 1)
- **Regras de Negócio e Indicadores Específicos:**
  1. **Percentual de órgãos com ações estruturadas de preparação para a inatividade**
     - *Status:* A avaliar | *Dificuldade:* 5
  2. **Percentual de assentamentos digitalizados (RPPS)**
     - *Status:* A agendar com unidade responsável | *Dificuldade:* 5
  3. **Tempo médio de tramitação e atendimento em processos de aposentadoria e pensão**
     - *Status:* A agendar com unidade responsável | *Dificuldade:* 4
  4. **Percentual de servidores com abono permanência**
     - *Fonte:* PEP / SIAPE | *Status:* Dados disponíveis/obtidos | *Dificuldade:* 2
     - *Regra de Automação:* Habilitar script/rotina de Webscraping ou integração de dados referenciando a página: `https://pep.paineis.gov.br/extensions/pep/index.html#servidores-abono`.
     - *Parâmetros de validação base:*
       - Quantidade de servidores em abono de permanência = 69.518
       - % de servidores em abono de permanência = 12,31%
  5. **Percentual de processos apoiados por fluxos digitais e automação**
     - *Status:* Mapear fonte | *Dificuldade:* 3

---

## 📋 REQUISITOS DE SAÍDA E EXECUÇÃO:

1. **Estrutura de Navegação:** Crie um menu lateral ou dashboard principal separando claramente as 6 dimensões como módulos autônomos.
2. **Tratamento de Status dos Indicadores:**
   - Indicadores com status *"Dados disponíveis/obtidos"* devem possuir cards numéricos, gráficos de tendência e filtros ativos.
   - Indicadores com status *"A avaliar"*, *"Mapear fonte"* ou *"A agendar com unidade responsável"* devem aparecer na interface no formato de "Card de Indicador Futuro/Em Construção", exibindo a respectiva nota de status e nível de dificuldade (1 a 5).
3. **Integrações Específicas:** Estruture a arquitetura do Módulo 5 prevendo cálculos estatísticos de Gini, e a arquitetura do Módulo 6 prevendo a ingestão de dados raspados (webscraping) do painel PEP.

Apresente a estrutura de páginas de cada módulo, as tabelas de banco de dados necessárias e o rascunho de layout (framework visual) para aprovação.