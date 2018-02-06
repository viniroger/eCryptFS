#!/usr/bin/rexx
/*********************************************************
Este programa é um software livre; você pode redistribuí-lo e/ou modificá-lo dentro dos termos da Licença Pública Geral GNU como publicada pela Fundação do Software Livre (FSF); na versão 2 da Licença, ou (na sua opinião) qualquer versão.
Este programa é distribuído na esperança de que possa ser útil, mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO a qualquer MERCADO ou APLICAÇÃO EM PARTICULAR. Veja a Licença Pública Geral GNU para maiores detalhes.
Você deve ter recebido uma cópia da Licença Pública Geral GNU junto com este programa, se não, escreva para a Fundação do Software Livre(FSF) Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA 
*********************************************************/

/* trace (?i)   */
/* cria diretório para uso de dados criptografados */
/* Se preferir escolher o frontend, passe como parâmetro um destes: zenity, kdialog ou dialog*/

frontend = ''
opcao_escolhida = ''
param1 = ''
param2 = ''
parse arg param1 param2        /* obtem front end e opçao de montagem caso seja passado como parâmetro */

if param1 <> '' & wordpos(param1, 'zenity kdialog dialog mount umount') = 0 then do;
   Say "Parâmetro ("frontend") inválido: escolha um destes: zenity, kdialog ou dialog e/ou mount, umount"
   exit 9999 
   end
if wordpos(param1, 'zenity kdialog dialog') <> 0 then do;
   frontend = param1
   opcao_escolhida = param2
   end
else opcao_escolhida = param1

if frontend = '' then do;
    ADDRESS SYSTEM '. ssft.sh; ssft_choose_frontend; echo $SSFT_RESULT' ,
                WITH OUTPUT STEM sysfrontend.
    if sysfrontend.1 = "text" then do;
       say "ATENÇÃO: Não foi encontrada nenhuma destas interfaces: zenity, kdialog ou dialog"
       exit 999
       end
    frontend = sysfrontend.1
    end
value(SSFT_FRONTEND, frontend, ENVIRONMENT)
Say "SSFT_FRONTEND="Value( 'SSFT_FRONTEND', , 'ENVIRONMENT' )

if USERID() <> "root" then do;        /* verifica se está rodando como root  */
   ADDRESS SYSTEM '. ssft.sh; ssft_display_error "----A T E N Ç Ã O----" "Este script deve ser executado pelo ROOT"'
   exit 9999
   end

/***** Inicio - Caso sejam passados os arquivos e parâmentros diretamente sem necessidade de ficar escolhendo os arquivos */
if opcao_escolhida <> '' then do
   if queued() = 0 then do
      ADDRESS SYSTEM '. ssft.sh; ssft_display_error "----A T E N Ç Ã O----" "E R R O:\nInformado parametro de montagem ou desmontagem sem enfileirar o(s) diretório(s) e/ou cofre da frase secreta"'
      exit 9999
      end
   if opcao_escolhida = "umount" then do
      call UmountCripto_rex  
      exit result
      end
   else do
      call MountCripto_rex 
      exit result
      end
   end
/***** Fim - Caso sejam passados os arquivos e parâmentros diretamente sem necessidade de ficar escolhendo os arquivos */   

ADDRESS SYSTEM '. ssft.sh; if ssft_select_single "Escolha a opção" "Montar ou Desmontar Diretório" "Mount" "UMount"; then echo $SSFT_RESULT; else exit 1; fi' ,
                WITH OUTPUT STEM opcao.
if rc <> 0 then exit rc

if opcao.1 = "UMount" then do /* umount */
      ADDRESS SYSTEM '. ssft.sh; if ssft_directory_selection "Informe o diretório a desmontar" "Selecione um diretório"; then echo $SSFT_RESULT; else exit 1; fi' ,
                      WITH OUTPUT STEM diretorio_destino.
      if rc = 1 then exit rc
      queue diretorio_destino.1
      call UmountCripto_rex  
      exit result
      end 

ADDRESS SYSTEM '. ssft.sh; if ssft_directory_selection "Informe o diretório dados criptografados" "Selecione um diretório";                     then echo $SSFT_RESULT; else exit 1; fi' ,
                      WITH OUTPUT STEM diretorio_origem.
if rc = 1 then exit rc

ADDRESS SYSTEM '. ssft.sh; if ssft_directory_selection "Informe o diretório dados decriptados" "Selecione um diretório"; then echo $SSFT_RESULT; else exit 1; fi' ,
                      WITH OUTPUT STEM diretorio_destino.
if rc = 1 then exit rc

ADDRESS SYSTEM '. ssft.sh; if ssft_file_selection "Arquivo de armazenamento da frase secreta (arquivo texto qualquer)" "Selecione um arquivo"; then echo $SSFT_RESULT; else exit 1; fi' ,
                  WITH OUTPUT STEM arquivo_frase_secreta.
if rc\=0 then exit

cmd = 'stat -c%s "' || arquivo_frase_secreta.1 || '"'
ADDRESS SYSTEM cmd WITH OUTPUT STEM tam_arquivo.

# Primeira montagem
if tam_arquivo.1 < 3 then do
   ADDRESS SYSTEM '. ssft.sh; if ssft_yesno "Atenção!!" "Arquivo ' arquivo_frase_secreta.1 '(armazenador da FRASE SECRETA) vazio \n\n Primeira montagem? \n\n Continuar?"; then exit 0; else exit 1; fi'
   
   if rc > 0 then exit 999
   opcao.1 = "Primeira Montagem"
   end
# primeira montagem

if opcao.1 = "Primeira Montagem" then do;
   cmd = 'ls -A' diretorio_destino.1
   ADDRESS SYSTEM cmd WITH OUTPUT STEM resultado.
   if resultado.0 > 0 then do
      ADDRESS SYSTEM '. ssft.sh; ssft_display_message "ATENÇÃO" "Diretório "' diretorio_destino.1 '"não está VAZIO!!!!. \n\n Salvar os arquivos; deletá-los e recolocá-los após montagem do diretório"'
      exit 9999
      end
   erro = "1"
   do until erro = "0"
      ADDRESS SYSTEM '. ssft.sh; if ssft_read_password "FRASE SECRETA" "Digite a FRASE SECRETA (não precisa decorar - irá criptografar os dados)"; then echo $SSFT_RESULT; else exit 1; fi' ,
                  WITH OUTPUT STEM senha_a.
      if rc <> 0 then exit rc    
      ADDRESS SYSTEM '. ssft.sh; if ssft_read_password "FRASE SECRETA" "RE-DIGITE a frase secreta (não precisa decorar - irá criptografar os dados)"; then echo $SSFT_RESULT; else exit 1; fi' ,
                    WITH OUTPUT STEM senha_b.   
      if rc <> 0 then exit rc 
      if senha_a.1 <> senha_b.1 then do
         ADDRESS SYSTEM '. ssft.sh; ssft_display_error "E R R O" "As frases secretas estão DIFERENTES!!!"'
         end
      else erro = "0"
      end
   frase_secreta = senha_a.1
   drop senha_a.
   erro = "1"
   do until erro = "0"
      ADDRESS SYSTEM '. ssft.sh; if ssft_read_password "S E N H A" "Digite a SENHA para envelopar frase secreta (essa precisa decorar)"; then echo $SSFT_RESULT; else exit 1; fi' ,
                  WITH OUTPUT STEM senha_a.
      if rc <> 0 then exit rc    
      ADDRESS SYSTEM '. ssft.sh; if ssft_read_password "S E N H A" "RE-DIGITE a senha para envelopar frase secreta (essa precisa decorar)"; then echo $SSFT_RESULT; else exit 1; fi' ,
                    WITH OUTPUT STEM senha_b.
      if rc <> 0 then exit rc 
      if senha_a.1 <> senha_b.1 then do
         ADDRESS SYSTEM '. ssft.sh; ssft_display_error "E R R O" "As senhas estão DIFERENTES!!!"'
         end
      else erro = "0"
      end
   senha_a_ser_decorada = senha_a.1
   cmd = 'printf "%s\n%s" "'frase_secreta'" "'senha_a_ser_decorada'" | ecryptfs-wrap-passphrase "'arquivo_frase_secreta.1'"'

   ADDRESS SYSTEM cmd WITH OUTPUT STEM result.
   if rc <> 0 then do
      ADDRESS SYSTEM '. ssft.sh; ssft_display_error "A T E N Ç Ã O" "Houve problemas no envelopamento da frase secreta. Verificar logs"'
      exit 99
      end
   end

Queue diretorio_origem.1
Queue diretorio_destino.1
Queue arquivo_frase_secreta.1
call MountCripto_rex 

exit 0

/***************************************************************************/
MountCripto_rex:
say "REXX script - Monta diretório criptografado por ecryptfs"                                                              

if queued() = 3 then do 
   parse pull diretorio_cripto_lower
   parse pull diretorio_decript_upper
   parse pull arquivo_frase_secreta
   end
else do
   say "Parâmetros inválidos. Enfileirar: 1 - diretório criptografado; 2 - diretório decriptado; 3 - Cofre frase secreta"
   exit 999
   end 

cmd = 'mount | grep "'||  diretorio_decript_upper ||'"'

ADDRESS SYSTEM cmd WITH OUTPUT STEM resultado. 

if resultado.0 > 0 then do
   ADDRESS SYSTEM '. ssft.sh; ssft_display_error "A T E N Ç Ã O" "Diretório ' diretorio_decript_upper ' já está montado!!!"'
   exit 99
   end

if diretorio_cripto_lower <> diretorio_decript_upper then do
   cmd = 'ls -A "'|| diretorio_decript_upper ||'"'
   ADDRESS SYSTEM cmd WITH OUTPUT STEM resultado.
   if resultado.0 > 0 then do
      ADDRESS SYSTEM '. ssft.sh; ssft_display_error "A T E N Ç Ã O" "Diretório ' diretorio_decript_upper 'não vazio!!!!.\n\n Houve algum problema anterior.\n\n Salvar os arquivos; deletá-los e recolocá-los após a montagem do diretório""'
      exit 9999
      end
   end

ADDRESS SYSTEM '. ssft.sh; if ssft_read_password "SENHA" "Digite a senha para abrir frase secreta"; then echo $SSFT_RESULT; else exit 1; fi' ,
                 WITH OUTPUT STEM opcao.
if rc <> 0 then exit rc 
cmd = 'printf "%s" "'opcao.1'" | ecryptfs-unwrap-passphrase "'arquivo_frase_secreta'"'

ADDRESS SYSTEM cmd WITH OUTPUT STEM result.
if rc <> 0 then do
   ADDRESS SYSTEM '. ssft.sh; ssft_display_error "A T E N Ç Ã O" "A senha digitada está ERRADA!!!"'
   exit 99
   end

cmd = ''
cmd = cmd || 'mount -t ecryptfs "'diretorio_cripto_lower'" "'diretorio_decript_upper'"'
cmd = cmd || ' -o ecryptfs_cipher=aes,ecryptfs_key_bytes=24,key=passphrase:passphrase_passwd="'result.2'",'
cmd = cmd || 'ecryptfs_passthrough=n,ecryptfs_enable_filename_crypto=n,no_sig_cache'

ADDRESS SYSTEM cmd

cmd = 'mount | grep "'||  diretorio_decript_upper ||'"'

ADDRESS SYSTEM cmd WITH OUTPUT STEM resultado. 

if resultado.0 > 0 then do
   ADDRESS SYSTEM '. ssft.sh; ssft_display_message "PARABÉNS" "Diretório ' diretorio_decript_upper ' montado com sucesso"'
   end
else do
   ADDRESS SYSTEM '. ssft.sh; ssft_display_error "A T E N Ç Ã O" "Diretório ' diretorio_decript_upper ' NÃO MONTADO! Problemas"'
   exit 99
   end
exit 0

/**********************************************************/

UmountCripto_rex:

say "REXX script - Desmonta diretório criptografado por ecryptfs"                                                               

if queued() = 1 then do
  parse pull diretorio_decript_upper
  end
else do
   say "Parâmetros inválidos. Foi chamado sem enfileirar diretório"
   exit 999
   end

cmd = 'mount | grep "'|| diretorio_decript_upper ||'"' 

ADDRESS SYSTEM cmd WITH OUTPUT STEM resultado.

if resultado.0 > 0 then do
   cmd = 'sudo umount "'diretorio_decript_upper'"'
   ADDRESS SYSTEM cmd
   if rc <> 0 then do  /*******************/
       ADDRESS SYSTEM '. ssft.sh; ssft_display_error "A T E N Ç Ã O" "Diretório ' diretorio_decript_upper ,
       ' NÃO foi desmontado. Problemas"'
       exit 99
   end                
   
   ADDRESS SYSTEM '. ssft.sh; ssft_display_message "PARABÉNS" "Diretório ' diretorio_decript_upper ' desmontado com sucesso"'
   exit rc
   end
else do
   ADDRESS SYSTEM '. ssft.sh; ssft_display_error "A T E N Ç Ã O" "Diretório ' diretorio_decript_upper 'NÃO está montado!!!"'
   exit 0
   end 
/************************************************************/

