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

Ho scelto di utilizzare CIS benchmark per verificare la sicurezza del cluster e verificare che le best practice fossero state eseguite.