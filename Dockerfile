FROM tomcat:10.1-jdk21

# Supprimer l'application ROOT par défaut de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Déployer les fichiers webapp (JSP, web.xml) dans ROOT
COPY src/main/webapp /usr/local/tomcat/webapps/ROOT

# Créer le dossier WEB-INF/classes pour les servlets et beans compilés
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/WEB-INF/classes

# Copier le code source Java
COPY src/main/java /tmp/src

# Compiler les classes Java avec l'API Jakarta Servlet de Tomcat et bibliothèques
RUN javac -encoding UTF-8 -cp "/usr/local/tomcat/lib/*:/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*" -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes $(find /tmp/src -name "*.java") \
    && rm -rf /tmp/src

EXPOSE 8080

CMD ["catalina.sh", "run"]
