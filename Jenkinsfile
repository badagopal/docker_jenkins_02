pipeline {
    agent any

    environment {
        // Define Docker image and network names
        DOCKER_IMAGE = 'myapp'
        DOCKER_NETWORK_PREFIX = 'branch_network'
        DOCKER_VOLUME_PREFIX = 'branch_volume'
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout code from the repository
                checkout scm
            }
        }

        stage('Build and Deploy') {
            // Iterate over all branches in the repository
            steps {
                script {
                    // Get list of branches from Git repository
                    def branches = sh(script: 'git ls-remote --heads origin', returnStdout: true).trim().split('\n')

                    branches.each { branch ->
                        // Extract branch name from Git reference
                        def branchName = branch.tokenize('/').last()

                        // Skip the 'refs/heads/master' branch if desired
                        if (branchName == 'master') {
                            echo "Skipping deployment for master branch"
                            return
                        }

                        // Build Docker image for the branch
                        docker.build("${DOCKER_IMAGE}:${branchName}")

                        // Create and run Docker container for the branch
                        docker.withRegistry('http://your-docker-registry-url', 'docker-credentials-id') {
                            def dockerNetwork = "${DOCKER_NETWORK_PREFIX}_${branchName}"
                            def dockerVolume = "${DOCKER_VOLUME_PREFIX}_${branchName}"

                            // Create Docker network for the branch (if needed)
                            sh "docker network create ${dockerNetwork} || true"

                            // Create Docker volume for the branch (if needed)
                            sh "docker volume create ${dockerVolume} || true"

                            // Run Docker container
                            def containerId = docker.run("-d --name ${DOCKER_IMAGE}_${branchName} --network ${dockerNetwork} -v ${dockerVolume}:/app/data ${DOCKER_IMAGE}:${branchName}")

                            echo "Deployed branch ${branchName} with container ID ${containerId}"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up: Remove unused Docker containers, networks, and volumes
            cleanDocker()
        }
    }
}

def cleanDocker() {
    // Remove all stopped containers
    sh "docker rm -f \$(docker ps -a -q) || true"

    // Remove all unused networks
    sh "docker network prune -f"

    // Remove all unused volumes
    sh "docker volume prune -f"
}
