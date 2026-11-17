
# Use Java 21 runtime as the base image
FROM eclipse-temurin:21-jre

# Set the working directory inside the container
WORKDIR /app

# Copy the Maven-generated JAR into the container
COPY target/hello-maven-1.0-SNAPSHOT.jar app.jar

# Start the Java application when the container runs
ENTRYPOINT ["java", "-jar", "app.jar"]

