# 🎞️ Animations Script — Instruções de Instalação  
**Versão: 2.1**

## 📦 Instalação

1. **Extrair os Arquivos**  
   Extraia todo o conteúdo do arquivo `.7z` ou `.zip` para uma pasta de sua preferência.

2. **mikTeX.7z**  
   - Se você já possui o MikTeX instalado, ignore e delete a versão portátil, se desejar.
   - Se não, descompacte o arquivo na raiz do projeto 
   - A versão portátil disponibilizada contém todos os pacotes para esta versão da ferramenta.

3. **Executar o Instalador de Atalho**  
   - Vá até a pasta extraída.  
   - Execute o arquivo `install.bat` para criar um atalho na Área de Trabalho.

4. **Iniciar a Aplicação**  
   - Clique no atalho `Animation Script` na Área de Trabalho.  
   - A aplicação será iniciada sem mostrar a janela do terminal.

5. **Desinstalação**  
   - Exclua o atalho da Área de Trabalho.  
   - Para remover a aplicação por completo, delete a pasta `Animations`.

---

## 🗂️ Organização das Animações e Áudios

1. Para sequências embutidas no laudo,
    crie pastas com prefixo `Seq` dentro da pasta `Sequences`, enumeradas conforme a ordem no apêndice 
    (ex.: `Seq1`, `Seq2`, `Seq3`).

2. Dentro de cada pasta, nomeie os arquivos de imagem com o prefixo `frame`, começando do zero:  
   `frame0.jpg`, `frame1.jpg`, ..., `frame10.jpg`.  
   - Aceita `.pdf` ou `.jpg`, sendo `.pdf` prioritário em caso de conflito.  
   - Outros formatos exigem alteração no código.

3. Nomeie os áudios sincronizados com `SeqAudio` e a numeração da sequência:  
   `SeqAudio1.mp3`, `SeqAudio2.mp3`, etc.  
   - Apenas `.mp3` é suportado (outros formatos exigem alteração no código).

4. Vídeos devem ter o prefixo `Video` no formato MP4, dentro da pasta `Videos`, numerados a partir de 1:  
   `Video1.mp4`, `Video2.mp4`, etc.

5. Áudios independentes devem ter o prefixo `Audio` no formato MP3, entro da pasta `Audios`, numerados a partir de 1:  
   `Audio1.mp3`, `Audio2.mp3`, etc.

6. Documentos e arquivos devem ter o prefixo `File` no formato PDF, entro da pasta `Files`, numerados a partir de 1:  
   `File1.pdf`, `File2.pdf`, etc. `Data1.txt`, `Data2.txt`, etc,  `Sheet1.csv`, `Sheet2.csv`, etc

7. Legendas podem ser adicionadas com arquivos `.txt` dentro das respectivas pastas usando os prefixos:  
   - `SeqCaptionX.txt` para animações
   - `VideoCaptionX.txt` para Vídeos
   - `AudioCaptionX.txt` para Áudios
   - `FileCaptionX.txt`  para Documentos PDF
   - `DataCaptionX.txt`  para Dados brutos txt
   - `SheetCaptionX.txt` para Planilhas CSV

8. Caso deseje personalizar a taxa de quadros de uma sequência específica, após uma compilação, copie o arquivo
   SeqTimelineX.txt da pasta Auxs para a pasta Sequences e ajuste conforme o Exemplo.


---

## ▶️ Rodar a Ferramenta

1. Execute a ferramenta via `Animation Script`.

2. Escolha a taxa de quadros padrão (pode ser ajustada depois).

3. Aponte a **pasta raiz** contendo:
   - Pastas `Sequences` com pastas das sequências
   - `Videos`
   - `Audios`
   - `Files`  
   *(vide pasta `Example`)*

4. Após a primeira execução, será gerado o arquivo `Anime.pdf` com o resultado.

5. A ferramenta `Animate.bat` solicitará o número do laudo:
   - Digite `s` para continuar sem anexar
   - Ou digite o número de laudo para anexar automaticamente

6. Para personalizar a taxa de quadros de uma sequência:
   - Copie o arquivo `SeqTimeLineX.txt` para a raiz das animações  
   - Siga as instruções: [CTAN Animate Package](http://tug.ctan.org/macros/latex/contrib/animate/animate.pdf)

7. Ao selecionar a criptografia do APÊNDICE, visando proteção de conteúdo sensível ou sigiloso,
   esse será anexado ao Laudo e somente será acessado mediante inserção da senha definida
---

## 💡 Dicas para Produção de Sequências

1. **PotPlayer** é recomendado para extrair quadros e áudios no padrão esperado.

2. Em `/Example`, há um script `ff-samples.bat` com `ffmpeg`:
   - Basta editar o caminho do Bin do `ffmpeg` no script
   - Ele extrai a sequência completa com taxa e sensibilidade desejadas

3. Na pasta `Example`, arquivos `.odg` incluem macro útil para produção de quadros e diagramas dinâmicos.

---

## 📁 Estrutura de Pastas

```
Animations/
├── Bib/                     # Utilitários e scripts
│   ├── pdftk.exe            # Anexa e o PDF resultante, permitindo criptografia
│   ├── laudo.sty	     # Define a estrutura e modelo do PDF
│   ├── run.bat              # Executa a aplicação
│   ├── run.vbs              # Executa sem mostrar terminal
│   ├── install.vbs          # Cria o atalho com ícone
│   ├── icon.ico             # Ícone personalizado
│   ├── Animate_GUI.py       # Script principal da interface
│   ├── Tools/       	     # Pasta contendo ferramentas úteis
│   └── ...
├── README.md                # Este arquivo
├── install.bat              # Cria o atalho da Ferramenta no desktop e na raiz
├── Animete.bat  	     # Versão da ferramenta via cmd
└── Auxs/
    ├── Anime.log            # Log do LaTeX
    ├── interface_out.log    # Log da interface
    ├── SeqTimeLine1.txt     # Taxa de quadros customizada
    └── ...
```
