pipeline {
    agent  { label 'master' } 
    environment {
        Deployment_Versions = "2.0\n1.0"
        //gettags = ("git ls-remote -t -h git@github.com:RLIndia/cc.git | grep refs/tags | cut -f 3 -d '/'").execute()
    }
    stages {
        stage ('Initialize') {
            steps {
                script {
                    env.Deployment_Name = input(id: 'name', message: 'Select Deployment Stack Name', parameters: [
                        [$class: 'TextParameterDefinition', defaultValue: 'cc', description: 'Stack Name', name: 'name']
                    ])
                }
                echo "Deployment Stack ${env.Deployment_Name}"
            }
        }
        stage ('Pick the Version') {
            steps {
                script {
                    env.Deployment_Version = input(id: 'version', message: 'Select Deployment Version', parameters: [
                            choice(
                                name: 'Deployment Version',
                                choices: env.Deployment_Versions,
                                description: "Deployment Version...")
                    ])
                }
                echo "Releasing package  v${env.Deployment_Version}"
            }
        }
        stage ('Deployment Method') {
            // Blue/Green Deployment
            // A/B Testing
            // Canary 
            // Clean or Fresh Deployment
            steps {
                script {
                    env.Deployment_Method = input (id: 'method', message: 'Select Deployment Methods', ok: 'Deploy',
                        parameters: [
                            choice(
                                name: 'Deployment Methods',
                                choices:"Clean\nBlue/Green\nA/B Testing\nCanary",
                                description: "Deployment Methods...")
                    ])
                }
                echo "Releasing on ${env.Deployment_Method} mode."
            }
        }
        stage ('Prepare Release') {
            steps {
                sh "bash prepare.sh ${env.Deployment_Version} ${env.Deployment_Method}"
                echo "Preparing Release Procedure..."
            }
        }
        // stage ('Prepare Chef') {
        //     steps {
        //         echo "Preparing Chef Procedure..."
        //     }
        // }
        stage ('Release') {
            parallel {
                stage('Releasing On FrontEnd Cluster') {
                    // agent {
                    //     label "frontend"
                    // }
                    steps {
                        echo "Releasing on frontend Cluster"
                    }
                    post {
                        always {
                            //junit "**/TEST-*.xml"
                            echo "Verified FrontEnd release"
                        }
                    }
                }
                stage('Releasing On Backend Cluster') {
                    // agent {
                    //     label "backend"
                    // }
                    steps {
                         echo "Releasing on backend Cluster"
                    }
                    post {
                        always {
                            //junit "**/TEST-*.xml"
                            echo "Verified Backend release"
                        }
                    }
                }
                stage('Migrating Data Store') {
                    // agent {
                    //     label "database"
                    // }
                    steps {
                         echo "No Data Migration available to do..."
                    }
                    post {
                        always {
                            //junit "**/TEST-*.xml"
                            echo "Verified Data Migration"
                        }
                    }
                }
            }

        }
        stage ('Cleanup') {
            steps {
                echo "Cleanup in progress..."
            }
        }        
    }
}


def docker_pull(version) {
    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
        //def img = docker.image("relevancelab/cc:${version}")
        //img.pull()
        sh "docker pull graha/go-web:${version}"
    }
}


def notify(status, version, environment) {
    def host = sh(script: 'hostname', returnStdout: true).trim()
    def os = sh(script: 'uname', returnStdout: true).trim()

  //slackSend (color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
  emailext (
      subject: "Deployment of 'CC:v${version} on ${host}-${os} (${environment}) , ${status}'",
      body: """<p>Deployment of 'CC:v${version} on ${host}-${os} (${environment}), ${status}'</p>
        <p>Check console output at "<a href="${env.BUILD_URL}">${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>"</p>""",
      mimeType: 'text/html',
      //to: "rlc.support@relevancelab.com"
      to: "giragadurai.vallirajan@relevancelab.com"
      //recipientProviders: [[$class: 'DevelopersRecipientProvider']]
    )
}