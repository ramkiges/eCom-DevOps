pipeline {
    agent none

    parameters {
        booleanParam(name: 'BUILD_PACKAGES', defaultValue: isReleaseBranch(),
                     description: 'Create Android, iOS and Windows packages for succeeding builds')

        booleanParam(name: 'BUILD_FOR_ANDROID', defaultValue: buildForNode('Android'),
                     description: 'Compile the project for Android')
        booleanParam(name: 'BUILD_FOR_IOS', defaultValue: buildForNode('iOS'),
                     description: 'Compile the project for iOS')
        booleanParam(name: 'BUILD_FOR_LINUX', defaultValue: buildForNode('Linux'),
                     description: 'Compile the project for Linux')
        booleanParam(name: 'BUILD_FOR_MACOS', defaultValue: buildForNode('macOS'),
                     description: 'Compile the project for macOS')
        booleanParam(name: 'BUILD_FOR_WINDOWS', defaultValue: buildForNode('Windows'),
                     description: 'Compile the project for Windows')
    }

    options {
        skipDefaultCheckout()
    }

    environment {
        QT_QPA_PLATFORM = 'offscreen'
    }

    stages {
        stage('Show Build Parameters') {
            steps {
                echo """
                    BUILD_PACKAGES: ${params.BUILD_PACKAGES}
                    BUILD_FOR_ANDROID: ${params.BUILD_FOR_ANDROID}
                    BUILD_FOR_IOS: ${params.BUILD_FOR_IOS}
                    BUILD_FOR_LINUX: ${params.BUILD_FOR_LINUX}
                    BUILD_FOR_MACOS: ${params.BUILD_FOR_MACOS}
                    BUILD_FOR_WINDOWS: ${params.BUILD_FOR_WINDOWS}
                    """.stripIndent()
            }
        } // stage

        stage('Mobile Apps') {
            parallel {
                stage('macOS') {
                    agent {
                        node {
                            label 'macOS'
                            customWorkspace shortWorkspacePath()
                        }
                    }

                    when {
                        expression { return params.BUILD_FOR_MACOS }
                    }

                    environment {
                        BUILDDIR = "build-${STAGE_NAME}"
                        CCACHE_BASEDIR = "${WORKSPACE}"
                        PATH = pathWithToolsAdded()
                        QT_ROOT = "${env.QT_ROOT_MACOS}"
                    }

                    stages {
                        stage('Checkout for macOS') {
                            steps { checkoutFromBitbucket() }
                        }

                        stage('Configure for macOS') {
                            steps {
                                configureWithCMake env.BUILDDIR, [
                                    '-DFXM_SERIALPORT_ENABLED:BOOL=ON',
                                ]
                            }
                        }

                        stage('Compile for macOS') {
                            steps { buildProject env.BUILDDIR }
                        }

                        stage('Test on macOS') {
                            steps { runTests env.BUILDDIR }
                            post { always { junit "build-macOS/tests/auto/tst_*.xml" } }
                        }
                    }
                } // stage

                stage('iOS') {
                    agent {
                        node {
                            label 'iOS'
                            customWorkspace shortWorkspacePath()
                        }
                    }

                    when {
                        expression { return params.BUILD_FOR_IOS }
                    }

                    environment {
                        BUILDDIR = "build-${STAGE_NAME}"
                        CCACHE_BASEDIR = "${WORKSPACE}"
                        PATH = pathWithToolsAdded()
                        QT_ROOT = "${env.QT_ROOT_IOS}"
                    }

                    stages {
                        stage('Checkout for iOS') {
                            steps { checkoutFromBitbucket() }
                        }

                        stage('Configure for iOS') {
                            steps {
                                configureWithQMake env.BUILDDIR, [
                                        'CONFIG+=iphoneos', 'CONFIG+=device', 'PROVISIONING=development',
                                        'QMAKE_CC=/usr/local/opt/ccache/libexec/clang',
                                        'QMAKE_CXX=/usr/local/opt/ccache/libexec/clang++',
                                    ]
                            }
                        }

                        stage('Compile for iOS') {
                            steps { buildProject env.BUILDDIR }
                        }

                        stage('Package for iOS') {
                            when { expression { return params.BUILD_PACKAGES } }
                            steps { createPackage env.BUILDDIR }

                            post {
                                always {
                                    archiveArtifacts artifacts: 'build-*/packages/*.dSYM.zip'
                                    archiveArtifacts artifacts: 'build-*/packages/*.ipa'
                                }
                            }
                        }
                    }
                } // stage

                stage('Android') {
                    agent {
                        node {
                            label 'Android'
                            customWorkspace shortWorkspacePath()
                        }
                    }

                    when {
                        expression { return params.BUILD_FOR_ANDROID }
                    }

                    environment {
                        ANDROID_NDK_PLATFORM = "android-23"
                        BUILDDIR = "build-${STAGE_NAME}"
                        CCACHE_BASEDIR = "${WORKSPACE}"
                        PATH = pathWithToolsAdded()
                        QT_ROOT = "${env.QT_ROOT_ANDROID}"
                    }

                    stages {
                        stage('Checkout for Android') {
                            steps { checkoutFromBitbucket() }
                        }

                        stage('Configure for Android') {
                            steps {
                                configureWithQMake env.BUILDDIR, ['FXM_CCACHE_PREFIX=ccache']
                            }
                        }

                        stage('Compile for Android') {
                            steps { buildProject env.BUILDDIR }
                        }

                        stage('Package for Android') {
                            when { expression { return params.BUILD_PACKAGES } }

                            steps {
                                withCredentials([string(credentialsId: 'meiller-mobileapps-storepass', variable: 'storepass')]) {
                                    withEnv(["ANDROID_STOREPASS=$storepass"]) {
                                        createPackage env.BUILDDIR
                                    }
                                }
                            }

                            post { always { archiveArtifacts artifacts: 'build-*/packages/*.apk' } }
                        }
                    }
                } // stage

                stage('Linux') {
                    agent {
                        node {
                            label 'Linux'
                            customWorkspace shortWorkspacePath()
                        }
                    }

                    when {
                        expression { return params.BUILD_FOR_LINUX }
                    }

                    environment {
                        BUILDDIR = "build-${STAGE_NAME}"
                        CCACHE_BASEDIR = "${WORKSPACE}"
                        PATH = pathWithToolsAdded()
                        QT_ROOT = "${env.QT_ROOT_LINUX}"
                    }

                    stages {
                        stage('Checkout for Linux') {
                            steps { checkoutFromBitbucket() }
                        }

                        stage('Configure for Linux') {
                            steps {
                                configureWithCMake env.BUILDDIR, [
                                    '-DFXM_SERIALPORT_ENABLED:BOOL=ON',
                                ]
                            }
                        }

                        stage('Compile for Linux') {
                            steps { buildProject env.BUILDDIR }
                        }

                        stage('Test on Linux') {
                            steps { runTests env.BUILDDIR }
                            post { always { junit "build-Linux/tests/auto/tst_*.xml" } }
                        }
                    }
                } // stage

                stage('Windows') {
                    agent {
                        node {
                            label 'Windows'
                            customWorkspace shortWorkspacePath()
                        }
                    }

                    when {
                        expression { return params.BUILD_FOR_WINDOWS }
                    }

                    environment {
                        BUILDDIR = "build-${STAGE_NAME}"
                        CCACHE_BASEDIR = "${WORKSPACE}"
                        PATH = pathWithToolsAdded()
                        QT_ROOT = "${env.QT_ROOT_WINDOWS}"
                    }

                    stages {
                        stage('Checkout for Windows') {
                            steps { checkoutFromBitbucket() }
                        }

                        stage('Configure for Windows') {
                            steps {
                                configureWithCMake env.BUILDDIR, [
                                    '-DFXM_CANBUS_INTERFACE:STRING=kvaser',
                                    '-DFXM_BODYBUILDER_ENABLED:BOOL=ON',
                                    '-DFXM_FAKE_BODYBUILDER_ENABLED:BOOL=ON',
                                    '-DFXM_SERIALPORT_ENABLED:BOOL=ON',
                                ]
                            }
                        }

                        stage('Compile for Windows') {
                            steps { buildProject env.BUILDDIR }
                        }

                        stage('Test on Windows') {
                            steps { runTests env.BUILDDIR }
                            post { always { junit "build-Windows/tests/auto/tst_*.xml" } }
                        }

                        stage('Package for Windows') {
                            when { expression { return params.BUILD_PACKAGES } }
                            steps { createPackage env.BUILDDIR }
                            post { always { archiveArtifacts artifacts: 'build-*/packages/*.msi' } }
                        }
                    }
                } // stage
            } // parallel

            post {
                success {
                    echo 'Sending success message to Discord'
                    discordSend successful: true,
                                title: "${BRANCH_NAME}${currentBuild.displayName}",
                                description: randomSuccessQuote(),
                                footer: "This build succeeded within ${currentBuild.durationString}",
                                link: env.RUN_DISPLAY_URL,
                                thumbnail: randomMugshot(),
                                webhookURL: env.DISCORD_WEBHOOK_URL
                }

                failure {
                    echo 'Sending failure message to Discord'
                    discordSend successful: false,
                                title: "${BRANCH_NAME}${currentBuild.displayName}",
                                description: randomFailureQuote(),
                                footer: "This build failed after ${currentBuild.durationString}",
                                link: env.RUN_DISPLAY_URL,
                                thumbnail: randomMugshot(),
                                webhookURL: env.DISCORD_WEBHOOK_URL
                }
            } // post
        } // stage
    } // stages
} // pipeline

def randomElement(quotes) {
    return quotes[new Random().nextInt(quotes.size())]
}

def randomMugshot() {
    return randomElement([
        'actor.png', 'alien.png', 'austin.png', 'automotive.png', 'balloon.png', 'belarus.png', 'cosmonaut.png',
        'cowboy.png', 'cute.png', 'fire.png', 'formal.png', 'general.png', 'jenkins.png', 'jenkinstein.png',
        'jenkins-x.png', 'magician.png', 'magritte.png', 'miner.png', 'musketeer.png', 'ninja.png', 'paris-eiffel.png',
        'pest-control.png', 'peter-the-great.png', 'plumber.png', 'raleigh.png', 'russian.png', 'san-diego.png',
        'santa-claus.png', 'sherlock.png', 'superhero.png', 'washington.png'
    ].collect{
        env.ARTWORK_URL + 'mini/' + it
    })
}

def randomSuccessQuote() {
    return randomElement([
        "As always sir, a great pleasure watching you work.",
        "You get hurt, hurt 'em back. You get killed... walk it off.",
        "Activating instant kill.",
        "I can do this all day.",
        "Finger on throat means death! Metaphor!",
        "Just a typical homecoming, on the outside of an invisible jet, fighting my girlfriend's dad.",
        "You walked right into this one. I've dated hotter chicks than you.",
        "You said it yourself, bitch! We're the guardians of the galaxy!",
        "Let me know if 'real power' wants a magazine or anything.",
        "Asleep for the danger, awake for the money, as per frickin' usual.",
        "Genius. Billionaire. Playboy. Philanthropist.",
    ])
}

def randomFailureQuote() {
    return randomElement([
        "Oh, no no. Daddy don't get scared.",
        "No hard feelings Point Break, you've got a mean swing.",
        "He just kicked your ass, full-size. You really want to find out what it's like when you can't see him coming?",
        "That's not a question I need answered.",
        "I don't know what you've got inside you already. The mix could be... an abomination.",
        "Sir, I'm gonna have to ask you to exit the donut.",
        "Drop your socks and grab your crocs, we're about to get wet on this ride.",
        "I'm sorry, did I step on your moment?",
        "Geez, somebody get that kid a sandwich!",
        "Funny how annoying a little prick can be, isn't it?",
        "What are you waiting for? It's Christmas. Take 'em to church!",
        "Hey fellas, either one of you know where the Smithsonian is? I'm here to pick up a fossil.",
        "I need a horse.",
        "Teach me!",
    ])
}

def checkoutFromBitbucket() {
    lock("checkout-on-${env.NODE_NAME}") {
        dir('sources') {
            checkout([
                $class: 'GitSCM',
                branches: scm.branches, browser: scm.browser,
                doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                userRemoteConfigs: scm.userRemoteConfigs,
                submoduleCfg: scm.submoduleCfg,
                extensions: [
                    [$class: 'CloneOption', reference: "${env.GITCACHE_ROOT}/meiller-mobileapps.git", depth: 30, shallow: true],
                    [$class: 'SubmoduleOption', reference: "${env.GITCACHE_ROOT}/meiller-mobileapps.git", parentCredentials: true, recursiveSubmodules: true],
                    [$class: 'ChangelogToBranch', options: [compareRemote: 'origin', compareTarget: 'master']],
                    [$class: 'LocalBranch', localBranch: 'same-as-remote'],
                    [$class: 'CleanBeforeCheckout'],
                    [$class: 'CleanCheckout'],
                ]
            ])
        }
    }
}

def configureWithCMake(String buildDir, ArrayList<String> arguments = []) {
    echo "Configures using CMake"

    def configureCommand = """
        cmake ../sources -GNinja
        -DCMAKE_BUILD_TYPE:STRING=Release
        -DCMAKE_PREFIX_PATH:STRING=${QT_ROOT}
        -DFXM_DECLARATIVE_LINTER_PROGRAM:PATH=none
        -DFXM_TEST_REPORTS:BOOL=ON
        """.stripIndent().replace('\n', ' ')

    configureCommand = ([configureCommand] + arguments).join(' ')

    dir("${WORKSPACE}/${buildDir}") {
        deleteDir()
        if (isUnix()) { sh configureCommand }
        else { bat configureCommand }
    }
}

def configureWithQMake(String buildDir, ArrayList<String> arguments = []) {
    echo "Configures using QMake"

    dir("${WORKSPACE}/${buildDir}") {
        def configureCommand = """
            ${QT_ROOT}/bin/qmake -r ../sources/meiller-mobileapps.pro
            CONFIG+=release CONFIG-=debug_and_release
            PACKAGE=integration-tests
            """.stripIndent().replace('\n', ' ')

        configureCommand = ([configureCommand] + arguments).join(' ')

        deleteDir()
        if (isUnix()) { sh configureCommand }
        else { bat configureCommand }
    }
}

def isCMake() {
    return fileExists('CMakeCache.txt')
}

def isUnix() {
    return env.PATH[0] == '/'
}

def makeCommandForArgs(String args) {
    return isUnix() ? "make ${args}" : "mingw32-make ${args}"
}

def cmakeCommandForTarget(String target) {
    return "cmake --build . --target ${target}"
}

def buildCommandForTarget(String target = null) {
    if (isCMake()) {
        return cmakeCommandForTarget(target ? target : 'all')
    } else {
        return makeCommandForArgs(["-j${env.MAKE_JOBS}", target].grep().join(' '))
    }
}

def buildProject(String buildDir) {
    lock("build-on-${env.NODE_NAME}") {
        dir("${WORKSPACE}/${buildDir}") {
            if (isUnix()) {
                sh "ccache -z"
                sh buildCommandForTarget()
                sh "ccache -s"
            } else {
                bat "ccache -z"
                bat buildCommandForTarget()
                bat "ccache -s"
            }
        }
    }
}

def runTests(String buildDir) {
    dir("${WORKSPACE}/${buildDir}") {
        if (isCMake()) {
            withEnv(["PATH+WHATEVER=${QT_ROOT}/bin"]) {
                if (isUnix()) { sh script: cmakeCommandForTarget('test'), returnStatus: true }
                else { bat script: cmakeCommandForTarget('test'), returnStatus: true }
            }
        } else {
            def testCommand = makeCommandForArgs("-j${env.MAKE_JOBS} -k check TESTARGS='-xunitxml -o \$(QMAKE_TARGET).xml'")
            if (isUnix()) { sh script: testCommand, returnStatus: true }
            else { bat script: testCommand, returnStatus: true }
        }
    }
}

def createPackage(String buildDir) {
    dir("${WORKSPACE}/${buildDir}") {
        if (isUnix()) { sh buildCommandForTarget('package') }
        else { bat buildCommandForTarget('package') }
    }
}

def isReleaseBranch() {
    return BRANCH_NAME.startsWith('alpha/') ||
           BRANCH_NAME.startsWith('beta/') ||
           BRANCH_NAME.startsWith('release/') ||
           BRANCH_NAME.endsWith('#packaged')
}

def quoted(String qc, String text) {
    return qc + text + qc
}

def buildForNode(String expectedNode) {
    def matches = BRANCH_NAME =~ /#nodes=(.*)/
    def nodes = matches ? matches[0][1].toLowerCase().trim() : ''
    return nodes.empty || quoted(',', nodes).contains(quoted(',', expectedNode.toLowerCase()))
}

def base32String(byte[] bytes) {
    return new org.apache.commons.codec.binary.Base32().encodeAsString(bytes).replace('=', '')
}

def md5String(String s) {
    return md5Digest(s).encodeHex().toString()
}

def md5Digest(String s) {
    return java.security.MessageDigest.getInstance('MD5').digest(s.bytes)
}

def shortWorkspacePath() {
    return 'work/' + base32String(md5Digest(env.JOB_NAME) as byte[])
}

def pathWithToolsAdded() {
    def binSuffix = (isUnix() ? '/bin' : '\\bin')
    def pathSeparator = (isUnix() ? ':' : ';')

    def knownTools = [env.NOTHING, env.CCACHE_ROOT, env.CMAKE_ROOT, env.JAVA_JDK_ROOT, env.MINGW_ROOT, env.WIX_ROOT]
    def availableTools = knownTools.grep().collect{it + binSuffix}

    return availableTools ? (availableTools + env.PATH).join(pathSeparator) : env.PATH
}
