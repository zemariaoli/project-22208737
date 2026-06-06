# Trabalho Prático – Computação Móvel
## Aplicação Metro de Lisboa

### Alunos

| Nome | Número |
|--------|--------|
| Tomás Figueiredo | 22211218 |
| José Oliveira | 22208737 |

---

# Capturas de Ecrã da Aplicação

| Dashboard | 
|-----------|
| <img width="362" height="773" alt="image" src="https://github.com/user-attachments/assets/91219376-e451-4b4b-accd-00e6435dec83" /> |


| Lista de Estações |
|-------------------|
| <img width="362" height="772" alt="image" src="https://github.com/user-attachments/assets/aff61686-a604-4629-aff3-4dde37499573" /> |

| Detalhe da Estação |
|------------|
| <img width="356" height="770" alt="image" src="https://github.com/user-attachments/assets/aa62bb01-d822-4ac9-9e85-7dd59214c44e" /> |
 
| Reporte de Incidentes |
|------------|
| <img width="360" height="777" alt="image" src="https://github.com/user-attachments/assets/33122fac-a399-41d2-98b6-a5a22585a206" /> |

| Mapa de Estações |
|------------|
| <img width="360" height="770" alt="image" src="https://github.com/user-attachments/assets/6b22046a-5115-44f4-a0ec-c0149606689a" /> |

---

# Funcionalidades Implementadas

A implementação foi desenvolvida tendo por base os requisitos das duas fases do projeto e respetiva grelha de avaliação.

### Integração com API Externa
- Consumo da API disponibilizada no enunciado.
- Obtenção dinâmica das estações e respetiva informação operacional.

### Funcionamento Offline
- Persistência local dos dados obtidos através da API.
- Em ausência de ligação à Internet, a aplicação apresenta os últimos dados sincronizados e guardados localmente.

### Mapa de Estações
- Integração com Google Maps.
- Apresentação das estações através de marcadores geográficos.
- Navegação para o detalhe da estação através da seleção de um marcador.

### Localização do Utilizador
- Obtenção da localização atual do dispositivo.
- Utilização da geolocalização em diferentes áreas da aplicação.

### Distância até à Estação
- Cálculo da distância entre o utilizador e a estação selecionada.
- Apresentação da distância em metros no ecrã de detalhe.

### Tempos de Espera
- Consulta dos tempos de espera disponíveis na API.
- Organização dos tempos por cais.
- Ordenação dos tempos por proximidade da chegada.

### Reporte de Incidentes
- Formulário de registo de incidentes.
- Validação dos campos obrigatórios.
- Associação do incidente à estação selecionada.
- Atualização imediata dos dados da estação.

### Estatísticas de Incidentes
- Apresentação dos incidentes associados a cada estação.
- Cálculo e apresentação da média das avaliações dos incidentes registados.

### Interface e Experiência de Utilização
- Interface desenvolvida segundo os princípios Material Design.
- Adaptação a diferentes dimensões de ecrã.
- Utilização de componentes visuais consistentes em toda a aplicação.

---

# Arquitetura da Aplicação

A aplicação foi desenvolvida segundo uma arquitetura em camadas, promovendo a separação de responsabilidades, a reutilização de código e a facilidade de manutenção.

## Camada de Modelos (Models)

Contém as entidades de domínio da aplicação:

- Station
- IncidentReport
- WaitingTime

Estas classes representam exclusivamente os dados utilizados pela aplicação.

## Camada de Dados (Data)

Responsável pelo acesso e gestão de dados.

### MetroRepository

O repositório centraliza toda a lógica de acesso aos dados e abstrai a origem dos mesmos.

Os ecrãs da aplicação não necessitam de saber se a informação provém:
- da API;
- da base de dados local;
- ou de outra fonte.

### Data Sources

Foram utilizadas diferentes fontes de dados:

- Fonte remota para comunicação com a API;
- Fonte local para persistência de informação offline.

Esta abordagem facilita futuras alterações sem impacto na interface gráfica.

## Camada de Apresentação (Screens)

Cada funcionalidade principal encontra-se isolada no seu próprio ecrã:

- DashboardScreen
- ListScreen
- StationDetailScreen
- MapScreen
- IncidentScreen

Esta divisão torna o projeto mais organizado e facilita a evolução da aplicação.

## Gestão de Estado

Foi utilizado o package Provider para:

- Disponibilizar dependências globais;
- Partilhar dados entre ecrãs;
- Atualizar automaticamente a interface quando existem alterações aos dados.

---

# Boas Práticas Utilizadas

### Separação de Responsabilidades
A lógica de negócio encontra-se separada da interface gráfica.

### Reutilização de Componentes
Criação de widgets e métodos auxiliares para evitar duplicação de código.

### Programação Assíncrona
Utilização de FutureBuilder para operações dependentes de:
- rede;
- localização;
- carregamento de dados.

### Tratamento de Erros
Implementação de mensagens adequadas para:
- falhas de comunicação;
- ausência de Internet;
- erros de validação.

### Persistência de Dados
Armazenamento local dos dados necessários para funcionamento offline.

### Manutenção e Escalabilidade
Estrutura modular preparada para inclusão de novas funcionalidades sem alterações significativas à arquitetura existente.

---

# Autoavaliação

Tendo em consideração os requisitos implementados, a qualidade da interface, a arquitetura adotada e os resultados obtidos nos testes automáticos:

| Componente | Nota Prevista |
|------------|------------|
| Parte 2 | 17.5 / 20 |

Consideramos que a aplicação cumpre integralmente os requisitos obrigatórios e apresenta uma implementação organizada, robusta e alinhada com as boas práticas de desenvolvimento em Flutter.

---

# Vídeo de Apresentação

O vídeo demonstrativo da aplicação encontra-se disponível no seguinte endereço:

**YouTube (Não Listado):**

👉 INSERIR_LINK_YOUTUBE
