# Debian Family
Este repositório é para compartilhar os arquivos de atualização dos sistemas da Família Debian de ser.
O Fedora ainda continua como meu "porto seguro" mas todas as distros tem uma nova chance né.
Hoje 2 de novembro de 2026, elaborei o shell script "quarentena_debiansid.sh" o qual funciona para controle das novas atualizações de pacotes. Onde podemos ter controle para pinar os pacotes que estão com bugs registrados e para pinar as novas atualizações com a contagem de 5 dias. passado este período caso o pacote não seja incluído na lista de bugs, será recomendada o unhold e liberado para atualização.
O shell script "quarentena_debiansid.sh" funciona em conjunto com o "Atualização Debian Sid.sh" o qual também possui outros comandos validando o "quarentena_debiansid.sh", assim temos um double-check.
Portanto na utilização do Atualização Debian Sid.sh, façam o download do quarentena_debiansid.sh e deem permissão de execução para ambos. E tenham a experiência completa de minimizar pelo menos a dor de cabeça com as atualizações bugadas que podem ocorrer. 
Pode não ser perfeito, mas já é o início de um controle.
Esse 2 são os mais atuais portanto os outros são "menos completos" até pq eu acredito que os 2 scripts do Debian Sid seja até o dia de hoje os mais completos e quiçá os mais complexos existentes neste Github.
