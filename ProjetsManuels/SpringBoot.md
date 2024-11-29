# Tutoriel : Création d'une application Spring Boot sur Ubuntu 22.04

### **1. Préparation de l'environnement**

1. **Mettre à jour le système** :
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Installer Java (JDK 17)** :
   ```bash
   sudo apt install openjdk-17-jdk -y
   java -version
   ```

3. **Installer Maven** :
   ```bash
   sudo apt install maven -y
   mvn -version
   ```

---

### **2. Création de la structure du projet à la main**

#### **2.1 Structure complète du projet**
Voici l'arborescence complète du projet Spring Boot que vous allez construire manuellement :

```
springboot-app/
├── src/
│   ├── main/
│   │   ├── java/com/example/demo/
│   │   │   ├── DemoApplication.java
│   │   │   ├── controller/
│   │   │       └── HelloController.java
│   │   ├── resources/
│   │       ├── application.properties
├── pom.xml
```

---

#### **2.2 Création des dossiers**
- Exécutez les commandes suivantes pour créer la structure de dossiers :

```bash
mkdir -p ~/springboot-app/src/main/java/com/example/demo/controller
mkdir -p ~/springboot-app/src/main/resources
```

---

### **3. Création des fichiers un par un**

#### **3.1 Fichier : `DemoApplication.java`**
- **Chemin** : `~/springboot-app/src/main/java/com/example/demo/DemoApplication.java`
- **Code :**

```java
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```

- **Explication** :
  - Ce fichier contient le point d'entrée principal de l'application.
  - L'annotation `@SpringBootApplication` configure Spring Boot automatiquement.

---

#### **3.2 Fichier : `HelloController.java`**
- **Chemin** : `~/springboot-app/src/main/java/com/example/demo/controller/HelloController.java`
- **Code :**

```java
package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @GetMapping("/")
    public String hello() {
        return "Hello, Spring Boot!";
    }
}
```

- **Explication** :
  - Ce fichier définit un contrôleur Spring Boot.
  - L'annotation `@RestController` permet de gérer les requêtes HTTP.
  - La méthode `hello()` retourne le texte `"Hello, Spring Boot!"` lorsqu'on accède à la racine (`/`).

---

#### **3.3 Fichier : `application.properties`**
- **Chemin** : `~/springboot-app/src/main/resources/application.properties`
- **Code :**

```properties
server.port=8080
```

- **Explication** :
  - Ce fichier configure le port du serveur (par défaut : 8080).

---

#### **3.4 Fichier : `pom.xml`**
- **Chemin** : `~/springboot-app/pom.xml`
- **Code :**

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <properties>
        <java.version>17</java.version>
        <spring-boot.version>3.1.4</spring-boot.version>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
            <version>${spring-boot.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <version>${spring-boot.version}</version>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.10.1</version>
                <configuration>
                    <source>${java.version}</source>
                    <target>${java.version}</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>${spring-boot.version}</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

- **Explication** :
  - Ce fichier contient la configuration du projet Maven.
  - Les dépendances incluent Spring Boot et Spring Web.
  - Le plugin `spring-boot-maven-plugin` permet de créer un JAR exécutable.

---

### **4. Compilation et exécution**

#### **4.1 Compilation du projet**
- Placez-vous dans le répertoire du projet :
  ```bash
  cd ~/springboot-app
  ```
- Compilez et packagez l'application :
  ```bash
  mvn clean package
  ```

---

#### **4.2 Exécution de l'application**
- Lancez l'application Spring Boot :
  ```bash
  java -jar target/demo-0.0.1-SNAPSHOT.jar
  ```

---

### **5. Résultat attendu**

1. Ouvrez un navigateur ou utilisez `curl` pour accéder à l'application :
   ```bash
   curl http://<EC2_PUBLIC_IP>:8080
   ```
2. Le navigateur ou `curl` doit afficher :
   ```
   Hello, Spring Boot!
   ```
