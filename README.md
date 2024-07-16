# Inizio Documentazione Challegne Kiratech

08/07
Dopo aver ricevuto il documento della challenge, ho proveduto a leggere e a cercare di comprendere i requisiti richiesti.
Alla fine sono riuscito a capire che i requisiti richiesti dalla challenge sono i seguenti:

- Fare il provisioning di un'infrastruttura di 3 vm, utilizzando tool a piacere
- Sulla infrastruttura di 3 vm, installare un cluster kubernetes usando Ansible. 
    Il cluster dovrà essere composto di un master e 2 worker
- Le configurazioni da applicare devono garantire il rispetto dei requisiti 
    in termini di Risorse Computazionali, Filesystem e Sicurezza (minima) relativi a Kubernetes.
- Il provisioning del cluster Kubernetes deve essere eseguito predisponendo un
provider Terraform che:
- Installi un manager e due worker configurando un cluster Kubernetes
- Crei un namespace denominato “kiratech-test”
- Esegua un benchmark di security a scelta disponibile pubblicamente
- Deployare usando Helm un'applicazione sul cluster kubernetes composta da 3 servizi
- l’applicazione sia deployata in modo tale da permetterne un
aggiornamento ad una eventuale nuova versione limitando al minimo il tempo
di indisponibilità dell’applicazione stessa.

I requisiti per avviare questa challenge sono:
-virtualbox 7.0
-vagrant 2.41
-terraform 1.9.1

Per esegure il test su macchina locale, scaricare il repository
ed installare i plugin per vagrant con questi comandi

'vagrant plugin install vagrant-vbguest'
'vagrant plugin install vagrant-disksize'

in seguito avviare vagrant con il comando
'vagrant up'

una volta che le vm sono state avviate, utilizzare
terraform nella cartella terraform ed eseguire i comandi:
'terraform init'
'terraform apply'

Per accedere alla pagina web del frontend dell'app
collegarsi da browser all'indirizzo ip 10.0.0.10:30080
e testare l'app.



## Resoconto della challenge:

Cercando su internet ho trovato questi requisiti minimi per un cluster kubernetes:

 - Per quanto riguarda i requisiti hardware minimi ho trovato:
    - Per il master node  2 vCPU e 2GB RAM
    - Per i nodi worker  1vCPU e 2 GB RAM
    - range indirizzi ip statici 10.X.X.X/X 
    - per ogni vm 20 gb di spazio libero
- Per quanto riguarda i requisiti di filesystem:
    - Il filesystem sarà ext4
    - Su ogni vm sarà disabilitato la memoria swap

Per i requisiti di sicurezza

Per il provision delle vm ho scelto di usare Vagrant.
Questo perchè Vagrant è un tool per il provision di VM su workstation,
gratuito e facile da usare. Dato che volevo provare a lavorare
sul mio computer, ho pensato di lavorare in locale creando
delle vm sul mio pc su cui poi installare il cluster kubernetes.
Potevo scegliere di utilzzare qualche public cloud provider, 
ma non volevo aggiungere ulteriore complessità, dato il
tempo limitato. Così ho installato Vagrant e Virtualbox come
software per la virtualizzazione. Virtualbox l'ho scelto
perchè ha una grande compatibilità con Vagrant.

Il mio computer ha come OS Windows 10. Questo significa
che non potevo installare Ansible su macchina locale, se non
usando particolari sistemi come WSL o altro.
A questo punto ho pensato due soluzioni:

- Creare un'altra VM su cui installare linux e Ansible e usarla
    per fare il provisioning delle altre VM
- Usare il provider locale di ansible che esiste per Vagrant, così
    che su ogni vm creata, Vagrant installi ansible ed esegua
    il playbook specificato

All'inizio ho seguito la prima strada, dato che però non volevo
caricare troppo il sistema di VM, ho optato poi per la seconda
soluzione.
Specificando il provider "ansible_local" Vagrant installa ed esegue
Ansible sulla VM, così da preparare e installare sulle VM un cluster
Kubernetes. Così ho creato un cluster di vm, di cui un master node
e due worker node per kubernetes. 

Il problema è che creare Kubernetes su Vagrant, ho scoperto poi
porta diversi problemi, non facilmente identificabili e bisogna
quindi fare delle impostazioni sulle macchine per fare
in modo che kubernetes funzioni in modo corretto su Vagrant.
Questo perchè, da quello che ho potuto capire, Vagrant crea molte
interfacce di rete virtuali e Kubernetes fa fatica a capire quale
configurare per la comunicazioni fra per esempio api-server e nodi.
Quindi nel playbook di Ansible ho dovuto inserire diversi task
che configurassero la macchina in modo tale che kubernetes 
funzioni in modo corretto.
Questo però ha richiesto parecchio tempo e debugging, comportando quindi
che la maggiore difficoltà per me è stato proprio quello di riuscire
a installare in modo corretto kubernetes su vm gestite da Vagrant.
I problemi principali è che avendo Vagrant diverse interfaccie di rete virtuali,
kubernetes da solo sbagliava a configurare in modo corretto gli indirizzi
dell'api server e dei nodi. Quindi quando eseguivo semplici comandi con kubectl
mi dava errori, per esempio che non riusciva a connetersi in maniera corretta
ai nodi del cluster.
Il resto dei task non sono stati invece per fortuna troppo difficili
da completare.


Ho utilizzato Ansible per configurare le vm, per settare i requisti per kubernetes
e in seguito creare il cluster kubernetes sulle vm.
All'inizio avevo sviluppato un playbook per il master e un altro per i workers.
Poi dato che molti comandi erano in comune, ho creato un unico playbook.
Per fare in modo che alcuni comandi venissero eseguiti a seconda su un tipo
di nodo o l'altro, ho aggiunto delle condizioni nel playbook che controllase
un inventory di host e confrontasse il nome del host in quel momento.
Ho usato sempre il provider locale di ansible di Vagrant per creare
al momento un inventory con specificato un dictionary con all'interno
il gruppo di host e all'interno i nome degli host per ciascun gruppo.

Per quanto riguarda il playbook di Ansible, i task che esegue sono i seguenti:

- Si assicura che gli indirizzi DNS siano corretti
- Installi i package di base richiesti
- Installa containerd, quindi kubernetes utilizzerà come runtime di container
- Configura containerd e abilità i moduli del kernel overlay e br_netfilter
- Si assicura che la memoria Swap non ci sia anche dopo il riavvio
- Aggiunge i repository e poi li installa di Kubelet, Kubeadm e Kubectl
- Configura l'ip forwarding e le iptables
- Sul nodo master inizializza il cluster kubernetes usando il comando kubeadm init.
  Su questo comando specifico l'indirizzo ip dell'api server perchè su Vagrant Kubernetes è solito
  configurare in maniera automatica male quale interfaccia di rete virtuale settare, dato che Vagrant
  configura diverse interfaccie di rete diverse.
  Quando non facevo così, dopo mi dava errore quando tentavo di connettermi all'api server
- Sul nodo master copia il comando per la join dei nodi e lo salva sulla cartella condivisa dalle vm,
  così che gli altri nodi workers possano prendere il file text con il comando dentro
  ed eseguirlo per joinare il cluster
- Sui nodi workers prende il file di testo con il comando di join e lo esegue,
 così che i nodi workers possano joinare il cluster
- Crea la cartella .kube in Home e copia il file di configurazione di kubernetes
- copia il file di configurazione su cartella condivisa delle VM, così che poi Terraform
    possa utilizzarlo per il provider Kubernetes ed eseguire i task sul cluster
- Copia il file di configurazione di kubernetes, in una cartella nascosta in home
- Setto in maniera precisa l'indirizzo ip del nodo, aggiungendo un'opzione al
 file 10-kubeadm.con, aggiungendo come variabile di ambiente KUBELET_EXTRA_ARGS
 l'opzione node-ip con l'indirizzo ip della vm. Questo lo faccio sia su master
 che su nodi worker, perchè se no, anche se facessi kubectl get nodes il comando mi
 dia la lista di nodi corretta, se poi faccio kubectl logs "nome del pod" mi direbbe
 che non trova il nodo specificato. Questo è un problema dovuto al fatto di utilizzare
 Vagrant, dato che kubernetes configura l'indirizzo ip di ogni nodo non con l'indirizzo ip
 corretto.
 - Aggiungo una variabile d'ambiente KUBECONFIG, con il path del file di configurazione
 di kubernetes, così da non avere problemi quando eseguo un comando kubectl e trovare
 in modo corretto l'api server. Questo è un altro comando che va usato se si usa
 un cluster Kubernetes su Vagrant.
 - Riavvio il servizio kubelet se no dopo le configurazioni ad hoc fatte prima
 non hanno effetto
- Setto i permessi di alcuni file, indicazione fatta dal benchmark di sicurezza




Ho utilizzato terraform per installare il plugin calico per il networking,
aspettare che tutti i nodi passassero da not ready a ready,
scaricare ed eseguire il benchmark di sicurezza per kubernetes,
utilizzare il provider di kubernetes per creare un namespace "kiratech-test",
installare helm sul nodo master ed deployare l'applicazione utilizzando helm.

per la comunicazione nel cluster ho installato calico
Calico è una soluzione open-source per gestire il networking e la sicurezza in un cluster kubernetes.
Caratteristiche principali di Calico

Calico utilizza il routing basato su IP per fornire una rete ad alte prestazioni per i pod di Kubernetes. Può anche utilizzare BGP (Border Gateway Protocol) per distribuire le informazioni di routing tra i nodi.
Modalità Overlay e Non-Overlay: Calico può operare sia in modalità overlay che non-overlay. In modalità overlay, utilizza l'incapsulamento IP-in-IP o VXLAN per il traffico di rete tra i nodi. In modalità non-overlay, si basa sull'infrastruttura di rete sottostante per il routing.
Politiche di Rete:
 Calico consente di definire politiche di sicurezza della rete per controllare il flusso di traffico da e verso i pod di Kubernetes. Queste politiche possono essere utilizzate per applicare regole di sicurezza granulari basate su etichette dei pod, namespace, indirizzi IP e porte.
Politiche Globali e per Namespace: Calico supporta sia le politiche di rete globali (che si applicano a livello di cluster) sia le politiche di rete per namespace (che si applicano a namespace specifici).
Gestione degli Indirizzi IP:
Calico assegna dinamicamente indirizzi IP ai pod da pool IP configurabili.
È possibile definire pool IP personalizzati e subnet per controllare gli intervalli di indirizzi IP utilizzati da Calico.
 Calico si integra con Kubernetes come plugin CNI (Container Network Interface), fornendo una rete senza soluzione di continuità per i pod di Kubernetes.
alico implementa le risorse NetworkPolicy di Kubernetes, consentendo di utilizzare definizioni standard delle politiche di rete di Kubernetes.
Prestazioni e Scalabilità:
Calico è progettato per fornire una rete ad alte prestazioni con bassa latenza e alta velocità di trasmissione.


Le alternative a Calico sono le seguenti:

Flannel
Weave
Cilium:
Cilium 
Kube-Router

Differenze tra Calico e Altre Soluzioni
Calico e Kube-Router sono noti per le alte prestazioni grazie al loro approccio basato sul routing, mentre Flannel e Weave utilizzano reti overlay che possono introdurre un sovraccarico aggiuntivo.
Calico, Weave e Cilium offrono funzionalità robuste per le politiche di rete, mentre Flannel ha un supporto limitato per le politiche di rete.
Flannel e Weave sono noti per la loro semplicità e facilità di setup, mentre Calico e Cilium offrono funzionalità più avanzate e richiedono una configurazione maggiore.
Cilium eccelle nelle funzionalità di sicurezza avanzate grazie alla sua implementazione basata su eBPF, mentre Calico offre anche funzionalità di sicurezza solide. Flannel è più basico in termini di capacità di sicurezza.

Ho scelto di usare Calico perchè mi è sembrato quello più completo e usato in rete. Ho trovato parecchia documentazione e quindi ho pensato che mi sarebbe stato
più facile trovare soluzioni se avessi trovato problemi. Non avevo particolari requisiti di prestazioni di networking, data la piccola dimensione del cluster e i pochi pod deployati,
quindi non ho trovato particolari motivi per decidere fra un plugin o l'altro. La funzionalità di Calico di assegnare dinamicamente gli indirizzi IP ai pod da pool IP configurabili mi è sembrata
una buona funzionalità da sfruttare così da ridurre la necessità di configurazione da parte mia.

Per eseguire il benchmark di sicurezza sul cluster ho scelto di utilizzare il tool Kube-bench.
Ho scelto questo tool perchè mi è sembrato quello più affidabile e facile da utilizzare.
Posso eseguire CIS Benchmarks su kubernetes, security benchmark che ho scelto.
Per utilizzarlo mi è bastato creare un pod nel cluster.
Per il benchmark di sicurezza per kubernetes ho scelto di utilizzare CIS benchmark

I benchmark di sicurezza per Kubernetes forniscono linee guida e best practice per garantire la sicurezza e la conformità dei cluster Kubernetes.
 I benchmark di sicurezza più comunemente citati sono forniti dal Center for Internet Security (CIS) e
  dal National Institute of Standards and Technology (NIST).

Ho scelto di utilizzare CIS benchmark per verificare la sicurezza del cluster e verificare che le best practice fossero state eseguite,
perchè è uno dei più famosi ed è facilmente utilizzabile utilizzando il tool kube-bench.
Kube-bench supporta in maniera nativa l'uso del CIS benchmark.

Per avviare il benchmark, terraform scarica sul nodo master un file di deploy
che fa eseguire un pod con il container del tool kube-bench.
Una volta che il pod ha terminato la sua esecuzione si può accedere al risultato
del benchmark accedendo al log del pod, con kubectl logs "nome pod di benchmark" 

Ho cercato di risolvere tutti i fail nella sicurezza dei nodi e dei pod, ma sono rimasti
dei fail nella politica di sicurezza delle policy.
Dato che non avevo tempo di lavorare oltre, non sono riuscito a fare altro.

L'applicazione di test usata è un'applicazione sviluppata in node.js,
che è composta da un servizio di front end e uno di back end, che si connette
a un db mongodb. Tutto questo deployato su un cluster kubernetes.

Per l'app ho sviluppato un'applicazione frontend e backend in node.js.
L'applicazione è formata da un servizio di frontend e backend.
Il frontend riceve richieste http dall'esterno e presenta una pagina web
dove l'utente può inserire una stringa di testo.
La web page invia il messaggio al servizio frontend deployato su kubernetes,
e poi fa da proxy per inviare il messaggio al servizio di backend.
Il backend si connette a un db mongodb, riceve il messaggio dal frontend 
e poi invia il messaggio a db per essere salvato.
L'utente può premete il tasto get message, per richiedere al back-end
di ritornare tutti i messaggi salvati fino ad ora.
I messaggi verranno quindi mostrati sulla pagina, in una lista.
Il servizio di backend riprova la connessione al servizio di mongodb ogni 5 minuti,
così che se il servizio o il pod ha un rollback, la connessione può riprendere.

L'applicazione si struttura sul cluster kubernetes, come composta
da 3 service e 3 deployment. I service gestiscono la comunicazione verso i rispettivi pod gestiti,
i deployment gestiscono la configurazione del deployment dei pod su cui sono presenti i container
definiti per i servizi  dell'app di frontend, backed e di mongodb.
Per implementare i container, una volta sviluppato l'app, ho definito
dei dockerfile su cui ho predefinito l'uso di un'immagine che supporti
node.js e ho pushato le immagini buildate su docker hub nel registry pubblico
sul mio account. Così che quando kubernetes crea i pod scarichi l'immagine
da docker hub.
Per il deploy dell'app sviluppata ho utilizzato helm.
Ho definito un chart e i file di deploy per i servizi e i deployment che gestiscono
i pod su cui si trova il container su cui gira il servizio dell'applicazione.
Il deployment è configurato per lanciare 3 pod per ogni serivizio di backend e frontend,
e un pod solo per mongodb.
I pod dei servizi si connettono ai service di kubernetes, i pod di frontend al service
di backend, i pod di backend al service di mongodb. I service poi inviano i messagi ai
pod di riferimento.

Per fare in modo che l'applicazione permetta l'upgrade dell'app in modo da minimizzare
il tempo di downtime ho usato i rolling updates.
Helm utilizza i deployment di Kubernetes, che supportano i rolling update in maniera nativa

Si può accedere dall'esterno al servizio di frontend, tramite un NodePort,
che ascolta le richieste sulla porta 30080.
Per fare in modo che si possa accedere al servizio su kubernetes dall'host di vagrant,
nel Vagrantfile ho impostato il port forwarding della porta 30080 sulla macchina di master.

Per accedere il servizio frontend dell'app, ci sono diverse possibili risorse che kubernetes
offre per questa funzionalità.
Questi sono:

- ClusterIP

Un servizio ClusterIP è il servizio predefinito di Kubernetes. 
Fornisce un servizio all'interno del cluster a cui possono accedere altre app all'interno del cluster. 
Non c'è accesso esterno.
Si può accedere un clusterIp dall'esterno usando il proxy di Kubernetes.
Ci sono alcuni scenari in cui è utile usare il proxy di Kubernetes per accedere ai servizi:
Debug dei  servizi o connessione diretta a loro dal host per qualche motivo.
Consentire il traffico interno, visualizzare dashboard interne, ecc.
Poiché questo metodo richiede di eseguire kubectl come utente autenticato,
non si dovrebbe usarlo per esporre il servizio all'esterno o usarlo per servizi in produzione.

- NodePort

Un servizio NodePort è il modo più primitivo per accedere dall'esterno direttamente al servizio. 
NodePort, come implica il nome, apre una porta specifica su tutti i nodi (le VM) e 
qualsiasi traffico inviato a questa porta viene inoltrato al servizio.
Fondamentalmente, un servizio NodePort ha due differenze rispetto a un normale servizio "ClusterIP". 
Innanzitutto, il tipo è "NodePort". C'è anche una porta aggiuntiva chiamata nodePort che specifica quale porta aprire sui nodi. 
Se non viene specifica questa porta, ne sceglierà una casuale. 

Ci sono molti svantaggi in questo metodo:

Si può avere un solo servizio per porta.
Si può usare solo le porte 30000–32767.
Se l'indirizzo IP del tuo nodo/VM cambia, deve essere gestito.
Per questi motivi, non è consigliato di usare questo metodo in produzione per esporre direttamente il tuo servizio.
Un buon caso d'uso per questo servizio è nel caso di un'app demo o qualcosa di temporaneo.

LoadBalancer
Un servizio LoadBalancer è il modo standard per esporre un servizio a Internet. 
Su un cloud provider, questo avvierà un  Load Balancer che darà un indirizzo IP che inoltrerà tutto il traffico al servizio.
Se si vuole esporre direttamente un servizio, questo è il metodo predefinito. 
Tutto il traffico sulla porta specificata verrà inoltrato al servizio. Non c'è filtraggio, non c'è routing, ecc. 
Questo significa che si può inviare quasi qualsiasi tipo di traffico, come HTTP, TCP, UDP, Websockets, gRPC, o altro.

Il grande svantaggio è che ogni servizio che si espone con un LoadBalancer otterrà il proprio indirizzo IP
 e dovrai pagare per un LoadBalancer per ogni servizio esposto se il servizio è a pagamento.

Ingress

A differenza di tutti gli esempi sopra, Ingress in realtà noe è un tipo di servizio. 
Invece, si trova davanti a più servizi e agisce come un "router intelligente" o punto di ingresso nel tuo cluster.
Si può fare molte cose diverse con un Ingress e ci sono molti tipi di controller Ingress che hanno diverse capacità.
Ingress è probabilmente il modo più potente per esporre i servizi, ma può anche essere il più complicato. 
Ci sono molti tipi di controller Ingress, dal Google Cloud Load Balancer, Nginx, Contour, Istio e altro.
 Ci sono anche plugin per i controller Ingress, come il cert-manager, che possono fornire automaticamente certificati SSL per i servizi.
Ingress è il più utile se si vuole esporre più servizi sotto lo stesso indirizzo IP e questi servizi usano tutti lo stesso protocollo L7 (tipicamente HTTP).


Per l'applicazione di test ho deciso di utilizzare un Nodeport, questo perchè data
la natura di test dell'app, deployata in ambiente locale e non accessibile all'esterno,
non mi dovevo preoccupare di particolari requisiti di sicurezza o funzionalità,
ma solo mostrare che l'app funzioni.

Per accedere al servizio di frontend da host locale dove è stato fatto
il provisioning delle vm usando vagrant, si può accedere da porta 30080
e con indirizzo ip di uno dei nodi, per esempio 10.0.0.10:30080

Avevo pensato di implementare un load balancer locale usando metalLb, ma 
alla fine ho deciso di tenere semplice l'infrastruttura, dato il poco tempo.

Per gestire il continuos integration, ho deciso di utilizzare Github Actions.
Questo perchè Github Actions è un servizio di continuos integration gratuito
offerto da Github, per poter esegure task specifici in remoto sul proprio
repository git su github. Ho definito dei file di configurazione per 
workflow per Github action, utilizzando i linter per controllare
la correttezza dei file di configurazione per Ansible, Terraform e Helm.