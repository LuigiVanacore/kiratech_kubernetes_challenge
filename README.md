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

