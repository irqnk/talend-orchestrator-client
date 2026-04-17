# Talend Orchestrator — Guide d'installation

## Prérequis

Installez les deux outils suivants avant de commencer :

| Outil | Lien | Note |
|---|---|---|
| **Docker Desktop** | https://www.docker.com/products/docker-desktop | Obligatoire |
| **Git** *(optionnel)* | https://git-scm.com | Pour les mises à jour automatiques |

> Après l'installation de Docker Desktop, attendez que l'icône Docker soit verte dans la barre des tâches avant de continuer.

---

## Installation

### Sur Windows

Ouvrez une invite de commande (`cmd`) et exécutez :

```bash
git clone https://github.com/irqnk/talend-orchestrator-client.git
cd talend-orchestrator-client
start_client.bat
```

### Sur Mac / Linux

Ouvrez un terminal et exécutez :

```bash
git clone https://github.com/irqnk/talend-orchestrator-client.git
cd talend-orchestrator-client
docker-compose -f docker-compose.prod.yml up -d
```

---

## Sans Git (téléchargement manuel)

Si vous n'avez pas Git, téléchargez les fichiers manuellement :

**Windows** — ouvrez `cmd` et copiez ces 3 commandes :
```bash
curl -O https://raw.githubusercontent.com/irqnk/talend-orchestrator-client/main/docker-compose.prod.yml
curl -O https://raw.githubusercontent.com/irqnk/talend-orchestrator-client/main/agent_windows.bat
curl -O https://raw.githubusercontent.com/irqnk/talend-orchestrator-client/main/start_client.bat
start_client.bat
```

**Mac / Linux** :
```bash
curl -O https://raw.githubusercontent.com/irqnk/talend-orchestrator-client/main/docker-compose.prod.yml
docker-compose -f docker-compose.prod.yml up -d
```

---

## Accès à l'application

Une fois démarré, ouvrez votre navigateur et allez sur :

```
http://localhost:8001
```

---

## Mise à jour

Quand une nouvelle version est disponible :

**Windows :**
```bash
git pull
start_client.bat
```

**Mac / Linux :**
```bash
git pull
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

---

## Arrêter l'application

**Windows :**
```bash
docker-compose -f docker-compose.prod.yml down
```

**Mac / Linux :**
```bash
docker-compose -f docker-compose.prod.yml down
```

---

## Problèmes fréquents

**Docker Desktop n'est pas démarré**
> Lancez Docker Desktop depuis le menu Démarrer et attendez que l'icône soit verte.

**Le port 8001 est déjà utilisé**
> Modifiez `8001:8001` en `8080:8001` dans `docker-compose.prod.yml` et accédez à `http://localhost:8080`.

**L'application ne démarre pas**
> Consultez les logs :
> ```bash
> docker logs talend_app
> ```

---

## Support

Contactez l'administrateur pour toute question.
