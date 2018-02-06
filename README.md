# eCryptFS
Programas em Rexx para criptografar diretórios

OBS: Os programas deste pacote são software livre; você pode redistribuí-lo e/ou modificá-lo dentro dos termos da Licença Pública Geral GNU como publicada pela Fundação do Software Livre (FSF); na versão 2 da Licença, ou (na sua opinião) qualquer versão.
Este programa é distribuído na esperança de que possa ser útil, mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO a qualquer MERCADO ou APLICAÇÃO EM PARTICULAR. Veja a Licença Pública Geral GNU para maiores detalhes.
Você deve ter recebido uma cópia da Licença Pública Geral GNU junto com este programa, se não, escreva para a Fundação do Software Livre(FSF) Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*** VEJA MAIS INFORMAÇÕES EM https://www.monolitonimbus.com.br/criptografia-no-linux-uma-opcao ***

Utilização

1) Instalar os pacotes através do repositório:

$ sudo apt-get install regina-rexx ecryptfs-utils ssft

2) Crie as pastas de origem (com os dados criptografados, por exemplo, diretorio_origem) e de destino (com os dados a serem trabalhados, por exemplo, diretorio_destino) e um arquivo em branco fora das pastas onde for criptografar os dados para guardar a frase secreta (frasesecreta.txt, por exemplo);

3) Copie o arquivo eCryptFS.rex (clique no link do final do post para baixá-lo) em algum lugar que não seja dentro das pastas envolvidas na criptografia, torne-o executável (comando da 1ª linha) e execute-o como super usuário (comando da segunda linha):

$ sudo chmod +x eCryptFS.rex
$ sudo ./eCryptFS.rex

Opcionalmente, após o nome do arquivo, você pode digitar o nome do diálogo escolhido (zenity ou kdialog ou dialog) após um espaço e dê enter.

4) Após a execução, será aberta uma janela de diálogo escolhendo para montar (mount) ou desmontar (umount);

5) Escolhendo "mount", aparecerá a segunda caixa de diálogo, escolha a pasta onde serão guardados os dados criptografados (ex: /media/pendrive/diretorio_origem);

6) Na tela seguinte, escolha a pasta onde será montado (ex: /home/user/Documentos/diretorio_destino);

7) Na próxima tela, informe um arquivo vazio para guardar a frase secreta (não precisa decorar), redigitando-a posteriormente;

8) Na sequência, digite uma senha para criptografar a frase secreta;

9) Esta senha será pedida uma vez mais para iniciar o processo de montagem do diretório de dados decriptados.

Pronto. Todos os arquivos que forem utilizados na pasta onde foi montado (no caso, /home/user/Documentos/diretorio_destino) serão copiados criptografados para a pasta onde os arquivos serão guardados (/media/pendrive/diretorio_origem, no nosso exemplo). Para desmontar, basta executar novamente o arquivo "eCryptFS.rex", escolher a opção "umount" e o diretório a ser desmontado (diretorio_destino, no exemplo, que depois de desmontada aparecerá vazia). Os arquivos da pasta criptografada (diretorio_origem) estarão com um tamanho maior e não abrirão corretamente, devido à criptografia, abrindo somente se acessados pela "pasta_destino" após reiniciar o processo de montagem. Se desligar ou reiniciar o computador ele será automaticamente desmontado.

Simplificando o processo

Uma vez feito todo o processo de preparação dos diretórios para serem criptografados fica trabalhosa a interação para escolha de diretórios e arquivo de frase secreta sempre que for necessário montar o diretório de dados decriptados.

Para facilitar o processo além do eCryptFS.rex escrevi um modelo que, uma vez personalizado para um determinado diretório criptografado, faz todo o processo somente solicitando a senha para decriptar a frase secreta. O script Modelo_monta_desmonta_diretorio.rex (clique no link do final do post para baixá-lo) deve ter as seguintes alterações:

/*****  Substitua os conteúdos das variáveis abaixo   *****/
/*****  Início das alterações a serem feitas no modelo *****/
diretorio_origem  = "Coloque aqui, entre as aspas, o diretório dos dados criptografados, incluindo o caminho absoluto"
diretorio_destino = "Coloque aqui, entre as aspas, o diretório dos dados montado para uso, incluindo o caminho absoluto"
arquivo_frase_secreta = "Coloque aqui, entre as aspas, o arquivo onde foi armazenada a frase secreta, incluindo o caminho absoluto"
/*****  Fim das alterações a serem feitas no modelo ********/

Feitas as alterações acima, ele deve ser gravado com algum nome escolhido a gosto de quem personalizar o processo. No caso de ser gravado com o nome de MontaDiretorioSecreto.rex, a execução para montagem será (não esqueça de torná-lo executável com o comando "chmod +x"):

$ sudo ./MontaDiretorioSecreto.rex

Para desmontagem:

$ sudo ./MontaDiretorioSecreto.rex umount

Caso queira utilizar uma interface gráfica específica, ela deve ser informada no parâmetro. Por exemplo, se quiser utilizar o kdialog:

$ sudo ./MontaDiretorioSecreto.rex kdialog

ou

$ sudo ./MontaDiretorioSecreto.rex umount kdialog

*** VEJA MAIS INFORMAÇÕES EM https://www.monolitonimbus.com.br/criptografia-no-linux-uma-opcao ***
