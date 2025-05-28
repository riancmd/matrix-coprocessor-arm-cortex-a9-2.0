# MATRIKS: Biblioteca para coprocessador aritmético de matrizes

**Matriks** é uma biblioteca em Assembly desenvolvida para facilitar a comunicação entre o processador ARM Cortex-A9 (rodando Linux) da plataforma DE1-SoC e um coprocessador aritmético para matrizes implementado na Intel FPGA em Verilog.

O coprocessador é capaz de performar operações básicas entre matrizes quadradas de n <= 5 (operações como soma, subtração, multiplicação por escalar ou outra matriz, determinante, oposta e transposta). A biblioteca possui um conjunto de funções em Assembly que permitem ao usuário enviar dados, realizar operações e receber os resultados por meio de um mapeamento de memória.

Para obter mais informações sobre o coprocessador aritmético, acesse o [repositório](https://github.com/riancmd/matrix-coprocessor-arm-cortex-a9).

## 🚀 Sumário

* [Introdução](#-introdução)
* [Sobre o coprocessador](#-sobre-o-coprocessador)
* [Pré-requisitos](#-pré-requisitos)
* [Como instalar?](#-como-instalar)
* [Requisitos do problema](#-requisitos-do-problema)
* [Recursos utilizados](#-recursos-utilizados)
* [Metodologia](#-metodologia)
  * [Comunicação HPS-FPGA e mapeamento de memória](#-comunicação-HPS-FPGA-e-mapeamento-de-memória)
* [Testes](#testes)
  * [Como realizar testes?](#como-realizar-testes)
  * [Casos de teste](#casos-de-teste)
* [Como utilizar a biblioteca?](#como-utilizar-o-coprocessador)
* [Conclusão](#conclusão)
* [Referências](#-referências)
* [Colaboradores](#-colaboradores)

## 🧠 Introdução
Os anananannanaana

## 👨‍💻 Sobre o coprocessador
Para utilizar a biblioteca Matriks, é necessário ter o coprocessador aritmético para matrizes implementado na FPGA do kit DE1-SoC. Caso contrário, não será possível utilizá-la, pois a biblioteca depende do processamento das instruções pelo coprocessador.

O [coprocessador aritmético de matrizes](https://github.com/riancmd/matrix-coprocessor-arm-cortex-a9), desenvolvido para trabalhar em conjunto com o processador ARM Cortex A9, foi implementado em Verilog e possui toda sua documentação disponível no repositório linkado. Entretanto, junto a este repositório, há uma versão atualizada do coprocessador para trabalhar em conjunto com a biblioteca. Portanto, **a biblioteca deve ser usada junto à nova versão do coprocessador**. A versão 2.0 do coprocessador possui modificações para conserto de alguns bugs, além da adição de novos módulos para a lógica de comunicação entre o HPS (o processador) e o coprocessador na FPGA.

## 📄 Pré-requisitos


## 🔧 Como instalar?
* Faça o download do projeto como arquivo `.zip` e extraia a pasta matrix-coprocessor-arm-cortex-a9.
* Abra o **Quartus Prime**.
* Vá em **File** > **Open Project**.
* Encontre o arquivo `matrix-coprocessor-arm-cortex-a9.qpf` na pasta que você extraiu do GitHub.
* Selecione-o e abra.
* Com o projeto aberto, clique no botão que é uma seta azul para a direita, para iniciar a compilação, ou vá em **Processing** > **Start Compilation**.
* Vai em **Tools** > **Programmer**.
* Clique em Hardware Setup pra garantir que o Quartus achou sua placa.
* Depois, carregue o arquivo `.sof` gerado e clique em **Start**.

## 📃 Requisitos do problema


## 📦 Recursos utilizados


## 🔨 Metodologia


## 🗣 Comunicação HPS-FPGA e mapeamento de memória


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
