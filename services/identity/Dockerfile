FROM crapi/crapi-identity

ARG SERVER_PORT 

EXPOSE ${SERVER_PORT}

ENV JAVA_TOOL_OPTIONS "-Xmx128m"

CMD java -jar /app/identity-service-1.0-SNAPSHOT.jar
