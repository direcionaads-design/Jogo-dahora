# Lobisomem: Quaresma em Minas

Jogo de terror em primeira pessoa na roça mineira, feito na **Godot 4.7** com GDScript.
O roteiro completo e as regras de design estão em [`CLAUDE.md`](CLAUDE.md).

## Como abrir o projeto (passo a passo)

1. Baixe a Godot 4.7 (versão "Standard", não precisa da .NET) em https://godotengine.org/download
2. Abra a Godot. Na janela do Gerenciador de Projetos, clique em **Importar**.
3. Escolha o arquivo `project.godot` desta pasta e clique em **Importar e Editar**.
   Na primeira vez a Godot demora um pouco criando a pasta `.godot/` (ela não vai para o Git).
4. Aperte **F5** (ou o botão ▶ no canto superior direito) para rodar a cena de teste.

## Controles

| Ação | Tecla |
|---|---|
| Andar | W A S D ou setas |
| Olhar | Mouse |
| Correr | Shift (a estamina acaba) |
| Interagir | E ou clique esquerdo |
| Segurar o fôlego | Espaço (segurar) |
| Soltar o mouse | Esc (clique na janela para prender de novo) |

Para mudar teclas: **Projeto > Configurações do Projeto > Mapa de Entrada**.

## Estrutura de pastas

```
cenas/
  jogador/jogador.tscn        Mateus: corpo, cabeça, câmera e raio de interação
  ui/hud.tscn                 mira, texto "[E] ...", objetivos, legendas, barra de fôlego
  ui/pos_processamento.tscn   granulado, vinheta e cores lavadas (estilo Fears to Fathom)
  teste/cena_teste.tscn       cena para testar o jogador (casa provisória, balde, árvores)
  fases/                      as fases do jogo (fase 1 em diante)
scripts/
  autoload/jogo.gd            estado global: objetivos e mensagens (use Jogo.xxx em qualquer script)
  jogador/jogador.gd          movimento, olhar, balanço, passos, estamina, fôlego, tremor, interação
  objetos/interagivel.gd      base para qualquer objeto que se usa com o botão E
  ui/hud.gd                   liga a interface ao jogador e ao Jogo
shaders/pos_processamento.gdshader
audio/ambiente, efeitos, vozes, musica   (barramentos de áudio com os mesmos nomes)
modelos/  texturas/  dialogos/
.claude/skills/               skills de gamedev usadas pelo Claude Code
```

## O visual "low-fi"

- O 3D é desenhado em cerca de 480 px de largura e esticado com suavização:
  **Configurações do Projeto > Renderização > Scaling 3D > Scale = 0.375**. Aumente para ficar mais nítido.
- Neblina, céu nublado e saturação ficam no nó **Ambiente** (WorldEnvironment) de cada cena.
- Granulado, vinheta e o parâmetro `medo` ficam no nó **PosProcessamento > Filtro**,
  no Inspetor, em **Material > Shader Parameters**.

## Como criar um objeto interagível

1. Na cena, clique com o botão direito no nó raiz > **Adicionar Nó Filho** e procure **Interagivel**.
2. Dê a ele um filho **CollisionShape3D** (com uma forma) e um **MeshInstance3D** (o visual).
3. No Inspetor, preencha **Texto Interacao** (ex.: "Pegar a lenha").
4. Selecione o nó, vá na aba **Nó > Sinais**, dê dois cliques em `interagido` e conecte ao script da fase.
5. No script, use por exemplo `Jogo.concluir_objetivo("lenha")`.

## Para a IA do lobisomem (próximas fases)

O jogador já emite o sinal `fez_barulho(posicao, intensidade)`: 0.3 andando, 0.8 correndo
e 1.0 quando o fôlego acaba. A criatura vai escutar esse sinal. Para esconderijos e
cutscenes, use `jogador.pode_mover = false` (o fôlego continua funcionando) e
`jogador.tremer(0.6)` nos sustos.
