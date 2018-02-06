#!/usr/bin/rexx  
/*********************************************************
Este programa é um software livre; você pode redistribuí-lo e/ou modificá-lo dentro dos termos da Licença Pública Geral GNU como publicada pela Fundação do Software Livre (FSF); na versão 2 da Licença, ou (na sua opinião) qualquer versão.
Este programa é distribuído na esperança de que possa ser útil, mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO a qualquer MERCADO ou APLICAÇÃO EM PARTICULAR. Veja a Licença Pública Geral GNU para maiores detalhes.
Você deve ter recebido uma cópia da Licença Pública Geral GNU junto com este programa, se não, escreva para a Fundação do Software Livre(FSF) Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA 
*********************************************************/

/*trace (?i) */
   
/* scritp personalizado para montar/desmontar diretório: __________________ */

/******************  Substitua os conteúdos das variáveis abaixo   *************************************/
/******************  Início das alteraçes a serem feitas no modelo ************************************/

diretorio_origem  = "Coloque aqui, entre as aspsas, o diretório dos dados criptografados, incluindo o caminho absoluto"
diretorio_destino = "Coloque aqui, entre as aspas, o diretório dos dados montado para uso, incluindo o caminho absoluto"
arquivo_frase_secreta = "Coloque aqui, entre as aspas, o arquivo onde foi armazenada a frase secreta, incluindo o caminho absoluto"

/******************  Fim das alterações a serem feitas no modelo ************************************/
/******************  Só mexa daqui para baixo se você souber o que está fazendo *******************/

if wordpos('Directory', STREAM( diretorio_origem, 'c', 'FSTAT')) = 0 then do
   say 'Diretório origem dos dados critpografados ('diretorio_origem') inválido'
   exit 99
   end
if wordpos('Directory', STREAM( diretorio_destino, 'c', 'FSTAT')) = 0 then do
   say 'Diretório origem dos dados decriptados ('diretorio_destino') inválido'
   exit 99
   end
if STREAM( arquivo_frase_secreta, 'c', 'QUERY EXISTS') = '' then do
   say 'Arquivo para frase secreta ('arquivo_frase_secreta') inválido'
   exit 99
   end

frontend = ''
opcao = ''
param1 = ''
param2 = ''
parse arg param1 param2        /* obtem front end e/ou opção caso sejam passados como parâmetro */

if param1 <> '' & wordpos(param1, 'zenity kdialog dialog mount umount') = 0 then do;
   Say "Parâmetro ("param1") inválido: escolha um destes: zenity, kdialog ou dialog e/ou mount, umount"
   exit 9999 
   end
if param2 <> '' & wordpos(param2, 'zenity kdialog dialog mount umount') = 0 then do;
   Say "Parâmetro ("param2") inválido: escolha um destes: zenity, kdialog ou dialog e/ou mount, umount"
   exit 9999 
   end
if wordpos(param1, 'zenity kdialog dialog') <> 0 then frontend = param1
if wordpos(param1, 'mount umount')<> 0 then opcao = param1
if wordpos(param2, 'zenity kdialog dialog') <> 0 then frontend = param2
if wordpos(param2, 'mount umount')<> 0 then opcao = param2


parse source system invocation filename   /* obtem o nome do script rexx chamado */

ADDRESS SYSTEM ' dirname "'||filename||'"' WITH OUTPUT STEM dir_fonte. /* obtem o diretório do script rexx chamado  */

arquivo_existe = STREAM( dir_fonte.1||'/eCryptFS.rex', 'c', 'QUERY EXISTS')

if arquivo_existe = "" then do
   say "Está procurando o programa eCryptFS.rex, pois este script está sendo executado a partir de outro diretório. Isso pode demorar. Se quiser que fique mais rápido coloque este script no mesmo diretório que o programa eCryptFS.rex"
   cmd = "find / -name eCryptFS_facil.rex 2> /dev/null"
   ADDRESS SYSTEM cmd WITH OUTPUT STEM filename.
   ADDRESS SYSTEM ' dirname "'||filename.1||'"' WITH OUTPUT STEM dir_fonte.
   end

value(REGINA_MACROS, dir_fonte.1, ENVIRONMENT)  /* coloca o diretório obtido na variável de ambiente para  */
                                                /* poder chamar os demais módulos (mount e umount)         */
if opcao = "umount" then do
   Queue diretorio_destino 
   call 'eCryptFS.rex' frontend opcao
   exit result
   end
opcao = "mount"
Queue diretorio_origem
Queue diretorio_destino
Queue arquivo_frase_secreta
call 'eCryptFS.rex' frontend opcao

exit result
