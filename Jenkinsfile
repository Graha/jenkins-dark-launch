pipeline {
    agent  { label 'master' } 
    environment {
        Deployment_Versions = "v1.0\nv1.1\nv1.1\nv1.1.24\nv1.2\nv1.6.0\nv1.7.0\nv1.7.1\nv1.8.0"
        //gettags = ("git ls-remote -t -h git@github.com:RLIndia/cc.git | grep refs/tags | cut -f 3 -d '/'").execute()
    }
    stages {
        stage ('Initialize') {
            steps {
                echo "Initializing... "
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
        // stage ('Pick the Version') {
        //     steps {
        //         script {
        //             env.Deployment_Version = input(id: 'version', message: 'Select Deployment Version', parameters: [
        //                 [$class: 'TextParameterDefinition', defaultValue: '1.0', description: 'Version', name: 'version']
        //             ])
        //         }
        //         echo "Releasing package  v${env.Deployment_Version}"
        //     }
        // }
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
                         echo "Doing Data Migration..."
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