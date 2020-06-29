# Requires web server running, serving install files up via HTTP
# Used 'hello-world-nginx' container with the /website_files volume remapped to the project directory for
# this container.   'hello-world-nginx' was built from kinematic/http.

FROM cdougan/install_manager
MAINTAINER Craig Dougan "Craig.Dougan@gmail.com"
ADD install_response_file.xml /tmp/install_response_file.xml
ENV hostip=192.168.0.5 \
    webport=32771 
ENV weblink=http://${hostip}:${webport} \
    was_install_file_one=was.repo.8550.developers.ilan_part1.zip \ 
    was_install_file_two=was.repo.8550.developers.ilan_part2.zip \
    was_install_file_three=was.repo.8550.developers.ilan_part3.zip \
    java_install_file_one=was.repo.8550.java7_part1.zip \
    java_install_file_two=was.repo.8550.java7_part2.zip \
    java_install_file_three=was.repo.8550.java7_part3.zip 

RUN cd /tmp && \
    yum install -y PyYAML && \
    yum install -y xorg-x11-fonts-Type1 && \
    yum install -y xorg-x11-server-common && \
    yum install -y xorg-x11-apps && \
    yum install -y xorg-x11-xkb-utils && \
    yum install -y xorg-x11-server-Xorg && \
    yum install -y xorg-x11-font-utils && \
    yum install -y xorg-x11-xauth && \
    yum --enablerepo rhel-7-server-optional-rpms install -y xorg-x11-server-Xvfb && \
    yum clean all && \
    mkdir /tmp/was_install && \
    wget $weblink/$was_install_file_one -O /tmp/$was_install_file_one && \
    unzip /tmp/$was_install_file_one -d /tmp/was_install && \
    rm -rf /tmp/${was_install_file_one}* && \
    wget $weblink/$was_install_file_two -O /tmp/$was_install_file_two && \
    unzip /tmp/$was_install_file_two -d /tmp/was_install && \
    rm -rf /tmp/${was_install_file_two}* && \
    wget $weblink/$was_install_file_three -O /tmp/$was_install_file_three && \
    unzip /tmp/$was_install_file_three -d /tmp/was_install && \
    rm -rf /tmp/${was_install_file_three}* && \
    /opt/IBM/InstallationManager/eclipse/tools/imcl -acceptLicense input /tmp/install_response_file.xml -log /tmp/install_log.xml && \
    rm -rf /tmp/was_install && \
    rm -rf /tmp/install_response_file.xml && \
    mkdir /tmp/JDK7 && \
    wget $weblink/$java_install_file_one -O /tmp/$java_install_file_one && \
    unzip /tmp/$java_install_file_one -d /tmp/JDK7 && \
    rm -rf /tmp/${java_install_file_one}* && \
    wget $weblink/$java_install_file_two -O /tmp/$java_install_file_two && \
    unzip /tmp/$java_install_file_two -d /tmp/JDK7 && \
    rm -rf /tmp/$*{java_install_file_two}* && \
    wget $weblink/$java_install_file_three -O /tmp/$java_install_file_three && \
    unzip /tmp/$java_install_file_three -d /tmp/JDK7 && \
    rm -rf /tmp/${java_install_file_three}* && \
    /opt/IBM/InstallationManager/eclipse/tools/imcl install com.ibm.websphere.IBMJAVA.v70 -repositories /tmp/JDK7 -installationDirectory /opt/IBM/WebSphere/AppServer && \
    rm -rf /tmp/JDK7 && \
    /opt/IBM/WebSphere/AppServer/bin/managesdk.sh -setCommandDefault -sdkname 1.7_64 && \
    /opt/IBM/WebSphere/AppServer/bin/managesdk.sh -setNewProfileDefault -sdkname 1.7_64 && \
    mkdir -p /usr/local/bin && \
    useradd wasuser && \
    chown -R wasuser:wasuser /opt/IBM/WebSphere && \
    chage -E -1 -M -1 -d -1 wasuser 
    
EXPOSE 9080 9060 22 8877
ENTRYPOINT ["/usr/sbin/sshd", "-D"]

