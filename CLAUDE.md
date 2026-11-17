# Jogo de terror: lobisomem em Minas Gerais

Contexto completo para o Claude Code. Leia tudo antes de começar e siga a ordem das fases.

## 1. Resumo do projeto
- Jogo de terror 3D em primeira pessoa, curto (30 a 60 minutos), passado na zona rural de Minas Gerais durante a quaresma.
- Folclore brasileiro: o lobisomem não é o dos filmes. É magro, de pelo preto com falhas, focinho de porco, olhos vermelhos como brasa, membros alongados e desproporcionais, orelhas longas, e anda apoiado nos cotovelos.
- Referência visual e de ritmo: **Fears to Fathom** (low-poly, câmera em primeira pessoa, cenário cotidiano, medo lento, pouca música, muito som ambiente).
- Idioma do jogo: português do Brasil, com fala mineira nos avós (ex.: "num", "uns trem", "cumprida").

## 2. Motor e configuração recomendados
- **Godot 4.x** (as skills de Godot visam a 4.7). Alternativa: continuar no navegador com three.js (existe um protótipo, ver seção 9).
- Estilo visual: texturas pequenas (64 a 256 px) com filtro "nearest", resolução interna baixa (cerca de 480 px de largura) suavizada, neblina densa verde-acinzentada, céu nublado, sombras reais, granulado animado, vinheta, cores dessaturadas, câmera com leve balanço.
- Referências do cenário (fotos de fazendas de Minas): casa branca de telhado de telha laranja e janelas azuis, flamboyant vermelho, bambuzais, morros verdes, estrada de terra vermelha com cerca de arame, curral de madeira, galpão, coqueiro, milharal, céu nublado.

## 3. Instalação (rodar na pasta do projeto)
Conferir antes com `--list`, pois os nomes vêm de repositórios da comunidade.

```bash
# 1) Ver o que será instalado
npx skills add gamedev-skills/awesome-gamedev-agent-skills --list

# 2) Opção A (tudo, 66 skills + roteador) no projeto atual
npx skills add gamedev-skills/awesome-gamedev-agent-skills --agent claude-code

# 2) Opção B (enxuta, via plugin marketplace do Claude Code)
claude plugin marketplace add gamedev-skills/awesome-gamedev-agent-skills
claude plugin install router@awesome-gamedev-agent-skills
claude plugin install godot@awesome-gamedev-agent-skills
claude plugin install disciplines@awesome-gamedev-agent-skills

# 3) Skill extra de terror para Godot (ritmo de tensão, IA sensorial, estresse)
npx skills add thedivergentai/gd-agentic-skills --skill godot-genre-horror --agent claude-code
```

Se o nome de algum plugin falhar, use `/plugin` dentro do Claude Code para ver os nomes exatos. Leia o SKILL.md de cada skill de terceiros antes de confiar nela.

Se o jogo ficar no navegador, instalar também: `threejs-scene-setup` e `threejs-gltf-loading` (do mesmo repositório).

## 4. Skills a usar e para quê
- **router**: ponto de entrada, escolhe a skill certa.
- **audio-design** e **godot-audio**: som é metade do medo (vento, cigarras, silêncio abrupto, respiração, passos, tom grave).
- **game-ai**: perseguição do lobisomem com visão e audição (ver seção 8).
- **camera-systems**: primeira pessoa, balanço, tremor.
- **game-feel**: tremor de tela, hit-stop e feedback nos sustos.
- **dialogue-systems**: diálogos com escolhas.
- **level-design**: layout da fazenda, milharal e mata, e ritmo.
- **shader-programming** e **godot-shaders**: granulado, vinheta, pixelização leve, neblina.
- **godot-3d-essentials**: iluminação, neblina, pós-processamento.
- **godot-genre-horror** (repositório thedivergentai): picos e alívios de tensão, IA sensorial, estresse.
- **input-systems**: teclado, mouse e toque.
- **performance-optimization**: manter leve, inclusive no celular.
- **save-systems**: opcional, para checkpoints.

## 5. Regras de design (valem para todas as fases)
- Ritmo: calma, aviso, tensão, susto, alívio, repetir. Nunca depender de jump scare. Mostrar o monstro aos poucos (silhueta, mãos, olhos, só no fim o focinho).
- Som guia o jogador: respiração, galhos e passos do monstro mudam de lado.
- O lobisomem nunca é mostrado inteiro e nítido, exceto breve visão no fim da fase 5.
- Sem gore explícito. Ferimentos ficam sugeridos.
- Controles: andar, olhar, interagir (um botão), correr e segurar o fôlego quando necessário.

## 6. História e personagens
**Protagonista (jogador): Mateus**, adolescente de cerca de 17 anos. Passa o fim de semana na casa dos avós na roça, durante a quaresma. A história é contada em primeira pessoa.

**Avós** (Mateus os chama de vô e vó):
- **Seu Monteiro** (vô): descreve a aparência do lobisomem. Senhor de cabelo e barba grisalhos curtos, pele morena, camisa xadrez azul-acinzentada, sem chapéu. Tem uma espingarda velha.
- **Dona Graça** (vó): fala da quaresma e de como quebrar a maldição. Dá a Mateus uma medalhinha de São Bento e usa terço e sal grosso.

**Outros:** **Lucas**, amigo vizinho e da mesma idade. **Seu Antônio**, pai de Lucas e leiteiro. **Roberto**, outro vizinho, com câmera de vigilância. **Seu Osmair**, vizinho estranho e mal-humorado que "mexe com feitiços", e é o lobisomem.

**A magia:** Osmair se transforma por um livro maligno: tira a roupa, vira do avesso e rola num lugar onde um animal se deitou (a clareira onde o gado deita). Para quebrar o feitiço é preciso **desvirar a roupa dele**.

## 7. Fases (roteiro completo)
**Fase 0, chegada (tarde de sexta):** Mateus chega de carro com os pais, diz que passará o fim de semana. Vô e vó o recebem, a vó faz bolinhos de chuva. A primeira noite é tranquila, só exploração e clima caseiro (grilos, estrelas). A vó comenta de passagem que é quaresma ("nada de carne hoje").

**Fase 1, tarefas com o vô (manhã de sábado):** pegar o balde de milho na varanda, alimentar as galinhas (seis no galinheiro), buscar lenha, levar à cozinha e ajudar o vô no curral. Conversa no curral: Mateus debocha dizendo que lobisomem de filme é forte e nada assusta. O vô descreve o lobisomem verdadeiro (seção 1). Mateus engole seco, o som ambiente cai por um instante. O vô: "Num duvida não, ainda mais na quaresma. Tá sumindo galinha, ontem eram sete." Escolhas de fala do jogador: "Ah, vô…", "Tá falando sério?" ou ficar calado. Pistas: cachorro rosnando para o milharal, pegadas grandes e tortas perto da cerca.

**Fase 2, cozinha com a vó (fim de manhã):** ajudar a descascar mandioca, pôr a mesa. Sem sinal de celular. A vó diz que na quaresma o bicho anda solto, principalmente nas sextas, e conta que o homem tira a roupa, vira do avesso e rola onde bicho deitou. Quem desvira a roupa desfaz o feitiço, mas ninguém tem coragem de chegar perto. Ela entrega a medalha de São Bento. Sal grosso na soleira, telefone fixo com chiado.

**Fase 3A, leite na casa do seu Antônio (tarde):** o vô pede para buscar leite. Lucas e Mateus combinam a festa. Perto dali está a casa aparentemente abandonada do seu Osmair, com mato alto, mas com fumaça na chaminé. Lucas: "Aquela casa é do seu Osmair. Ele é bem estranho, quase nunca vejo ele e ele sempre está mal-humorado. Dizem que ele mexe com feitiços, mas não acredito muito nessas coisas." Os dois espiam pela janela (livro grosso, roupas penduradas, marcas de pata). Osmair aparece de repente, olhos amarelados por um instante: "Saiam daí da minha casa, moleques!" Fogem correndo.

**Fase 3B, conversa dos vizinhos (fim de tarde, varanda do vô):** seu Monteiro, seu Antônio e Roberto. Seu Antônio perdeu um bezerro, morto com mordidas e arranhões. Roberto perdeu galinhas. Seu Antônio suspeita de onça. Seu Monteiro fala em lobisomem e seu Antônio chama de bobagem. Roberto mostra a imagem borrada da câmera: silhueta alta e torta de braços compridos. Seu Antônio, com medo: "deve ser javali". Seu Monteiro: "Javali não anda de pé." Silêncio.

**Fase 4, a festa (noite de sábado):** os avós pedem que Mateus não vá por causa da quaresma, ele vai mesmo assim com Lucas. Na festa: forró (minigame de ritmo sem punição), pastelzinho de milho e canjica, sanfona e luz amarela. Detalhe opcional: silhueta parada na estrada, que some quando se tenta focar. Na volta riem da festa até Lucas ter vontade de ir ao banheiro e entrar no milharal.

**Fase 5, o milharal:** Mateus espera na estrada, o som some aos poucos, vem cheiro forte de carniça e barulhos no mato. Pistas: boné de Lucas, folhas esmagadas, marcas de pata, saliva escura. Mateus encontra Lucas caído e ferido no ombro, com a criatura atrás dele (visão breve, lanterna tremendo). Começa a fuga.

**Fase 6, fuga e o tiro do vô:** corrida pelo milharal seguindo a luz da casa, a lanterna cai, a cerca de arame, o pasto aberto. O vô grita "Mateus! Abaixa!" e dá o tiro de espingarda que afugenta a criatura. Mateus chega em casa, o vô tranca a porta, a vó reza.

**Fase 7, a decisão (madrugada):** o vô repreende Mateus. Mateus insiste em resgatar Lucas. O telefone fixo: seu Antônio não atende e a polícia demora cerca de uma hora. O vô repete a regra da maldição e diz que o local do rolamento é a clareira perto do bezerro morto. Preparação: nova lanterna, saquinho de sal grosso, terço e medalha. A vó os abençoa.

**Fase 8, caminho com o vô e o ataque:** trilha com neblina, pegadas, bezerro morto. A criatura salta sobre o vô, que manda Mateus correr: "Acha as roupas e salva o Lucas!" Mateus corre, a criatura deixa o vô ferido e vai atrás dele.

**Fase 9, parte solo:** fuga pela mata e o esconderijo: Mateus entra num tronco oco atrás de uma árvore. Nesse momento o jogador **não pode se mover nem fazer barulho**, pode segurar o fôlego (barra que esgota), e se falhar é game over e a cena recomeça. A criatura passa perto, farejando, e segue adiante. Depois Mateus corre até a clareira onde o gado deita, acha as roupas do Osmair viradas do avesso e **desvira peça por peça** (ação segurada, com o monstro se aproximando). A última peça desvirada quebra o feitiço: uivo que vira grito humano, e Osmair se destransforma (mostrar de longe e de costas), inconsciente, em trapos. Mateus resgata Lucas, ferido mas vivo.

**Fase 10, amanhecer e final (domingo):** reencontro com o vô ferido no ombro, volta para casa, a vó abraça os três. Mateus liga para a polícia e para a ambulância. Na clareira só restam terra revirada, pelos pretos e as roupas desviradas, e Osmair sumiu. Na casa dele: porta aberta, cama vazia, livro sumido. Cena final na varanda: Lucas com ataduras, bem, o vô enfaixado, e o carro dos pais chega. Vô: "Dá pra dizer que agora ele acredita, né?" Mateus: "Acredito, vô." Último susto opcional: pegada comprida e torta com garras perto da cerca, e um uivo distante nos créditos.

## 8. Mecânicas a implementar
- Interação por proximidade com um botão (prompt na tela).
- Lista de objetivos no canto da tela, trocando por fase.
- Diálogos com caixa de texto e escolhas.
- Fuga: correr, tropeçar, o som do monstro indica a distância.
- Stealth: esconder-se, segurar o fôlego, game over e recomeço da cena.
- Ação segurada de "desvirar roupas".
- IA do lobisomem: patrulha, visão limitada pela neblina, audição de passos e respiração, perda de rastro.
- Checkpoint por fase.

## 9. Protótipo existente (referência)
O arquivo `fase1.html` (three.js) é um protótipo jogável da fase 1 (cenário, texturas, sombras, galinha low-poly, vô com cabelo e barba grisalhos e camisa xadrez, tarefas, diálogo do vô). Use-o como referência de layout, cores, tarefas e falas. Layout da fazenda no protótipo: casa em (0, 0) voltada para +z, galinheiro em (-9, 10), curral em (30, -14), milharal em x de -46 a -22 e z de 6 a 34, estrada de terra sinuosa em x ≈ 16.

## 10. Como começar (primeiros prompts sugeridos)
1. "Leia o CLAUDE.md e o fase1.html. Crie o projeto Godot 4 com a estrutura de pastas e o jogador em primeira pessoa."
2. "Monte a fase 1 (fazenda) com o visual descrito, usando as skills de level-design, shader-programming e audio-design."
3. "Implemente as tarefas, o diálogo do vô com escolhas e o sistema de objetivos."
4. Siga fase por fase, testando e pedindo ajustes antes de passar para a próxima.
