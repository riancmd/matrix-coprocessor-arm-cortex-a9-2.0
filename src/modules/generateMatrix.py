import os
# Para utilizar o script, basta colar um feixe de 200 bits da matriz desejada. A matriz em decimal, minimamente formatada,
# será exibida em seguida.

def generateMenu():
    matrizz = input('Digite a matriz completa: ')
    os.system('cls')
    matrixx = gerarMatriz(matrizz)

def gerarMatriz(matriz):
    matrix = [[0]*5 for _ in range(5)]
    begin = 0
    end = 8
    for i in range(5):
        print("|    ", end="")
        for j in range(5):
            bits = matriz[begin:end]
            matrix[i][j] = bits
            print(binaryToDec(bits), end="    ")
            begin += 8
            end += 8
        print("|")
    return matrix

def binaryToDec(n):
    val = int(n, 2)
    if n[0] == '1':  # bit de sinal
        val -= 256
    return val

while True:
    generateMenu()
    continuar = input('Deseja continuar? (S/N): ')
    if continuar.upper() == 'S':
        os.system('cls')
    else:
        break
