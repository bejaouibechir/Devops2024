### Tutoriel : Création d'un Folder Jenkins avec Jobs et Configuration des Health Metrics

---

### 1️⃣ Objectif de la démo
- Créer un **Folder** pour organiser des jobs dans Jenkins.
- Ajouter des jobs dans le folder.
- Configurer et utiliser **Health Metrics** pour suivre la stabilité globale des jobs dans le folder.

---

### 2️⃣ Étapes détaillées

#### **Étape 1 : Créer un Folder dans Jenkins**
1. Allez dans Jenkins → `New Item`.
2. Donnez un nom au folder, par exemple : `MyFolder`.
3. Choisissez **"Folder"** comme type de projet.
4. Cliquez sur **OK**.
5. Configurez le folder :
   - Ajoutez une description (par exemple : "Dossier pour organiser mes projets").
   - Cliquez sur **Save**.

---

#### **Étape 2 : Ajouter des Jobs dans le Folder**

##### **A. Ajout d'un Job qui réussit (SimpleJob)**
1. Entrez dans `MyFolder`.
2. Cliquez sur `New Item`.
3. Donnez un nom au job : `SimpleJob`.
4. Sélectionnez **Freestyle Project** et cliquez sur **OK**.
5. Configurez une tâche simple :
   - Dans **Build** → **Execute Shell**, ajoutez :
     ```bash
     echo "Hello from SimpleJob in MyFolder"
     ```
   - Cliquez sur **Save**.
6. Lancez le job :
   - Cliquez sur **Build Now**.
   - Vérifiez que le job réussit.

---

##### **B. Ajout d'un Job qui échoue (FailingJob)**
1. Retournez dans `MyFolder` → `New Item`.
2. Donnez un nom au job : `FailingJob`.
3. Sélectionnez **Freestyle Project** et cliquez sur **OK**.
4. Configurez une tâche qui échoue intentionnellement :
   - Dans **Build** → **Execute Shell**, ajoutez :
     ```bash
     exit 1
     ```
   - Cliquez sur **Save**.
5. Lancez le job :
   - Cliquez sur **Build Now**.
   - Vérifiez que le job échoue.

---

#### **Étape 3 : Configurer les Health Metrics**

1. Retournez dans les paramètres de `MyFolder` :
   - Cliquez sur **Configure**.
2. Activez les **Health Metrics** :
   - Dans la section **Health metrics**, cliquez sur **Add metric**.
   - Sélectionnez **Child item with worst health**.
3. Sauvegardez.

---

#### **Étape 4 : Observer les résultats des Health Metrics**

1. Retournez à la page d’accueil de Jenkins.
2. Vérifiez l’icône de santé associée au folder `MyFolder` :
   - Si `FailingJob` échoue, la santé du folder est mauvaise (rouge ou jaune).
   - Si tous les jobs réussissent, la santé sera bonne (verte).
3. Les métriques sont automatiquement mises à jour après chaque build.

---

### Résultat attendu
- **Folder `MyFolder`** contient deux jobs :
  - `SimpleJob` qui réussit.
  - `FailingJob` qui échoue.
- L’état de santé global du folder reflète le statut du job ayant la pire performance (via Health Metrics).

---

### 3️⃣ Avantages de cette configuration
- **Organisation** : Les jobs sont regroupés pour un meilleur suivi.
- **Suivi de stabilité** : L’état de santé global permet de repérer rapidement les problèmes.
- **Efficacité** : Priorisation des actions à entreprendre pour stabiliser les jobs.

---

