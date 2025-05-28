# MATRIKS: Biblioteca para coprocessador aritmético de matrizes

**Matriks** é uma biblioteca em Assembly desenvolvida para facilitar a comunicação entre o processador ARM Cortex-A9 (rodando Linux) da plataforma DE1-SoC e um coprocessador aritmético para matrizes implementado na Intel FPGA em Verilog.

O coprocessador é capaz de performar operações básicas entre matrizes quadradas de n <= 5 (operações como soma, subtração, multiplicação por escalar ou outra matriz, determinante, oposta e transposta). A biblioteca possui um conjunto de funções em Assembly que permitem ao usuário enviar dados, realizar operações e receber os resultados por meio de um mapeamento de memória.

Para obter mais informações sobre o coprocessador aritmético, acesse o [repositório](https://github.com/riancmd/matrix-coprocessor-arm-cortex-a9).

## 🚀 Sumário

* [Sobre o coprocessador](#-sobre-o-coprocessador)
* [Pré-requisitos](#-pré-requisitos)
* [Como instalar?](#-como-instalar)
* [Recursos utilizados](#-recursos-utilizados)
* [Metodologia](#-metodologia)
  * [Mapeamento de memória](#-mapeamento-de-memória)
  * [Comunicação HPS-FPGA](#-comunicação-HPS-FPGA)
  * [Remoção de lixo](#-remoção-de-lixo)
  * [Criação de novas instruções na FPGA](#-as-novas-instruções)
  * [A biblioteca](#-a-biblioteca)
  * [Programa principal](#-programa-principal)
* [Testes](#testes)
  * [Como realizar testes?](#como-realizar-testes)
  * [Casos de teste](#casos-de-teste)
* [Como utilizar a biblioteca?](#como-utilizar-o-coprocessador)
* [Conclusão](#conclusão)
* [Referências](#-referências)
* [Colaboradores](#-colaboradores)

## 👨‍💻 Sobre o coprocessador
Para utilizar a biblioteca Matriks, é necessário ter o coprocessador aritmético para matrizes implementado na FPGA do kit DE1-SoC. Caso contrário, não será possível utilizá-la, pois a biblioteca depende do processamento das instruções pelo coprocessador.

O [coprocessador aritmético de matrizes](https://github.com/riancmd/matrix-coprocessor-arm-cortex-a9), desenvolvido para trabalhar em conjunto com o processador ARM Cortex A9, foi implementado em Verilog e possui toda sua documentação disponível no repositório linkado. Entretanto, junto a este repositório, há uma versão atualizada do coprocessador para trabalhar em conjunto com a biblioteca. Portanto, **a biblioteca deve ser usada junto à nova versão do coprocessador**. A versão 2.0 do coprocessador possui modificações para conserto de alguns bugs, além da adição de novos módulos para a lógica de comunicação entre o HPS (o processador) e o coprocessador na FPGA e, por fim, inserção do clock próprio da placa.

## 📄 Pré-requisitos
Para que o projeto funcione corretamente, é necessário que você tenha:

- Um **kit de desenvolvimento DE1-SoC** com FPGA Cyclone V.
- O software **Quartus Prime Lite Edition 23.1.1** instalado no seu computador.
- Uma distribui **Linux instalado e funcional no HPS** (Hard Processor System) do kit DE1-SoC.
- Conexão entre o HPS e o computador via **cabo Ethernet**.
- O **compilador GCC** já instalado no Linux do HPS (geralmente vem por padrão).

> ⚠️ Estes requisitos **devem** ser seguidos. O projeto foi desenvolvido exclusivamente para o kit DE1-SoC, cuja pinagem e arquitetura são específicas. Ele **não funciona** com outros kits ou configurações diferentes.


## 🔧 Como instalar?
### 1. Preparar o projeto

- Faça o download do projeto como arquivo `.zip` no GitHub.
- Extraia a pasta `matrix-coprocessor-arm-cortex-a9-2.0`.

### 2. Compilar no Quartus Prime

- Abra o **Quartus Prime Lite Edition**.
- Vá em **File > Open Project**.
- Navegue até a pasta extraída do projeto.
- Selecione o arquivo `soc_system.qpf` e clique em **Abrir**.
- Clique na **seta azul para a direita** ou vá em **Processing > Start Compilation** para iniciar a compilação.
- Após a compilação, vá em **Tools > Programmer**.
- Clique em **Hardware Setup** e verifique se a placa foi reconhecida.
- Carregue o arquivo `.sof` gerado.
- Clique em **Start** para programar a FPGA.

### 3. Conectar ao HPS via SSH

- Conecte o HPS ao seu computador via **cabo Ethernet**.
- Verifique o IP da placa (disponível na sua placa).
- Abra o terminal no seu computador.
- Utilize o comando SSH para acessar o HPS:
  - `ssh <seu_usuario>@<ip_do_hps>`

### 4. Transferir os arquivos para o HPS

- Certifique-se de que a pasta `src` (com `main.c` e `makefile`) e a pasta `lib` estão organizadas corretamente.
- Use um dos métodos abaixo para transferir os arquivos para o HPS:

#### Opção 1: Pelo terminal (Linux/macOS/WSL)

- Acesse o terminal no seu computador.
- Use o comando `scp` para copiar os arquivos:
  - `scp -r src lib <seu_usuario>@<ip_do_hps>:~/`

#### Opção 2: Pelo gerenciador de arquivos

- No **Linux**:
  - Abra o gerenciador de arquivos.
  - Acesse `sftp://<seu_usuario>@<ip_do_hps>` e copie os arquivos.
- No **Windows**:
  - Use programas como **WinSCP** ou **FileZilla** para realizar a transferência via SFTP.

### 5. Compilar e rodar no HPS

- Acesse o terminal do HPS via SSH.
- Navegue até a pasta `src` onde está o `makefile`.
- Compile o projeto com o comando `make compile`.
- Execute o programa com o comando `make run`.
- Siga as instruções do terminal para escolher a operação, o tamanho da matriz e digitar seus elementos.


## 📦 Recursos utilizados
### 🧩 Placa DE1-SoC

A placa DE1-SoC, baseada no SoC Cyclone V, integra um sistema de processador (HPS) com uma FPGA, permitindo projetos embarcados que combinam software e hardware dedicados.

[Manual da placa - Intel](https://www.intel.com/content/www/us/en/developer/articles/technical/fpga-academic-boards.html)

### 🛠️ Quartus Prime Lite (versões 20.1 e 23.1)

Ferramenta oficial da Intel para desenvolvimento com FPGAs. Permite a criação de circuitos digitais usando linguagens como Verilog e VHDL, com suporte a simulação, análise e programação das placas.

[Site Oficial do Software](https://www.intel.com.br/content/www/br/pt/products/details/fpga/development-tools/quartus-prime.html)

### 🐧 Sistema Linux no HPS (CORRIGIRRRRRR distribuição)

O sistema operacional Linux no HPS é responsável por rodar o programa que interage com o coprocessador implementado na FPGA através da biblioteca Assembly.

---

## 🔨 Metodologia


## 🗺 Mapeamento de memória


## 🗣 Comunicação HPS-FPGA


## 🚮 Remoção de lixo


## 👩‍💻 Criação de novas instruções na FPGA


## 📚 A biblioteca


## 💻 Programa principal


## Testes


## Como realizar testes?


## Casos de teste


## Como utilizar a biblioteca?


## Conclusão


## 📚 Referências
* Patterson, D. A. ; Hennessy, J. L. 2016. Morgan Kaufmann Publishers. Computer organization and design: ARM edition. 5ª edição.

* INTEL CORPORATION. Intel 8087 Numeric Data Processor: User’s Manual. Disponível em: https://datasheets.chipdb.org/Intel/x86/808x/datashts/8087/205835-007.pdf. 

* REFERENCIA DO ASSEMBLY Q ESQUECI O LINK

* REFERENCIA DO QSYS COLCOAR LINK

* REFERENCIA DO PIO COLOCAR LINK

* REFERENCIA DO C COLOCAR LINK

* REFERENCIA DO ARMV7 ASSEMBLY LINK

## 👥 Colaboradores
* **Rian da Silva Santos** -  [Rian](https://github.com/riancmd)
* **Victor Ariel Matos Menezes** - [Victor](https://github.com/VitrolaVT)
