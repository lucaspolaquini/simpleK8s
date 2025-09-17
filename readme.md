# SimpleK8s NGINX Demo — Guia Completo e Didático

Este projeto demonstra, na prática, como gerenciar Deployments no Kubernetes usando estratégias Blue/Green e Canary, inspirado em labs como o "Managing Deployments Using Kubernetes Engine" do Google Cloud. Aqui você aprende desde o básico até técnicas avançadas de atualização e rollback, com exemplos e comandos explicados em português.

---

## Dicas Rápidas

- **Descubra o que cada recurso faz:**  
  `kubectl explain <tipo>`  
  Exemplo:  
  `kubectl explain deployment`  
  Mostra a documentação do recurso, campos obrigatórios e exemplos.

- **Veja todos os campos de um recurso:**  
  `kubectl explain deployment --recursive`  
  Exibe todos os campos possíveis do objeto deployment.

- **Veja toda a configuração de um recurso:**  
  `kubectl get <tipo> <nome> -o yaml`  
  Exemplo:  
  `kubectl get deployment nginx-blue -o yaml`

- **Liste todos os recursos principais:**  
  `kubectl get all`

- **Filtre recursos por label:**  
  `kubectl get pods -l app=nginx-demo`

- **Veja detalhes completos de um recurso:**  
  `kubectl describe <tipo> <nome>`  
  Exemplo:  
  `kubectl describe deployment nginx-blue`

---

## Estrutura dos Arquivos

```
cleanup.sh
configmaps/
  nginx-v1-config.yaml
  nginx-v2-config.yaml
deployments/
  nginx-blue.yaml
  nginx-canary.yaml
  nginx-green.yaml
services/
  nginx-blue-service.yaml
  nginx-green-service.yaml
  nginx.yaml
```

### Descrição dos Arquivos

- **cleanup.sh**  
  Script para deletar todos os recursos criados no laboratório. Remove Services, Deployments e ConfigMaps relacionados ao projeto.

- **configmaps/nginx-v1-config.yaml**  
  ConfigMap para a versão 1.0.0 do NGINX. Define o conteúdo do `index.html` exibindo "Versão 1.0.0".

- **configmaps/nginx-v2-config.yaml**  
  ConfigMap para a versão 2.0.0 do NGINX. Define o conteúdo do `index.html` exibindo "Versão 2.0.0".

- **deployments/nginx-blue.yaml**  
  Deployment para o ambiente "Blue" (versão 1.0.0). Cria 3 réplicas do NGINX 1.25.5, usando o ConfigMap da versão 1.

- **deployments/nginx-green.yaml**  
  Deployment para o ambiente "Green" (versão 2.0.0). Cria 3 réplicas do NGINX 1.26.0, usando o ConfigMap da versão 2.

- **deployments/nginx-canary.yaml**  
  Deployment para o ambiente "Canary" (versão 2.0.0). Cria 1 réplica do NGINX 1.26.0, usando o ConfigMap da versão 2. Permite testar a nova versão antes de migrar totalmente.

- **services/nginx.yaml**  
  Service principal, expõe o NGINX na porta 80 via LoadBalancer, selecionando pods com `app: nginx-demo`.

- **services/nginx-blue-service.yaml**  
  Service para o ambiente Blue, expõe pods da versão 1.0.0.

- **services/nginx-green-service.yaml**  
  Service para o ambiente Green, expõe pods da versão 2.0.0.

---

## Pré-requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado e rodando.
- [kubectl](https://kubernetes.io/docs/tasks/tools/) instalado e configurado para usar o cluster local do Docker Desktop.

---

## Passo a Passo: Execução Local

### 1. Iniciar o Kubernetes no Docker Desktop

Abra o Docker Desktop e habilite o Kubernetes nas configurações. Aguarde até que o cluster esteja pronto.

### 2. Aplicar ConfigMaps

```sh
kubectl apply -f configmaps/nginx-v1-config.yaml
kubectl apply -f configmaps/nginx-v2-config.yaml
```
Esses comandos criam arquivos de página para cada versão, para isso, estamos usando o configmaps.

### 3. Deploy Blue (Versão 1.0.0)

```sh
kubectl apply -f deployments/nginx-blue.yaml
kubectl apply -f services/nginx-blue-service.yaml
```
Cria 3 pods NGINX versão 1.0.0 e um Service para expor esses pods.

### 4. Deploy Green (Versão 2.0.0)

```sh
kubectl apply -f deployments/nginx-green.yaml
kubectl apply -f services/nginx-green-service.yaml
```
Cria 3 pods NGINX versão 2.0.0 e um Service para expor esses pods.

### 5. Deploy Canary (Teste da nova versão)

```sh
kubectl apply -f deployments/nginx-canary.yaml
```
Cria 1 pod NGINX versão 2.0.0 para testes antes de migrar totalmente.

### 6. Service Global

```sh
kubectl apply -f services/nginx.yaml
```
Cria um Service LoadBalancer que pode ser usado para rotear para todos os pods com `app: nginx-demo`.

---

## Testando os Deploys e Explorando Recursos

### Listar Pods

```sh
kubectl get pods -l app=nginx-demo
```
Mostra todos os pods NGINX criados.

### Ver os grupos de réplicas (ReplicaSets)

```sh
kubectl get rs
```
Mostra os grupos que garantem o número de pods de cada versão.

### Ver os Deployments

```sh
kubectl get deployments
```
Lista todos os Deployments ativos (Blue, Green, Canary).

### Ver os serviços

```sh
kubectl get svc
```
Mostra os serviços, portas e IPs para acessar os pods.

### Ver recursos relacionados

```sh
kubectl get all
```
Mostra pods, services, deployments, replicaSets, etc. de uma vez.

### Buscar Status dos Deployments

```sh
kubectl rollout status deployment/nginx-blue
kubectl rollout status deployment/nginx-green
kubectl rollout status deployment/nginx-canary
```
Mostra se o rollout está completo ou ainda em andamento.

### Pausar e Retomar Deployments

Pausar:
```sh
kubectl rollout pause deployment/nginx-green
```
Interrompe atualizações automáticas do Deployment "nginx-green".

Retomar:
```sh
kubectl rollout resume deployment/nginx-green
```
Continua o rollout do Deployment.

### Ver detalhes de um recurso

```sh
kubectl describe deployment nginx-blue
kubectl describe pod <nome-do-pod>
kubectl describe svc nginx-blue
kubectl describe configmap nginx-v1-config
```
Mostra informações detalhadas sobre o recurso, incluindo eventos, status, labels, volumes, etc.

### Ver toda a configuração de um recurso

```sh
kubectl get deployment nginx-blue -o yaml
```
Exibe o YAML completo do Deployment.

### Testar a versão servida

Descubra a porta do serviço:
```sh
kubectl get svc nginx-blue
kubectl get svc nginx-green
```
Acesse pelo navegador ou curl:
```sh
curl http://localhost:<PORTA>
```
Você verá "Versão 1.0.0" ou "Versão 2.0.0" conforme o serviço acessado.

### Ver logs dos pods

```sh
kubectl logs <nome-do-pod>
```
Veja os logs do container NGINX para depuração.

### Acessar o shell do pod

```sh
kubectl exec -it <nome-do-pod> -- /bin/bash
```
Acesse o shell do pod para investigar arquivos, processos, etc.

---

## Demo Completa

1. **Crie os ConfigMaps**  
   `kubectl apply -f configmaps/nginx-v1-config.yaml`  
   `kubectl apply -f configmaps/nginx-v2-config.yaml`

2. **Deploy Blue**  
   `kubectl apply -f deployments/nginx-blue.yaml`  
   `kubectl apply -f services/nginx-blue-service.yaml`

3. **Verifique pods e services**  
   `kubectl get pods -l app=nginx-demo,version=1.0.0`  
   `kubectl get svc nginx-blue`

4. **Deploy Green**  
   `kubectl apply -f deployments/nginx-green.yaml`  
   `kubectl apply -f services/nginx-green-service.yaml`

5. **Deploy Canary**  
   `kubectl apply -f deployments/nginx-canary.yaml`

6. **Verifique ReplicaSets e status**  
   `kubectl get rs`  
   `kubectl rollout status deployment/nginx-green`

7. **Pause e retome o rollout**  
   `kubectl rollout pause deployment/nginx-green`  
   `kubectl rollout resume deployment/nginx-green`

8. **Teste o conteúdo**  
   `curl http://localhost:<PORTA_BLUE>`  
   `curl http://localhost:<PORTA_GREEN>`

9. **Limpeza**  
   `sh cleanup.sh`

---

## O que é esperado?

- **Blue:** NGINX servindo "Versão 1.0.0" em 3 réplicas.
- **Green:** NGINX servindo "Versão 2.0.0" em 3 réplicas.
- **Canary:** NGINX servindo "Versão 2.0.0" em 1 réplica para teste.
- **Services:** Cada ambiente exposto em uma porta diferente.
- **Rollout:** Status, pausa e retomada funcionam conforme esperado.
- **Limpeza:** Todos os recursos removidos com `cleanup.sh`.

---

## Resumo dos Comandos Mais Usados

| Comando                                    | O que faz                                               |
|---------------------------------------------|---------------------------------------------------------|
| kubectl apply -f <arquivo>                  | Cria ou atualiza recurso a partir de um arquivo YAML    |
| kubectl get <tipo>                          | Lista recursos do tipo especificado                     |
| kubectl describe <tipo> <nome>              | Mostra detalhes completos do recurso                    |
| kubectl get all                             | Lista todos os recursos principais                      |
| kubectl rollout status deployment/<nome>    | Mostra status do rollout do Deployment                  |
| kubectl rollout pause/resume deployment/<nome> | Pausa ou retoma atualizações automáticas                |
| kubectl logs <pod>                          | Mostra logs do pod                                      |
| kubectl exec -it <pod> -- /bin/bash         | Abre terminal dentro do pod                             |
| sh cleanup.sh                               | Remove todos os recursos do projeto                     |

---

## Dicas para Explorar

- Use `kubectl explain <tipo>` para aprender sobre cada campo de um recurso.
- Use `kubectl get <tipo> -o yaml` para ver a configuração completa em YAML.
- Experimente alterar réplicas nos arquivos YAML e aplicar novamente para ver o efeito.
- Use labels para filtrar e organizar seus recursos.

---

## Observações

- No Docker Desktop, o tipo `LoadBalancer` pode ser mapeado para `NodePort`. Use `kubectl get svc` para descobrir a porta.
- Para ambientes reais, adapte os manifests para seu cluster.

---

## Referências

- [Documentação oficial do Kubernetes](https://kubernetes.io/docs/home/)
- [NGINX Docker Hub](https://hub.docker.com/_/nginx)