Inizio Documentazione Challegne Kiratech

08/07
Dopo aver ricevuto il documento della challenge, ho proveduto a leggere e a cercare di comprendere i requisiti richiesti.
Alla fine sono riuscito a capire che i requisiti richiesti dalla challenge sono i seguenti:

- Fare il provisioning di un'infrastruttura di 3 vm, utilizzando tool a piacere
- Sulla infrastruttura di 3 vm, installare un cluster kubernetes usando Ansible. 
    Il cluster dovrà essere composto di un master e 2 worker
- Le configurazioni da applicare devono garantire il rispetto dei requisiti 
    in termini di Risorse Computazionali, Filesystem e Sicurezza (minima) relativi a Kubernetes.
- 






Per installare e usare Jenkins ho deciso di usare docker, installato sul mio pc windows 10.
Ho utilizzato il comando:
docker pull jenkins/jenkins

Così da scaricare l'immagine di Jenkins.
Ho usato poi il comando:
docker run -p 8080:8080 -p 50000:50000 -v C:/JenkinsData:/var/jenkins_home jenkins/jenkins
così da far partire jenkins, configurando le porte e la cartella di appoggio 
Mi sono connesso a Jenkins su localhost:8080 e ho usato la password che ha generato per loggare la prima volta
Ho scelto di installare i plugin di default. Dato che nei requisiti era richiesto di utilizzare un linter per 
Ansible, Terraform e Helm ho provveduto a installare i componenti necessari.



uso il comando:
vagrant validate
così da controllare se il vagrant file è corretto

per controllare lo stato delle vm da vagrant uso il comando
vagrant global-status

quando avviavo vagrant con il comando:
vagrant up

mi dava come messaggio di errore:
The guest additions on this VM do not match the installed version of VirtualBox!
cercando online ho trovato che potevo risolvere utilizzando il comando:
vagrant plugin install vagrant-vbguest

per configurare la dimensione del disco ho installato questo plugin
vagrant plugin install vagrant-disksize



Cercando su internet ho trovato questi requisiti minimi per un cluster kubernetes:

 - Per quanto riguarda i requisiti hardware minimi ho trovato:
    - Per il master node  2 vCPU e 2GB RAM
    - Per i nodi worker  1vCPU e 2 GB RAM
    - range indirizzi ip statici 10.X.X.X/X 
    - per ogni vm 20 gb di spazio libero
- Per quanto riguarda i requisiti di filesystem:
    - Il filesystem sarà ext4
    - Su ogni vm sarà disabilitato la memoria swap
    - Sulle vm worker sarà definito una directory "/var/lib/kubelet"
    - Sulla vm master sarà definito una directory "/var/lib/etcd"



per la comunicazione nel cluster ho installato calico
Calico è una soluzione open-source per gestire il networking e la sicurezza in un cluster kubernetes.
Caratteristiche principali di Calico

Routing e Switching: Calico utilizza il routing basato su IP per fornire una rete ad alte prestazioni per i pod di Kubernetes. Può anche utilizzare BGP (Border Gateway Protocol) per distribuire le informazioni di routing tra i nodi.
Modalità Overlay e Non-Overlay: Calico può operare sia in modalità overlay che non-overlay. In modalità overlay, utilizza l'incapsulamento IP-in-IP o VXLAN per il traffico di rete tra i nodi. In modalità non-overlay, si basa sull'infrastruttura di rete sottostante per il routing.
Politiche di Rete:

 Calico consente di definire politiche di sicurezza della rete per controllare il flusso di traffico da e verso i pod di Kubernetes. Queste politiche possono essere utilizzate per applicare regole di sicurezza granulari basate su etichette dei pod, namespace, indirizzi IP e porte.
Politiche Globali e per Namespace: Calico supporta sia le politiche di rete globali (che si applicano a livello di cluster) sia le politiche di rete per namespace (che si applicano a namespace specifici).
Gestione degli Indirizzi IP:

 Calico assegna dinamicamente indirizzi IP ai pod da pool IP configurabili.
Pool IP Personalizzati: È possibile definire pool IP personalizzati e subnet per controllare gli intervalli di indirizzi IP utilizzati da Calico.
Integrazione con Kubernetes:

 Calico si integra con Kubernetes come plugin CNI (Container Network Interface), fornendo una rete senza soluzione di continuità per i pod di Kubernetes.
Calico implementa le risorse NetworkPolicy di Kubernetes, consentendo di utilizzare definizioni standard delle politiche di rete di Kubernetes.
Prestazioni e Scalabilità:

Calico è progettato per fornire una rete ad alte prestazioni con bassa latenza e alta velocità di trasmissione.
Scalabilità: Calico può scalare fino a grandi cluster Kubernetes con migliaia di nodi e decine di migliaia di pod.

Le alternative a Calico sono le seguenti:

Esistono diverse alternative a Calico, ognuna con le proprie caratteristiche e casi d'uso. Alcune delle alternative più comuni sono:

Flannel:
Flannel è un fornitore di rete overlay semplice e facile da configurare per Kubernetes.
Casi d'Uso: Adatto per cluster di piccole e medie dimensioni dove la semplicità è una priorità.

Weave:
Weave fornisce una soluzione di rete multi-host progettata per semplicità e setup rapido.
Casi d'Uso: Adatto per cluster dove la facilità d'uso e la gestione automatica della rete sono importanti.

Cilium:
Cilium è una soluzione di networking, sicurezza e bilanciamento del carico basata su eBPF (extended Berkeley Packet Filter).
Casi d'Uso: Adatto per ambienti che richiedono sicurezza avanzata, osservabilità e integrazione con service mesh.

Kube-Router:
Kube-Router è un fornitore CNI che si concentra sulla semplicità operativa e alte prestazioni.
Routing basato su BGP, politiche di rete, proxy di servizio, regole firewall.
Casi d'Uso: Adatto per cluster di grandi dimensioni con necessità di alte prestazioni e funzionalità di routing avanzate.

Differenze tra Calico e Altre Soluzioni
Calico e Kube-Router sono noti per le alte prestazioni grazie al loro approccio basato sul routing, mentre Flannel e Weave utilizzano reti overlay che possono introdurre un sovraccarico aggiuntivo.
Calico, Weave e Cilium offrono funzionalità robuste per le politiche di rete, mentre Flannel ha un supporto limitato per le politiche di rete.
Flannel e Weave sono noti per la loro semplicità e facilità di setup, mentre Calico e Cilium offrono funzionalità più avanzate e richiedono una configurazione maggiore.
 Cilium eccelle nelle funzionalità di sicurezza avanzate grazie alla sua implementazione basata su eBPF, mentre Calico offre anche funzionalità di sicurezza solide. Flannel è più basico in termini di capacità di sicurezza.

Ho scelto di usare Calico perchè mi è sembrato quello più completo e usato in rete. Ho trovato parecchia documentazione e quindi ho pensato che mi sarebbe stato
più facile trovare soluzioni se avessi trovato problemi. 


Per eseguire il benchmark di sicurezza sul cluster ho scelto di utilizzare il tool Kube-bench.
Ho scelto questo tool perchè mi è sembrato quello più affidabile e facile da utilizzare.
Posso eseguire CIS Benchmarks su kubernetes, security benchmark che ho scelto.
Per utilizzarlo mi è bastato creare un pod nel cluster.
Per il benchmark di sicurezza per kubernetes ho scelto di utilizzare CIS benchmark

I benchmark di sicurezza per Kubernetes forniscono linee guida e best practice per garantire la sicurezza e la conformità dei cluster Kubernetes.
 I benchmark di sicurezza più comunemente citati sono forniti dal Center for Internet Security (CIS) e
  dal National Institute of Standards and Technology (NIST).

La lista dei security benchmark è la seguente:
CIS Kubernetes Benchmark
Il CIS Kubernetes Benchmark è un insieme completo di linee guida per la sicurezza dei cluster Kubernetes.
 Copre una vasta gamma di aree, tra cui la configurazione del cluster, le politiche di rete e la sicurezza in fase di runtime.
Garantisce che il control-plane di Kubernetes sia configurato in modo sicuro.
Fornisce linee guida per la sicurezza dei nodi di lavoro.
Raccomanda l'implementazione di politiche di sicurezza di rete e dei pod.
Copre le best practice per la registrazione e il monitoraggio dell'ambiente Kubernetes.
Garantisce l'implementazione di meccanismi di autenticazione e autorizzazione appropriati.
Adatto per organizzazioni che cercano una valutazione completa della sicurezza e una guida alla configurazione dei loro cluster Kubernetes.

NIST SP 800-190
NIST SP 800-190 è una pubblicazione speciale del National Institute of Standards and Technology
focalizzata sulla sicurezza dei container, incluso Kubernetes. Fornisce linee guida per la sicurezza dell'ecosistema dei container.
Copre le misure di sicurezza durante tutto il ciclo di vita dei container.
Fornisce linee guida per la sicurezza delle piattaforme di orchestrazione dei container come Kubernetes.
Sottolinea l'importanza di proteggere il sistema operativo host che esegue i container.
Raccomanda le best practice per la sicurezza della rete all'interno degli ambienti dei container.
Ideale per organizzazioni che necessitano di un quadro completo di sicurezza che copra tutti gli aspetti della sicurezza dei container, non solo Kubernetes.
NSA Kubernetes Hardening Guidance
 La National Security Agency (NSA) fornisce linee guida per l'hardening dei cluster Kubernetes. 
 Queste linee guida si concentrano sulla sicurezza dei componenti e dei carichi di lavoro di Kubernetes.
Garantisce configurazioni sicure per l'API server.
Raccomanda l'implementazione di politiche di rete per limitare la comunicazione tra i pod.
Sottolinea l'importanza di proteggere i container in esecuzione e limitare le loro capacità.
Affronta le preoccupazioni di sicurezza relative alla catena di fornitura del software.
Adatto per organizzazioni che gestiscono informazioni sensibili che richiedono misure di sicurezza rigorose.

Differenze tra i Benchmark
CIS Benchmark: Principalmente focalizzato su configurazioni specifiche di Kubernetes e best practice.
NIST SP 800-190: Copre un ambito più ampio, incluso l'intero ciclo di vita dei container e l'orchestrazione.
NSA Guidance: Sottolinea gli ambienti ad alta sicurezza con raccomandazioni specifiche per l'hardening di Kubernetes.

Ho scelto di utilizzare CIS benchmark per verificare la sicurezza del cluster e verificare che le best practice fossero state eseguite.