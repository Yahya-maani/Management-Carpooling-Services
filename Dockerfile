# Build stage: Utilisation de JDK 17 pour correspondre à Jenkins
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

COPY pom.xml ./
COPY src ./src

# Package
RUN mvn -B -DskipTests package

# Runtime stage: Tomcat 9 avec JDK 17
FROM tomcat:9.0-jdk17-temurin

# Nettoyage et déploiement
RUN rm -rf /usr/local/tomcat/webapps/*

# Correction : on utilise une wildcard pour copier le WAR quel que soit son nom exact
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 7070
# On s'assure que Tomcat écoute sur le port 7070 (par défaut c'est 8080)
# Note: Pour que EXPOSE 7070 fonctionne vraiment, il faut modifier le server.xml de Tomcat
# Sinon, changez juste votre commande de run : docker run -p 7070:8080
CMD ["catalina.sh", "run"]