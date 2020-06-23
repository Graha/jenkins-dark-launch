pipeline {
    agent any  
    stages {
        stage ('Initialize') {
            steps {
                echo "Chosen Stack Name :: ${env.Deployment_Name}"
            }
        }
        stage ('Release Version') {
            steps {
                echo "Chosen package Version :: ${env.Deployment_Version}"
            }
        }
        stage ('Deployment Method') {
            steps {
                echo "Releasing on ${env.Deployment_Method} mode."
            }
        }
        stage ('Prepare Release') {
            steps {
                echo "Preparing Release Procedure..."
                //TBR
                //docker_pull(env.Deployment_Version)
                sleep 5
            }
        }
        // stage ('Prepare Chef') {
        //     steps {
        //         echo "Preparing Chef Procedure..."
        //     }
        // }
        stage ('Release') {
            parallel {
                stage('Releasing On Application Cluster') {
                    // agent {
                    //     label "frontend"
                    // }
                    steps {
                        echo "Releasing on Application Cluster"
                        //TBR
                        //sh "bash deploy.sh ${env.Deployment_Version} ${env.Deployment_Method} ${env.Deployment_Name}"
                        echo "bash deploy.sh ${env.Deployment_Version} ${env.Deployment_Method} ${env.Deployment_Name}"
                    }
                    post {
                        always {
                            echo "Verified Application release"
                        }
                    }
                }
                stage('Updating Configuration') {
                    // agent {
                    //     label "database"
                    // }
                    steps {
                         echo "No configuration updates available to do..."
                    }
                    post {
                        always {
                            echo "Verified Configuration Updates (if any)"
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
                            echo "Verified Data Migration (if any)"
                        }
                    }
                }
            }

        }
        stage ('Cleanup') {
            steps {
                echo "Cleanup in progress..."
                script{
                    //Clean\nBlue/Green\nA/B-Testing\nCanary
                    if (env.Deployment_Method == 'Blue/Green') {
                        script {
                            env.Cleanup = input (id: 'cleanup', message: 'Release or Rollback?', ok: 'Do',
                                parameters: [
                                    choice(
                                        name: 'Release or Rollback Version',
                                        choices:"Rollback\nRelease",
                                        description: "Release or Rollback the Version...")
                            ])
                        }
                        //TBR
                        //sh "bash clean.sh ${env.Cleanup} ${env.Deployment_Name}"
                        echo "bash clean.sh ${env.Cleanup} ${env.Deployment_Name}"
                    }else if (env.Deployment_Method == 'Canary') {
                        script {
                            env.Cleanup = input (id: 'cleanup', message: 'Addup or Rollback Canary?', ok: 'Do',
                                parameters: [
                                    choice(
                                        name: 'Addup or Rollback Canary',
                                        choices:"Rollback\nAddup",
                                        description: "Addup or Rollback the Canary...")
                            ])
                        }
                        //TBR
                        //sh "bash clean.sh ${env.Cleanup} ${env.Deployment_Name}"
                        echo "bash clean.sh ${env.Cleanup} ${env.Deployment_Name}"
                    } else if (env.Deployment_Method == 'A/B-Testing') { 
                        script {
                            env.Cleanup = input (id: 'cleanup', message: 'Cleanup A or B?', ok: 'Do',
                                parameters: [
                                    choice(
                                        name: 'Cleanup A or B Version',
                                        choices:"A\nB",
                                        description: "Cleanup A or B Version...")
                            ])
                        }
                        //TBR
                        //sh "bash clean.sh ${env.Cleanup} ${env.Deployment_Name}"
                        echo "bash clean.sh ${env.Cleanup} ${env.Deployment_Name}"                    
                    } else {
                        echo "Cleanup process skipped..."
                    }
                }
                notify("Done", env.Deployment_Version, "Demo")
            }
        }        
    }
}


def docker_pull(version) {
    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
        sh "docker pull cc:${version}"
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
      to: "satheesh@polysign.io"
    )
}
